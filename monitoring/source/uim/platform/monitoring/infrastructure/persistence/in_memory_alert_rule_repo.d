module uim.platform.xyz.infrastructure.persistence.memory.alert_rule_repo;

import domain.types;
import domain.entities.alert_rule;
import domain.ports.alert_rule_repository;

import std.algorithm : filter;
import std.array : array;

class MemoryAlertRuleRepository : AlertRuleRepository
{
    private AlertRule[AlertRuleId] store;

    AlertRule findById(AlertRuleId id)
    {
        if (auto p = id in store)
            return *p;
        return AlertRule.init;
    }

    AlertRule[] findByTenant(TenantId tenantId)
    {
        return store.byValue().filter!(e => e.tenantId == tenantId).array;
    }

    AlertRule[] findByResource(TenantId tenantId, MonitoredResourceId resourceId)
    {
        return store.byValue()
            .filter!(e => e.tenantId == tenantId && e.resourceId == resourceId)
            .array;
    }

    AlertRule[] findByMetric(TenantId tenantId, string metricName)
    {
        return store.byValue()
            .filter!(e => e.tenantId == tenantId && e.metricName == metricName)
            .array;
    }

    AlertRule[] findEnabled(TenantId tenantId)
    {
        return store.byValue()
            .filter!(e => e.tenantId == tenantId && e.isEnabled)
            .array;
    }

    void save(AlertRule rule) { store[rule.id] = rule; }
    void update(AlertRule rule) { store[rule.id] = rule; }
    void remove(AlertRuleId id) { store.remove(id); }
}
