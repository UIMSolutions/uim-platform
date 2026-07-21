/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.keystore.infrastructure.persistence.repositories.keystores;

import uim.platform.keystore;

mixin(ShowModule!());

@safe:

class KeystoreRepository : TenantRepository!(Keystore, KeystoreId), IKeystoreRepository {

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
///
unittest {
  mixin(ShowTest!("KeystoreRepository Tests"));

  void testExistsByName() {
    auto repo = new KeystoreRepository();
    auto tenantId = TenantId("tenant1");
    auto accountId = "account1";
    auto applicationId = "app1";
    auto level = KeystoreLevel.application;
    auto name = "myKeystore";

    // Add a keystore
    auto ks = Keystore(tenantId);
    ks.id = KeystoreId("keystore1");
    ks.accountId = accountId;
    ks.applicationId = applicationId;
    ks.level = level;
    ks.name = name;
    repo.save(ks);

    assert(repo.existsByName(tenantId, accountId, applicationId, level, name) == true);
    assert(repo.existsByName(tenantId, accountId, applicationId, level, "nonExistentName") == false);
  }

  void testFindByName() {
    auto repo = new KeystoreRepository();
    auto tenantId = TenantId("tenant1");
    auto accountId = "account1";
    auto applicationId = "app1";
    auto level = KeystoreLevel.application;
    auto name = "myKeystore";

    // Add a keystore
    auto ks = Keystore(tenantId);
    ks.id = KeystoreId("keystore1");
    ks.accountId = accountId;
    ks.applicationId = applicationId;
    ks.level = level;
    ks.name = name;
    repo.save(ks);

    auto foundKs = repo.findByName(tenantId, accountId, applicationId, level, name);
    assert(foundKs.id == KeystoreId("keystore1"));

    auto notFoundKs = repo.findByName(tenantId, accountId, applicationId, level, "nonExistentName");
    assert(notFoundKs.isNull);
  }

  void testRemoveByName() {
    auto repo = new KeystoreRepository();
    auto tenantId = TenantId("tenant1");
    auto accountId = "account1";
    auto applicationId = "app1";
    auto level = KeystoreLevel.application;
    auto name = "myKeystore";

    // Add a keystore
    auto ks = Keystore(tenantId);
    ks.id = KeystoreId("keystore1");
    ks.accountId = accountId;
    ks.applicationId = applicationId;
    ks.level = level;
    ks.name = name;
    repo.save(ks);

    assert(repo.existsByName(tenantId, accountId, applicationId, level, name) == true);

    repo.removeByName(tenantId, accountId, applicationId, level, name);
    assert(repo.existsByName(tenantId, accountId, applicationId, level, name) == false);
  }

  void testCountByAccount() {
    auto repo = new KeystoreRepository();
    auto tenantId = TenantId("tenant1");
    auto accountId = "account1";

    // Add keystores
    auto ks1 = Keystore(tenantId);
    ks1.id = KeystoreId("keystore1");
    ks1.accountId = accountId;
    repo.save(ks1);

    auto ks2 = Keystore(tenantId);
    ks2.id = KeystoreId("keystore2");
    ks2.accountId = accountId;
    repo.save(ks2);

    assert(repo.countByAccount(tenantId, accountId) == 2);
  }

  void testFindByAccount() {
    auto repo = new KeystoreRepository();
    auto tenantId = TenantId("tenant1");
    auto accountId = "account1";

    // Add keystores
    auto ks1 = Keystore(tenantId);
    ks1.id = KeystoreId("keystore1");
    ks1.accountId = accountId;
    repo.save(ks1);

    auto ks2 = Keystore(tenantId);
    ks2.id = KeystoreId("keystore2");
    ks2.accountId = accountId;
    repo.save(ks2);

    auto keystores = repo.findByAccount(tenantId, accountId);
    assert(keystores.length == 2);
  }

  void testRemoveByAccount() {
    auto repo = new KeystoreRepository();
    auto tenantId = TenantId("tenant1");
    auto accountId = "account1";

    // Add keystores
    auto ks1 = Keystore(tenantId);
    ks1.id = KeystoreId("keystore1");
    ks1.accountId = accountId;
    repo.save(ks1);

    auto ks2 = Keystore(tenantId);
    ks2.id = KeystoreId("keystore2");
    ks2.accountId = accountId;
    repo.save(ks2);

    assert(repo.countByAccount(tenantId, accountId) == 2);

    repo.removeByAccount(tenantId, accountId);
    assert(repo.countByAccount(tenantId, accountId) == 0);
  }

  void testCountByApplication() {
    auto repo = new KeystoreRepository();
    auto tenantId = TenantId("tenant1");
    auto accountId = "account1";
    auto applicationId = "app1";

    // Add keystores
    auto ks1 = Keystore(tenantId);
    ks1.id = KeystoreId("keystore1");
    ks1.accountId = accountId;
    ks1.applicationId = applicationId;
    repo.save(ks1);

    auto ks2 = Keystore(tenantId);
    ks2.id = KeystoreId("keystore2");
    ks2.accountId = accountId;
    ks2.applicationId = applicationId;
    repo.save(ks2);

    assert(repo.countByApplication(tenantId, accountId, applicationId) == 2);
  }

  void testFindByApplication() {
    auto repo = new KeystoreRepository();
    auto tenantId = TenantId("tenant1");
    auto accountId = "account1";
    auto applicationId = "app1";

    // Add keystores
    auto ks1 = Keystore(tenantId);
    ks1.id = KeystoreId("keystore1");
    ks1.accountId = accountId;
    ks1.applicationId = applicationId;
    repo.save(ks1);

    auto ks2 = Keystore(tenantId);
    ks2.id = KeystoreId("keystore2");
    ks2.accountId = accountId;
    ks2.applicationId = applicationId;
    repo.save(ks2);

    auto keystores = repo.findByApplication(tenantId, accountId, applicationId);
    assert(keystores.length == 2);
  }

  void testRemoveByApplication() {
    auto repo = new KeystoreRepository();
    auto tenantId = TenantId("tenant1");
    auto accountId = "account1";
    auto applicationId = "app1";

    // Add keystores
    auto ks1 = Keystore(tenantId);
    ks1.id = KeystoreId("keystore1");
    ks1.accountId = accountId;
    ks1.applicationId = applicationId;
    repo.save(ks1);

    auto ks2 = Keystore(tenantId);
    ks2.id = KeystoreId("keystore2");
    ks2.accountId = accountId;
    ks2.applicationId = applicationId;
    repo.save(ks2);

    assert(repo.countByApplication(tenantId, accountId, applicationId) == 2);

    repo.removeByApplication(tenantId, accountId, applicationId);
    assert(repo.countByApplication(tenantId, accountId, applicationId) == 0);
  }

  void testCountBySubscription() {
    auto repo = new KeystoreRepository();
    auto tenantId = TenantId("tenant1");
    auto accountId = "account1";
    auto subscriptionId = "sub1";

    // Add keystores
    auto ks1 = Keystore(tenantId);
    ks1.id = KeystoreId("keystore1");
    ks1.accountId = accountId;
    ks1.subscriptionId = subscriptionId;
    repo.save(ks1);

    auto ks2 = Keystore(tenantId);
    ks2.id = KeystoreId("keystore2");
    ks2.accountId = accountId;
    ks2.subscriptionId = subscriptionId;
    repo.save(ks2);

    assert(repo.countBySubscription(tenantId, accountId, subscriptionId) == 2);
  }

  void testFindBySubscription() {
    auto repo = new KeystoreRepository();
    auto tenantId = TenantId("tenant1");
    auto accountId = "account1";
    auto subscriptionId = "sub1";

    // Add keystores
    auto ks1 = Keystore(tenantId);
    ks1.id = KeystoreId("keystore1");
    ks1.accountId = accountId;
    ks1.subscriptionId = subscriptionId;
    repo.save(ks1);

    auto ks2 = Keystore(tenantId);
    ks2.id = KeystoreId("keystore2");
    ks2.accountId = accountId;
    ks2.subscriptionId = subscriptionId;
    repo.save(ks2);

    auto keystores = repo.findBySubscription(tenantId, accountId, subscriptionId);
    assert(keystores.length == 2);
  }

  void testRemoveBySubscription() {
    auto repo = new KeystoreRepository();
    auto tenantId = TenantId("tenant1");
    auto accountId = "account1";
    auto subscriptionId = "sub1";

    // Add keystores
    auto ks1 = Keystore(tenantId);
    ks1.id = KeystoreId("keystore1");
    ks1.accountId = accountId;
    ks1.subscriptionId = subscriptionId;
    repo.save(ks1);

    auto ks2 = Keystore(tenantId);
    ks2.id = KeystoreId("keystore2");
    ks2.accountId = accountId;
    ks2.subscriptionId = subscriptionId;
    repo.save(ks2);

    assert(repo.countBySubscription(tenantId, accountId, subscriptionId) == 2);

    repo.removeBySubscription(tenantId, accountId, subscriptionId);
    assert(repo.countBySubscription(tenantId, accountId, subscriptionId) == 0);
  }

  void runAllTests() {
    testExistsByName();
    testFindByName();
    testRemoveByName();
    testCountByAccount();
    testFindByAccount();
    testRemoveByAccount();
    testCountByApplication();
    testFindByApplication();
    testRemoveByApplication();
    testCountBySubscription();
    testFindBySubscription();
    testRemoveBySubscription();
  }
}