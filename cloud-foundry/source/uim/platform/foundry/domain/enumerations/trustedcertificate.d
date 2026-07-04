/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.domain.enumerations.trustedcertificate;
import uim.platform.foundry;

mixin(ShowModule!());

@safe:
enum TrustedCertificateStatus {
    active,
    inactive,
    expired,
}
TrustedCertificateStatus toTrustedCertificateStatus(string s) {
    const map = [
        "active": TrustedCertificateStatus.active,
        "inactive": TrustedCertificateStatus.inactive,
        "expired": TrustedCertificateStatus.expired
    ];
    return map.get(s.toLower, TrustedCertificateStatus.inactive);
}

enum ClientAuthMode {
    required,
    optional,
    disabled,
}
ClientAuthMode toClientAuthMode(string s) {
    const map = [
        "required": ClientAuthMode.required,
        "optional": ClientAuthMode.optional,
        "disabled": ClientAuthMode.disabled
    ];
    return map.get(s.toLower, ClientAuthMode.disabled);
}