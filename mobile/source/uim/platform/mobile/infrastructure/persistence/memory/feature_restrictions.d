/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.infrastructure.persistence.memory.feature_restrictions;
// import uim.platform.mobile.domain.entities.feature_restriction;
// import uim.platform.mobile.domain.ports.repositories.feature_restrictions;


import uim.platform.mobile;

// mixin(Showmodule!());

@safe:

class MemoryFeatureRestrictionRepository : TenantRepository!(FeatureRestriction,FeatureRestrictionId), FeatureRestrictionRepository {

  bool existsByKey(TenantId tenantId, MobileAppId appId, string featureKey) {
    return findByApp(tenantId, appId).any!(r => r.featureKey == featureKey);
  }
  FeatureRestriction findByKey(TenantId tenantId, MobileAppId appId, string featureKey) {
    foreach (r; findByApp(tenantId, appId)) {
      if (r.featureKey == featureKey)
        return r;
    }
    return FeatureRestriction.init;
  }

  size_t countByApp(TenantId tenantId, MobileAppId appId) {
    return findByApp(tenantId, appId).length;
  }

  FeatureRestriction[] findByApp(TenantId tenantId, MobileAppId appId) {
    return findByTenant(tenantId).filter!(r => r.appId == appId).array;
  }
  void removeByApp(TenantId tenantId, MobileAppId appId) {
    findByApp(tenantId, appId).each!(r => remove(r));
  }

  size_t countEnabled(TenantId tenantId, MobileAppId appId) {
    return findEnabled(tenantId, appId).length;
  }
  FeatureRestriction[] findEnabled(TenantId tenantId, MobileAppId appId) {
    return findByApp(tenantId, appId).filter!(r => r.enabled).array;
  }
  void removeEnabled(TenantId tenantId, MobileAppId appId) {
    findEnabled(tenantId, appId).each!(r => remove(r));
  }

}
