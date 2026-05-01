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

class MemoryFeatureRestrictionRepository : FeatureRestrictionRepository {
  private FeatureRestriction[FeatureRestrictionId] store;

  bool existsById(FeatureRestrictionId id) {
    return id in store ? true : false;
  }

  FeatureRestriction findById(FeatureRestrictionId id) {
    return existsById(id) ? store[id] : FeatureRestriction.init;
  }

  FeatureRestriction findByKey(MobileAppId appId, string featureKey) {
    foreach (r; findByApp(appId)) {
      if (r.featureKey == featureKey)
        return r;
    }
    return FeatureRestriction.init;
  }

  FeatureRestriction[] findByApp(MobileAppId appId) {
    return store.values.filter!(r => r.appId == appId).array;
  }

  FeatureRestriction[] findEnabled(MobileAppId appId) {
    return findByApp(appId).filter!(r => r.enabled).array;
  }

  FeatureRestriction[] findByTenant(TenantId tenantId) {
    return store.values.filter!(r => r.tenantId == tenantId).array;
  }

  void save(FeatureRestriction restriction) {
    store[restriction.id] = restriction;
  }

  void update(FeatureRestriction restriction) {
    store[restriction.id] = restriction;
  }

  void remove(FeatureRestrictionId id) {
    store.removeById(id);
  }

  size_t countByApp(MobileAppId appId) {
    return store.values.filter!(r => r.appId == appId).array.length;
  }
}
