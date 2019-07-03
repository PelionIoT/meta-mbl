# meta-psa OpenEmbedded layer

The meta-psa OpenEmbedded layer provides reference implementations and tests for
the Arm Platform Security Architecture APIs.

## PSA
The Arm Platform Security Architecture (PSA) is a holistic set of threat
models, security analyses, hardware and firmware architecture specifications,
and an open source firmware reference implementation. PSA provides a recipe,
based on industry best practice, that allows security to be consistently
designed in, at both a hardware and firmware level.

For more information, see the [PSA website][psa].

## Recipes
This layer currently provides recipes for:
* [Mbed Crypto][mbed-crypto] - an implementation of the Arm [PSA Crypto API][psa-crypto].
* [psa-arch-tests][psa-arch-tests] - the Arm PSA Architecture test suite.

[psa]: https://developer.arm.com/architectures/security-architectures/platform-security-architecture
[mbed-crypto]: https://github.com/ARMmbed/mbed-crypto
[psa-crypto]: https://armmbed.github.io/mbed-crypto/html/general.html
[psa-arch-tests]: https://github.com/ARM-software/psa-arch-tests
