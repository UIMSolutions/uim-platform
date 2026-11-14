/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.application.usecases.get_account_overview;

import uim.platform.management;

mixin(ShowModule!());

@safe:

/// Use case: generate dashboard figures for a tenant or a single global account.
class GetAccountOverviewUseCase : IGetAccountOverviewUseCase {
  protected IGlobalAccountRepository globalAccountRepo;
  protected ISubaccountRepository subaccountRepo;
  protected IDirectoryRepository directoryRepo;
  protected IEntitlementRepository entitlementRepo;
  protected IEnvironmentRepository environmentRepo;
  protected ISubscriptionRepository subscriptionRepo;
  protected IServicePlanRepository servicePlanRepo;
  protected ILabelRepository labelRepo;
  protected IEnvironmentEventRepository eventRepo;

  this(IGlobalAccountRepository globalAccountRepo, ISubaccountRepository subaccountRepo,
      IDirectoryRepository directoryRepo, IEntitlementRepository entitlementRepo,
      IEnvironmentRepository environmentRepo, ISubscriptionRepository subscriptionRepo,
      IServicePlanRepository servicePlanRepo, ILabelRepository labelRepo, IEnvironmentEventRepository eventRepo) {
    this.globalAccountRepo = globalAccountRepo;
    this.subaccountRepo = subaccountRepo;
    this.directoryRepo = directoryRepo;
    this.entitlementRepo = entitlementRepo;
    this.environmentRepo = environmentRepo;
    this.subscriptionRepo = subscriptionRepo;
    this.servicePlanRepo = servicePlanRepo;
    this.labelRepo = labelRepo;
    this.eventRepo = eventRepo;
  }

  AccountOverview getOverview(TenantId tenantId, GlobalAccountId globalAccountId) {
    AccountOverview ov;

    auto subaccounts = subaccountRepo.findByGlobalAccount(tenantId, globalAccountId);
    ov.totalSubaccounts = subaccounts.length;
    ov.activeSubaccounts = subaccounts.count!(s => s.isActive);
    ov.totalDirectories = directoryRepo.findByGlobalAccount(tenantId, globalAccountId).length;
    ov.totalEntitlements = entitlementRepo.findByGlobalAccount(tenantId, globalAccountId).length;

    // Environments and subscriptions carry their global account, so one scan each suffices.
    ov.totalEnvironments = environmentRepo.findByTenant(tenantId).count!(e => e.globalAccountId == globalAccountId);
    ov.totalSubscriptions = subscriptionRepo.findByTenant(tenantId).count!(s => s.globalAccountId == globalAccountId);
    ov.recentEventsCount = eventRepo.findByGlobalAccount(tenantId, globalAccountId).length;
    return ov;
  }

  TenantOverview getTenantOverview(TenantId tenantId) {
    TenantOverview ov;
    ov.tenantId = tenantId;

    auto gas = globalAccountRepo.findByTenant(tenantId);
    ov.globalAccounts = gas.length;
    ov.activeGlobalAccounts = gas.count!(g => g.status == GlobalAccountStatus.active);
    ov.suspendedGlobalAccounts = gas.count!(g => g.status == GlobalAccountStatus.suspended);

    ov.directories = directoryRepo.countByTenant(tenantId);

    auto subs = subaccountRepo.findByTenant(tenantId);
    ov.subaccounts = subs.length;
    ov.activeSubaccounts = subs.count!(s => s.status == SubaccountStatus.active);
    ov.suspendedSubaccounts = subs.count!(s => s.status == SubaccountStatus.suspended);

    foreach (e; entitlementRepo.findByTenant(tenantId)) {
      ov.entitlements++;
      if (e.status == EntitlementStatus.revoked) {
        ov.revokedEntitlements++;
        continue;
      }
      if (e.isOverQuota)
        ov.overQuotaEntitlements++;
      if (!e.unlimited)
        ov.quotaAssigned += e.quotaAssigned;
      ov.quotaUsed += e.quotaUsed;
    }

    ov.environments = environmentRepo.countByTenant(tenantId);
    ov.subscriptions = subscriptionRepo.findByTenant(tenantId).count!(s => s.isLive);
    ov.servicePlans = servicePlanRepo.countByTenant(tenantId);
    ov.labels = labelRepo.countByTenant(tenantId);

    foreach (e; eventRepo.findByTenant(tenantId)) {
      ov.events++;
      if (e.severity >= EnvironmentEventSeverity.warning)
        ov.warningEvents++;
      if (e.timestamp > ov.lastEventAt)
        ov.lastEventAt = e.timestamp;
    }
    return ov;
  }
}
