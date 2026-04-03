/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.domain.ports.feature_toggle_repository;

import uim.platform.mobile.domain.entities.feature_toggle;
import uim.platform.mobile.domain.types;

/// Port: outgoing — feature toggle persistence.
interface FeatureToggleRepository
{
  FeatureToggle findById(FeatureToggleId id);
  FeatureToggle findByKey(MobileAppId appId, string key);
  FeatureToggle[] findByApp(MobileAppId appId);
  FeatureToggle[] findByStatus(MobileAppId appId, ToggleStatus status);
  void save(FeatureToggle toggle);
  void update(FeatureToggle toggle);
  void remove(FeatureToggleId id);
}
