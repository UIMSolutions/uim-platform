/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.domain.ports.repositories.feature_restrictions;

import uim.platform.mobile.domain.entities.feature_restriction;
import uim.platform.mobile.domain.types;

interface FeatureRestrictionRepository {

  bool existsByKey(MobileAppId appId, string featureKey);
  FeatureRestriction findByKey(MobileAppId appId, string featureKey);
  void removeByKey(MobileAppId appId, string featureKey);

  size_t countByApp(MobileAppId appId);
  FeatureRestriction[] findByApp(MobileAppId appId);
  void removeByApp(MobileAppId appId);

  size_t countEnabled(MobileAppId appId);
  FeatureRestriction[] findEnabled(MobileAppId appId);
  void removeEnabled(MobileAppId appId);

}
