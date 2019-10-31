# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause
#
# Object Identifiers taken from:
# https://github.com/ARM-software/arm-trusted-firmware/blob/master/include/tools_share/tbbr_oid.h

"""Define the certificate structure and key list for the ATF Chain of Trust."""

from signing.pki.x509utils import (
    X509CertificateExtensions,
    HashExtension,
    PKExtension,
    CounterExtension,
    ExtensionValueGetter,
)


trusted_boot_fw_cert = X509CertificateExtensions(
    "Trusted Boot FW Certificate",
    dict(
        TRUSTED_FW_NVCOUNTER=CounterExtension(
            oid="1.3.6.1.4.1.4128.2100.1", critical=True
        ),
        TRUSTED_BOOT_FW_HASH=HashExtension(
            oid="1.3.6.1.4.1.4128.2100.201",
            critical=True,
            content_file="tb-fw.bin",
        ),
        TRUSTED_BOOT_FW_CONFIG_HASH=HashExtension(
            oid="1.3.6.1.4.1.4128.2100.202", critical=False
        ),
        HW_CONFIG_HASH=HashExtension(
            oid="1.3.6.1.4.1.4128.2100.203", critical=False
        ),
    ),
    file_name="tb-fw-cert.bin",
    signer="rot-key",
)


trusted_key_cert = X509CertificateExtensions(
    "Trusted Key Certificate",
    dict(
        TRUSTED_FW_NVCOUNTER=CounterExtension(
            oid="1.3.6.1.4.1.4128.2100.1", critical=True
        ),
        TRUSTED_WORLD_PK=PKExtension(
            oid="1.3.6.1.4.1.4128.2100.302",
            pub_key_name="trusted-world-key",
            critical=True,
        ),
        NON_TRUSTED_WORLD_PK=PKExtension(
            oid="1.3.6.1.4.1.4128.2100.303",
            pub_key_name="non-trusted-world-key",
            critical=True,
        ),
    ),
    file_name="trusted-key-cert.bin",
    signer="rot-key",
)


soc_fw_key_cert = X509CertificateExtensions(
    "SoC Firmware Key Certificate",
    dict(
        TRUSTED_FW_NVCOUNTER=CounterExtension(
            oid="1.3.6.1.4.1.4128.2100.1", critical=True
        ),
        SOC_FW_CONTENT_CERT_PK=PKExtension(
            oid="1.3.6.1.4.1.4128.2100.501",
            pub_key_name="soc-fw-key",
            critical=True,
        ),
    ),
    file_name="soc-fw-key-cert.bin",
    signer="trusted-world-key",
)


soc_fw_content_cert = X509CertificateExtensions(
    "SoC Firmware Content Certificate",
    dict(
        TRUSTED_FW_NVCOUNTER=CounterExtension(
            oid="1.3.6.1.4.1.4128.2100.1", critical=True
        ),
        SOC_AP_FW_HASH=HashExtension(
            oid="1.3.6.1.4.1.4128.2100.603",
            content_file="soc-fw.bin",
            critical=True,
        ),
        SOC_FW_CONFIG_HASH=HashExtension(
            oid="1.3.6.1.4.1.4128.2100.604", critical=False
        ),
    ),
    file_name="soc-fw-cert.bin",
    signer="soc-fw-key",
)


scp_firmware_key_cert = X509CertificateExtensions(
    "SCP Firmware Key Certificate",
    dict(
        SCP_FW_CONTENT_CERT_PK=PKExtension(
            oid="1.3.6.1.4.1.4128.2100.701",
            pub_key_name="scp-fw-key",
            critical=True,
        )
    ),
    file_name="scp-fw-key-cert.bin",
    signer="trusted-world-key",
)


scp_firmware_content_cert = X509CertificateExtensions(
    "SCP Firmware Content Certificate",
    dict(
        SCP_FW_HASH=HashExtension(
            oid="1.3.6.1.4.1.4128.2100.801", critical=True
        ),
        SCP_ROM_PATCH_HASH=HashExtension(
            oid="1.3.6.1.4.1.4128.2100.802", critical=False
        ),
    ),
    file_name="scp-fw-cert.bin",
    signer="scp-fw-key",
)


trusted_os_firmware_key_cert = X509CertificateExtensions(
    "Trusted OS Firmware Key Certificate",
    dict(
        TRUSTED_FW_NVCOUNTER=CounterExtension(
            oid="1.3.6.1.4.1.4128.2100.1", critical=True
        ),
        TRUSTED_OS_FW_CONTENT_CERT_PK=PKExtension(
            oid="1.3.6.1.4.1.4128.2100.901",
            pub_key_name="tos-fw-key",
            critical=True,
        ),
    ),
    file_name="tos-fw-key-cert.bin",
    signer="trusted-world-key",
)


trusted_os_firmware_content_cert = X509CertificateExtensions(
    "Trusted OS Firmware Content Certificate",
    dict(
        TRUSTED_FW_NVCOUNTER=CounterExtension(
            oid="1.3.6.1.4.1.4128.2100.1", critical=True
        ),
        TRUSTED_OS_FW_HASH=HashExtension(
            oid="1.3.6.1.4.1.4128.2100.1001",
            critical=True,
            content_file="tos-fw.bin",
        ),
        TRUSTED_OS_FW_EXTRA1_HASH=HashExtension(
            oid="1.3.6.1.4.1.4128.2100.1002",
            critical=False,
            content_file="tos-fw-extra1.bin",
        ),
        TRUSTED_OS_FW_EXTRA2_HASH=HashExtension(
            oid="1.3.6.1.4.1.4128.2100.1003",
            critical=False,
            content_file="tos-fw-extra2.bin",
        ),
        TRUSTED_OS_FW_CONFIG_HASH=HashExtension(
            oid="1.3.6.1.4.1.4128.2100.1004", critical=False
        ),
    ),
    file_name="tos-fw-cert.bin",
    signer="tos-fw-key",
)


non_trusted_firmware_key_cert = X509CertificateExtensions(
    "Non-Trusted Firmware Key Certificate",
    dict(
        NON_TRUSTED_FW_NVCOUNTER=CounterExtension(
            oid="1.3.6.1.4.1.4128.2100.2", critical=True
        ),
        NON_TRUSTED_FW_CONTENT_CERT_PK=PKExtension(
            oid="1.3.6.1.4.1.4128.2100.1101",
            pub_key_name="nt-fw-key",
            critical=True,
        ),
    ),
    file_name="nt-fw-key-cert.bin",
    signer="non-trusted-world-key",
)


non_trusted_firmware_content_cert = X509CertificateExtensions(
    "Non-Trusted Firmware Content Certificate",
    dict(
        NON_TRUSTED_FW_NVCOUNTER=CounterExtension(
            oid="1.3.6.1.4.1.4128.2100.2", critical=True
        ),
        NON_TRUSTED_WORLD_BOOTLOADER_HASH=HashExtension(
            oid="1.3.6.1.4.1.4128.2100.1201",
            critical=True,
            content_file="nt-fw.bin",
        ),
        NON_TRUSTED_FW_CONFIG_HASH=HashExtension(
            oid="1.3.6.1.4.1.4128.2100.1202", critical=False
        ),
    ),
    file_name="nt-fw-cert.bin",
    signer="nt-fw-key",
)


content_extension_filenames = dict(
    SOC_AP_FW_HASH="soc-fw.bin",
    TRUSTED_BOOT_FW_HASH="tb-fw.bin",
    TRUSTED_OS_FW_EXTRA1_HASH="tos-fw-extra1.bin",
    TRUSTED_OS_FW_EXTRA2_HASH="tos-fw-extra2.bin",
    TRUSTED_OS_FW_HASH="tos-fw.bin",
    NON_TRUSTED_WORLD_BOOTLOADER_HASH="nt-fw.bin",
)


cot_keys = (
    "rot-key",
    "trusted-world-key",
    "non-trusted-world-key",
    "soc-fw-key",
    "tos-fw-key",
    "scp-fw-key",
    "nt-fw-key",
)


cot_certs = {
    "trusted-key-cert": trusted_key_cert,
    "tb-fw-cert": trusted_boot_fw_cert,
    "tos-fw-cert": trusted_os_firmware_content_cert,
    "soc-fw-key-cert": soc_fw_key_cert,
    "nt-fw-key-cert": non_trusted_firmware_key_cert,
    "tos-fw-key-cert": trusted_os_firmware_key_cert,
    "soc-fw-cert": soc_fw_content_cert,
    "nt-fw-cert": non_trusted_firmware_content_cert,
}
