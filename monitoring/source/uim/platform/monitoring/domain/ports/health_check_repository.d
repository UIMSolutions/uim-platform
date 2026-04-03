module uim.platform.xyz.domain.ports.health_check_repository;

import domain.entities.health_check;
import domain.types;

/// Port: outgoing - health check configuration persistence.
interface HealthCheckRepository
{
    HealthCheck findById(HealthCheckId id);
    HealthCheck[] findByTenant(TenantId tenantId);
    HealthCheck[] findByResource(TenantId tenantId, MonitoredResourceId resourceId);
    HealthCheck[] findByType(TenantId tenantId, CheckType checkType);
    void save(HealthCheck check);
    void update(HealthCheck check);
    void remove(HealthCheckId id);
}
