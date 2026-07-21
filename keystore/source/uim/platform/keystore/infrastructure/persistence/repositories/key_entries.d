/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.keystore.infrastructure.persistence.repositories.key_entries;

import uim.platform.keystore;

mixin(ShowModule!());

@safe:

class KeyEntryRepository : TenantRepository!(KeyEntry, KeyEntryId), IKeyEntryRepository {

  bool existsByAlias(TenantId tenantId, KeystoreId keystoreId, string alias_) {
    return findByKeystore(tenantId, keystoreId).any!(e => e.alias_ == alias_);
  }

  KeyEntry findByAlias(TenantId tenantId, KeystoreId keystoreId, string alias_) {
    foreach (ks; findByKeystore(tenantId, keystoreId)) {
      if (ks.alias_ == alias_)
        return ks;
    }
    return KeyEntry.init;
  }

  // #region ByKeystore
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
  // #region ByKeystore

}
///
unittest {
  mixin(ShowTest!("KeyEntryRepository Tests"));

  void testExistsByAlias() {
    auto repo = new KeyEntryRepository();
    auto tenantId = TenantId("tenant1");
    auto keystoreId = KeystoreId("keystore1");

    // Add a key entry
    auto entry = KeyEntry.init;
    entry.id = KeyEntryId("entry1");
    entry.keystoreId = keystoreId;
    entry.alias_ = "myAlias";
    entry.tenantId = tenantId;
    repo.save(entry);

    assert(repo.existsByAlias(tenantId, keystoreId, "myAlias") == true);
    assert(repo.existsByAlias(tenantId, keystoreId, "nonExistentAlias") == false);
  }

  void testFindByAlias() {
    auto repo = new KeyEntryRepository();
    auto tenantId = TenantId("tenant1");
    auto keystoreId = KeystoreId("keystore1");
    // Add a key entry
    auto entry = KeyEntry.init;
    entry.id = KeyEntryId("entry1");
    entry.keystoreId = keystoreId;
    entry.alias_ = "myAlias";
    entry.tenantId = tenantId;
    repo.save(entry);

    auto foundEntry = repo.findByAlias(tenantId, keystoreId, "myAlias");
    assert(foundEntry.id == KeyEntryId("entry1"));
    auto notFoundEntry = repo.findByAlias(tenantId, keystoreId, "nonExistentAlias");
    assert(notFoundEntry.isNull);
  }

  void testCountByKeystore() {
    auto repo = new KeyEntryRepository();
    auto tenantId = TenantId("tenant1");
    auto keystoreId = KeystoreId("keystore1");

    // Add key entries
    auto entry1 = KeyEntry.init;
    entry1.id = KeyEntryId("entry1");
    entry1.keystoreId = keystoreId;
    entry1.alias_ = "alias1";
    entry1.tenantId = tenantId;
    repo.save(entry1);

    auto entry2 = KeyEntry.init;
    entry2.id = KeyEntryId("entry2");
    entry2.keystoreId = keystoreId;
    entry2.alias_ = "alias2";
    entry2.tenantId = tenantId;
    repo.save(entry2);

    assert(repo.countByKeystore(tenantId, keystoreId) == 2);
  }

  void testFindByKeystore() {
    auto repo = new KeyEntryRepository();
    auto tenantId = TenantId("tenant1");
    auto keystoreId = KeystoreId("keystore1");

    // Add key entries
    auto entry1 = KeyEntry.init;
    entry1.id = KeyEntryId("entry1");
    entry1.keystoreId = keystoreId;
    entry1.alias_ = "alias1";
    entry1.tenantId = tenantId;
    repo.save(entry1);

    auto entry2 = KeyEntry.init;
    entry2.id = KeyEntryId("entry2");
    entry2.keystoreId = keystoreId;
    entry2.alias_ = "alias2";
    entry2.tenantId = tenantId;
    repo.save(entry2);

    auto entries = repo.findByKeystore(tenantId, keystoreId);
    assert(entries.length == 2);
  }

  void testRemoveByKeystore() {
    auto repo = new KeyEntryRepository();
    auto tenantId = TenantId("tenant1");
    auto keystoreId = KeystoreId("keystore1");

    // Add key entries
    auto entry1 = KeyEntry.init;
    entry1.id = KeyEntryId("entry1");
    entry1.keystoreId = keystoreId;
    entry1.alias_ = "alias1";
    entry1.tenantId = tenantId;
    repo.save(entry1);

    auto entry2 = KeyEntry.init;
    entry2.id = KeyEntryId("entry2");
    entry2.keystoreId = keystoreId;
    entry2.alias_ = "alias2";
    entry2.tenantId = tenantId;
    repo.save(entry2);

    repo.removeByKeystore(tenantId, keystoreId);
    assert(repo.countByKeystore(tenantId, keystoreId) == 0);
  }

  void runAllTests() {
    testExistsByAlias();
    testFindByAlias();
    testCountByKeystore();
    testFindByKeystore();
    testRemoveByKeystore();
  }
}
