/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.domain.ports.repositories.feature_restrictions;

import uim.platform.mobile;

// mixin(Showmodule!());

@safe:

interface FeatureRestrictionRepository : ITentRepository!(FeatureRestriction, FeatureRestrictionId) {

  bool existsByKey(TenantId tenantId, MobileAppId appId, string featureKey);
  FeatureRestriction findByKey(TenantId tenantId, MobileAppId appId, string featureKey);
  void removeByKey(TenantId tenantId, MobileAppId appId, string featureKey);

  size_t countByApp(TenantId tenantId, MobileAppId appId);
  FeatureRestriction[] findByApp(TenantId tenantId, MobileAppId appId);
  void removeByApp(TenantId tenantId, MobileAppId appId);

  size_t countEnabled(TenantId tenantId, MobileAppId appId);
  FeatureRestriction[] findEnabled(TenantId tenantId, MobileAppId appId);
  void removeEnabled(TenantId tenantId, MobileAppId appId);

}
