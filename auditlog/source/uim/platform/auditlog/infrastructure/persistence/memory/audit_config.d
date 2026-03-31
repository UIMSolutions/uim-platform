module uim.platform.auditlog.infrastructure.persistence.memory.audit_config;

import uim.platform.auditlog.domain.types;
import uim.platform.auditlog.domain.entities.audit_config;
import uim.platform.auditlog.domain.ports.audit_config_repository;

import std.algorithm : filter;
import std.array : array;

class InMemoryAuditConfigRepository : AuditConfigRepository
{
    private AuditConfig[AuditConfigId] store;

    AuditConfig[] findAll()
    {
        return store.byValue().array;
    }

    AuditConfig* findByTenant(TenantId tenantId)
    {
        foreach (ref c; store.byValue())
            if (c.tenantId == tenantId)
                return &c;
        return null;
    }

    AuditConfig* findById(AuditConfigId id)
    {
        if (auto p = id in store)
            return p;
        return null;
    }

    void save(AuditConfig config) { store[config.id] = config; }
    void update(AuditConfig config) { store[config.id] = config; }
    void remove(AuditConfigId id, TenantId tenantId)
    {
        if (auto p = id in store)
            if (p.tenantId == tenantId)
                store.remove(id);
    }
}
