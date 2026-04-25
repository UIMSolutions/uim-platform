/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.infrastructure.persistence.memory.entitlements;

// import uim.platform.management.domain.types;
// import uim.platform.management.domain.entities.entitlement;
// import uim.platform.management.domain.ports.repositories.entitlements;

// // import std.algorithm : filter;
// // import std.array : array;

import uim.platform.management;

mixin(ShowModule!());
@safe:

class MemoryEntitlementRepository : IdRepository!(Entitlement, EntitlementId), EntitlementRepository {
  // TODO: mixin IdRepositoryTemplate!(MemoryEntitlementRepository, Entitlement, EntitlementId);

  // #region ByGlobalAccount
  size_t countByGlobalAccount(GlobalAccountId globalAccountId) {
    return findByGlobalAccount(globalAccountId).length;
  }

  Entitlement[] filterByGlobalAccount(Entitlement[] items, GlobalAccountId globalAccountId) {
    return items.filter!(e => e.globalAccountId == globalAccountId).array;
  }

  Entitlement[] findByGlobalAccount(GlobalAccountId globalAccountId) {
    return findAll().filterByGlobalAccount(globalAccountId);
  }

  void removeByGlobalAccount(GlobalAccountId globalAccountId) {
    findByGlobalAccount(globalAccountId).removeAll();
  }
  // #endregion ByGlobalAccount

  // #region BySubaccount
  size_t countBySubaccount(SubaccountId subaccountId) {
    return findBySubaccount(subaccountId).length;
  }

  Entitlement[] filterBySubaccount(Entitlement[] items, SubaccountId subaccountId) {
    return items.filter!(e => e.subaccountId == subaccountId).array;
  }

  Entitlement[] findBySubaccount(SubaccountId subaccountId) {
    return findAll().filterBySubaccount(subaccountId);
  }

  void removeBySubaccount(SubaccountId subaccountId) {
    findBySubaccount(subaccountId).each!(e => remove(e));
  }
  // #endregion BySubaccount

  // #region ByDirectory
  size_t countByDirectory(DirectoryId directoryId) {
    return findByDirectory(directoryId).length;
  } 

Entitlement[] filterByDirectory(Entitlement[] items, DirectoryId directoryId) {
    return items.filter!(e => e.directoryId == directoryId).array;
  }

  Entitlement[] findByDirectory(DirectoryId directoryId) {
    return findAll().filterByDirectory(directoryId);
  }

  void removeByDirectory(DirectoryId directoryId) {
    findByDirectory(directoryId).each!(e => remove(e));
  }
  // #endregion ByDirectory

  // #region ByServicePlan
  size_t countByServicePlan(GlobalAccountId globalAccountId, ServicePlanId planId) {
    return findByServicePlan(globalAccountId, planId).length;
  }

  Entitlement[] filterByServicePlan(Entitlement[] items, ServicePlanId planId) {
    return items.filter!(e => e.servicePlanId == planId).array;
  }

  Entitlement[] findByServicePlan(GlobalAccountId globalAccountId, ServicePlanId planId) {
    return findByGlobalAccount(globalAccountId).filterByServicePlan(planId);
  }

  void removeByServicePlan(GlobalAccountId globalAccountId, ServicePlanId planId) {
    findByServicePlan(globalAccountId, planId).each!(e => remove(e));
  }
  // #region ByServicePlan

}
