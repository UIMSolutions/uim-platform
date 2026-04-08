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

  AuditLogEntry entry1 = AuditLogEntry.init;
  entry1.tenantId = TenantId("tenant1");
  entry1.userId = UserId("user1");
  entry1.userName = "User One";
  entry1.serviceId = ServiceId("service1");
  entry1.serviceName = "Service One";
  entry1.category = AuditCategory.dataAccess;
  entry1.severity = AuditSeverity.warning;
  entry1.action = AuditAction.dataAccess;
  entry1.outcome = AuditOutcome.failure;
  entry1.objectType = "objectType1";
  entry1.objectId = "objectId1";
  entry1.message = "Test log entry 1";
  entry1.ipAddress = "127.0.0.1";
  entry1.userAgent = "UnitTest/1.0";
  entry1.correlationId = "corr1";
  entry1.originApp = "UnitTestApp";
  entry1.timestamp = Clock.currStdTime();

  AuditLogEntry entry2 = AuditLogEntry.init;
  entry2.tenantId = TenantId("tenant1");
  entry2.userId = UserId("user2");
  entry2.userName = "User Two";
  entry2.serviceId = ServiceId("service2");
  entry2.serviceName = "Service Two";
  entry2.category = AuditCategory.dataModification; 
  entry2.severity = AuditSeverity.info;
  entry2.action = AuditAction.dataAccess;
  entry2.outcome = AuditOutcome.success;
  entry2.objectType = "objectType2";
  entry2.objectId = "objectId2";
  entry2.message = "Test log entry 2";
  entry2.ipAddress = "127.0.0.2";
  entry2.userAgent = "UnitTest/1.0";
  entry2.correlationId = "corr2";
  entry2.originApp = "UnitTestApp";
  entry2.timestamp = Clock.currStdTime();

  repo.save(entry1);
  repo.save(entry2);

  assert(repo.existsByTenant(TenantId("tenant1")));
  assert(repo.findByTenant(TenantId("tenant1")).length == 2);
  assert(repo.existsById(TenantId("tenant1"), entry1.id));
  assert(repo.findById(TenantId("tenant1"), entry1.id) == entry1);
  assert(repo.findByCategory(TenantId("tenant1"), AuditCategory.dataAccess).length == 1);
  assert(repo.findByUser(TenantId("tenant1"), UserId("user1")).length == 1);
  assert(repo.findByService(TenantId("tenant1"), ServiceId("service1")).length == 1);
  assert(repo.findByCorrelation(TenantId("tenant1"), "corr1").length == 1);

  // repo.removeOlderThan(TenantId("tenant1"), Clock.currTime() + dur!"secs"(5)); // remove all
  // assert(repo.countByTenant(TenantId("tenant1")) == 0);
}
