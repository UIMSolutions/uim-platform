module uim.platform.monitoring.domain.ports.health_check_result_repository;

import uim.platform.monitoring.domain.entities.health_check_result;
import uim.platform.monitoring.domain.types;

/// Port: outgoing - health check result persistence.
interface HealthCheckResultRepository
{
    HealthCheckResult findById(HealthCheckResultId id);
    HealthCheckResult[] findByCheck(TenantId tenantId, HealthCheckId checkId);
    HealthCheckResult[] findByResource(TenantId tenantId, MonitoredResourceId resourceId);
    HealthCheckResult findLatestByCheck(TenantId tenantId, HealthCheckId checkId);
    HealthCheckResult[] findInTimeRange(TenantId tenantId, HealthCheckId checkId, long startTime, long endTime);
    void save(HealthCheckResult result);
    void removeOlderThan(TenantId tenantId, long beforeTimestamp);
}
