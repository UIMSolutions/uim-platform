/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.buildcode.domain.ports.usecases.projects;

import uim.platform.buildcode;

mixin(ShowModule!());

@safe:

interface IManageProjectsUseCase {
  
  UsecaseResult create(TenantId tenantId, CreateProjectRequest req);
  Project getById(TenantId tenantId, string id);
  Project[] list(TenantId tenantId);
  Project[] listByStatus(TenantId tenantId, string statusStr);
  UsecaseResult update(TenantId tenantId, string id, UpdateProjectRequest req);
  UsecaseResult remove(TenantId tenantId, string id);

}

