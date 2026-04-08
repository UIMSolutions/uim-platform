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
class MemoryAuditLogRepository : MemoryTenantRepository!(AuditLogEntry, AuditLogId), AuditLogRepository {
  private AuditLogEntry[AuditLogId][TenantId] store;

  // bool existsByTenant(TenantId tenantId) {
  //   return (tenantId in store) && !store[tenantId].empty;
  // }

  // AuditLogEntry[] findByTenant(TenantId tenantId) {
  //   return existsByTenant(tenantId) ? store[tenantId].byValue().array : null;
  // }

  // bool existsById(TenantId tenantId, AuditLogId id) {
  //   return existsByTenant(tenantId) && (id in store[tenantId]) ? true : false;
  // }

  // AuditLogEntry findById(TenantId tenantId, AuditLogId id) {
  //   return existsById(tenantId, id) ? store[tenantId][id] : AuditLogEntry.init;
  // }

  AuditLogEntry[] findByCategory(TenantId tenantId, AuditCategory category) {
    return findByTenant(tenantId).filter!(e => e.category == category).array;
  }

  AuditLogEntry[] findByTimeRange(TenantId tenantId, long timeFrom, long timeTo) {
    return findByTenant(tenantId).filter!(e => e.timestamp >= timeFrom && e.timestamp <= timeTo)
      .array;
  }

  AuditLogEntry[] findByUser(TenantId tenantId, UserId userId) {
    return findByTenant(tenantId).filter!(e => e.userId == userId).array;
  }

  AuditLogEntry[] findByService(TenantId tenantId, ServiceId serviceId) {
    return findByTenant(tenantId).filter!(e => e.serviceId == serviceId).array;
  }

  AuditLogEntry[] findByCorrelation(TenantId tenantId, string correlationId) {
    return findByTenant(tenantId).filter!(e => e.correlationId == correlationId).array;
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
      return [];
    auto end = offset + limit;
    if (end > filtered.length)
      end = cast(int)filtered.length;
    return filtered[offset .. end];
  }

  long countByTenant(TenantId tenantId) {
    return findByTenant(tenantId).length;
  }

  // void save(TenantId tenantId, AuditLogEntry entry) {
  // entry.tenantId = tenantId;
  // save(entry);
  // }
  // 
  // void save(AuditLogEntry entry) {
  // if (!existsByTenant(entry.tenantId)) {
  // AuditLogEntry[AuditLogId] tenantStore;
  // store[entry.tenantId] = tenantStore;
  // }
  // store[entry.tenantId][entry.id] = entry;
  // }

  // void update(AuditLogEntry entry) {

  //   if (!existsById(entry.tenantId, entry.id))
  //     return; // or throw an exception  

  //   store[entry.tenantId][entry.id] = entry;
  // }

  void removeOlderThan(TenantId tenantId, long beforeTimestamp) {
    findByTenant(tenantId).filter!(e => e.timestamp < beforeTimestamp)
      .map!(e => e.id)
      .each!(id => store[tenantId].remove(id));
  }
}
///
unittest {
  auto repo = new MemoryAuditLogRepository();

  auto tenantId = TenantId("tenant1");
  auto entry1 = AuditLogEntry(AuditLogId("log1"), tenantId, "user1", "service1",
    AuditCategory("category1"), "action1", "details1", "corr1", Clock.currTime());
  auto entry2 = AuditLogEntry(AuditLogId("log2"), tenantId, "user2", "service2",
    AuditCategory("category2"), "action2", "details2", "corr2", Clock.currTime());

  repo.save(entry1);
  repo.save(entry2);

  assert(repo.existsByTenant(tenantId));
  assert(repo.findByTenant(tenantId).length == 2);
  assert(repo.existsById(tenantId, entry1.id));
  assert(repo.findById(tenantId, entry1.id) == entry1);
  assert(repo.findByCategory(tenantId, AuditCategory("category1")).length == 1);
  assert(repo.findByUser(tenantId, UserId("user1")).length == 1);
  assert(repo.findByService(tenantId, ServiceId("service1")).length == 1);
  assert(repo.findByCorrelation(tenantId, "corr1").length == 1);

  repo.removeOlderThan(tenantId, Clock.currTime() + 1000); // remove all
  assert(repo.countByTenant(tenantId) == 0);
}
