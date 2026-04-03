module uim.platform.identity.directory.domain.ports.audit_repository;

import uim.platform.identity.directory.domain.entities.audit_event;
import uim.platform.identity.directory.domain.types;

/// Port: outgoing — audit event persistence.
interface AuditRepository
{
  void save(AuditEvent event);
  AuditEvent[] findByTenant(TenantId tenantId, uint offset = 0, uint limit = 100);
  AuditEvent[] findByActor(string actorId, uint offset = 0, uint limit = 100);
  AuditEvent[] findByTarget(string targetId, uint offset = 0, uint limit = 100);
  AuditEvent[] findByType(TenantId tenantId, AuditEventType eventType,
      uint offset = 0, uint limit = 100);
  AuditEvent[] findByTimeRange(TenantId tenantId, long from, long to,
      uint offset = 0, uint limit = 100);
  ulong countByTenant(TenantId tenantId);
}
