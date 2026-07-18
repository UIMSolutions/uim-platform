/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.buildcode.infrastructure.persistence.repositories.templates;

import uim.platform.buildcode;

mixin(ShowModule!());

@safe:

class MemoryTemplateRepository : TemplateRepository {
  private ProjectTemplate[string] _store;

  override void save(ProjectTemplate entity)              { _store[entity.id.value] = entity; }
  override void update(ProjectTemplate entity)            { _store[entity.id.value] = entity; }
  override void remove(TenantId tenantId, TemplateId id)    { _store.remove(id.value); }

  override ProjectTemplate findById(TenantId tenantId, TemplateId id) {
    if (id.value in _store) return _store[id.value];
    ProjectTemplate t; return t;
  }

  override ProjectTemplate[] findByTenant(TenantId tenantId) {
    ProjectTemplate[] result;
    foreach (t; _store.byValue)
      if (t.tenantId == tenantId) result ~= t;
    return result;
  }

  override ProjectTemplate[] findByProjectType(TenantId tenantId, ProjectType type) {
    ProjectTemplate[] result;
    foreach (t; _store.byValue)
      if (t.tenantId == tenantId && t.projectType == type) result ~= t;
    return result;
  }

  override ProjectTemplate[] findByTechStack(TenantId tenantId, TechStack stack) {
    ProjectTemplate[] result;
    foreach (t; _store.byValue)
      if (t.tenantId == tenantId && t.techStack == stack) result ~= t;
    return result;
  }

  override ProjectTemplate[] findBuiltIn(TenantId tenantId) {
    ProjectTemplate[] result;
    foreach (t; _store.byValue)
      if (t.tenantId == tenantId && t.isBuiltIn) result ~= t;
    return result;
  }
}
