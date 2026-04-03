module uim.platform.auditlog.infrastructure.persistence.memory.audit_log;

// import uim.platform.auditlog.domain.types;
// import uim.platform.auditlog.domain.entities.audit_log_entry;
// import uim.platform.auditlog.domain.ports.audit_log_repository;
// 
// // import std.algorithm : filter, sort;
// // import std.array : array;

import uim.platform.auditlog;

mixin(ShowModule!());

@safe:
class MemoryAuditLogRepository : AuditLogRepository {
  private AuditLogEntry[AuditLogId] store;

  bool existsById(AuditLogId id, TenantId tenantId) {
    return (id in store && store[id].tenantId == tenantId);
  }

  AuditLogEntry findById(AuditLogId id, TenantId tenantId) {
    return existsById(id, tenantId) ? store[id] : AuditLogEntry.init;
  }

  AuditLogEntry[] findByTenant(TenantId tenantId) {
    return store.byValue().filter!(e => e.tenantId == tenantId).array;
  }

  AuditLogEntry[] findByCategory(TenantId tenantId, AuditCategory category) {
    return findByTenant(tenantId)
      .filter!(e => e.category == category)
      .array;
  }

  AuditLogEntry[] findByTimeRange(TenantId tenantId, long timeFrom, long timeTo) {
    return findByTenant(tenantId)
      .filter!(e => e.timestamp >= timeFrom && e.timestamp <= timeTo)
      .array;
  }

  AuditLogEntry[] findByUser(TenantId tenantId, UserId userId) {
    return findByTenant(tenantId)
      .filter!(e => e.userId == userId)
      .array;
  }

  AuditLogEntry[] findByService(TenantId tenantId, ServiceId serviceId) {
    return findByTenant(tenantId)
      .filter!(e => e.serviceId == serviceId)
      .array;
  }

  AuditLogEntry[] findByCorrelation(string correlationId) {
    return store.byValue()
      .filter!(e => e.correlationId == correlationId)
      .array;
  }

  AuditLogEntry[] search(TenantId tenantId, AuditCategory[] categories,
    long timeFrom, long timeTo, int limit, int offset) {
    auto filtered = store.byValue()
      .filter!(e => e.tenantId == tenantId)
      .filter!((e) {
        if (timeFrom > 0 && e.timestamp < timeFrom)
          return false;
        if (timeTo > 0 && e.timestamp > timeTo)
          return false;
        if (categories.length > 0) {
          bool found = false;
          foreach (c; categories)
            if (e.category == c) {
              found = true;
              break;
            }
          if (!found)
            return false;
        }
        return true;
      })
      .array;

    // Sort by timestamp descending
    filtered.sort!((a, b) => a.timestamp > b.timestamp);

    // Apply pagination
    if (offset >= filtered.length)
      return [];
    auto end = offset + limit;
    if (end > filtered.length)
      end = cast(int)filtered.length;
    return filtered[offset .. end];
  }

  long countByTenant(TenantId tenantId) {
    return findByTenant(tenantId).length;
  }

  void save(AuditLogEntry entry) {
    store[entry.id] = entry;
  }

  void removeOlderThan(TenantId tenantId, long beforeTimestamp) {
    store
      .findByTenant(tenantId)
      .filter!(e => e.timestamp < beforeTimestamp)
      .map!(e => e.id)
      .each(id => store.remove(id));
  }
}
