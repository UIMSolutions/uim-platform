/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.application.usecases.get_account_overview;
// import uim.platform.management.application.dto;
// import uim.platform.management.domain.ports.repositories.global_accounts;
// import uim.platform.management.domain.ports.repositories.subaccounts;
// import uim.platform.management.domain.ports.repositories.directorys;
// import uim.platform.management.domain.ports.repositories.entitlements;
// import uim.platform.management.domain.ports.repositories.environment_instances;
// import uim.platform.management.domain.ports.repositories.subscriptions;
// import uim.platform.management.domain.ports.repositories.platform_events;

import uim.platform.management;

mixin(ShowModule!());

@safe:
/// Use case: generate a dashboard overview for a global account.
class GetAccountOverviewUseCase { // TODO: UIMUseCase {
  protected SubaccountRepository subaccountRepo;
  protected DirectoryRepository directoryRepo;
  protected EntitlementRepository entitlementRepo;
  protected EnvironmentRepository environmentRepo;
  protected SubscriptionRepository subscriptionRepo;
  protected EnvironmentEventRepository eventRepo;

  this(SubaccountRepository subaccountRepo, DirectoryRepository directoryRepo, EntitlementRepository entitlementRepo,
      EnvironmentRepository environmentRepo,
      SubscriptionRepository subscriptionRepo, EnvironmentEventRepository eventRepo) {
    this.subaccountRepo = subaccountRepo;
    this.directoryRepo = directoryRepo;
    this.entitlementRepo = entitlementRepo;
    this.environmentRepo = environmentRepo;
    this.subscriptionRepo = subscriptionRepo;
    this.eventRepo = eventRepo;
  }

  AccountOverview getOverview(TenantId tenantId, GlobalAccountId globalAccountId) {
    AccountOverview ov;

    auto subaccounts = subaccountRepo.findByGlobalAccount(tenantId, globalAccountId);
    ov.totalSubaccounts = subaccounts.length;

    int activeCount = 0;
    foreach (s; subaccounts) {
      if (s.status == SubaccountStatus.active)
        activeCount++;
    }
    ov.activeSubaccounts = activeCount;

    auto dirs = directoryRepo.findByGlobalAccount(tenantId, globalAccountId);
    ov.totalDirectories = dirs.length;

    auto ents = entitlementRepo.findByGlobalAccount(tenantId, globalAccountId);
    ov.totalEntitlements = ents.length;

    // Count environments across all subaccounts
    size_t envCount = 0;
    size_t subCount = 0;
    foreach (s; subaccounts) {
      auto envs = environmentRepo.findBySubaccount(tenantId, s.id);
      envCount += envs.length;
      auto subs = subscriptionRepo.findBySubaccount(tenantId, s.id);
      subCount += subs.length;
    }
    ov.totalEnvironments = envCount;
    ov.totalSubscriptions = subCount;

    auto events = eventRepo.findByGlobalAccount(tenantId, globalAccountId);
    ov.recentEventsCount = events.length;

    return ov;
  }
}
