/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.keystore.infrastructure.persistence.memory.key_passwords;

import uim.platform.keystore.domain.entities.key_password;
import uim.platform.keystore.domain.ports.repositories.key_password_repository;
import uim.platform.keystore.domain.types;

import std.algorithm : filter;
import std.array : array;

@safe:

class MemoryKeyPasswordRepository : KeyPasswordRepository {
  private KeyPassword[KeyPasswordId] store;

  bool existsByAlias(string accountId, string applicationId, string alias_) {
    return findByAlias(accountId, applicationId, alias_).id.length > 0;
  }

  KeyPassword findByAlias(string accountId, string applicationId, string alias_) {
    foreach (kp; findAll) {
      if (kp.accountId == accountId && kp.applicationId == applicationId && kp.alias_ == alias_)
        return kp;
    }
    return KeyPassword.init;
  }

  KeyPassword[] findByApplication(string accountId, string applicationId) {
    return store.values
      .filter!(kp => kp.accountId == accountId && kp.applicationId == applicationId)
      .array;
  }

  void save(KeyPassword kp) {
    store[kp.id] = kp;
  }

  void update(KeyPassword kp) {
    store[kp.id] = kp;
  }

  void removeByAlias(string accountId, string applicationId, string alias_) {
    foreach (id, kp; store) {
      if (kp.accountId == accountId && kp.applicationId == applicationId && kp.alias_ == alias_) {
        store.removeById(id);
        return;
      }
    }
  }

  size_t countByApplication(string accountId, string applicationId) {
    return store.values
      .filter!(kp => kp.accountId == accountId && kp.applicationId == applicationId)
      .array.length;
  }
}
