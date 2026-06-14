/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.domain.enumerations.dashboard;
import uim.platform.foundry;

// mixin(ShowModule!());

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
DashboardMetricType toDashboardMetricType(string s) {
    const map = [
            "certificateexpiration": DashboardMetricType.certificateExpiration,
            "domainhealth": DashboardMetricType.domainHealth,
            "requestvolume": DashboardMetricType.requestVolume,
            "tlshandshakeerrors": DashboardMetricType.tlsHandshakeErrors,
            "dnsresolutiontime": DashboardMetricType.dnsResolutionTime,
            "certificatecount": DashboardMetricType.certificateCount,
            "domaincount": DashboardMetricType.domainCount,
            "mappingcount": DashboardMetricType.mappingCount
    ];
    return map.get(s.toLower, DashboardMetricType.certificateExpiration);
}

enum HealthStatus {
    healthy,
    warning,
    critical,
    unknown,
}
HealthStatus toHealthStatus(string s) {
    const map = [
        "healthy": HealthStatus.healthy,
        "warning": HealthStatus.warning,
        "critical": HealthStatus.critical,
        "unknown": HealthStatus.unknown
    ];
    return map.get(s.toLower, HealthStatus.unknown);
}

enum ExpirationSeverity {
    none,
    info,
    warning,
    critical,
    expired,
}
ExpirationSeverity toExpirationSeverity(string s) {
    const map = [
        "none": ExpirationSeverity.none,
        "info": ExpirationSeverity.info,
        "warning": ExpirationSeverity.warning,
        "critical": ExpirationSeverity.critical,
        "expired": ExpirationSeverity.expired
    ];
    return map.get(s.toLower, ExpirationSeverity.none);
}
