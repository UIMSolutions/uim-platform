/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.domain.ports.offline_config_repository;

import uim.platform.mobile.domain.entities.offline_config;
import uim.platform.mobile.domain.types;

/// Port: outgoing — offline configuration persistence.
interface OfflineConfigRepository
{
  OfflineConfig findById(OfflineConfigId id);
  OfflineConfig[] findByApp(MobileAppId appId);
  void save(OfflineConfig config);
  void update(OfflineConfig config);
  void remove(OfflineConfigId id);
}
