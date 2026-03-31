module domain.ports.alert_rule_repository;

import domain.entities.alert_rule;
import domain.types;

/// Port: outgoing - alert rule persistence.
interface AlertRuleRepository
{
    AlertRule findById(AlertRuleId id);
    AlertRule[] findByTenant(TenantId tenantId);
    AlertRule[] findByResource(TenantId tenantId, MonitoredResourceId resourceId);
    AlertRule[] findByMetric(TenantId tenantId, string metricName);
    AlertRule[] findEnabled(TenantId tenantId);
    void save(AlertRule rule);
    void update(AlertRule rule);
    void remove(AlertRuleId id);
}
