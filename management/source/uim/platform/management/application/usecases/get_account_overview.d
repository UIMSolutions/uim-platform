module uim.platform.management.application.usecases.get_account_overview;

// import uim.platform.management.application.dto;
// import uim.platform.management.domain.ports.global_account_repository;
// import uim.platform.management.domain.ports.subaccount_repository;
// import uim.platform.management.domain.ports.directory_repository;
// import uim.platform.management.domain.ports.entitlement_repository;
// import uim.platform.management.domain.ports.environment_instance_repository;
// import uim.platform.management.domain.ports.subscription_repository;
// import uim.platform.management.domain.ports.platform_event_repository;
// import uim.platform.management.domain.types;
import uim.platform.management;

mixin(ShowModule!());

@safe:
/// Use case: generate a dashboard overview for a global account.
class GetAccountOverviewUseCase {
    private SubaccountRepository subaccountRepo;
    private DirectoryRepository directoryRepo;
    private EntitlementRepository entitlementRepo;
    private EnvironmentInstanceRepository environmentRepo;
    private SubscriptionRepository subscriptionRepo;
    private PlatformEventRepository eventRepo;

    this(SubaccountRepository subaccountRepo, DirectoryRepository directoryRepo,
        EntitlementRepository entitlementRepo, EnvironmentInstanceRepository environmentRepo,
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
        ov.totalSubaccounts = cast(long)subaccounts.length;

        int activeCount = 0;
        foreach (ref s; subaccounts) {
            if (s.status == SubaccountStatus.active)
                activeCount++;
        }
        ov.activeSubaccounts = cast(long)activeCount;

        auto dirs = directoryRepo.findByGlobalAccount(gaId);
        ov.totalDirectories = cast(long)dirs.length;

        auto ents = entitlementRepo.findByGlobalAccount(gaId);
        ov.totalEntitlements = cast(long)ents.length;

        // Count environments across all subaccounts
        int envCount = 0;
        int subCount = 0;
        foreach (ref s; subaccounts) {
            auto envs = environmentRepo.findBySubaccount(s.id);
            envCount += cast(int)envs.length;
            auto subs = subscriptionRepo.findBySubaccount(s.id);
            subCount += cast(int)subs.length;
        }
        ov.totalEnvironments = cast(long)envCount;
        ov.totalSubscriptions = cast(long)subCount;

        auto events = eventRepo.findByGlobalAccount(gaId);
        ov.recentEventsCount = cast(long)events.length;

        return ov;
    }
}
