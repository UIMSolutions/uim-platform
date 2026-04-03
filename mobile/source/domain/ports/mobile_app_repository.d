/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.domain.ports.mobile_app_repository;

import uim.platform.mobile.domain.entities.mobile_app;
import uim.platform.mobile.domain.types;

/// Port: outgoing — mobile app persistence.
interface MobileAppRepository
{
  MobileApp findById(MobileAppId id);
  MobileApp[] findByTenant(TenantId tenantId);
  MobileApp[] findByStatus(TenantId tenantId, AppStatus status);
  MobileApp findByBundleId(TenantId tenantId, string bundleId);
  void save(MobileApp app);
  void update(MobileApp app);
  void remove(MobileAppId id);
}
