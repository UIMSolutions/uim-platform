/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.buildcode.domain.ports.usecases.pipelines;

import uim.platform.buildcode;

mixin(ShowModule!());

@safe:

interface IManagePipelinesUseCase {

  CommandResult create(TenantId tenantId, CreatePipelineRequest req);
  Pipeline getById(TenantId tenantId, string id);
  Pipeline[] list(TenantId tenantId);
  Pipeline[] listByProject(TenantId tenantId, string projectId);
  CommandResult update(TenantId tenantId, string id, UpdatePipelineRequest req);
  CommandResult remove(TenantId tenantId, string id);

}

