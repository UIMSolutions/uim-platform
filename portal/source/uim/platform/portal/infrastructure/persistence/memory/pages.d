/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.infrastructure.persistence.memory.pages;

// import uim.platform.portal.domain.entities.page;
// import uim.platform.portal.domain.types;
// import uim.platform.portal.domain.ports.repositories.pages;

import uim.platform.portal;

mixin(ShowModule!());

@safe:
class MemoryPageRepository : PageRepository {
  private Page[PageId] store;

  Page findById(PageId id) {
    if (auto p = id in store)
      return *p;
    return Page.init;
  }

  Page[] findBySite(SiteId siteId, uint offset = 0, uint limit = 100) {
    Page[] result;
    uint idx;
    foreach (p; store.byValue()) {
      if (p.siteId == siteId) {
        if (idx >= offset && result.length < limit)
          result ~= p;
        idx++;
      }
    }
    return result;
  }

  Page findByAlias(SiteId siteId, string alias_) {
    foreach (p; store.byValue()) {
      if (p.siteId == siteId && p.alias_ == alias_)
        return p;
    }
    return Page.init;
  }

  void save(Page page) {
    store[page.id] = page;
  }

  void update(Page page) {
    store[page.id] = page;
  }

  void remove(PageId id) {
    store.remove(id);
  }
}
