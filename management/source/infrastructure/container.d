module infrastructure.container;

import infrastructure.config;

// Repositories
import infrastructure.persistence.memory.global_account_repo;
import infrastructure.persistence.memory.directory_repo;
import infrastructure.persistence.memory.subaccount_repo;
import infrastructure.persistence.memory.entitlement_repo;
import infrastructure.persistence.memory.environment_instance_repo;
import infrastructure.persistence.memory.subscription_repo;
import infrastructure.persistence.memory.service_plan_repo;
import infrastructure.persistence.memory.platform_event_repo;
import infrastructure.persistence.memory.label_repo;

// Domain Services
import domain.services.entitlement_evaluator;
import domain.services.environment_provisioner;

// Use Cases
import application.usecases.manage_global_accounts;
import application.usecases.manage_directories;
import application.usecases.manage_subaccounts;
import application.usecases.manage_entitlements;
import application.usecases.manage_environment_instances;
import application.usecases.manage_subscriptions;
import application.usecases.manage_service_plans;
import application.usecases.manage_labels;
import application.usecases.query_platform_events;
import application.usecases.get_account_overview;

// Controllers
import presentation.http.global_account_controller;
import presentation.http.directory_controller;
import presentation.http.subaccount_controller;
import presentation.http.entitlement_controller;
import presentation.http.environment_controller;
import presentation.http.subscription_controller;
import presentation.http.service_plan_controller;
import presentation.http.label_controller;
import presentation.http.event_controller;
import presentation.http.overview_controller;
import presentation.http.health_controller;

/// Dependency injection container — wires all layers together.
struct Container
{
    // Repositories (driven adapters)
    InMemoryGlobalAccountRepository globalAccountRepo;
    InMemoryDirectoryRepository directoryRepo;
    InMemorySubaccountRepository subaccountRepo;
    InMemoryEntitlementRepository entitlementRepo;
    InMemoryEnvironmentInstanceRepository environmentRepo;
    InMemorySubscriptionRepository subscriptionRepo;
    InMemoryServicePlanRepository servicePlanRepo;
    InMemoryPlatformEventRepository eventRepo;
    InMemoryLabelRepository labelRepo;

    // Domain services
    EntitlementEvaluator entitlementEvaluator;
    EnvironmentProvisioner environmentProvisioner;

    // Use cases (application layer)
    ManageGlobalAccountsUseCase manageGlobalAccounts;
    ManageDirectoriesUseCase manageDirectories;
    ManageSubaccountsUseCase manageSubaccounts;
    ManageEntitlementsUseCase manageEntitlements;
    ManageEnvironmentInstancesUseCase manageEnvironments;
    ManageSubscriptionsUseCase manageSubscriptions;
    ManageServicePlansUseCase manageServicePlans;
    ManageLabelsUseCase manageLabels;
    QueryPlatformEventsUseCase queryEvents;
    GetAccountOverviewUseCase getOverview;

    // Controllers (driving adapters)
    GlobalAccountController globalAccountController;
    DirectoryController directoryController;
    SubaccountController subaccountController;
    EntitlementController entitlementController;
    EnvironmentController environmentController;
    SubscriptionController subscriptionController;
    ServicePlanController servicePlanController;
    LabelController labelController;
    EventController eventController;
    OverviewController overviewController;
    HealthController healthController;
}

/// Build the full dependency graph.
Container buildContainer(AppConfig config)
{
    Container c;

    // Infrastructure adapters
    c.globalAccountRepo = new MemoryGlobalAccountRepository();
    c.directoryRepo = new MemoryDirectoryRepository();
    c.subaccountRepo = new MemorySubaccountRepository();
    c.entitlementRepo = new MemoryEntitlementRepository();
    c.environmentRepo = new MemoryEnvironmentInstanceRepository();
    c.subscriptionRepo = new MemorySubscriptionRepository();
    c.servicePlanRepo = new MemoryServicePlanRepository();
    c.eventRepo = new MemoryPlatformEventRepository();
    c.labelRepo = new MemoryLabelRepository();

    // Domain services
    c.entitlementEvaluator = new EntitlementEvaluator();
    c.environmentProvisioner = new EnvironmentProvisioner();

    // Application use cases
    c.manageGlobalAccounts = new ManageGlobalAccountsUseCase(c.globalAccountRepo, c.eventRepo);
    c.manageDirectories = new ManageDirectoriesUseCase(c.directoryRepo);
    c.manageSubaccounts = new ManageSubaccountsUseCase(c.subaccountRepo, c.eventRepo);
    c.manageEntitlements = new ManageEntitlementsUseCase(c.entitlementRepo, c.entitlementEvaluator);
    c.manageEnvironments = new ManageEnvironmentInstancesUseCase(
        c.environmentRepo, c.subaccountRepo, c.environmentProvisioner);
    c.manageSubscriptions = new ManageSubscriptionsUseCase(c.subscriptionRepo, c.eventRepo);
    c.manageServicePlans = new ManageServicePlansUseCase(c.servicePlanRepo);
    c.manageLabels = new ManageLabelsUseCase(c.labelRepo);
    c.queryEvents = new QueryPlatformEventsUseCase(c.eventRepo);
    c.getOverview = new GetAccountOverviewUseCase(
        c.subaccountRepo, c.directoryRepo, c.entitlementRepo,
        c.environmentRepo, c.subscriptionRepo, c.eventRepo);

    // Presentation controllers
    c.globalAccountController = new GlobalAccountController(c.manageGlobalAccounts);
    c.directoryController = new DirectoryController(c.manageDirectories);
    c.subaccountController = new SubaccountController(c.manageSubaccounts);
    c.entitlementController = new EntitlementController(c.manageEntitlements);
    c.environmentController = new EnvironmentController(c.manageEnvironments);
    c.subscriptionController = new SubscriptionController(c.manageSubscriptions);
    c.servicePlanController = new ServicePlanController(c.manageServicePlans);
    c.labelController = new LabelController(c.manageLabels);
    c.eventController = new EventController(c.queryEvents);
    c.overviewController = new OverviewController(c.getOverview);
    c.healthController = new HealthController();

    return c;
}
