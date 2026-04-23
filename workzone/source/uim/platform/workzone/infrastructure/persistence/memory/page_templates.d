/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.infrastructure.persistence.memory.page_templates;

import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.page_template;
import uim.platform.workzone.domain.ports.repositories.page_templates;

// import std.algorithm : filter;
// import std.array : array;

class MemoryPageTemplateRepository : TenantRRepository!(PageTemplate, PageTemplateId), PageTemplateRepository {

  bool existsDefault(TenantId tenantId) {
    return findByTenant(tenantId).any!(t => t.isDefault);
  }

  PageTemplate findDefault(TenantId tenantId) {
    foreach (t; findByTenant(tenantId))
      if (t.isDefault)
        return t;
    return PageTemplate.init;
  }

  void removeDefault(TenantId tenantId) {
    foreach (t; findByTenant(tenantId))
      if (t.isDefault) {
        remove(t);
        break;
      }
  }

  size_t countPublic() {
    return findPublic().length;
  }

  PageTemplate[] findPublic() {
    return store.byValue().filter!(t => t.isPublic).array;
  }

  void removePublic() {
    findPublic().each!(t => remove(t));
  }

}
