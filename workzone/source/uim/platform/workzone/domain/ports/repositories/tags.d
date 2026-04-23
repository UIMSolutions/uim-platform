/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.ports.repositories.tags;

// import uim.platform.workzone.domain.types;
// import uim.platform.workzone.domain.entities.tag;
import uim.platform.workzone;

mixin(ShowModule!());

@safe:
interface TagRepository : ITenantRepository!(Tag, TagId) {

  bool existsByName(TenantId tenantId, string name);
  Tag findByName(TenantId tenantId, string name);
  void removeByName(TenantId tenantId, string name);

  size_t countByParent(TenantId tenantId, TagId parentTag);
  Tag[] findByParent(TenantId tenantId, TagId parentTag);
  void removeByParent(TenantId tenantId, TagId parentTag);

}
