/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.master_data_integration.domain.ports.key_mappings;

import uim.platform.master_data_integration.domain.entities.key_mapping;
import uim.platform.master_data_integration.domain.types;

/// Port: outgoing — key mapping persistence.
interface KeyMappingRepository {
  KeyMapping findById(KeyMappingId id);
  KeyMapping[] findByTenant(TenantId tenantId);
  KeyMapping[] findByObjectId(TenantId tenantId, MasterDataObjectId objectId);
  KeyMapping[] findByCategory(TenantId tenantId, MasterDataCategory category);
  KeyMapping findByClientKey(TenantId tenantId, ClientId clientId, string localKey);
  void save(KeyMapping mapping);
  void update(KeyMapping mapping);
  void remove(KeyMappingId id);
}
