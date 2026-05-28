/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.buildcode.domain.ports.repositories.templates;

import uim.platform.buildcode;

mixin(ShowModule!());

@safe:

interface TemplateRepository : ITenantRepository!(ProjectTemplate, TemplateId) {
  ProjectTemplate[]  findByProjectType(TenantId tenantId, ProjectType type);
  ProjectTemplate[]  findByTechStack(TenantId tenantId, TechStack stack);
  ProjectTemplate[]  findBuiltIn(TenantId tenantId);
}
