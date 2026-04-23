/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.domain.ports.repositories.client_logs;

import uim.platform.mobile.domain.entities.client_log_entry;
import uim.platform.mobile.domain.types;

interface ClientLogRepository : ITenantRepository!(ClientLogEntry, ClientLogEntryId) {

  size_t countByApp(MobileAppId appId);
  ClientLogEntry[] findByApp(MobileAppId appId);
  void removeByApp(MobileAppId appId);

  size_t countByDevice(DeviceRegistrationId deviceId);
  ClientLogEntry[] findByDevice(DeviceRegistrationId deviceId);
  void removeByDevice(DeviceRegistrationId deviceId);

  size_t countByLevel(MobileAppId appId, LogLevel level);
  ClientLogEntry[] findByLevel(MobileAppId appId, LogLevel level);
  void removeByLevel(MobileAppId appId, LogLevel level);

}
