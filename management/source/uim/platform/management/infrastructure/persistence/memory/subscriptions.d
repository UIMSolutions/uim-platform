/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.infrastructure.persistence.memory.subscriptions;
// import uim.platform.management.domain.types;
// import uim.platform.management.domain.entities.subscription;
// import uim.platform.management.domain.ports.repositories.subscriptions;
// 
//  

import uim.platform.management;

mixin(ShowModule!());
@safe:

class MemorySubscriptionRepository : TenantRepository!(Subscription, SubscriptionId), SubscriptionRepository {
  // TODO: mixin IdRepositoryTemplate!(MemorySubscriptionRepository, Subscription, SubscriptionId);

  size_t countBySubaccount(TenantId tenantId, SubaccountId subaccountId) {
    return findBySubaccount(tenantId, subaccountId).length;
  }

  Subscription[] filterBySubaccount(Subscription[] items, SubaccountId subaccountId) {
    return items.filter!(e => e.subaccountId == subaccountId).array;
  }

  Subscription[] findBySubaccount(TenantId tenantId, SubaccountId subaccountId) {
    return filterBySubaccount(findByTenant(tenantId), subaccountId);
  }

  void removeBySubaccount(TenantId tenantId, SubaccountId subaccountId) {
    findBySubaccount(tenantId, subaccountId).each!(e => remove(e));
  }

  size_t countByApp(TenantId tenantId, SubaccountId subaccountId, string appName) {
    return findByApp(tenantId, subaccountId, appName).length;
  }

  Subscription[] filterByApp(Subscription[] items, SubaccountId subaccountId, string appName) {
    return items.filter!(e => e.subaccountId == subaccountId && e.appName == appName).array;
  }

  Subscription[] findByApp(TenantId tenantId, SubaccountId subaccountId, string appName) {
    return filterByApp(findBySubaccount(tenantId, subaccountId), appName);
  }

  void removeByApp(TenantId tenantId, SubaccountId subaccountId, string appName) {
    findByApp(tenantId, subaccountId, appName).each!(e => remove(e));
  }

  size_t countByStatus(TenantId tenantId, SubaccountId subaccountId, SubscriptionStatus status) {
    return findByStatus(tenantId, subaccountId, status).length;
  }

  Subscription[] filterByStatus(Subscription[] items, SubaccountId subaccountId, SubscriptionStatus status) {
    return items.filter!(e => e.subaccountId == subaccountId && e.status == status).array;
  }

  Subscription[] findByStatus(TenantId tenantId, SubaccountId subaccountId, SubscriptionStatus status) {
    return filterByStatus(findByTenant(tenantId), subaccountId, status);
  }

  void removeByStatus(TenantId tenantId, SubaccountId subaccountId, SubscriptionStatus status) {
    findByStatus(tenantId,  subaccountId, status).each!(e => remove(e));
  }

}
