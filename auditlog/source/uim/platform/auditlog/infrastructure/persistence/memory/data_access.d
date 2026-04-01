module uim.platform.auditlog.infrastructure.persistence.memory.data_access;

import uim.platform.auditlog.domain.types;
import uim.platform.auditlog.domain.entities.data_access_log;
import uim.platform.auditlog.domain.ports.data_access_log_repository;

import std.algorithm : filter;
import std.array : array;

@safe:
class InMemoryDataAccessLogRepository : DataAccessLogRepository {
  private DataAccessLog[] store;

  bool existsByAuditLogId(AuditLogId auditLogId, TenantId tenantId) {
    return store.findByTenant(tenantId).any!(e => e.auditLogId == auditLogId);
  }

  DataAccessLog findByAuditLogId(AuditLogId auditLogId, TenantId tenantId) {
    foreach (ref e; store)
      if (e.auditLogId == auditLogId && e.tenantId == tenantId)
        return e;
    return DataAccessLog.init;
  }

  DataAccessLog[] findByTenant(TenantId tenantId) {
    return store.filter!(e => e.tenantId == tenantId).array;
  }

  DataAccessLog[] findByAccessor(TenantId tenantId, UserId accessedBy) {
    return findByTenant(tenantId).filter!(e => e.accessedBy == accessedBy).array;
  }

  DataAccessLog[] findByDataSubject(TenantId tenantId, string dataSubject) {
    return findByTenant(tenantId).filter!(e => e.dataSubject == dataSubject).array;
  }

  DataAccessLog[] findByTimeRange(TenantId tenantId, long timeFrom, long timeTo) {
    return findByTenant(tenantId).filter!(e => e.timestamp >= timeFrom && e.timestamp <= timeTo)
      .array;
  }

  void save(DataAccessLog log) {
    store ~= log;
  }

  void removeOlderThan(TenantId tenantId, long beforeTimestamp) {
    store = store.filter!(e => !(e.tenantId == tenantId && e.timestamp < beforeTimestamp))
      .array;
  }
}
