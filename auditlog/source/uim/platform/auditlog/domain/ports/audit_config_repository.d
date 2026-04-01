module uim.platform.auditlog.domain.ports.audit_config_repository;

import uim.platform.auditlog.domain.types;
import uim.platform.auditlog.domain.entities.audit_config;

/// Port for persisting tenant-level audit configurations.
@safe:
interface AuditConfigRepository {
    AuditConfig[] findAll();

    bool existsByTenant(TenantId tenantId);
    AuditConfig findByTenant(TenantId tenantId);

    bool existsById(AuditConfigId id);
    AuditConfig findById(AuditConfigId id);
    
    void save(AuditConfig config);
    void update(AuditConfig config);
    void remove(AuditConfigId id, TenantId tenantId);
}
