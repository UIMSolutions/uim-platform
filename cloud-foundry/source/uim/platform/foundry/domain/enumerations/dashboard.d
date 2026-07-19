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

DashboardMetricType[] toDashboardMetricType(string[] arr) {
    return arr.map!(toDashboardMetricType).array;
}

string toString(DashboardMetricType t) {
    return t.to!string;
}

string[] toStrings(DashboardMetricType[] arr) {
    return arr.map!(toString).array;
}
/// 
unittest {
    mixin(ShowTest!("DashboardMetricType"));

    assert(toDashboardMetricType(
            "certificateExpiration") == DashboardMetricType.certificateExpiration);
    assert(toDashboardMetricType("domainHealth") == DashboardMetricType.domainHealth);
    assert(toDashboardMetricType("requestVolume") == DashboardMetricType.requestVolume);
    assert(toDashboardMetricType("tlsHandshakeErrors") == DashboardMetricType.tlsHandshakeErrors);
    assert(toDashboardMetricType("dnsResolutionTime") == DashboardMetricType.dnsResolutionTime);
    assert(toDashboardMetricType("certificateCount") == DashboardMetricType.certificateCount);
    assert(toDashboardMetricType("domainCount") == DashboardMetricType.domainCount);
    assert(toDashboardMetricType("mappingCount") == DashboardMetricType.mappingCount);
    assert(toDashboardMetricType("unknown") == DashboardMetricType.certificateExpiration);

    assert(toString(DashboardMetricType.certificateExpiration) == "certificateExpiration");
    assert(toString(DashboardMetricType.domainHealth) == "domainHealth");
    assert(toString(DashboardMetricType.requestVolume) == "requestVolume");
    assert(toString(DashboardMetricType.tlsHandshakeErrors) == "tlsHandshakeErrors");
    assert(toString(DashboardMetricType.dnsResolutionTime) == "dnsResolutionTime");
    assert(toString(DashboardMetricType.certificateCount) == "certificateCount");
    assert(toString(DashboardMetricType.domainCount) == "domainCount");
    assert(toString(DashboardMetricType.mappingCount) == "mappingCount");

    assert([
        toString(DashboardMetricType.certificateExpiration),
        toString(DashboardMetricType.domainHealth),
        toString(DashboardMetricType.requestVolume),
        toString(DashboardMetricType.tlsHandshakeErrors),
        toString(DashboardMetricType.dnsResolutionTime),
        toString(DashboardMetricType.certificateCount),
        toString(DashboardMetricType.domainCount),
        toString(DashboardMetricType.mappingCount)
    ] ==
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
        toDashboardMetricType("certificateExpiration"),
        toDashboardMetricType("domainHealth"),
        toDashboardMetricType("requestVolume"),
        toDashboardMetricType("tlsHandshakeErrors"),
        toDashboardMetricType("dnsResolutionTime"),
        toDashboardMetricType("certificateCount"),
        toDashboardMetricType("domainCount"),
        toDashboardMetricType("mappingCount")
    ] ==
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

HealthStatus[] toHealthStatus(string[] arr) {
    return arr.map!(toHealthStatus).array;
}

string toString(HealthStatus t) {
    return t.to!string;
}

string[] toStrings(HealthStatus[] arr) {
    return arr.map!(toString).array;
}
///
unittest {
    mixin(ShowTest!("HealthStatus"));

    assert(toHealthStatus("healthy") == HealthStatus.healthy);
    assert(toHealthStatus("warning") == HealthStatus.warning);
    assert(toHealthStatus("critical") == HealthStatus.critical);
    assert(toHealthStatus("unknown") == HealthStatus.unknown);
    assert(toHealthStatus("invalid") == HealthStatus.unknown);

    assert(toString(HealthStatus.healthy) == "healthy");
    assert(toString(HealthStatus.warning) == "warning");
    assert(toString(HealthStatus.critical) == "critical");
    assert(toString(HealthStatus.unknown) == "unknown");
    assert([
        toString(HealthStatus.healthy),
        toString(HealthStatus.warning),
        toString(HealthStatus.critical),
        toString(HealthStatus.unknown)
    ] ==
        ["healthy",
            "warning",
            "critical",
            "unknown"]);

    assert([
        toHealthStatus("healthy"),
        toHealthStatus("warning"),
        toHealthStatus("critical"),
        toHealthStatus("unknown")
    ] ==
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

ExpirationSeverity[] toExpirationSeverity(string[] arr) {
    return arr.map!(toExpirationSeverity).array;
}

string toString(ExpirationSeverity t) {
    return t.to!string;
}

string[] toStrings(ExpirationSeverity[] arr) {
    return arr.map!(toString).array;
}
///
unittest {
    mixin(ShowTest!("ExpirationSeverity"));

    assert(toExpirationSeverity("none") == ExpirationSeverity.none);
    assert(toExpirationSeverity("info") == ExpirationSeverity.info);
    assert(toExpirationSeverity("warning") == ExpirationSeverity.warning);
    assert(toExpirationSeverity("critical") == ExpirationSeverity.critical);
    assert(toExpirationSeverity("expired") == ExpirationSeverity.expired);
    assert(toExpirationSeverity("invalid") == ExpirationSeverity.none);

    assert(toString(ExpirationSeverity.none) == "none");
    assert(toString(ExpirationSeverity.info) == "info");
    assert(toString(ExpirationSeverity.warning) == "warning");
    assert(toString(ExpirationSeverity.critical) == "critical");
    assert(toString(ExpirationSeverity.expired) == "expired");
    assert([
        ExpirationSeverity.none,
        ExpirationSeverity.info,
        ExpirationSeverity.warning,
        ExpirationSeverity.critical,
        ExpirationSeverity.expired
    ].toString ==
        ["none", "info",
            "warning",
            "critical",
            "expired"]);

    assert(["none", "info", "warning", "critical", "expired"].toExpi ==
        [
            ExpirationSeverity.none,
            ExpirationSeverity.info,
            ExpirationSeverity.warning,
            ExpirationSeverity.critical,
            ExpirationSeverity.expired
        ]);
}
