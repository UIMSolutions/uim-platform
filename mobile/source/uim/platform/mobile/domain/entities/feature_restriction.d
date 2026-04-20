/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.domain.entities.feature_restriction;

import uim.platform.mobile.domain.types;

struct FeatureRestriction {
  mixin TenantEntity!(FeatureRestrictionId);

  MobileAppId appId;
  string featureKey;
  string description;
  RestrictionType type;
  bool enabled;
  int percentage;           // for gradual rollout (0-100)
  string[] whitelist;       // user/device IDs for whitelist type
  string metadata;          // JSON additional config
  
  Json toJson() const {
      return entityToJson
          .set("appId", appId.value)
          .set("featureKey", featureKey)
          .set("description", description)
          .set("type", type.to!string)
          .set("enabled", enabled)
          .set("percentage", percentage)
          .set("whitelist", whitelist.array)
          .set("metadata", metadata);
  }
}
