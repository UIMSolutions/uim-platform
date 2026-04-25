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

class MemorySubscriptionRepository : IdRepository!(Subscription, SubscriptionId), SubscriptionRepository {
  mixin IdRepositoryTemplate!(MemorySubscriptionRepository, Subscription, SubscriptionId);

  size_t countBySubaccount(SubaccountId subaccountId) {
    return findBySubaccount(subaccountId).length;
  }

  Subscription[] filterBySubaccount(Subscription[] items, SubaccountId subaccountId) {
    return items.filter!(e => e.subaccountId == subaccountId).array;
  }

  Subscription[] findBySubaccount(SubaccountId subaccountId) {
    return findAll().filterBySubaccount(subaccountId);
  }

  void removeBySubaccount(SubaccountId subaccountId) {
    findBySubaccount(subaccountId).each!(e => remove(e.id));
  }

  size_t countByApp(SubaccountId subaccountId, string appName) {
    return findByApp(subaccountId, appName).length;
  }

  Subscription[] filterByApp(Subscription[] items, SubaccountId subaccountId, string appName) {
    return items.filter!(e => e.subaccountId == subaccountId && e.appName == appName).array;
  }

  Subscription[] findByApp(SubaccountId subaccountId, string appName) {
    return findBySubaccount(subaccountId).filterByApp(subaccountId, appName);
  }

  void removeByApp(SubaccountId subaccountId, string appName) {
    findByApp(subaccountId, appName).each!(e => remove(e.id));
  }

  size_t countByStatus(SubaccountId subaccountId, SubscriptionStatus status) {
    return findByStatus(subaccountId, status).length;
  }

  Subscription[] filterByStatus(Subscription[] items, SubaccountId subaccountId, SubscriptionStatus status) {
    return items.filter!(e => e.subaccountId == subaccountId && e.status == status).array;
  }

  Subscription[] findByStatus(SubaccountId subaccountId, SubscriptionStatus status) {
    return findBySubaccount(subaccountId).filter!(e => e.status == status).array;
  }

  void removeByStatus(SubaccountId subaccountId, SubscriptionStatus status) {
    findByStatus(subaccountId, status).each!(e => remove(e.id));
  }
  
}
