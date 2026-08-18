/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.buildcode.domain.ports.usecases.templates;

import uim.platform.buildcode;

mixin(ShowModule!());

@safe:

interface IManageTemplatesUseCase {

  UsecaseResult create(TenantId tenantId, CreateTemplateRequest req);
  ProjectTemplate getById(TenantId tenantId, string id);
  ProjectTemplate[] list(TenantId tenantId);
  ProjectTemplate[] listByProjectType(TenantId tenantId, string typeStr);
  ProjectTemplate[] listBuiltIn(TenantId tenantId);
  UsecaseResult remove(TenantId tenantId, string id);

}
