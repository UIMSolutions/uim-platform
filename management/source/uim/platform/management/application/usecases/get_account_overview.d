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
class GetAccountOverviewUseCase : UIMUseCase {
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

  AccountOverview getOverview(GlobalAccountId gaId) {
    AccountOverview ov;

    auto subaccounts = subaccountRepo.findByGlobalAccount(gaId);
    ov.totalSubaccounts = cast(long) subaccounts.length;

    int activeCount = 0;
    foreach (s; subaccounts) {
      if (s.status == SubaccountStatus.active)
        activeCount++;
    }
    ov.activeSubaccounts = cast(long) activeCount;

    auto dirs = directoryRepo.findByGlobalAccount(gaId);
    ov.totalDirectories = cast(long) dirs.length;

    auto ents = entitlementRepo.findByGlobalAccount(gaId);
    ov.totalEntitlements = cast(long) ents.length;

    // Count environments across all subaccounts
    int envCount = 0;
    int subCount = 0;
    foreach (s; subaccounts) {
      auto envs = environmentRepo.findBySubaccount(s.id);
      envCount += cast(int) envs.length;
      auto subs = subscriptionRepo.findBySubaccount(s.id);
      subCount += cast(int) subs.length;
    }
    ov.totalEnvironments = cast(long) envCount;
    ov.totalSubscriptions = cast(long) subCount;

    auto events = eventRepo.findByGlobalAccount(gaId);
    ov.recentEventsCount = cast(long) events.length;

    return ov;
  }
}
