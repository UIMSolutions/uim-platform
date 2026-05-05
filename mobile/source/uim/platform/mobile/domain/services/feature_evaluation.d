/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.domain.services.feature_evaluation;

import uim.platform.mobile.domain.types;
import uim.platform.mobile.domain.entities.feature_restriction;

struct FeatureEvaluationService {
  // Evaluate whether a feature is enabled for a given user/device
  static bool isFeatureEnabled(FeatureRestriction restriction, string userId, string deviceId) {
    if (!restriction.enabled)
      return false;

    final switch (restriction.type) {
    case RestrictionType.boolean_:
      return true; // simply enabled

    case RestrictionType.percentage:
      return evaluatePercentage(restriction.percentage, userId);

    case RestrictionType.whitelist:
      return isInWhitelist(restriction.whitelist, userId, deviceId);
    }
  }

  // Percentage-based evaluation using a hash of the user ID
  private static bool evaluatePercentage(int percentage, string userId) {
    if (percentage >= 100)
      return true;
    if (percentage <= 0)
      return false;

    // Simple hash-based bucketing
    size_t hash = 0;
    foreach (c; userId) {
      hash = hash * 31 + cast(size_t) c;
    }
    return (hash % 100) < cast(size_t) percentage;
  }

  // Check if user or device is in whitelist
  private static bool isInWhitelist(string[] whitelist, string userId, string deviceId) {
    foreach (entry; whitelist) {
      if (entry == userId || entry == deviceId)
        return true;
    }
    return false;
  }

  // Validate feature key
  static bool validateFeatureKey(string key) {
    if (key.length == 0 || key.length > 255)
      return false;
    import std.regex : regex, matchAll;

    auto pat = regex(`^[a-zA-Z0-9_\-.]+$`);
    auto m = matchAll(key, pat);
    return !m.empty;
  }
}
