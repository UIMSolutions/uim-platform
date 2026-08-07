/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_autoscaler.domain.ports.usecases.scaling_history;

import uim.platform.application_autoscaler;

mixin(ShowModule!());

@safe:

interface IManageScalingHistoryUseCase {

  ScalingHistory[] getHistory(TenantId tenantId, AppBindingId appId);
  ScalingHistory[] getHistorySince(TenantId tenantId, AppBindingId appId, long sinceTimestamp);
  ScalingHistory getEvent(TenantId tenantId, ScalingHistoryId id);

}
