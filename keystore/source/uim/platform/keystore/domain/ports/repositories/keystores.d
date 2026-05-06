/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.keystore.domain.ports.repositories.keystore_repository;

// import uim.platform.keystore.domain.entities.keystore_entity;
// import uim.platform.keystore.domain.types;

import uim.platform.keystore;

mixin(ShowModule!());

@safe:

interface KeystoreRepository {
  bool existsById(KeystoreId id);
  KeystoreEntity findById(KeystoreId id);

  bool existsByName(string accountId, string applicationId, KeystoreLevel level, string name);
  KeystoreEntity findByName(string accountId, string applicationId, KeystoreLevel level, string name);

  KeystoreEntity[] findByAccount(string accountId);
  KeystoreEntity[] findByApplication(string accountId, string applicationId);
  KeystoreEntity[] findBySubscription(string accountId, string subscriptionId);

  void save(KeystoreEntity ks);
  void update(KeystoreEntity ks);
  void remove(KeystoreId id);
  void removeByName(string accountId, string applicationId, KeystoreLevel level, string name);

  size_t countByAccount(string accountId);
}
