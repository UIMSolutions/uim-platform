/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.keystore.infrastructure.persistence.memory.key_entries;

import uim.platform.keystore.domain.entities.key_entry;
import uim.platform.keystore.domain.ports.repositories.key_entry_repository;
import uim.platform.keystore.domain.types;

import std.algorithm : filter;
import std.array : array;

@safe:

class MemoryKeyEntryRepository : KeyEntryRepository {
  private KeyEntry[KeyEntryId] store;

  bool existsById(KeyEntryId id) {
    return (id in store) !is null;
  }

  KeyEntry findById(KeyEntryId id) {
    return existsById(id) ? store[id] : KeyEntry.init;
  }

  bool existsByAlias(KeystoreId keystoreId, string alias_) {
    return findByAlias(keystoreId, alias_).id.length > 0;
  }

  KeyEntry findByAlias(KeystoreId keystoreId, string alias_) {
    foreach (e; store) {
      if (e.keystoreId == keystoreId && e.alias_ == alias_)
        return e;
    }
    return KeyEntry.init;
  }

  KeyEntry[] findByKeystore(KeystoreId keystoreId) {
    return store.values.filter!(e => e.keystoreId == keystoreId).array;
  }

  void save(KeyEntry entry) {
    store[entry.id] = entry;
  }

  void update(KeyEntry entry) {
    store[entry.id] = entry;
  }

  void remove(KeyEntryId id) {
    store.remove(id);
  }

  void removeByKeystore(KeystoreId keystoreId) {
    foreach (id, e; store) {
      if (e.keystoreId == keystoreId)
        store.remove(id);
    }
  }

  size_t countByKeystore(KeystoreId keystoreId) {
    return store.values.filter!(e => e.keystoreId == keystoreId).array.length;
  }
}
