/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.domain.ports.repositories.client_logs;

import uim.platform.mobile;

mixin(Showmodule!());

@safe:

interface ClientLogRepository : ITenantRepository!(ClientLogEntry, ClientLogEntryId) {

  size_t countByApp(TenantId tenantId, MobileAppId appId);
  ClientLogEntry[] findByApp(TenantId tenantId, MobileAppId appId);
  void removeByApp(TenantId tenantId, MobileAppId appId);

  size_t countByDevice(TenantId tenantId, DeviceRegistrationId deviceId);
  ClientLogEntry[] findByDevice(TenantId tenantId, DeviceRegistrationId deviceId);
  void removeByDevice(TenantId tenantId, DeviceRegistrationId deviceId);

  size_t countByLevel(TenantId tenantId, MobileAppId appId, LogLevel level);
  ClientLogEntry[] findByLevel(TenantId tenantId, MobileAppId appId, LogLevel level);
  void removeByLevel(TenantId tenantId, MobileAppId appId, LogLevel level);

}
