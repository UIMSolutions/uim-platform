/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.infrastructure.persistence.memory.config_change;

// import uim.platform.auditlog.domain.types;
// import uim.platform.auditlog.domain.entities.config_change_log;
// import uim.platform.auditlog.domain.ports.repositories.config_change_logs;

// import std.algorithm : filter;
// import std.array : array;

import uim.platform.auditlog;

mixin(ShowModule!());

@safe:
class MemoryConfigChangeLogRepository : ConfigChangeLogRepository {
  private ConfigChangeLog[] store;

  bool existsByTenant(TenantId tenantId) {
    return store.any!(e => e.tenantId == tenantId);
  }

  ConfigChangeLog[] findByTenant(TenantId tenantId) {
    return store.filter!(e => e.tenantId == tenantId).array;
  }

  bool existsByAuditLogId(TenantId tenantId, AuditLogId auditLogId) {
    return findByTenant(tenantId).any!(e => e.id == auditLogId);
  }

  ConfigChangeLog findByAuditLogId(TenantId tenantId, AuditLogId auditLogId) {
    foreach (e; findByTenant(tenantId))
      if (e.id == auditLogId)
        return e;
    return ConfigChangeLog.init;
  }

  ConfigChangeLog[] findByUser(TenantId tenantId, UserId changedBy) {
    return findByTenant(tenantId).filter!(e => e.changedBy == changedBy).array;
  }

  ConfigChangeLog[] findByConfigType(TenantId tenantId, string configType) {
    return findByTenant(tenantId).filter!(e => e.configType == configType).array;
  }

  ConfigChangeLog[] findByTimeRange(TenantId tenantId, long timeFrom, long timeTo) {
    return findByTenant(tenantId).filter!(e => e.timestamp >= timeFrom && e.timestamp <= timeTo)
      .array;
  }

  void save(ConfigChangeLog log) {
    store ~= log;
  }

  void removeOlderThan(TenantId tenantId, long beforeTimestamp) {
    store = store.filter!(e => !(e.tenantId == tenantId && e.timestamp < beforeTimestamp)).array;
  }
}
///
unittest {  
  auto repository = new MemoryConfigChangeLogRepository();
  auto log = ConfigChangeLog();
  log.id = "log1";
  log.tenantId = "tenant1";
  log.changedBy = "user1";
  log.configType = "type1";
  log.timestamp = 1234567890;
  repository.save(log);

  assert(repository.existsByTenant(TenantId("tenant1")));
  assert(repository.findByTenant(TenantId("tenant1")).length == 1);
  assert(repository.existsByAuditLogId(TenantId("tenant1"), AuditLogId("log1")));
  assert(repository.findByAuditLogId(TenantId("tenant1"), AuditLogId("log1")).changedBy == UserId("user1"));
}