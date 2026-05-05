/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.master_data_integration.infrastructure.persistence.memory.key_mapping;

import uim.platform.master_data_integration.domain.types;
import uim.platform.master_data_integration.domain.entities.key_mapping;
import uim.platform.master_data_integration.domain.ports.repositories.key_mappings;

// import std.algorithm : filter;
// import std.array : array;

class MemoryKeyMappingRepository : TenantRepository!(KeyMapping, KeyMappingId), KeyMappingRepository {

  KeyMapping findByClientKey(TenantId tenantId, ClientId clientId, string localKey) {
    foreach (mapping; findByTenant(tenantId)) {
      foreach (entry; mapping.entries) {
        if (entry.clientId == clientId && entry.localKey == localKey)
          return mapping;
      }
    }
    return KeyMapping.init;
  }

  size_t countByObjectId(TenantId tenantId, MasterDataObjectId objectId) {
    return findByObjectId(tenantId, objectId).length;
  }
  KeyMapping[] filterByObjectId(KeyMapping[] mappings, MasterDataObjectId objectId) {
    return mappings.filter!(e => e.masterDataObjectId == objectId).array;
  }
  KeyMapping[] findByObjectId(TenantId tenantId, MasterDataObjectId objectId) {
    return filterByObjectId(findByTenant(tenantId), objectId);
  }
  void removeByObjectId(TenantId tenantId, MasterDataObjectId objectId) {
    findByObjectId(tenantId, objectId).each!(entity => remove(entity));
  }

   size_t countByCategory(TenantId tenantId, MasterDataCategory category) {
    return findByCategory(tenantId, category).length;
  }
  KeyMapping[] filterByCategory(KeyMapping[] mappings, MasterDataCategory category) {
    return mappings.filter!(e => e.category == category).array;
  }

  KeyMapping[] findByCategory(TenantId tenantId, MasterDataCategory category) {
    return filterByCategory(findByTenant(tenantId), category);
  }
  void removeByCategory(TenantId tenantId, MasterDataCategory category) {
    findByCategory(tenantId, category).each!(entity => remove(entity));
  }

}
