/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.infrastructure.persistence.memory.subaccounts;

// import uim.platform.management.domain.types;
// import uim.platform.management.domain.entities.subaccount;
// import uim.platform.management.domain.ports.repositories.subaccounts;

// // import std.algorithm : filter;
// // import std.array : array;

import uim.platform.management;

mixin(ShowModule!());
@safe:

class MemorySubaccountRepository : SubaccountRepository {
  private Subaccount[SubaccountId] store;

  bool existsById(SubaccountId id) {
    return (id in store) ? true : false;
  }
  
  Subaccount findById(SubaccountId id) {
    return existsById(id) ? store[id] : Subaccount.init;
  }

  bool existsBySubdomain(string subdomain) {
    return store.byValue().any!(s => s.subdomain == subdomain);
  }

  Subaccount findBySubdomain(string subdomain) {
    foreach (s; store.byValue()) {
      if (s.subdomain == subdomain)
        return s;
    }
    return Subaccount.init;
  }

  Subaccount[] findByGlobalAccount(GlobalAccountId globalAccountId) {
    return store.byValue().filter!(e => e.globalAccountId == globalAccountId).array;
  }

  Subaccount[] findByDirectory(DirectoryId directoryId) {
    return store.byValue().filter!(e => e.parentDirectoryId == directoryId).array;
  }

  Subaccount[] findByRegion(GlobalAccountId globalAccountId, string region) {
    return store.byValue().filter!(e => e.globalAccountId == globalAccountId
        && e.region == region).array;
  }

  Subaccount[] findByStatus(GlobalAccountId globalAccountId, SubaccountStatus status) {
    return store.byValue().filter!(e => e.globalAccountId == globalAccountId
        && e.status == status).array;
  }

  void save(Subaccount sub) {
    store[sub.id] = sub;
  }

  void update(Subaccount sub) {
    store[sub.id] = sub;
  }

  void remove(SubaccountId id) {
    store.remove(id);
  }
}
