/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.domain.ports.client_logs;

import uim.platform.mobile.domain.entities.client_log_entry;
import uim.platform.mobile.domain.types;

interface ClientLogRepository {
  ClientLogEntry findById(ClientLogEntryId id);
  ClientLogEntry[] findByApp(MobileAppId appId);
  ClientLogEntry[] findByDevice(DeviceRegistrationId deviceId);
  ClientLogEntry[] findByLevel(MobileAppId appId, LogLevel level);
  ClientLogEntry[] findByTenant(TenantId tenantId);
  void save(ClientLogEntry entry);
  void remove(ClientLogEntryId id);
  long countByApp(MobileAppId appId);
  long countByTenant(TenantId tenantId);
}
