/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.buildcode.domain.ports.usecases.devspaces;

import uim.platform.buildcode;

mixin(ShowModule!());

@safe:

interface IManageDevSpacesUseCase {

  CommandResult create(TenantId tenantId, CreateDevSpaceRequest req);
  DevSpace getById(TenantId tenantId, string id);
  DevSpace[] listByProject(TenantId tenantId, string projectId);
  DevSpace[] list(TenantId tenantId);
  CommandResult setStatus(TenantId tenantId, string id, string statusStr);
  CommandResult remove(TenantId tenantId, string id);

}
