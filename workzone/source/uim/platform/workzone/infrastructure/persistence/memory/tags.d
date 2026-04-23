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

class MemoryTagRepository : TenantRepository!(Tag, TagId), TagRepository {

  // #region ByName
  bool existsByName(TenantId tenantId, string name) {
    return findByTenant(tenantId).any!(t => t.name == name);
  }

  Tag findByName(TenantId tenantId, string name) {
    foreach (t; findByTenant(tenantId))
      if (t.name == name)
        return t;
    return Tag.init;
  }

  void removeByName(TenantId tenantId, string name) {
    foreach (t; findByTenant(tenantId))
      if (t.name == name) {
        store.remove(t);
        break;
      }
  }
  // #endregion ByName

  // #region ByParent
  size_t countByParent(TenantId tenantId, TagId parentTagId) {
    return findByParent(tenantId, parentTagId).length;
  }

  Tag[] findByParent(TenantId tenantId, TagId parentTagId) {
    return findByTenant(tenantId).filter!(t => t.parentTagId == parentTagId).array;
  }

  void removeByParent(TenantId tenantId, TagId parentTagId) {
    findByParent(tenantId, parentTagId).each!(t => remove(t));
  }
  // #endregion ByParent
}
