/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.infrastructure.persistence.memory.security_event;

// import uim.platform.auditlog.domain.types;
// import uim.platform.auditlog.domain.entities.security_event;
// import uim.platform.auditlog.domain.ports.security_event_repository;

// // import std.algorithm : filter;
// // import std.array : array;

import uim.platform.auditlog;

mixin(ShowModule!());

@safe:
class MemorySecurityEventRepository : SecurityEventRepository
{
  private SecurityEvent[] store;

  bool existsByAuditLogId(AuditLogId auditLogId, TenantId tenantId)
  {
    return findByTenant(tenantId).any!(e => e.auditLogId == auditLogId);
  }

  SecurityEvent findByAuditLogId(AuditLogId auditLogId, TenantId tenantId)
  {
    foreach (e; findByTenant(tenantId))
      if (e.auditLogId == auditLogId)
        return e;
    return SecurityEvent.init;
  }

  SecurityEvent[] findByTenant(TenantId tenantId)
  {
    return store.filter!(e => e.tenantId == tenantId).array;
  }

  SecurityEvent[] findByUser(TenantId tenantId, UserId userId)
  {
    return findByTenant(tenantId).filter!(e => e.userId == userId).array;
  }

  SecurityEvent[] findByOutcome(TenantId tenantId, AuditOutcome outcome)
  {
    return findByTenant(tenantId).filter!(e => e.outcome == outcome).array;
  }

  SecurityEvent[] findByTimeRange(TenantId tenantId, long timeFrom, long timeTo)
  {
    return findByTenant(tenantId).filter!(e => e.timestamp >= timeFrom && e.timestamp <= timeTo)
      .array;
  }

  void save(SecurityEvent event)
  {
    store ~= event;
  }

  void removeOlderThan(TenantId tenantId, long beforeTimestamp)
  {
    store = store.filter!(e => !(e.tenantId == tenantId && e.timestamp < beforeTimestamp)).array;
  }
}
