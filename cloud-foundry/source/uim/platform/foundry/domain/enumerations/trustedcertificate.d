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
TrustedCertificateStatus toTrustedCertificateStatus(string value) {
    mixin(EnumSwitch("TrustedCertificateStatus", "active"));
}
TrustedCertificateStatus[] toTrustedCertificateStatuses(string[] values) {
    return values.map!(toTrustedCertificateStatus).array;
}
string toString(TrustedCertificateStatus status) {
    return status.to!string;
}
string[] toStrings(TrustedCertificateStatus[] statuses) {
    return statuses.map!toString.array;
}
/// 
unittest {
    mixin(ShowTest!("TrustedCertificateStatus"));

    assert(TrustedCertificateStatus.active.toString == "active");
    assert(TrustedCertificateStatus.inactive.toString == "inactive");
    assert(TrustedCertificateStatus.expired.toString == "expired");

    assert("active".toTrustedCertificateStatus == TrustedCertificateStatus.active);
    assert("inactive".toTrustedCertificateStatus == TrustedCertificateStatus.inactive);
    assert("expired".toTrustedCertificateStatus == TrustedCertificateStatus.expired);

    assert(toStrings([TrustedCertificateStatus.active, TrustedCertificateStatus.expired]) == ["active", "expired"]);
    assert(toTrustedCertificateStatuses(["active", "expired"]) == [TrustedCertificateStatus.active, TrustedCertificateStatus.expired]);
}

enum ClientAuthMode {
    required,
    optional,
    disabled,
}
ClientAuthMode toClientAuthMode(string value) {
    mixin(EnumSwitch("ClientAuthMode", "required"));
}
ClientAuthMode[] toClientAuthModes(string[] values) {
    return values.map!(toClientAuthMode).array;
}
string toString(ClientAuthMode mode) {
    return mode.to!string;
}
string[] toStrings(ClientAuthMode[] modes) {
    return modes.map!toString.array;
}
///
unittest {
    mixin(ShowTest!("ClientAuthMode")); 

    assert(ClientAuthMode.required.toString == "required");
    assert(ClientAuthMode.optional.toString == "optional");
    assert(ClientAuthMode.disabled.toString == "disabled"); 

    assert("required".toClientAuthMode == ClientAuthMode.required);
    assert("optional".toClientAuthMode == ClientAuthMode.optional);
    assert("disabled".toClientAuthMode == ClientAuthMode.disabled);

    assert("".toClientAuthMode == ClientAuthMode.required);
    assert("invalid".toClientAuthMode == ClientAuthMode.required);

    assert(toStrings([ClientAuthMode.required, ClientAuthMode.disabled]) == ["required", "disabled"]);
    assert(toClientAuthModes(["required", "disabled"]) == [ClientAuthMode.required, ClientAuthMode.disabled]);
}