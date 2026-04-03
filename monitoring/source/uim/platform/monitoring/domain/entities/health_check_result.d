module uim.platform.monitoring.domain.entities.health_check_result;

import uim.platform.monitoring.domain.types;

/// Result of executing a health check.
struct HealthCheckResult
{
    HealthCheckResultId id;
    TenantId tenantId;
    HealthCheckId checkId;
    MonitoredResourceId resourceId;
    CheckStatus status = CheckStatus.unknown;
    double value_;
    string message;
    int responseTimeMs;
    int httpStatusCode;
    long executedAt;
}
