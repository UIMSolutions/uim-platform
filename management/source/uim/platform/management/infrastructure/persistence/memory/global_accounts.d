/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.infrastructure.persistence.memory.global_accounts;

// import uim.platform.management.domain.entities.global_account;
// import uim.platform.management.domain.ports.repositories.global_accounts;
// 
//  

import uim.platform.management;

// mixin(ShowModule!());
@safe:

class MemoryGlobalAccountRepository : TenantRepository!(GlobalAccount, GlobalAccountId), GlobalAccountRepository {
  // TODO: mixin IdRepositoryTemplate!(MemoryGlobalAccountRepository, GlobalAccount, GlobalAccountId);

  size_t countByStatus(TenantId tenantId, GlobalAccountStatus status) {
    return findByStatus(tenantId, status).length;
  }

  GlobalAccount[] filterByStatus(GlobalAccount[] items, GlobalAccountStatus status) {
    return items.filter!(e => e.status == status).array;
  }

  GlobalAccount[] findByStatus(TenantId tenantId, GlobalAccountStatus status) {
    return filterByStatus(findByTenant(tenantId), status);
  }

  void removeByStatus(TenantId tenantId, GlobalAccountStatus status) {
    findByStatus(tenantId, status).each!(e => remove(e));
  }

}
///
unittest {
  auto repo = new MemoryGlobalAccountRepository();
  auto tenantId = TenantId("tenant1");
  auto gaId = GlobalAccountId("ga1");
  auto ga = GlobalAccount(tenantId);
  ga.id = gaId;
  ga.displayName = "Global Account 1";
  ga.status = GlobalAccountStatus.active;

  repo.save(ga);

  assert(repo.countByStatus(tenantId, GlobalAccountStatus.active) == 1);
  assert(repo.findByStatus(tenantId, GlobalAccountStatus.active).length == 1);
  assert(repo.findByStatus(tenantId, GlobalAccountStatus.active)[0].id == gaId);

  repo.removeByStatus(tenantId, GlobalAccountStatus.active);
  assert(repo.countByStatus(tenantId, GlobalAccountStatus.active) == 0);
}
