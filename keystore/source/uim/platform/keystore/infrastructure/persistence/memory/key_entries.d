/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.keystore.infrastructure.persistence.memory.key_entries;
// import uim.platform.keystore.domain.entities.key_entry;
// import uim.platform.keystore.domain.ports.repositories.key_entry_repository;
// import uim.platform.keystore.domain.types;

import uim.platform.keystore;
mixin(ShowModule!());

@safe:

class MemoryKeyEntryRepository : TenantRepository!(KeyEntry, KeyEntryId), KeyEntryRepository {

  bool existsByAlias(TenantId tenantId, KeystoreId keystoreId, string alias_) {
    return findByKeystore(tenantId, keystoreId).any!(e => e.alias_ == alias_);
  }

  KeyEntry findByAlias(TenantId tenantId, KeystoreId keystoreId, string alias_) {
    foreach(ks; findByKeystore(tenantId, keystoreId)) {
      if (ks.alias_ == alias_)
        return ks;
    }
    return KeyEntry.init;
  }

  size_t countByKeystore(TenantId tenantId, KeystoreId keystoreId) {
    return findByKeystore(tenantId, keystoreId).length;
  }

  KeyEntry[] filterByKeystore(KeyEntry[] entries, KeystoreId keystoreId) {
    return entries.filter!(e => e.keystoreId == keystoreId).array;
  }
  
  KeyEntry[] findByKeystore(TenantId tenantId, KeystoreId keystoreId) {
    return filterByKeystore(findByTenant(tenantId), keystoreId);
  }
  
  void removeByKeystore(TenantId tenantId, KeystoreId keystoreId) {
    findByKeystore(tenantId, keystoreId).each!(e => remove(e));
  }

}
