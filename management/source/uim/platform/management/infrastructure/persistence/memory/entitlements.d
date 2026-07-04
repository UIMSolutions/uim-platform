/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.infrastructure.persistence.memory.entitlements;

// import uim.platform.management.domain.entities.entitlement;
// import uim.platform.management.domain.ports.repositories.entitlements;
// 
//  

import uim.platform.management;

mixin(ShowModule!());
@safe:

class MemoryEntitlementRepository : TenantRepository!(Entitlement, EntitlementId), EntitlementRepository {
  // TODO: mixin IdRepositoryTemplate!(MemoryEntitlementRepository, Entitlement, EntitlementId);

  // #region ByGlobalAccount
  size_t countByGlobalAccount(TenantId tenantId, GlobalAccountId globalAccountId) {
    return findByGlobalAccount(tenantId, globalAccountId).length;
  }

  Entitlement[] filterByGlobalAccount(Entitlement[] items, GlobalAccountId globalAccountId) {
    return items.filter!(e => e.globalAccountId == globalAccountId).array;
  }

  Entitlement[] findByGlobalAccount(TenantId tenantId, GlobalAccountId globalAccountId) {
    return filterByGlobalAccount(findByTenant(tenantId), globalAccountId);
  }

  void removeByGlobalAccount(TenantId tenantId, GlobalAccountId globalAccountId) {
    findByGlobalAccount(tenantId, globalAccountId).each!(e => remove(e));
  }
  // #endregion ByGlobalAccount

  // #region BySubaccount
  size_t countBySubaccount(TenantId tenantId, SubaccountId subaccountId) {
    return findBySubaccount(tenantId, subaccountId).length;
  }

  Entitlement[] filterBySubaccount(Entitlement[] items, SubaccountId subaccountId) {
    return items.filter!(e => e.subaccountId == subaccountId).array;
  }

  Entitlement[] findBySubaccount(TenantId tenantId, SubaccountId subaccountId) {
    return filterBySubaccount(findByTenant(tenantId), subaccountId);
  }

  void removeBySubaccount(TenantId tenantId, SubaccountId subaccountId) {
    findBySubaccount(tenantId, subaccountId).each!(e => remove(e));
  }
  // #endregion BySubaccount

  // #region ByDirectory
  size_t countByDirectory(TenantId tenantId, DirectoryId directoryId) {
    return findByDirectory(tenantId, directoryId).length;
  } 

Entitlement[] filterByDirectory(Entitlement[] items, DirectoryId directoryId) {
    return items.filter!(e => e.directoryId == directoryId).array;
  }

  Entitlement[] findByDirectory(TenantId tenantId, DirectoryId directoryId) {
    return filterByDirectory(findByTenant(tenantId), directoryId);
  }

  void removeByDirectory(TenantId tenantId, DirectoryId directoryId) {
    findByDirectory(tenantId, directoryId).each!(e => remove(e));
  }
  // #endregion ByDirectory

  // #region ByServicePlan
  size_t countByServicePlan(TenantId tenantId, GlobalAccountId globalAccountId, ServicePlanId planId) {
    return findByServicePlan(tenantId, globalAccountId, planId).length;
  }

  Entitlement[] filterByServicePlan(Entitlement[] items, ServicePlanId planId) {
    return items.filter!(e => e.servicePlanId == planId).array;
  }

  Entitlement[] findByServicePlan(TenantId tenantId, GlobalAccountId globalAccountId, ServicePlanId planId) {
    return filterByServicePlan(filterByGlobalAccount(findByTenant(tenantId), globalAccountId), planId);
  }

  void removeByServicePlan(TenantId tenantId, GlobalAccountId globalAccountId, ServicePlanId planId) {
    findByServicePlan(tenantId, globalAccountId, planId).each!(e => remove(e));
  }
  // #region ByServicePlan

}
///
unittest {
  auto repo = new MemoryEntitlementRepository();

  auto tenantId = TenantId("tenant1");
  auto globalAccountId = GlobalAccountId("ga1");
  auto subaccountId = SubaccountId("sa1");
  auto directoryId = DirectoryId("dir1");
  auto servicePlanId = ServicePlanId("plan1");

  // Create sample entitlements
  Entitlement e1;
  e1.id = EntitlementId("ent1");
  e1.tenantId = tenantId;
  e1.globalAccountId = globalAccountId;
  e1.subaccountId = subaccountId;
  e1.directoryId = directoryId;
  e1.servicePlanId = servicePlanId;

  repo.save(e1);
  
  // Test findByGlobalAccount
  auto entitlementsByGA = repo.findByGlobalAccount(tenantId, globalAccountId);
  assert(entitlementsByGA.length == 1);
  assert(entitlementsByGA[0].id == e1.id);

  // Test findBySubaccount
  auto entitlementsBySA = repo.findBySubaccount(tenantId, subaccountId);
  assert(entitlementsBySA.length == 1);
  assert(entitlementsBySA[0].id == e1.id);

}