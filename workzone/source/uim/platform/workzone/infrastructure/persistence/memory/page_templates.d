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

class MemoryPageTemplateRepository : PageTemplateRepository {
  private PageTemplate[PageTemplateId] store;

  PageTemplate[] findByTenant(TenantId tenantId) {
    return store.byValue().filter!(t => t.tenantId == tenantId).array;
  }

  PageTemplate* findById(PageTemplateId tenantId, id tenantId) {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        return p;
    return null;
  }

  PageTemplate* findDefault(TenantId tenantId) {
    foreach (t; store.byValue())
      if (t.tenantId == tenantId && t.isDefault)
        return &t;
    return null;
  }

  PageTemplate[] findPublic() {
    return store.byValue().filter!(t => t.isPublic).array;
  }

  void save(PageTemplate template_) {
    store[template_.id] = template_;
  }

  void update(PageTemplate template_) {
    store[template_.id] = template_;
  }

  void remove(PageTemplateId tenantId, id tenantId) {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        store.remove(id);
  }
}
