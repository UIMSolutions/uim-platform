/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.keystore.domain.ports.repositories.key_entries;
// import uim.platform.keystore.domain.entities.key_entry;
// import uim.platform.keystore.domain.types;

import uim.platform.keystore;
mixin(ShowModule!());

@safe:

interface KeyEntryRepository : ITenantRepository!(KeyEntry, KeyEntryId) {

  bool existsByAlias(TenantId tenantId, KeystoreId keystoreId, string alias_);
  KeyEntry findByAlias(TenantId tenantId, KeystoreId keystoreId, string alias_);

  size_t countByKeystore(TenantId tenantId, KeystoreId keystoreId);
  KeyEntry[] findByKeystore(TenantId tenantId, KeystoreId keystoreId);
  void removeByKeystore(TenantId tenantId, KeystoreId keystoreId);

}
