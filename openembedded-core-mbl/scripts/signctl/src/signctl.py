# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause


"""
This is a tool for signing FIP image components for Trusted Firmware for 
Cortex-A (TF-A).

The script makes use of the mbl-signing-lib to manage the FIP images and
to store and generate credentials.

The script creates a set of 'root' CAs as described by the TBBR, it then uses
the private keys to sign the certificates used by TF-A to verify the boot chain.


There are two commands, described below:

   * sign-tfa: Generate TF-A Chain of Trust keys and certificates.
              Optionally splitting and regenerating RPI3 unified bin.

   * generate: Generate signing keys and store them in the backend.
"""

import argparse
import functools
import hashlib
import logging
import os
import pathlib
import sys

from signing.fip import fiptool
from signing.pki import keystore
from signing.pki import tbbr_defs
from signing.pki.x509utils import extract_public_key, cert_pem_to_der

LOGGER = logging.getLogger()
LOGGER.setLevel(logging.INFO)
logging.getLogger("mbl-signing.fiptool").setLevel(logging.ERROR)
# Stop flask logging appearing in the console.
logging.getLogger("werkzeug").disabled = True
os.environ["WERKZEUG_RUN_MAIN"] = "true"

VAULT_SERVER_URL = "http://localhost:8200"

SCRIPT_DIR = pathlib.Path().cwd().absolute()
FIP_COMPONENTS_DIR = SCRIPT_DIR / "fip_components"
NEW_KEYS_DIR = SCRIPT_DIR / "new_keys"


def api_server_session(func):
    """
    Start the KeyStore REST API server.

    Ensures the server is closed when the current scope ends.

    Must be used as a decorator.
    """
    # wrapper
    @functools.wraps(func)
    def wrapper(args):
        with keystore.KeyStore() as ks:
            func(args=args, key_store=ks)

    return wrapper


def abspath(x):
    """Convert x to an absolute Path object."""
    return pathlib.Path(x).resolve()


def load_url_config():
    """Load the backend server url from a config file."""
    conf = pathlib.Path().home() / ".signctl.conf"
    try:
        return conf.read_text().strip()
    except FileNotFoundError:
        LOGGER.fatal(
            "No .signctl.conf file was found. "
            "You must create one and place it in your home directory. "
            "The file should contain your 'secrets engine' server URL. "
            "If your secrets engine is Hashicorp Vault, for example, "
            "it would include the URL of the Vault server. "
        )
        raise


class ArgParserWithDefaultHelp(argparse.ArgumentParser):
    """Show the help message when an error is raised."""

    def error(self, message):
        """
        Error handling function override.

        Prints the help message.
        """
        print(message, file=sys.stderr)
        self.print_help()
        raise SystemExit(2)


def parse_args():
    """Parse the command line input."""
    parser = ArgParserWithDefaultHelp()
    parser.add_argument("--backend-url", default=load_url_config())
    commands = parser.add_subparsers()
    dump_cmd = commands.add_parser(
        "generate",
        help="Generate a keychain and store it in the storage backend.",
    )
    dump_cmd.add_argument(
        "--cot-keys",
        action="store_true",
        help=(
            "Generate a TF-A chain of trust keychain, store the private "
            "keys."
        )
    )
    dump_cmd.add_argument(
        "--ca-ttl",
        help="Issuer TTL."
    )
    dump_cmd.add_argument(
        "--cert-ttl",
        help="End entity certificate TTL."
    )
    dump_cmd.add_argument(
        "--hab-srks",
        action="store_true",
        help="Generate super root public keys for NXP HAB.",
    )
    dump_cmd.add_argument(
        "--output-dir",
        type=abspath,
        default=SCRIPT_DIR,
        help="The output directory for the HAB SRKs (public part).",
    )
    dump_cmd.set_defaults(func=handle_gen_cmd)

    sign_cmd = commands.add_parser("sign-tfa", help="Sign TF-A BL and FIP.")
    sign_cmd.add_argument(
        "--rpi-armstub8", type=abspath, help="Path to armstub8.bin"
    )
    sign_cmd.add_argument(
        "--fip",
        type=abspath,
        nargs="+",
        required=True,
        help="Path to one or more FIPs to be signed.",
    )
    sign_cmd.add_argument(
        "--patch-rotkey",
        action="store_true",
        help="Patch root of trust public key hash into BL1 and BL2.",
    )
    sign_cmd.add_argument(
        "--output-dir",
        type=abspath,
        default=SCRIPT_DIR,
        help="Output dir for signed images and the original fip components.",
    )
    sign_cmd.set_defaults(func=handle_tfa_sign_cmd)
    args = parser.parse_args()
    if not hasattr(args, "func"):
        parser.error("No arguments given.")
    return args


def split_unified_binary(
    path_to_unified_bin,
    bl1_output_path,
    fip1_output_path,
    bl1_image_size=131072,
):
    """Split the RPi3 'unified binary' which contains bl1 shim and fip1."""
    with path_to_unified_bin.open(mode="rb") as ufb:
        bl1_output_path.write_bytes(ufb.read(bl1_image_size))
        ufb.seek(bl1_image_size, 0)
        fip1_output_path.write_bytes(ufb.read())


def generate_srks(
    key_store, num_srks, output_dir, ca_ttl="8750h", cert_ttl="430h"
):
    """Generate SRK pairs, export the public keys."""
    role_name = issuer = "CA1_sha256_2048_65537_v3_ca"
    key_store.generate_root(issuer, mount_point=issuer, ttl=ca_ttl)
    key_store.configure_role(
        role_name,
        issuer,
        allow_any_name=True,
        ttl=cert_ttl,
        ext_key_usage=[],
        no_store=True,
        use_csr_sans=False,
        enforce_hostnames=False,
        allow_bare_domains=True,
    )
    for i in range(num_srks):
        subject_common_name = "SRK{}_sha256_2048_65537_v3_ca".format(i + 1)
        response = key_store.request_certificate(
            issuer, subject_common_name, issuer, signature_alg="pkcs1_1_5"
        )
        der = cert_pem_to_der(response.data["certificate"])
        fp_der = pathlib.Path(
            output_dir, "SRK{}_sha256_2048_65537_v3_ca_crt.der".format(i + 1)
        ).absolute()
        fp_der.write_bytes(der)


def generate_keys(key_store, key_list, ca_ttl="8750h", cert_ttl="430h"):
    """Generate root signing keypairs, return the public keys."""
    pub_keys = dict()
    for key in key_list:
        response = key_store.generate_root(key, mount_point=key, ttl=ca_ttl)
        key_store.configure_role(
            key,
            key,
            allow_any_name=True,
            ttl=cert_ttl,
            key_usage=[],
            no_store=True,
            use_csr_sans=False,
            basic_constraints_valid_for_non_ca=True,
        )
        pub_keys[key] = extract_public_key(response.data["certificate"], "der")
    return pub_keys


def make_cert_chain(images_dir, img_spec, key_store, pub_keys, output_dir):
    """Make a certificate chain for a FIP image."""
    ext_val = tbbr_defs.ExtensionValueGetter(pub_keys, images_dir)
    for cert_name in img_spec:
        cert = tbbr_defs.cot_certs.get(cert_name, None)
        if cert is None:
            continue
        extensions = list()
        for ext in cert:
            ext.encode_value(ext_val.get(ext, cert))
            extensions.append(str(ext))
        response = key_store.request_certificate(
            cert.signer,
            cert.file_name[:-4],
            cert.signer,
            extensions=extensions,
            signature_alg="pkcs1_2_1",
        )
        der = cert_pem_to_der(response.data["certificate"])
        fp_der = pathlib.Path(output_dir, cert.file_name).absolute()
        fp_der.write_bytes(der)


def resolve_fip_component_paths(img_spec, images_dir):
    """Resolve paths to the images to include in the FIP."""
    for bootchain_component_path in images_dir.iterdir():
        for key in img_spec:
            if (
                bootchain_component_path.stem == key
                and "-cert" not in bootchain_component_path.stem
            ):
                img_spec[key] = dict(
                    path=str(bootchain_component_path.absolute())
                )


def resolve_fip_certificate_paths(img_spec, cert_path):
    """Resolve the paths to the certificates to include in the FIP."""
    for cert in cert_path.iterdir():
        for key in img_spec:
            if cert.stem == key and "-cert" in cert.stem:
                img_spec[key] = dict(path=str(cert.absolute()))


def replace_bl_rotkey(rotpk_hash, bl_path):
    """Patch the rot public key hash into a BL image."""
    sub_pk_info_header = (
        b"\x30\x31\x30\x0D\x06\x09\x60\x86"
        b"\x48\x01\x65\x03\x04\x02\x01\x05\x00\x04\x20"
    )
    bl_bytes = bl_path.read_bytes()
    der_begin = bl_bytes.find(sub_pk_info_header) + len(sub_pk_info_header)
    der_end = der_begin + len(rotpk_hash)
    embedded_rotpk = bl_bytes[der_begin:der_end]
    bl_bytes = bl_bytes.replace(embedded_rotpk, rotpk_hash)
    bl_path.write_bytes(bl_bytes)


def regen_unified_binary(bl1_path, fip1_path, output_dir):
    """Regenerate the 'unified binary'."""
    unified_bin_path = pathlib.Path(output_dir, "armstub8_new.bin")
    cat_bytes = bl1_path.read_bytes() + fip1_path.read_bytes()
    unified_bin_path.write_bytes(cat_bytes)


def fetch_keys(key_store, key_ids):
    """Fetch a set of public keys from the store."""
    pub_keys = dict()
    for key in key_ids:
        response = key_store.read_certificate("ca", key)
        pub_keys[key] = extract_public_key(response.data["certificate"], "der")
    return pub_keys


@api_server_session
def handle_tfa_sign_cmd(args, key_store):
    """Entry point for the sign-tfa command."""
    key_store.connect(args.backend_url)

    NEW_KEYS_DIR = args.output_dir / "new_certs"
    NEW_KEYS_DIR.mkdir(exist_ok=True)
    FIP_COMPONENTS_DIR = args.output_dir / "fip_components"
    FIP_COMPONENTS_DIR.mkdir(exist_ok=True)

    imgs_to_patch = list()
    if args.rpi_armstub8:
        UNPACKED_BIN_DIR = args.output_dir / "armstub8_components"
        UNPACKED_BIN_DIR.mkdir(exist_ok=True)
        print("Splitting bl1.bin and fip1.bin from armstub8.bin...")
        bl1_path = pathlib.Path(UNPACKED_BIN_DIR, "bl1_new.bin").absolute()
        fip1_path = pathlib.Path(UNPACKED_BIN_DIR, "fip1_new.bin").absolute()
        split_unified_binary(args.rpi_armstub8, bl1_path, fip1_path)
        args.fip.append(fip1_path)
        imgs_to_patch.append(bl1_path)

    fip_specs = {
        fpath.name: fiptool.unpack(fpath, out=FIP_COMPONENTS_DIR)
        for fpath in args.fip
    }

    for spec in fip_specs.values():
        resolve_fip_component_paths(spec, FIP_COMPONENTS_DIR)
        if "tb-fw" in spec:
            imgs_to_patch.append(spec["tb-fw"]["path"])

    pub_keys = fetch_keys(key_store, tbbr_defs.cot_keys)

    if args.patch_rotkey and imgs_to_patch:
        rotpk = hashlib.sha256(pub_keys["rot-key"]).digest()
        for img in imgs_to_patch:
            print("Patching rotkey in image: {}".format(str(img)))
            replace_bl_rotkey(rotpk, pathlib.Path(img))

    SIGNED_IMGS_DIR = args.output_dir / "signed_images"
    SIGNED_IMGS_DIR.mkdir(exist_ok=True)

    for name, spec in fip_specs.items():
        print(
            "Creating certificates in directory: {}".format(str(NEW_KEYS_DIR))
        )
        make_cert_chain(
            FIP_COMPONENTS_DIR, spec, key_store, pub_keys, NEW_KEYS_DIR
        )
        resolve_fip_certificate_paths(spec, NEW_KEYS_DIR)
        fipout_path = SIGNED_IMGS_DIR / name
        print("Creating signed FIP at path: {}".format(str(fipout_path)))
        fiptool.create(spec, fipout_path)
        if args.rpi_armstub8 and name == fip1_path.name:
            print(
                "Creating armstub8_new.bin in directory: {}".format(
                    str(SIGNED_IMGS_DIR)
                )
            )
            regen_unified_binary(bl1_path, fipout_path, SIGNED_IMGS_DIR)


@api_server_session
def handle_gen_cmd(args, key_store):
    """Entry point for the generate command."""
    key_store.connect(args.backend_url)

    if args.hab_srks:
        NEW_KEYS_DIR = args.output_dir / "new_certs"
        NEW_KEYS_DIR.mkdir(exist_ok=True)
        print("Saving HAB SRK certificates in {}".format(str(NEW_KEYS_DIR)))
        generate_srks(key_store, 4, NEW_KEYS_DIR)

    if args.cot_keys:
        generate_keys(
            key_store, tbbr_defs.cot_keys, args.ca_ttl, args.cert_ttl
        )


def main():
    """Entry point of the script."""
    args = parse_args()
    args.func(args=args)


if __name__ == "__main__":
    sys.exit(main())
