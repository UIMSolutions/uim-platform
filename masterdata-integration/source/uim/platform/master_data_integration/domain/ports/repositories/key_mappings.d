/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.master_data_integration.domain.ports.repositories.key_mappings;

import uim.platform.master_data_integration.domain.entities.key_mapping;
import uim.platform.master_data_integration.domain.types;

/// Port: outgoing — key mapping persistence.
interface KeyMappingRepository : ITenantRepository!(KeyMapping, KeyMappingId) {

  size_t countByObjectId(TenantId tenantId, MasterDataObjectId objectId);
  KeyMapping[] findByObjectId(TenantId tenantId, MasterDataObjectId objectId);
  void removeByObjectId(TenantId tenantId, MasterDataObjectId objectId);

  size_t countByCategory(TenantId tenantId, MasterDataCategory category);
  KeyMapping[] findByCategory(TenantId tenantId, MasterDataCategory category);
  void removeByCategory(TenantId tenantId, MasterDataCategory category);

  size_t countByClientKey(TenantId tenantId, ClientId clientId, string localKey);
  KeyMapping findByClientKey(TenantId tenantId, ClientId clientId, string localKey);
  void removeByClientKey(TenantId tenantId, ClientId clientId, string localKey);

}
