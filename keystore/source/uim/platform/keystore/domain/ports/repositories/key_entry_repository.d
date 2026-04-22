/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.keystore.domain.ports.repositories.key_entry_repository;

import uim.platform.keystore.domain.entities.key_entry;
import uim.platform.keystore.domain.types;

@safe:

interface KeyEntryRepository {
  bool existsById(KeyEntryId id);
  KeyEntry findById(KeyEntryId id);

  bool existsByAlias(KeystoreId keystoreId, string alias_);
  KeyEntry findByAlias(KeystoreId keystoreId, string alias_);

  KeyEntry[] findByKeystore(KeystoreId keystoreId);

  void save(KeyEntry entry);
  void update(KeyEntry entry);
  void remove(KeyEntryId id);
  void removeByKeystore(KeystoreId keystoreId);

  size_t countByKeystore(KeystoreId keystoreId);
}
