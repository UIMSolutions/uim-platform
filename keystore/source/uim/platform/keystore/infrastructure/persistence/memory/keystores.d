/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.keystore.infrastructure.persistence.memory.keystores;
// import uim.platform.keystore.domain.entities.keystore_entity;
// import uim.platform.keystore.domain.ports.repositories.keystore_repository;
// import uim.platform.keystore.domain.types;

import uim.platform.keystore;

mixin(ShowModule!());

@safe:

class MemoryKeystoreRepository : TenantRepository!(Keystore, KeystoreId), KeystoreRepository {

  bool existsByName(TenantId tenantId, string accountId, string applicationId, KeystoreLevel level, string name) {
    return findByApplication(tenantId, accountId, applicationId).any!(ks => ks.level == level && ks.name == name);        
  }

  Keystore findByName(TenantId tenantId, string accountId, string applicationId, KeystoreLevel level, string name) {
    foreach (ks; findByApplication(tenantId, accountId, applicationId)) {
      if (ks.level == level && ks.name == name)
        return ks;
    }
    return Keystore.init;
  }
  void removeByName(TenantId tenantId, string accountId, string applicationId, KeystoreLevel level, string name) {
    foreach (ks; findByApplication(tenantId, accountId, applicationId)) {
      if (ks.level == level && ks.name == name) {
        remove(ks);
        return;
      }
    }
  }

  // #region ByAccount
  size_t countByAccount(TenantId tenantId, string accountId) {
    return findByAccount(tenantId, accountId).length;
  }

  Keystore[] filterByAccount(Keystore[] keystores, string accountId) {
    return keystores.filter!(ks => ks.accountId == accountId).array;
  }

  Keystore[] findByAccount(TenantId tenantId, string accountId) {
    return filterByAccount(findByTenant(tenantId), accountId);
  }

  void removeByAccount(TenantId tenantId, string accountId) {
    findByAccount(tenantId, accountId).each!(ks => remove(ks));
  }
  // #endregion ByAccount

  // #region ByApplication
  size_t countByApplication(TenantId tenantId, string accountId, string applicationId) {
    return findByApplication(tenantId, accountId, applicationId).length;
  }

  Keystore[] filterByApplication(Keystore[] keystores, string applicationId) {
    return keystores.filter!(ks => ks.applicationId == applicationId).array;
  }

  Keystore[] findByApplication(TenantId tenantId, string accountId, string applicationId) {
    return filterByApplication(findByAccount(tenantId, accountId), applicationId);
  }

  void removeByApplication(TenantId tenantId, string accountId, string applicationId) {
    findByApplication(tenantId, accountId, applicationId).each!(ks => remove(ks));
  }
  // #endregion ByApplication

  // #region BySubscription
  size_t countBySubscription(TenantId tenantId, string accountId, string subscriptionId) {
    return findBySubscription(tenantId, accountId, subscriptionId).length;
  }

  Keystore[] filterBySubscription(Keystore[] keystores, string subscriptionId) {
    return keystores.filter!(ks => ks.subscriptionId == subscriptionId).array;
  }

  Keystore[] findBySubscription(TenantId tenantId, string accountId, string subscriptionId) {
    return filterBySubscription(findByAccount(tenantId, accountId), subscriptionId);
  }

  void removeBySubscription(TenantId tenantId, string accountId, string subscriptionId) {
    findBySubscription(tenantId, accountId, subscriptionId).each!(ks => remove(ks));
  }
  // #endregion BySubscription

}
