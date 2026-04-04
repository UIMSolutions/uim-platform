/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.infrastructure.persistence.memory.client_log_repo;

import uim.platform.mobile.domain.entities.client_log_entry;
import uim.platform.mobile.domain.ports.repositories.client_logs;
import uim.platform.mobile.domain.types;

import std.algorithm : filter;
import std.array : array;

class MemoryClientLogRepository : ClientLogRepository {
  private ClientLogEntry[ClientLogEntryId] store;

  ClientLogEntry findById(ClientLogEntryId id) {
    if (auto p = id in store)
      return *p;
    return ClientLogEntry.init;
  }

  ClientLogEntry[] findByApp(MobileAppId appId) {
    return store.values.filter!(e => e.appId == appId).array;
  }

  ClientLogEntry[] findByDevice(DeviceRegistrationId deviceId) {
    return store.values.filter!(e => e.deviceId == deviceId).array;
  }

  ClientLogEntry[] findByLevel(MobileAppId appId, LogLevel level) {
    return store.values.filter!(e => e.appId == appId && e.level == level).array;
  }

  ClientLogEntry[] findByTenant(TenantId tenantId) {
    return store.values.filter!(e => e.tenantId == tenantId).array;
  }

  void save(ClientLogEntry entry) {
    store[entry.id] = entry;
  }

  void remove(ClientLogEntryId id) {
    store.remove(id);
  }

  long countByApp(MobileAppId appId) {
    return cast(long) store.values.filter!(e => e.appId == appId).array.length;
  }

  long countByTenant(TenantId tenantId) {
    return cast(long) store.values.filter!(e => e.tenantId == tenantId).array.length;
  }
}
