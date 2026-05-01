/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.infrastructure.persistence.memory.audit_log;

// import uim.platform.auditlog.domain.types;
// import uim.platform.auditlog.domain.entities.audit_log_entry;
// import uim.platform.auditlog.domain.ports.repositories.audit_logs;
// 
// // import std.algorithm : filter, sort;
// // import std.array : array;

import uim.platform.auditlog;

mixin(ShowModule!());

@safe:
class MemoryAuditLogRepository : TenantRepository!(AuditLogEntry, AuditLogId), AuditLogRepository {

  size_t countByCategory(TenantId tenantId, AuditCategory category) {
    return findByCategory(tenantId, category).length;
  }

  AuditLogEntry[] filterByCategory(AuditLogEntry[] entries, AuditCategory category) {
    return entries.filter!(e => e.category == category).array;
  }

  AuditLogEntry[] findByCategory(TenantId tenantId, AuditCategory category) {
    return findByTenant(tenantId).filter!(e => e.category == category).array;
  }

  void removeByCategory(TenantId tenantId, AuditCategory category) {
    findByCategory(tenantId, category).each!(e => remove(e));
  }

  size_t countByTimeRange(TenantId tenantId, long timeFrom, long timeTo) {
    return findByTimeRange(tenantId, timeFrom, timeTo).length;
  }

  AuditLogEntry[] filterByTimeRange(AuditLogEntry[] entries, long timeFrom, long timeTo) {
    return entries.filter!(e => e.timestamp >= timeFrom && e.timestamp <= timeTo).array;
  }

  AuditLogEntry[] findByTimeRange(TenantId tenantId, long timeFrom, long timeTo) {
    return findByTenant(tenantId).filter!(e => e.timestamp >= timeFrom && e.timestamp <= timeTo)
      .array;
  }

  void removeByTimeRange(TenantId tenantId, long timeFrom, long timeTo) {
    findByTimeRange(tenantId, timeFrom, timeTo).each!(e => remove(e));
  }

  size_t countByUser(TenantId tenantId, UserId userId) {
    return findByUser(tenantId, userId).length;
  }

  AuditLogEntry[] filterByUser(AuditLogEntry[] entries, UserId userId) {
    return entries.filter!(e => e.userId == userId).array;
  }

  AuditLogEntry[] findByUser(TenantId tenantId, UserId userId) {
    return findByTenant(tenantId).filter!(e => e.userId == userId).array;
  }

  void removeByUser(TenantId tenantId, UserId userId) {
    findByUser(tenantId, userId).each!(e => remove(e));
  }

  size_t countByService(TenantId tenantId, ServiceId serviceId) {
    return findByService(tenantId, serviceId).length;
  }

  AuditLogEntry[] filterByService(AuditLogEntry[] entries, ServiceId serviceId) {
    return entries.filter!(e => e.serviceId == serviceId).array;
  }

  AuditLogEntry[] findByService(TenantId tenantId, ServiceId serviceId) {
    return findByTenant(tenantId).filter!(e => e.serviceId == serviceId).array;
  }

  void removeByService(TenantId tenantId, ServiceId serviceId) {
    findByService(tenantId, serviceId).each!(e => remove(e));
  }

  size_t countByCorrelation(TenantId tenantId, string correlationId) {
    return findByCorrelation(tenantId, correlationId).length;
  }

  AuditLogEntry[] filterByCorrelation(AuditLogEntry[] entries, string correlationId) {
    return entries.filter!(e => e.correlationId == correlationId).array;
  }

  AuditLogEntry[] findByCorrelation(TenantId tenantId, string correlationId) {
    return findByTenant(tenantId).filter!(e => e.correlationId == correlationId).array;
  }

  void removeByCorrelation(TenantId tenantId, string correlationId) {
    findByCorrelation(tenantId, correlationId).each!(e => remove(e));
  }

  AuditLogEntry[] search(TenantId tenantId, AuditCategory[] categories,
    long timeFrom, long timeTo, int limit, int offset) {
    auto filtered = findByTenant(tenantId)
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
      return null;
    auto end = offset + limit;
    if (end > filtered.length)
      end = cast(int)filtered.length;
    return filtered[offset .. end];
  }

  void removeOlderThan(TenantId tenantId, long beforeTimestamp) {
    findByTenant(tenantId).filter!(e => e.timestamp < beforeTimestamp)
      .map!(e => e.id)
      .each!(id => store[tenantId].removeById(id));
  }
}
