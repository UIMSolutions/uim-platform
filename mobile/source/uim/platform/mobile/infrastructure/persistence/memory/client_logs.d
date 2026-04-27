/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.infrastructure.persistence.memory.client_log;

import uim.platform.mobile.domain.entities.client_log_entry;
import uim.platform.mobile.domain.ports.repositories.client_logs;
import uim.platform.mobile.domain.types;

import std.algorithm : filter;
import std.array : array;

class MemoryClientLogRepository : TenantRepository!(ClientLogEntry, ClientLogEntryId), ClientLogRepository {

  size_t countByApp(MobileAppId appId) {
    return findByApp(appId).length;
  }
  ClientLogEntry[] filterByApp(ClientLogEntry[] entries, MobileAppId appId) {
    return entries.filter!(e => e.appId == appId).array;
  }
  ClientLogEntry[] findByApp(MobileAppId appId) {
    return filterByApp(findAll(), appId);
  }
  void removeByApp(MobileAppId appId) {
    findByApp(appId).each!(e => remove(e));
  }

  size_t countByDevice(DeviceRegistrationId deviceId) {
    return findByDevice(deviceId).length;
  }
  ClientLogEntry[] filterByDevice(ClientLogEntry[] entries, DeviceRegistrationId deviceId) {
    return entries.filter!(e => e.deviceId == deviceId).array;
  }
  ClientLogEntry[] findByDevice(DeviceRegistrationId deviceId) {
    return filterByDevice(findAll(), deviceId);
  }
  void removeByDevice(DeviceRegistrationId deviceId) {
    findByDevice(deviceId).each!(e => remove(e));
  }

  size_t countByLevel(MobileAppId appId, LogLevel level) {
    return findByLevel(appId, level).length;
  }
  ClientLogEntry[] filterByLevel(ClientLogEntry[] entries, MobileAppId appId, LogLevel level) {
    return entries.filter!(e => e.appId == appId && e.level == level).array;
  }
  ClientLogEntry[] findByLevel(MobileAppId appId, LogLevel level) {
    return filterByLevel(findByApp(appId), appId, level);
  }
  void removeByLevel(MobileAppId appId, LogLevel level) {
    findByLevel(appId, level).each!(e => remove(e));
  }

}
