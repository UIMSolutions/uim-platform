/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.buildcode.application.usecases.manage.templates;

import uim.platform.buildcode;

mixin(ShowModule!());

@safe:

interface IManageTemplatesUseCase {

  CommandResult create(TenantId tenantId, CreateTemplateRequest req);
  ProjectTemplate getById(TenantId tenantId, string id);
  ProjectTemplate[] list(TenantId tenantId);
  ProjectTemplate[] listByProjectType(TenantId tenantId, string typeStr);
  ProjectTemplate[] listBuiltIn(TenantId tenantId);
  CommandResult remove(TenantId tenantId, string id);

}
