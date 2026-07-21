/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.keystore.infrastructure.persistence.repositories.key_passwords;

import uim.platform.keystore;

mixin(ShowModule!());

@safe:

class KeyPasswordRepository : TenantRepository!(KeyPassword, KeyPasswordId), IKeyPasswordRepository {

  bool existsByAlias(TenantId tenantId, string accountId, string applicationId, string alias_) {
    return findByApplication(tenantId, accountId, applicationId).any!(kp => kp.alias_ == alias_);
  }

  KeyPassword findByAlias(TenantId tenantId, string accountId, string applicationId, string alias_) {
    foreach (kp; findByApplication(tenantId, accountId, applicationId)) {
      if (kp.alias_ == alias_)
        return kp;
    }
    return KeyPassword.init;
  }

  void removeByAlias(TenantId tenantId, string accountId, string applicationId, string alias_) {
    foreach (kp; findByApplication(tenantId, accountId, applicationId)) {
      if (kp.alias_ == alias_) {
        remove(kp);
        return;
      }
    }
  }

  KeyPassword[] filterByAccount(KeyPassword[] passwords, string accountId) {
    return passwords.filter!(kp => kp.accountId == accountId).array;
  }

  // #region ByApplication
  size_t countByApplication(TenantId tenantId, string accountId, string applicationId) {
    return findByApplication(tenantId, accountId, applicationId).length;
  }

  KeyPassword[] filterByApplication(KeyPassword[] passwords, string applicationId) {
    return passwords.filter!(kp => kp.applicationId == applicationId).array;
  }

  KeyPassword[] findByApplication(TenantId tenantId, string accountId, string applicationId) {
    return filterByApplication(filterByAccount(findByTenant(tenantId), accountId), applicationId);
  }

  void removeByApplication(TenantId tenantId, string accountId, string applicationId) {
    findByApplication(tenantId, accountId, applicationId).each!(kp => remove(kp));
  }
  // #endregion ByApplication

}
///
unittest {
  mixin(ShowTest!("KeyPasswordRepository Tests"));

  void testExistsByAlias() {
    auto repo = new KeyPasswordRepository();
    auto tenantId = TenantId("tenant1");
    auto accountId = "account1";
    auto applicationId = "app1";

    // Add a key password
    auto kp = KeyPassword.init;
    kp.id = KeyPasswordId("kp1");
    kp.tenantId = tenantId;
    kp.accountId = accountId;
    kp.applicationId = applicationId;
    kp.alias_ = "myAlias";
    repo.save(kp);

    assert(repo.existsByAlias(tenantId, accountId, applicationId, "myAlias") == true);
    assert(repo.existsByAlias(tenantId, accountId, applicationId, "nonExistentAlias") == false);
  }

  void testFindByAlias() {
    auto repo = new KeyPasswordRepository();
    auto tenantId = TenantId("tenant1");
    auto accountId = "account1";
    auto applicationId = "app1";

    // Add a key password
    auto kp = KeyPassword.init;
    kp.id = KeyPasswordId("kp1");
    kp.tenantId = tenantId;
    kp.accountId = accountId;
    kp.applicationId = applicationId;
    kp.alias_ = "myAlias";
    repo.save(kp);

    auto foundKp = repo.findByAlias(tenantId, accountId, applicationId, "myAlias");
    assert(foundKp.id == KeyPasswordId("kp1"));
  }

  void testRemoveByAlias() {
    auto repo = new KeyPasswordRepository();
    auto tenantId = TenantId("tenant1");
    auto accountId = "account1";
    auto applicationId = "app1";

    // Add a key password
    auto kp = KeyPassword.init;
    kp.id = KeyPasswordId("kp1");
    kp.tenantId = tenantId;
    kp.accountId = accountId;
    kp.applicationId = applicationId;
    kp.alias_ = "myAlias";
    repo.save(kp);

    assert(repo.existsByAlias(tenantId, accountId, applicationId, "myAlias") == true);
    repo.removeByAlias(tenantId, accountId, applicationId, "myAlias");
    assert(repo.existsByAlias(tenantId, accountId, applicationId, "myAlias") == false);
  }

  void testCountByApplication() {
    auto repo = new KeyPasswordRepository();
    auto tenantId = TenantId("tenant1");
    auto accountId = "account1";
    auto applicationId = "app1";

    // Add key passwords
    auto kp1 = KeyPassword.init;
    kp1.id = KeyPasswordId("kp1");
    kp1.tenantId = tenantId;
    kp1.accountId = accountId;
    kp1.applicationId = applicationId;
    repo.save(kp1);

    auto kp2 = KeyPassword.init;
    kp2.id = KeyPasswordId("kp2");
    kp2.tenantId = tenantId;
    kp2.accountId = accountId;
    kp2.applicationId = applicationId;
    repo.save(kp2);

    assert(repo.countByApplication(tenantId, accountId, applicationId) == 2);
  }

  void testRemoveByApplication() {
    auto repo = new KeyPasswordRepository();
    auto tenantId = TenantId("tenant1");
    auto accountId = "account1";
    auto applicationId = "app1";

    // Add key passwords
    auto kp1 = KeyPassword.init;
    kp1.id = KeyPasswordId("kp1");
    kp1.tenantId = tenantId;
    kp1.accountId = accountId;
    kp1.applicationId = applicationId;
    repo.save(kp1);

    auto kp2 = KeyPassword.init;
    kp2.id = KeyPasswordId("kp2");
    kp2.tenantId = tenantId;
    kp2.accountId = accountId;
    kp2.applicationId = applicationId;
    repo.save(kp2);

    assert(repo.countByApplication(tenantId, accountId, applicationId) == 2);
    repo.removeByApplication(tenantId, accountId, applicationId);
    assert(repo.countByApplication(tenantId, accountId, applicationId) == 0);
  }

  void testFindByApplication() {
    auto repo = new KeyPasswordRepository();
    auto tenantId = TenantId("tenant1");
    auto accountId = "account1";
    auto applicationId = "app1";

    // Add key passwords
    auto kp1 = KeyPassword.init;
    kp1.id = KeyPasswordId("kp1");
    kp1.tenantId = tenantId;
    kp1.accountId = accountId;
    kp1.applicationId = applicationId;
    repo.save(kp1);

    auto kp2 = KeyPassword.init;
    kp2.id = KeyPasswordId("kp2");
    kp2.tenantId = tenantId;
    kp2.accountId = accountId;
    kp2.applicationId = applicationId;
    repo.save(kp2);

    auto passwords = repo.findByApplication(tenantId, accountId, applicationId);
    assert(passwords.length == 2);
  }

  void testFilterByApplication() {
    auto repo = new KeyPasswordRepository();
    auto tenantId = TenantId("tenant1");
    auto accountId = "account1";
    auto applicationId = "app1";

    // Add key passwords
    auto kp1 = KeyPassword.init;
    kp1.id = KeyPasswordId("kp1");
    kp1.tenantId = tenantId;
    kp1.accountId = accountId;
    kp1.applicationId = applicationId;
    repo.save(kp1);

    auto kp2 = KeyPassword.init;
    kp2.id = KeyPasswordId("kp2");
    kp2.tenantId = tenantId;
    kp2.accountId = accountId;
    kp2.applicationId = applicationId;
    repo.save(kp2);

    auto allPasswords = repo.findByTenant(tenantId);
    auto filteredPasswords = repo.filterByApplication(allPasswords, applicationId);
    assert(filteredPasswords.length == 2);
  }

  void testFilterByAccount() {
    auto repo = new KeyPasswordRepository();
    auto tenantId = TenantId("tenant1");
    auto accountId = "account1";
    auto applicationId = "app1";

    // Add key passwords
    auto kp1 = KeyPassword.init;
    kp1.id = KeyPasswordId("kp1");
    kp1.tenantId = tenantId;
    kp1.accountId = accountId;
    kp1.applicationId = applicationId;
    repo.save(kp1);

    auto kp2 = KeyPassword.init;
    kp2.id = KeyPasswordId("kp2");
    kp2.tenantId = tenantId;
    kp2.accountId = accountId;
    kp2.applicationId = applicationId;
    repo.save(kp2);

    auto allPasswords = repo.findByTenant(tenantId);
    auto filteredPasswords = repo.filterByAccount(allPasswords, accountId);
    assert(filteredPasswords.length == 2);
  }

  void runAllTests() {
    testExistsByAlias();
    testFindByAlias();
    testRemoveByAlias();
    testCountByApplication();
    testRemoveByApplication();
    testFindByApplication();
    testFilterByApplication();
    testFilterByAccount();
  }
}
