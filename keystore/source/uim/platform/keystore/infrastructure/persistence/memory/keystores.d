/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.keystore.infrastructure.persistence.memory.keystores;

import uim.platform.keystore.domain.entities.keystore_entity;
import uim.platform.keystore.domain.ports.repositories.keystore_repository;
import uim.platform.keystore.domain.types;

import std.algorithm : filter;
import std.array : array;

@safe:

class MemoryKeystoreRepository : KeystoreRepository {
  private KeystoreEntity[KeystoreId] store;

  bool existsById(KeystoreId id) {
    return (id in store) !is null;
  }

  KeystoreEntity findById(KeystoreId id) {
    return existsById(id) ? store[id] : KeystoreEntity.init;
  }

  bool existsByName(string accountId, string applicationId, KeystoreLevel level, string name) {
    return findByName(accountId, applicationId, level, name).id.length > 0;
  }

  KeystoreEntity findByName(string accountId, string applicationId, KeystoreLevel level, string name) {
    foreach (ks; findAll) {
      if (ks.accountId == accountId && ks.applicationId == applicationId &&
          ks.level == level && ks.name == name)
        return ks;
    }
    return KeystoreEntity.init;
  }

  KeystoreEntity[] findByAccount(string accountId) {
    return findAll().filter!(ks => ks.accountId == accountId).array;
  }

  KeystoreEntity[] findByApplication(string accountId, string applicationId) {
    return store.values
      .filter!(ks => ks.accountId == accountId && ks.applicationId == applicationId)
      .array;
  }

  KeystoreEntity[] findBySubscription(string accountId, string subscriptionId) {
    return store.values
      .filter!(ks => ks.accountId == accountId && ks.subscriptionId == subscriptionId &&
                     ks.level == KeystoreLevel.subscription)
      .array;
  }

  void save(KeystoreEntity ks) {
    store[ks.id] = ks;
  }

  void update(KeystoreEntity ks) {
    store[ks.id] = ks;
  }

  void remove(KeystoreId id) {
    removeById(id);
  }

  void removeByName(string accountId, string applicationId, KeystoreLevel level, string name) {
    auto ks = findByName(accountId, applicationId, level, name);
    if (ks.id.length > 0)
      store.remove(ks.id);
  }

  size_t countByAccount(string accountId) {
    return findAll().filter!(ks => ks.accountId == accountId).array.length;
  }
}
