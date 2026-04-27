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

  KeyMapping[] findByTenant(TenantId tenantId) {
    return findAll()r!(e => e.tenantId == tenantId).array;
  }

  KeyMapping[] findByObjectId(TenantId tenantId, MasterDataObjectId objectId) {
    return findAll()r!(e => e.tenantId == tenantId
        && e.masterDataObjectId == objectId).array;
  }

  KeyMapping[] findByCategory(TenantId tenantId, MasterDataCategory category) {
    return findAll()r!(e => e.tenantId == tenantId && e.category == category).array;
  }

  KeyMapping findByClientKey(TenantId tenantId, ClientId clientId, string localKey) {
    foreach (mapping; findAll()
      if (mapping.tenantId != tenantId)
        continue;
      foreach (entry; mapping.entries) {
        if (entry.clientId == clientId && entry.localKey == localKey)
          return mapping;
      }
    }
    return KeyMapping.init;
  }

}
