/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.ports.repositories.tags;

import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.tag;

interface TagRepository {
  Tag[] findByTenant(TenantId tenantId);
  Tag* findById(TagId id, TenantId tenantId);
  Tag* findByName(string name, TenantId tenantId);
  Tag[] findByParent(TagId parentTagId, TenantId tenantId);
  void save(Tag tag);
  void update(Tag tag);
  void remove(TagId id, TenantId tenantId);
}
