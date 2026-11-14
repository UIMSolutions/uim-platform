/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.service_manager.ports.usecases.manage_platforms;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

interface IManagePlatforms {
  Platform[] listPlatforms(TenantId tenantId);
  Platform getPlatform(TenantId tenantId, PlatformId id);
  Platform registerPlatform(RegisterPlatformRequest request);
  Platform updatePlatform(UpdatePlatformRequest request);
  /// Refused while service instances are provisioned for the platform.
  void deregisterPlatform(TenantId tenantId, PlatformId id);
}
