/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.keystore.domain.ports.repositories.keystores;
// import uim.platform.keystore.domain.entities.keystore_entity;
// import uim.platform.keystore.domain.types;

import uim.platform.keystore;

// mixin(ShowModule!());

@safe:

interface KeystoreRepository : ITenantRepository!(Keystore, KeystoreId) {

  bool existsByName(TenantId tenantId, string accountId, string applicationId, KeystoreLevel level, string name);
  Keystore findByName(TenantId tenantId, string accountId, string applicationId, KeystoreLevel level, string name);
  void removeByName(TenantId tenantId, string accountId, string applicationId, KeystoreLevel level, string name);
  
  size_t countByAccount(TenantId tenantId, string accountId);
  Keystore[] findByAccount(TenantId tenantId, string accountId);
  void removeByAccount(TenantId tenantId, string accountId);

  size_t countByApplication(TenantId tenantId, string accountId, string applicationId);
  Keystore[] findByApplication(TenantId tenantId, string accountId, string applicationId);
  void removeByApplication(TenantId tenantId, string accountId, string applicationId);

  size_t countBySubscription(TenantId tenantId, string accountId, string subscriptionId);
  Keystore[] findBySubscription(TenantId tenantId, string accountId, string subscriptionId);
  void removeBySubscription(TenantId tenantId, string accountId, string subscriptionId);

}
