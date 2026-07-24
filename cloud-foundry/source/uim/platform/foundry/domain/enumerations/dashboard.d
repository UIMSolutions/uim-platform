/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.domain.enumerations.dashboard;
import uim.platform.foundry;

mixin(ShowModule!());

@safe:
enum DashboardMetricType {
    certificateExpiration,
    domainHealth,
    requestVolume,
    tlsHandshakeErrors,
    dnsResolutionTime,
    certificateCount,
    domainCount,
    mappingCount,
}

DashboardMetricType toDashboardMetricType(string value) {
    mixin(EnumSwitch("DashboardMetricType", "certificateExpiration"));
}

DashboardMetricType[] toDashboardMetricTypes(string[] arr) {
    return arr.map!(toDashboardMetricType).array;
}

string toString(DashboardMetricType t) {
    return t.to!string;
}

string[] toStrings(DashboardMetricType[] arr) {
    return arr.map!toString.array;
}
/// 
unittest {
    mixin(ShowTest!("DashboardMetricType"));

    assert("certificateExpiration".toDashboardMetricType == DashboardMetricType.certificateExpiration);
    assert("domainHealth".toDashboardMetricType == DashboardMetricType.domainHealth);
    assert("requestVolume".toDashboardMetricType == DashboardMetricType.requestVolume);
    assert("tlsHandshakeErrors".toDashboardMetricType == DashboardMetricType.tlsHandshakeErrors);
    assert("dnsResolutionTime".toDashboardMetricType == DashboardMetricType.dnsResolutionTime);
    assert("certificateCount".toDashboardMetricType == DashboardMetricType.certificateCount);
    assert("domainCount".toDashboardMetricType == DashboardMetricType.domainCount);
    assert("mappingCount".toDashboardMetricType == DashboardMetricType.mappingCount);
    assert("unknown".toDashboardMetricType == DashboardMetricType.certificateExpiration);

    assert(DashboardMetricType.certificateExpiration.toString == "certificateExpiration");
    assert(DashboardMetricType.domainHealth.toString == "domainHealth");
    assert(DashboardMetricType.requestVolume.toString == "requestVolume");
    assert(DashboardMetricType.tlsHandshakeErrors.toString == "tlsHandshakeErrors");
    assert(DashboardMetricType.dnsResolutionTime.toString == "dnsResolutionTime");
    assert(DashboardMetricType.certificateCount.toString == "certificateCount");
    assert(DashboardMetricType.domainCount.toString == "domainCount");
    assert(DashboardMetricType.mappingCount.toString == "mappingCount");

    assert([
        DashboardMetricType.certificateExpiration,
        DashboardMetricType.domainHealth,
        DashboardMetricType.requestVolume,
        DashboardMetricType.tlsHandshakeErrors,
        DashboardMetricType.dnsResolutionTime,
        DashboardMetricType.certificateCount,
        DashboardMetricType.domainCount,
        DashboardMetricType.mappingCount
    ].toStrings ==
        [
            "certificateExpiration",
            "domainHealth",
            "requestVolume",
            "tlsHandshakeErrors",
            "dnsResolutionTime",
            "certificateCount",
            "domainCount",
            "mappingCount"
        ]);

    assert([
        "certificateExpiration",
        "domainHealth",
        "requestVolume",
        "tlsHandshakeErrors",
        "dnsResolutionTime",
        "certificateCount",
        "domainCount",
        "mappingCount"
    ].toDashboardMetricTypes ==
        [
            DashboardMetricType.certificateExpiration,
            DashboardMetricType.domainHealth,
            DashboardMetricType.requestVolume,
            DashboardMetricType.tlsHandshakeErrors,
            DashboardMetricType.dnsResolutionTime,
            DashboardMetricType.certificateCount,
            DashboardMetricType.domainCount,
            DashboardMetricType.mappingCount
        ]);
}

enum HealthStatus {
    healthy,
    warning,
    critical,
    unknown,
}

HealthStatus toHealthStatus(string value) {
    mixin(EnumSwitch("HealthStatus", "unknown"));
}

HealthStatus[] toHealthStatuses(string[] arr) {
    return arr.map!(toHealthStatus).array;
}

string toString(HealthStatus t) {
    return t.to!string;
}

string[] toStrings(HealthStatus[] arr) {
    return arr.map!toString.array;
}
///
unittest {
    mixin(ShowTest!("HealthStatus"));

    assert("healthy".toHealthStatus == HealthStatus.healthy);
    assert("warning".toHealthStatus == HealthStatus.warning);
    assert("critical".toHealthStatus == HealthStatus.critical);
    assert("unknown".toHealthStatus == HealthStatus.unknown);
    assert("invalid".toHealthStatus == HealthStatus.unknown);

    assert(HealthStatus.healthy.toString == "healthy");
    assert(HealthStatus.warning.toString == "warning");
    assert(HealthStatus.critical.toString == "critical");
    assert(HealthStatus.unknown.toString == "unknown");
    assert([
        HealthStatus.healthy,
        HealthStatus.warning,
        HealthStatus.critical,
        HealthStatus.unknown
    ].toStrings ==
        ["healthy",
            "warning",
            "critical",
            "unknown"]);

    assert([
        "healthy",
        "warning",
        "critical",
        "unknown"
    ].toHealthStatuses ==
        [
            HealthStatus.healthy,
            HealthStatus.warning,
            HealthStatus.critical,
            HealthStatus.unknown
        ]);
}

enum ExpirationSeverity {
    none,
    info,
    warning,
    critical,
    expired,
}

ExpirationSeverity toExpirationSeverity(string value) {
    mixin(EnumSwitch("ExpirationSeverity", "none"));
}

ExpirationSeverity[] toExpirationSeverities(string[] arr)
    => arr.map!(toExpirationSeverity).array;

string toString(ExpirationSeverity t)
    => t.to!string;

string[] toStrings(ExpirationSeverity[] arr)
    => arr.map!toString.array;

///
unittest {
    mixin(ShowTest!("ExpirationSeverity"));

    assert("none".toExpirationSeverity == ExpirationSeverity.none);
    assert("info".toExpirationSeverity == ExpirationSeverity.info);
    assert("warning".toExpirationSeverity == ExpirationSeverity.warning);
    assert("critical".toExpirationSeverity == ExpirationSeverity.critical);
    assert("expired".toExpirationSeverity == ExpirationSeverity.expired);
    
    assert("".toExpirationSeverity == ExpirationSeverity.none);
    assert("invalid".toExpirationSeverity == ExpirationSeverity.none);

    assert(ExpirationSeverity.none.toString == "none");
    assert(ExpirationSeverity.info.toString == "info");
    assert(ExpirationSeverity.warning.toString == "warning");
    assert(ExpirationSeverity.critical.toString == "critical");
    assert(ExpirationSeverity.expired.toString == "expired");

    assert([
        ExpirationSeverity.none,
        ExpirationSeverity.info,
        ExpirationSeverity.warning,
        ExpirationSeverity.critical,
        ExpirationSeverity.expired
    ].toStrings ==
        ["none", "info",
            "warning",
            "critical",
            "expired"]);

    assert(["none", "info", "warning", "critical", "expired"].toExpirationSeverities == [
        ExpirationSeverity.none,
        ExpirationSeverity.info,
        ExpirationSeverity.warning,
        ExpirationSeverity.critical,
        ExpirationSeverity.expired
    ]);
}
