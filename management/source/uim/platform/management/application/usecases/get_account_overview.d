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
// import uim.platform.management.domain.types;
import uim.platform.management;

mixin(ShowModule!());

@safe:
/// Use case: generate a dashboard overview for a global account.
class GetAccountOverviewUseCase { // TODO: UIMUseCase {
  private SubaccountRepository subaccountRepo;
  private DirectoryRepository directoryRepo;
  private EntitlementRepository entitlementRepo;
  private EnvironmentInstanceRepository environmentRepo;
  private SubscriptionRepository subscriptionRepo;
  private PlatformEventRepository eventRepo;

  this(SubaccountRepository subaccountRepo, DirectoryRepository directoryRepo, EntitlementRepository entitlementRepo,
      EnvironmentInstanceRepository environmentRepo,
      SubscriptionRepository subscriptionRepo, PlatformEventRepository eventRepo) {
    this.subaccountRepo = subaccountRepo;
    this.directoryRepo = directoryRepo;
    this.entitlementRepo = entitlementRepo;
    this.environmentRepo = environmentRepo;
    this.subscriptionRepo = subscriptionRepo;
    this.eventRepo = eventRepo;
  }

  AccountOverview getOverview(string globalAccountId) {
    return getOverview(GlobalAccountId(globalAccountId));
  }

  AccountOverview getOverview(GlobalAccountId globalAccountId) {
    AccountOverview ov;

    auto subaccounts = subaccountRepo.findByGlobalAccount(globalAccountId);
    ov.totalSubaccounts = subaccounts.length;

    int activeCount = 0;
    foreach (s; subaccounts) {
      if (s.status == SubaccountStatus.active)
        activeCount++;
    }
    ov.activeSubaccounts = activeCount;

    auto dirs = directoryRepo.findByGlobalAccount(globalAccountId);
    ov.totalDirectories = dirs.length;

    auto ents = entitlementRepo.findByGlobalAccount(globalAccountId);
    ov.totalEntitlements = ents.length;

    // Count environments across all subaccounts
    int envCount = 0;
    int subCount = 0;
    foreach (s; subaccounts) {
      auto envs = environmentRepo.findBySubaccount(s.id);
      envCount += cast(int) envs.length;
      auto subs = subscriptionRepo.findBySubaccount(s.id);
      subCount += cast(int) subs.length;
    }
    ov.totalEnvironments = envCount;
    ov.totalSubscriptions = subCount;

    auto events = eventRepo.findByGlobalAccount(globalAccountId);
    ov.recentEventsCount = events.length;

    return ov;
  }
}
