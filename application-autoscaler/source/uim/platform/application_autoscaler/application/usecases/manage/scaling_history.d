/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_autoscaler.application.usecases.manage.scaling_history;

import uim.platform.application_autoscaler;

// mixin(ShowModule!());

@safe:

class ManageScalingHistoryUseCase {
  private ScalingHistoryRepository repo;

  this(ScalingHistoryRepository repo) {
    this.repo = repo;
  }

  ScalingHistory[] getHistory(AppBindingId appId) {
    return repo.findByApp(appId);
  }

  ScalingHistory[] getHistorySince(AppBindingId appId, long sinceTimestamp) {
    return repo.findByAppIdSince(appId, sinceTimestamp);
  }

  ScalingHistory getEvent(ScalingHistoryId id) {
    return repo.findById(id);
  }
}
