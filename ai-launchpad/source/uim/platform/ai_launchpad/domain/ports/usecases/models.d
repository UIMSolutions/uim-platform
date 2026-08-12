/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.domain.ports.usecases.models;

import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:
interface IManageModelsUseCase { 

  CommandResult registerModel(RegisterModelRequest r);

  Model getModel(TenantId tenantId, ConnectionId connectionId, ModelId id);

  Model[] listModels(TenantId tenantId, ConnectionId connectionId);

  Model[] listModels(TenantId tenantId, ConnectionId connectionId, ScenarioId scenarioId);

  CommandResult patchModel(PatchModelRequest r);

  CommandResult deleteModel(TenantId tenantId, ConnectionId connectionId, ModelId id);
  
}
