/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.domain.enumerations.tls;
import uim.platform.foundry;

// mixin(ShowModule!());

@safe:
enum TlsProtocolVersion {
    tls1_0,
    tls1_1,
    tls1_2,
    tls1_3,
}
TlsProtocolVersion toTlsProtocolVersion(string s) {
    const map = [
        "tls1_0": TlsProtocolVersion.tls1_0,
        "tls1_1": TlsProtocolVersion.tls1_1,
        "tls1_2": TlsProtocolVersion.tls1_2,
        "tls1_3": TlsProtocolVersion.tls1_3
    ];
    return map.get(s, TlsProtocolVersion.tls1_2);
}

enum CipherSuiteStrength {
    strong,
    medium,
    weak,
}
CipherSuiteStrength toCipherSuiteStrength(string s) {
    const map = [
        "strong": CipherSuiteStrength.strong,
        "medium": CipherSuiteStrength.medium,
        "weak": CipherSuiteStrength.weak
    ];
    return map.get(s, CipherSuiteStrength.strong);
}