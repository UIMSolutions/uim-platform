module uim.platform.foundry.domain.enumerations.dashboard;

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

enum HealthStatus {
    healthy,
    warning,
    critical,
    unknown,
}

enum ExpirationSeverity {
    none,
    info,
    warning,
    critical,
    expired,
}