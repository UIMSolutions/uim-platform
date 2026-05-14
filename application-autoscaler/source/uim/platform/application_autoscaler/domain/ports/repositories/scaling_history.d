/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_autoscaler.domain.ports.repositories.scaling_history;

import uim.platform.application_autoscaler;

mixin(ShowModule!());

@safe:

interface ScalingHistoryRepository {
  bool                   existsById(ScalingHistoryId id);
  ScalingHistoryEntity   findById(ScalingHistoryId id);
  ScalingHistoryEntity[] findByAppId(AppBindingId appId);
  ScalingHistoryEntity[] findByAppIdSince(AppBindingId appId, long sinceTimestamp);
  void save(ScalingHistoryEntity event);
  size_t countByAppId(AppBindingId appId);
}
