/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.domain.ports.feature_restriction_repository;

import uim.platform.mobile.domain.entities.feature_restriction;
import uim.platform.mobile.domain.types;

interface FeatureRestrictionRepository {
  FeatureRestriction findById(FeatureRestrictionId id);
  FeatureRestriction findByKey(MobileAppId appId, string featureKey);
  FeatureRestriction[] findByApp(MobileAppId appId);
  FeatureRestriction[] findEnabled(MobileAppId appId);
  FeatureRestriction[] findByTenant(TenantId tenantId);
  void save(FeatureRestriction restriction);
  void update(FeatureRestriction restriction);
  void remove(FeatureRestrictionId id);
  long countByApp(MobileAppId appId);
}
