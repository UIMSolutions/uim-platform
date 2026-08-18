/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.domain.ports.usecases.datasets;

import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:
interface IManageDatasetsUseCase { 
  
  UsecaseResult registerDataset(RegisterDatasetRequest r);

  Dataset getDataset(TenantId tenantId, ConnectionId connectionId, DatasetId id);

  Dataset[] listDatasets(TenantId tenantId, ConnectionId connectionId);

  Dataset[] listDatasets(TenantId tenantId, ConnectionId connectionId, ScenarioId scenarioId);

  UsecaseResult patchDataset(PatchDatasetRequest r);

  UsecaseResult deleteDataset(TenantId tenantId, ConnectionId connectionId, DatasetId id);
  
}
