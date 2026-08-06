/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.buildcode.infrastructure.persistence.repositories.templates;

import uim.platform.buildcode;

mixin(ShowModule!());

@safe:

class TemplateRepository : TenantRepository!(ProjectTemplate, TemplateId), ITemplateRepository {

  size_t countByProjectType(TenantId tenantId, ProjectType type) {
    return findByProjectType(tenantId, type).length;
  }

  ProjectTemplate[] filterByProjectType(ProjectTemplate[] templates, ProjectType type) {
    return templates.filter!(t => t.projectType == type).array;
  }

  ProjectTemplate[] findByProjectType(TenantId tenantId, ProjectType type) {
    return filterByProjectType(findByTenant(tenantId), type);
  }

  void removeByProjectType(TenantId tenantId, ProjectType type) {
    findByProjectType(tenantId, type).each!(t => remove(t));
  }

  size_t countByTechStack(TenantId tenantId, TechStack stack) {
    return findByTechStack(tenantId, stack).length;
  }

  ProjectTemplate[] filterByTechStack(ProjectTemplate[] templates, TechStack stack) {
    return templates.filter!(t => t.techStack == stack).array;
  }

  ProjectTemplate[] findByTechStack(TenantId tenantId, TechStack stack) {
    return filterByTechStack(findByTenant(tenantId), stack);
  }

  void removeByTechStack(TenantId tenantId, TechStack stack) {
    findByTechStack(tenantId, stack).each!(t => remove(t));
  }

  ProjectTemplate[] findBuiltIn(TenantId tenantId) {
    return findByTenant(tenantId).filter!(t => t.isBuiltIn).array;
  }
  
}
