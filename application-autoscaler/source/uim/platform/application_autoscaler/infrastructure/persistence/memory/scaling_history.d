/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_autoscaler.infrastructure.persistence.memory.scaling_history;

import uim.platform.application_autoscaler;

mixin(ShowModule!());

@safe:

class MemoryScalingHistoryRepository : ScalingHistoryRepository {
  private ScalingHistoryEntity[string] store;

  override bool existsById(ScalingHistoryId id) {
    return (id in store) !is null;
  }

  override ScalingHistoryEntity findById(ScalingHistoryId id) {
    auto p = id in store;
    return p ? *p : ScalingHistoryEntity.init;
  }

  override ScalingHistoryEntity[] findByApp(AppBindingId appId) {
    ScalingHistoryEntity[] result;
    foreach (e; store.byValue)
      if (e.appId == appId) result ~= e;
    return result;
  }

  override ScalingHistoryEntity[] findByAppIdSince(AppBindingId appId, long sinceTimestamp) {
    ScalingHistoryEntity[] result;
    foreach (e; store.byValue)
      if (e.appId == appId && e.timestamp >= sinceTimestamp) result ~= e;
    return result;
  }

  override void save(ScalingHistoryEntity event) {
    store[event.id] = event;
  }

  override size_t countByApp(AppBindingId appId) {
    size_t n;
    foreach (e; store.byValue)
      if (e.appId == appId) n++;
    return n;
  }
}
