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

  bool existsById(PageId id) {
    return (id in store) ? true : false;
  }

  Page findById(PageId id) {
    return existsById(id) ? store[id] : Page.init;
  }

  bool existsByAlias(SiteId siteId, string alias_) {
    return findAll()p => p.siteId == siteId && p.alias_ == alias_);
  }

  Page findByAlias(SiteId siteId, string alias_) {
    return findAll().filter!(p => p.siteId == siteId && p.alias_ == alias_).array;
  }

  Page[] findBySite(SiteId siteId, size_t offset = 0, size_t limit = 100) {
    Page[] result;
    size_t idx;
    foreach (p; findAll()
      if (p.siteId == siteId) {
        if (idx >= offset && result.length < limit)
          result ~= p;
        idx++;
      }
    }
    return result;
  }

  void save(Page page) {
    store[page.id] = page;
  }

  void update(Page page) {
    store[page.id] = page;
  }

  void remove(PageId id) {
    removeById(id);
  }
}
