/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.master_data_integration.domain.entities.key_mapping;

import uim.platform.master_data_integration.domain.types;

/// A key mapping entry — maps IDs across different systems.
struct KeyMapping {
  KeyMappingId id;
  TenantId tenantId;
  MasterDataObjectId masterDataObjectId;
  MasterDataCategory category = MasterDataCategory.businessPartner;

  string objectType; // e.g. "BusinessPartner"

  // Mapping pairs
  KeyMappingEntry[] entries;

  long createdAt;
  long modifiedAt;
}

/// A single system-to-key mapping entry.
struct KeyMappingEntry {
  ClientId clientId;
  string systemId;
  string localKey;
  KeyMappingSourceType sourceType = KeyMappingSourceType.local;
  bool isPrimary;
}
