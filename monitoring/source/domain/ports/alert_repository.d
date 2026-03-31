module domain.ports.alert_repository;

import domain.entities.alert;
import domain.types;

/// Port: outgoing - alert persistence.
interface AlertRepository
{
    Alert findById(AlertId id);
    Alert[] findByTenant(TenantId tenantId);
    Alert[] findByResource(TenantId tenantId, MonitoredResourceId resourceId);
    Alert[] findByState(TenantId tenantId, AlertState state);
    Alert[] findBySeverity(TenantId tenantId, AlertSeverity severity);
    Alert[] findByRule(TenantId tenantId, AlertRuleId ruleId);
    void save(Alert alert);
    void update(Alert alert);
    void remove(AlertId id);
}
