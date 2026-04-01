module infrastructure.persistence.memory.alert_repo;

import domain.types;
import domain.entities.alert;
import domain.ports.alert_repository;

import std.algorithm : filter;
import std.array : array;

class InMemoryAlertRepository : AlertRepository
{
    private Alert[AlertId] store;

    Alert findById(AlertId id)
    {
        if (auto p = id in store)
            return *p;
        return Alert.init;
    }

    Alert[] findByTenant(TenantId tenantId)
    {
        return store.byValue().filter!(e => e.tenantId == tenantId).array;
    }

    Alert[] findByResource(TenantId tenantId, MonitoredResourceId resourceId)
    {
        return store.byValue()
            .filter!(e => e.tenantId == tenantId && e.resourceId == resourceId)
            .array;
    }

    Alert[] findByState(TenantId tenantId, AlertState state)
    {
        return store.byValue()
            .filter!(e => e.tenantId == tenantId && e.state == state)
            .array;
    }

    Alert[] findBySeverity(TenantId tenantId, AlertSeverity severity)
    {
        return store.byValue()
            .filter!(e => e.tenantId == tenantId && e.severity == severity)
            .array;
    }

    Alert[] findByRule(TenantId tenantId, AlertRuleId ruleId)
    {
        return store.byValue()
            .filter!(e => e.tenantId == tenantId && e.ruleId == ruleId)
            .array;
    }

    void save(Alert alert) { store[alert.id] = alert; }
    void update(Alert alert) { store[alert.id] = alert; }
    void remove(AlertId id) { store.remove(id); }
}
