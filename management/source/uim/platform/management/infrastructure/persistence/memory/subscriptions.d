/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.infrastructure.persistence.memory.subscriptions;

// import uim.platform.management.domain.types;
// import uim.platform.management.domain.entities.subscription;
// import uim.platform.management.domain.ports.repositories.subscriptions;

// // import std.algorithm : filter;
// // import std.array : array;

import uim.platform.management;

mixin(ShowModule!());
@safe:

class MemorySubscriptionRepository : SubscriptionRepository {
  private Subscription[SubscriptionId] store;

  bool existsById(SubscriptionId id) {
    return (id in store) ? true : false;
  }

  Subscription findById(SubscriptionId id) {
    return existsById(id) ? store[id] : Subscription.init;
  }

  Subscription[] findBySubaccount(SubaccountId subaccountId) {
    return findAll()r!(e => e.subaccountId == subaccountId).array;
  }

  Subscription[] findByApp(SubaccountId subaccountId, string appName) {
    return findBySubaccount(subaccountId).filter!(e => e.appName == appName).array;
  }

  Subscription[] findByStatus(SubaccountId subaccountId, SubscriptionStatus status) {
    return findBySubaccount(subaccountId).filter!(e => e.status == status).array;
  }

  void save(Subscription sub) {
    store[sub.id] = sub;
  }

  void update(Subscription sub) {
    store[sub.id] = sub;
  }

  void remove(SubscriptionId id) {
    store.remove(id);
  }
}
