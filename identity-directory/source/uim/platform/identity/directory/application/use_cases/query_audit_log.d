module uim.platform.identity.directory.application.usecases.query_audit_log;

import uim.platform.identity.directory.domain.entities.audit_event;
import uim.platform.identity.directory.domain.types;
import uim.platform.identity.directory.domain.ports.audit_repository;

/// Application use case: query audit logs.
class QueryAuditLogUseCase
{
    private AuditRepository auditRepo;

    this(AuditRepository auditRepo)
    {
        this.auditRepo = auditRepo;
    }

    /// List audit events by tenant.
    AuditEvent[] listEvents(TenantId tenantId, uint offset = 0, uint limit = 100)
    {
        return auditRepo.findByTenant(tenantId, offset, limit);
    }

    /// Find events by actor.
    AuditEvent[] findByActor(string actorId, uint offset = 0, uint limit = 100)
    {
        return auditRepo.findByActor(actorId, offset, limit);
    }

    /// Find events by target resource.
    AuditEvent[] findByTarget(string targetId, uint offset = 0, uint limit = 100)
    {
        return auditRepo.findByTarget(targetId, offset, limit);
    }

    /// Find events by type.
    AuditEvent[] findByType(TenantId tenantId, AuditEventType eventType, uint offset = 0, uint limit = 100)
    {
        return auditRepo.findByType(tenantId, eventType, offset, limit);
    }

    /// Find events within a time range.
    AuditEvent[] findByTimeRange(TenantId tenantId, long from, long to, uint offset = 0, uint limit = 100)
    {
        return auditRepo.findByTimeRange(tenantId, from, to, offset, limit);
    }
}
