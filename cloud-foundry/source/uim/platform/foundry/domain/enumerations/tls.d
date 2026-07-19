/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.domain.enumerations.tls;
import uim.platform.foundry;
mixin(ShowModule!());

@safe:
enum TlsProtocolVersion {
    tls1_0,
    tls1_1,
    tls1_2,
    tls1_3,
}
TlsProtocolVersion toTlsProtocolVersion(string value) {
    mixin(EnumSwitch("TlsProtocolVersion", "tls1_2"));
}
TlsProtocolVersion[] toTlsProtocolVersion(string[] values) {
    return values.map!(toTlsProtocolVersion).array;
}
string toString(TlsProtocolVersion version_) {
    return version_.to!string;
}
string[] toString(TlsProtocolVersion[] versions) {
    return versions.map!(toString).array;
}
///
unittest {
    mixin(ShowTest!("TlsProtocolVersion"));

    assert("tls1_0".toTlsProtocolVersion == TlsProtocolVersion.tls1_0);
    assert("tls1_1".toTlsProtocolVersion == TlsProtocolVersion.tls1_1);
    assert("tls1_2".toTlsProtocolVersion == TlsProtocolVersion.tls1_2);
    assert("tls1_3".toTlsProtocolVersion == TlsProtocolVersion.tls1_3);
    
    assert("unknown".toTlsProtocolVersion == TlsProtocolVersion.tls1_2);
    assert("".toTlsProtocolVersion == TlsProtocolVersion.tls1_2);
    
    assert(TlsProtocolVersion.tls1_0.toString == "tls1_0");
    assert(TlsProtocolVersion.tls1_1.toString == "tls1_1");
    assert(TlsProtocolVersion.tls1_2.toString == "tls1_2");
    assert(TlsProtocolVersion.tls1_3.toString == "tls1_3");

    assert(toString([TlsProtocolVersion.tls1_0, TlsProtocolVersion.tls1_3]) == ["tls1_0", "tls1_3"]);
    assert(toTlsProtocolVersion(["tls1_0", "tls1_3"]) == [TlsProtocolVersion.tls1_0, TlsProtocolVersion.tls1_3]);
}

enum CipherSuiteStrength {
    strong,
    medium,
    weak,
}
CipherSuiteStrength toCipherSuiteStrength(string value) {
    mixin(EnumSwitch("CipherSuiteStrength", "strong"));
}
CipherSuiteStrength[] toCipherSuiteStrength(string[] values) {
    return values.map!(toCipherSuiteStrength).array;
}
string toString(CipherSuiteStrength strength) {
    return strength.to!string;
}
string[] toString(CipherSuiteStrength[] strengths) {
    return strengths.map!(toString).array;
}
/// 
unittest {
    mixin(ShowTest!("CipherSuiteStrength"));

    assert("strong".toCipherSuiteStrength == CipherSuiteStrength.strong);
    assert("medium".toCipherSuiteStrength == CipherSuiteStrength.medium);
    assert("weak".toCipherSuiteStrength == CipherSuiteStrength.weak);
    
    assert("unknown".toCipherSuiteStrength == CipherSuiteStrength.strong);
    assert("".toCipherSuiteStrength == CipherSuiteStrength.strong);
    
    assert(CipherSuiteStrength.strong.toString == "strong");
    assert(CipherSuiteStrength.medium.toString == "medium");
    assert(CipherSuiteStrength.weak.toString == "weak");

    assert(toString([CipherSuiteStrength.strong, CipherSuiteStrength.weak]) == ["strong", "weak"]);
    assert(toCipherSuiteStrength(["strong", "weak"]) == [CipherSuiteStrength.strong, CipherSuiteStrength.weak]);
}