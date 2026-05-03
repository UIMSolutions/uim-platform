/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.infrastructure.persistence.memory.feature_restriction;

import uim.platform.mobile.domain.entities.feature_restriction;
import uim.platform.mobile.domain.ports.repositories.feature_restrictions;
import uim.platform.mobile.domain.types;

import std.algorithm : filter;
import std.array : array;

class MemoryFeatureRestrictionRepository : TenantRepository!(FeatureRestriction,FeatureRestrictionId), FeatureRestrictionRepository {

  bool existsByKey(MobileAppId appId, string featureKey) {
    return findByApp(appId).any!(r => r.featureKey == featureKey);
  }
  FeatureRestriction findByKey(MobileAppId appId, string featureKey) {
    foreach (r; findByApp(appId)) {
      if (r.featureKey == featureKey)
        return r;
    }
    return FeatureRestriction.init;
  }

  size_t countByApp(MobileAppId appId) {
    return findByApp(appId).length;
  }

  FeatureRestriction[] findByApp(MobileAppId appId) {
    return findAll().filter!(r => r.appId == appId).array;
  }
  void removeByApp(MobileAppId appId) {
    findByApp(appId).each!(r => remove(r));
  }

  size_t countEnabled(MobileAppId appId) {
    return findEnabled(appId).length;
  }
  FeatureRestriction[] findEnabled(MobileAppId appId) {
    return findByApp(appId).filter!(r => r.enabled).array;
  }
  void removeEnabled(MobileAppId appId) {
    findEnabled(appId).each!(r => remove(r));
  }

}
