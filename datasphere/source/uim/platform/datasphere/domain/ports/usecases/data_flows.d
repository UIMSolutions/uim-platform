/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.domain.ports.usecases.data_flows;

import uim.platform.datasphere;

mixin(ShowModule!()); 

@safe:
interface IManageDataFlowsUseCase { 

  CommandResult createDataFlow(CreateDataFlowRequest r);
  DataFlow getDataFlow(TenantId tenantId, SpaceId spaceId, DataFlowId id);
  DataFlow[] listDataFlows(TenantId tenantId, SpaceId spaceId);
  CommandResult patchDataFlow(PatchDataFlowRequest r);
  CommandResult deleteDataFlow(TenantId tenantId, SpaceId spaceId, DataFlowId id);

}
