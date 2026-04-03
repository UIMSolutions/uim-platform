/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.directory.infrastructure.persistence.memory.audit_repo;

import uim.platform.identity.directory.domain.entities.audit_event;
import uim.platform.identity.directory.domain.types;
import uim.platform.identity.directory.domain.ports.audit_repository;

/// In-memory adapter for audit event persistence (append-only).
class MemoryAuditRepository : AuditRepository
{
  private AuditEvent[] store;

  void save(AuditEvent event)
  {
    store ~= event;
  }

  AuditEvent[] findByTenant(TenantId tenantId, uint offset = 0, uint limit = 100)
  {
    return filterPaged((AuditEvent e) => e.tenantId == tenantId, offset, limit);
  }

  AuditEvent[] findByActor(string actorId, uint offset = 0, uint limit = 100)
  {
    return filterPaged((AuditEvent e) => e.actorId == actorId, offset, limit);
  }

  AuditEvent[] findByTarget(string targetId, uint offset = 0, uint limit = 100)
  {
    return filterPaged((AuditEvent e) => e.targetId == targetId, offset, limit);
  }

  AuditEvent[] findByType(TenantId tenantId, AuditEventType eventType,
      uint offset = 0, uint limit = 100)
  {
    return filterPaged((AuditEvent e) => e.tenantId == tenantId
        && e.eventType == eventType, offset, limit);
  }

  AuditEvent[] findByTimeRange(TenantId tenantId, long from, long to,
      uint offset = 0, uint limit = 100)
  {
    return filterPaged((AuditEvent e) => e.tenantId == tenantId
        && e.timestamp >= from && e.timestamp <= to, offset, limit);
  }

  ulong countByTenant(TenantId tenantId)
  {
    ulong count;
    foreach (e; store)
    {
      if (e.tenantId == tenantId)
        count++;
    }
    return count;
  }

  private AuditEvent[] filterPaged(bool delegate(AuditEvent) pred, uint offset, uint limit)
  {
    AuditEvent[] result;
    uint idx;
    foreach (e; store)
    {
      if (pred(e))
      {
        if (idx >= offset && result.length < limit)
          result ~= e;
        idx++;
      }
    }
    return result;
  }
}
