/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.infrastructure.persistence.memory.global_accounts;

// import uim.platform.management.domain.types;
// import uim.platform.management.domain.entities.global_account;
// import uim.platform.management.domain.ports.repositories.global_accounts;

// // import std.algorithm : filter;
// // import std.array : array;

import uim.platform.management;

mixin(ShowModule!());
@safe:

class MemoryGlobalAccountRepository : GlobalAccountRepository {
  private GlobalAccount[GlobalAccountId] store;

  GlobalAccount findById(GlobalAccountId id) {
    if (auto p = id in store)
      return *p;
    return GlobalAccount.init;
  }

  GlobalAccount[] findByStatus(GlobalAccountStatus status) {
    return store.byValue().filter!(e => e.status == status).array;
  }

  GlobalAccount[] findAll() {
    return store.byValue().array;
  }

  void save(GlobalAccount account) {
    store[account.id] = account;
  }

  void update(GlobalAccount account) {
    store[account.id] = account;
  }

  void remove(GlobalAccountId id) {
    store.remove(id);
  }
}
