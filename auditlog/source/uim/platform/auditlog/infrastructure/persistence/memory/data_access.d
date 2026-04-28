/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.infrastructure.persistence.memory.data_access;

// import uim.platform.auditlog.domain.types;
// import uim.platform.auditlog.domain.entities.data_access_log;
// import uim.platform.auditlog.domain.ports.repositories.data_access_logs;
// 
// // import std.algorithm : filter;
// // import std.array : array;

import uim.platform.auditlog;

mixin(ShowModule!());

@safe:
class MemoryDataAccessLogRepository : TenantRepository!(DataAccessLog, DataAccessLogId), DataAccessLogRepository {

  // #region ByAuditLogId
  bool existsByAuditLogId(TenantId tenantId, AuditLogId auditLogId) {
    return findByTenant(tenantId).any!(e => e.auditLogId == auditLogId);
  }

  DataAccessLog findByAuditLogId(TenantId tenantId, AuditLogId auditLogId) {
    foreach (e; findByTenant(tenantId))
      if (e.auditLogId == auditLogId)
        return e;
    return DataAccessLog.init;
  }

  void removeByAuditLogId(TenantId tenantId, AuditLogId auditLogId) {
    if (existsByAuditLogId(tenantId, auditLogId)) {
      remove(findByAuditLogId(tenantId, auditLogId));
    }
  }
  // #endregion ByAuditLogId

  // #region ByAccessor
  size_t countByAccessor(TenantId tenantId, UserId accessedBy) {
    return findByAccessor(tenantId, accessedBy).length;
  }

  DataAccessLog[] findByAccessor(TenantId tenantId, UserId accessedBy) {
    return findByTenant(tenantId).filter!(e => e.accessedBy == accessedBy).array;
  }

  void removeByAccessor(TenantId tenantId, UserId accessedBy) {
    findByAccessor(tenantId, accessedBy).each!(e => remove(e));
  }
  // #endregion ByAccessor

  // #region ByDataSubject
  size_t countByDataSubject(TenantId tenantId, string dataSubject) {
    return findByDataSubject(tenantId, dataSubject).length;
  }

  DataAccessLog[] findByDataSubject(TenantId tenantId, string dataSubject) {
    return findByTenant(tenantId).filter!(e => e.dataSubject == dataSubject).array;
  }

  void removeByDataSubject(TenantId tenantId, string dataSubject) {
    findByDataSubject(tenantId, dataSubject).each!(e => remove(e));
  }
  // #endregion ByDataSubject

  // #region ByTimeRange
  size_t countByTimeRange(TenantId tenantId, long timeFrom, long timeTo) {
    return findByTimeRange(tenantId, timeFrom, timeTo).length;
  }

  DataAccessLog[] findByTimeRange(TenantId tenantId, long timeFrom, long timeTo) {
    return findByTenant(tenantId).filter!(e => e.timestamp >= timeFrom && e.timestamp <= timeTo)
      .array;
  }

  void removeByTimeRange(TenantId tenantId, long timeFrom, long timeTo) {
    findByTimeRange(tenantId, timeFrom, timeTo).each!(e => remove(e));
  }
  // #endregion ByTimeRange

  void removeOlderThan(TenantId tenantId, long beforeTimestamp) {
    findByTenant(tenantId).filter!(e => e.timestamp < beforeTimestamp).each!(e => remove(e));
  }
}
