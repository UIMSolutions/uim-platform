/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.infrastructure.persistence.memory.security_event;

// import uim.platform.auditlog.domain.types;
// import uim.platform.auditlog.domain.entities.security_event;
// import uim.platform.auditlog.domain.ports.repositories.security_events;

// // import std.algorithm : filter;
// // import std.array : array;

import uim.platform.auditlog;

mixin(ShowModule!());

@safe:
class MemorySecurityEventRepository : TenantRepository!(SecurityEvent, SecurityEventId), SecurityEventRepository {

  // #region ByAuditLogId
  bool existsByAuditLogId(TenantId tenantId, AuditLogId auditLogId) {
    return findByTenant(tenantId).any!(e => e.auditLogId == auditLogId);
  }

  SecurityEvent findByAuditLogId(TenantId tenantId, AuditLogId auditLogId) {
    foreach (e; findByTenant(tenantId))
      if (e.auditLogId == auditLogId)
        return e;
    return SecurityEvent.init;
  }

  void removeByAuditLogId(TenantId tenantId, AuditLogId auditLogId) {
    if (existsByAuditLogId(tenantId, auditLogId)) {
      remove(findByAuditLogId(tenantId, auditLogId));
    }
  }
  // #endregion ByAuditLogId

  // #region ByUser
  size_t countByUser(TenantId tenantId, UserId userId) {
    return findByUser(tenantId, userId).length;
  }

  SecurityEvent[] findByUser(TenantId tenantId, UserId userId) {
    return findByTenant(tenantId).filter!(e => e.userId == userId).array;
  }

  void removeByUser(TenantId tenantId, UserId userId) {
    findByUser(tenantId, userId).each!(e => remove(e));
  }
  // #endregion ByUser

  // #region ByOutcome
  size_t countByOutcome(TenantId tenantId, AuditOutcome outcome) {
    return findByOutcome(tenantId, outcome).length;
  }

  SecurityEvent[] findByOutcome(TenantId tenantId, AuditOutcome outcome) {
    return findByTenant(tenantId).filter!(e => e.outcome == outcome).array;
  }

  void removeByOutcome(TenantId tenantId, AuditOutcome outcome) {
    findByOutcome(tenantId, outcome).each!(e => remove(e));
  }
  // #endregion ByOutcome

  // #region ByTimeRange
  size_t countByTimeRange(TenantId tenantId, long timeFrom, long timeTo) {
    return findByTimeRange(tenantId, timeFrom, timeTo).length;
  }

  SecurityEvent[] findByTimeRange(TenantId tenantId, long timeFrom, long timeTo) {
    return findByTenant(tenantId).filter!(e => e.timestamp >= timeFrom && e.timestamp <= timeTo)
      .array;
  }

  void removeByTimeRange(TenantId tenantId, long timeFrom, long timeTo) {
    findByTimeRange(tenantId, timeFrom, timeTo).each!(e => remove(e));
  }
  // #endregion ByTimeRange

}
