module uim.platform.auditlog.infrastructure.persistence.memory.audit_config;

import uim.platform.auditlog.domain.types;
import uim.platform.auditlog.domain.entities.audit_config;
import uim.platform.auditlog.domain.ports.audit_config_repository;

import std.algorithm : filter;
import std.array : array;

@safe:
class InMemoryAuditConfigRepository : AuditConfigRepository {
    private AuditConfig[AuditConfigId] store;

    AuditConfig[] findAll() {
        return store.byValue().array;
    }

    
    AuditConfig findByTenant(TenantId tenantId) {
        foreach (c; store.byValue())
            if (c.tenantId == tenantId)
                return c;
        return AuditConfig.init;
    }

    AuditConfig findById(AuditConfigId id) {
        if (id in store)
            return store[id];
        return AuditConfig.init;
    }

    void save(AuditConfig config) {
        store[config.id] = config;
    }

    void update(AuditConfig config) {
        store[config.id] = config;
    }

    void remove(AuditConfigId id, TenantId tenantId) {
        if (id in store)
            if (store[id].tenantId == tenantId)
                store.remove(id);
    }
}
