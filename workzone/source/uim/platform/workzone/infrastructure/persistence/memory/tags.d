/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.infrastructure.persistence.memory.tags;

import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.tag;
import uim.platform.workzone.domain.ports.repositories.tags;

// import std.algorithm : filter;
// import std.array : array;

class MemoryTagRepository : TagRepository {
  private Tag[TagId] store;

  Tag[] findByTenant(TenantId tenantId) {
    return store.byValue().filter!(t => t.tenantId == tenantId).array;
  }

  Tag* findById(TagId tenantId, id tenantId) {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        return p;
    return null;
  }

  Tag* findByName(string name, TenantId tenantId) {
    foreach (t; store.byValue())
      if (t.tenantId == tenantId && t.name == name)
        return &t;
    return null;
  }

  Tag[] findByParent(TagId parentTagtenantId, id tenantId) {
    return store.byValue().filter!(t => t.tenantId == tenantId && t.parentTagId == parentTagId).array;
  }

  void save(Tag tag) {
    store[tag.id] = tag;
  }

  void update(Tag tag) {
    store[tag.id] = tag;
  }

  void remove(TagId tenantId, id tenantId) {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        store.remove(id);
  }
}
