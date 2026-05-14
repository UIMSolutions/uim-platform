/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.infrastructure.persistence.memory.client_log;

// import uim.platform.mobile.domain.entities.client_log_entry;
// import uim.platform.mobile.domain.ports.repositories.client_logs;
// import uim.platform.mobile.domain.types;

import uim.platform.mobile;

mixin(Showmodule!());

@safe:

class MemoryClientLogRepository : TenantRepository!(ClientLogEntry, ClientLogEntryId), ClientLogRepository {

  size_t countByApp(TenantId tenantId, MobileAppId appId) {
    return findByApp(tenantId, appId).length;
  }
  ClientLogEntry[] filterByApp(ClientLogEntry[] entries, MobileAppId appId) {
    return entries.filter!(e => e.appId == appId).array;
  }
  ClientLogEntry[] findByApp(TenantId tenantId, MobileAppId appId) {
    return filterByApp(findByTenant(tenantId), appId);
  }
  void removeByApp(TenantId tenantId, MobileAppId appId) {
    findByApp(tenantId, appId).each!(e => remove(e));
  }

  size_t countByDevice(TenantId tenantId, DeviceRegistrationId deviceId) {
    return findByDevice(tenantId, deviceId).length;
  }
  ClientLogEntry[] filterByDevice(ClientLogEntry[] entries, DeviceRegistrationId deviceId) {
    return entries.filter!(e => e.deviceId == deviceId).array;
  }
  ClientLogEntry[] findByDevice(TenantId tenantId, DeviceRegistrationId deviceId) {
    return filterByDevice(findByTenant(tenantId), deviceId);
  }
  void removeByDevice(TenantId tenantId, DeviceRegistrationId deviceId) {
    findByDevice(tenantId, deviceId).each!(e => remove(e));
  }

  size_t countByLevel(TenantId tenantId, MobileAppId appId, LogLevel level) {
    return findByLevel(tenantId, appId, level).length;
  }
  ClientLogEntry[] filterByLevel(ClientLogEntry[] entries, MobileAppId appId, LogLevel level) {
    return entries.filter!(e => e.appId == appId && e.level == level).array;
  }
  ClientLogEntry[] findByLevel(TenantId tenantId, MobileAppId appId, LogLevel level) {
    return filterByLevel(findByApp(tenantId, appId), appId, level);
  }
  void removeByLevel(TenantId tenantId, MobileAppId appId, LogLevel level) {
    findByLevel(tenantId, appId, level).each!(e => remove(e));
  }

}
