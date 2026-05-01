/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.infrastructure.persistence.memory.sections;

// import uim.platform.portal.domain.entities.section;
// import uim.platform.portal.domain.types;
// import uim.platform.portal.domain.ports.repositories.sections;

import uim.platform.portal;

mixin(ShowModule!());

@safe:
class MemorySectionRepository : SectionRepository {
  private PortalSection[SectionId] store;

  bool existsById(SectionId id) {
    return id in store ? true : false;
  }

  PortalSection findById(SectionId id) {
    return existsById(id) ? store[id] : PortalSection.init;
  }

  PortalSection[] findByPage(PageId pageId) {
    return findAll()r!(s => s.pageId == pageId).array;
  }

  void save(PortalSection section) {
    store[section.id] = section;
  }

  void update(PortalSection section) {
    store[section.id] = section;
  }

  void remove(SectionId id) {
    store.removeById(id);
  }
}
