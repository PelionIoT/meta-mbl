# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause


"""
Tool for signing bootloader images for Trusted Firmware for Cortex-A (TF-A).

The script makes use of the mbl-signing-lib to manage the FIP images and
to store and generate credentials.

The script creates a set of 'root' CAs as described by the TBBR, it then uses
the private keys to sign the certificates used by TF-A to verify the boot
chain.


There are two commands, described below:

   * sign: Sign TF-A FIP image and/or BL2.
   * generate: Generate signing keys and store them in the backend.
"""

import argparse
import functools
import hashlib
import logging
import os
import pathlib
import sys
import tempfile

from signing.fip import fiptool
from signing.fitimage.mkimage import MkImage
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


def tmpdir(func):
    """
    Open a temporary directory.

    Use as a decorator.
    """
    # retain original function metadata
    @functools.wraps(func)
    def wrapper(*args, **kwargs):
        with tempfile.TemporaryDirectory() as tmpdir:
            func(*args, **kwargs, tmpdir=pathlib.Path(tmpdir))

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
        ),
    )
    dump_cmd.add_argument("--ca-ttl", default="8750h", help="Issuer TTL.")
    dump_cmd.add_argument(
        "--cert-ttl", default="4375h", help="End entity certificate TTL."
    )
    dump_cmd.add_argument(
        "--hab-srks",
        action="store_true",
        help="Generate super root keys for NXP HAB.",
    )
    dump_cmd.add_argument(
        "--output-dir",
        type=abspath,
        default=SCRIPT_DIR,
        help="The output directory for the HAB SRKs (public part).",
    )
    dump_cmd.set_defaults(func=handle_gen_cmd)

    sign_cmd = commands.add_parser(
        "sign", help="Sign TF-A bootloader components."
    )
    sign_group = sign_cmd.add_mutually_exclusive_group()
    sign_group.add_argument(
        "--rpi-vc4-fw",
        type=abspath,
        metavar="PATH",
        help="Path to a Raspberry-PI 3 VC4 firmware image (e.g armstub8.bin) "
        "to be signed. Note, TF-A BL2 is also in the VC4 firmware image. "
        "To sign BL2 on raspberrypi3 use this option, not the --bl2 option.",
    )
    sign_group.add_argument(
        "--bl2",
        metavar="PATH",
        type=abspath,
        help="Path to a TF-A BL2 image to be signed.",
    )
    sign_cmd.add_argument(
        "--fip",
        metavar="PATH",
        type=abspath,
        nargs="+",
        help="Path to one or more FIPs to be signed.",
    )
    sign_cmd.set_defaults(func=handle_sign_cmd)
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


def generate_srks(key_store, num_srks, output_dir, ca_ttl, cert_ttl):
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


def generate_keys(key_store, key_list, ca_ttl, cert_ttl):
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
        if "cert" not in cert_name:
            continue

        cert = tbbr_defs.cot_certs.get(cert_name, None)
        if cert is None:
            raise ValueError(
                "Cert {} not found in chain of trust".format(cert_name)
            )

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


def resolve_fip_component_paths(img_specs, images_dir):
    """Resolve paths to the images to include in the FIP."""
    for bootchain_component_path in images_dir.iterdir():
        for img_spec in img_specs:
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


def regen_unified_binary(bl1_path, fip1_path, output_path):
    """Regenerate the RPi3 'unified binary'."""
    unified_bin_path = pathlib.Path(output_path)
    cat_bytes = bl1_path.read_bytes() + fip1_path.read_bytes()
    unified_bin_path.write_bytes(cat_bytes)


def fetch_keys(key_store, key_ids):
    """Fetch a set of public keys from the store."""
    pub_keys = dict()
    for key in key_ids:
        response = key_store.read_certificate("ca", key)
        pub_keys[key] = extract_public_key(response.data["certificate"], "der")
    return pub_keys


def make_imx_image(output_path, cfg_path, bl2_path):
    """
    Create an imximage from BL2.

    :param cfg_path Path: path to an imx image config file.
    :param bl2_path Path: path to a bl2 image.
    """
    mkimg = MkImage()
    mkimg.create_legacy_image(
        output_path=output_path,
        img_type="imximage",
        name=str(cfg_path),
        entry_point="0x9df00000",
        data_file_path=str(bl2_path),
    )


def unpack_fips(fip_paths, output_dir):
    """Unpack fip images into FipSpec objects."""
    if fip_paths is None:
        return dict()

    fip_specs = {
        fpath.name: fiptool.unpack(fpath, out=output_dir)
        for fpath in fip_paths
    }

    resolve_fip_component_paths(fip_specs.values(), output_dir)
    return fip_specs


@api_server_session
@tmpdir
def handle_sign_cmd(args, key_store, tmpdir):
    """Entry point for the sign command."""
    key_store.connect(args.backend_url)

    NEW_KEYS_DIR = tmpdir / "new_certs"
    NEW_KEYS_DIR.mkdir(exist_ok=True)
    FIP_COMPONENTS_DIR = tmpdir / "fip_components"
    FIP_COMPONENTS_DIR.mkdir(exist_ok=True)

    fip_specs = {}
    pub_keys = fetch_keys(key_store, tbbr_defs.cot_keys)
    imgs_to_patch = list()

    rotpk = hashlib.sha256(pub_keys["rot-key"]).digest()

    if args.rpi_vc4_fw:
        UNPACKED_BIN_DIR = tmpdir / "armstub8_components"
        UNPACKED_BIN_DIR.mkdir(exist_ok=True)
        print(
            "Splitting bl1.bin and fip1.bin from {}".format(
                args.rpi_vc4_fw.name
            )
        )
        bl1_path = pathlib.Path(UNPACKED_BIN_DIR, "bl1.bin").absolute()
        fip1_path = pathlib.Path(UNPACKED_BIN_DIR, "fip1.bin").absolute()
        split_unified_binary(args.rpi_vc4_fw, bl1_path, fip1_path)
        args.fip.append(fip1_path)
        imgs_to_patch.append(bl1_path)

    if args.bl2:
        imgs_to_patch.append(args.bl2)

    fip_specs = unpack_fips(args.fip, FIP_COMPONENTS_DIR)

    if imgs_to_patch:
        for spec in fip_specs.values():
            if "tb-fw" in spec:
                imgs_to_patch.append(spec["tb-fw"]["path"])

        rotpk = hashlib.sha256(pub_keys["rot-key"]).digest()
        for img in imgs_to_patch:
            print(
                "Patching root-of-trust public key hash in image: {}".format(
                    str(pathlib.Path(img).name)
                )
            )
            replace_bl_rotkey(rotpk, pathlib.Path(img))

    if fip_specs:
        for name, spec in fip_specs.items():
            print("Creating certificates for FIP image: {}".format(name))
            make_cert_chain(
                FIP_COMPONENTS_DIR, spec, key_store, pub_keys, NEW_KEYS_DIR
            )
            resolve_fip_certificate_paths(spec, NEW_KEYS_DIR)

        for fip_path in args.fip:
            spec = fip_specs[fip_path.name]
            print("Creating signed FIP at path: {}".format(str(fip_path)))
            fiptool.create(spec, fip_path)

        if args.rpi_vc4_fw:
            print(
                "Creating VC4 firmware binary at path: {}".format(
                    str(args.rpi_vc4_fw)
                )
            )
            regen_unified_binary(bl1_path, fip1_path, args.rpi_vc4_fw)


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
