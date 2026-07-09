/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.domain.entities.feature_restriction;

import uim.platform.mobile;

// mixin(Showmodule!());

@safe:

struct FeatureRestriction {
  mixin TenantEntity!(FeatureRestrictionId);

  string description;
  bool enabled;
  MobileAppId appId;
  string featureKey;
  RestrictionType type;
  int percentage; // for gradual rollout (0-100)
  string[] whitelist; // user/device IDs for whitelist type
  string metadata; // JSON additional config
  UserId[] allowedUsers;
  string[] allowedDevices;
  string minAppVersion;
  string maxAppVersion;
  Date startDate;
  Date endDate;

  Json toJson() const {
    return entityToJson
      .set("appId", appId.value)
      .set("featureKey", featureKey)
      .set("description", description)
      .set("type", type.to!string)
      .set("enabled", enabled)
      .set("percentage", percentage)
      .set("whitelist", whitelist.array.toJson)
      .set("metadata", metadata);
  }
}
