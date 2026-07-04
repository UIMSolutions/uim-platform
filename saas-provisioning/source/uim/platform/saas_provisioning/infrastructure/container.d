/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.saas_provisioning.infrastructure.container;

import uim.platform.saas_provisioning;

mixin(ShowModule!());

@safe:

/// Dependency-injection container — wires all repos, services, use cases and controllers.
struct Container {
    // Repositories (driven adapters)
    MemorySaasApplicationRepository saasApplicationRepo;
    MemoryAppSubscriptionRepository appSubscriptionRepo;
    MemorySubscriptionJobRepository subscriptionJobRepo;

    // Domain services
    SubscriptionEngine subscriptionEngine;

    // Application use cases
    ManageSaasApplicationsUseCase saasApplicationsUC;
    ManageAppSubscriptionsUseCase appSubscriptionsUC;
    ManageSubscriptionJobsUseCase subscriptionJobsUC;

    // HTTP controllers (driving adapters)
    SaasApplicationController  saasApplicationController;
    AppSubscriptionController  appSubscriptionController;
    SubscriptionJobController  subscriptionJobController;
    HealthController           healthController;
}

/// Build and fully wire the container graph.
Container buildContainer(SrvConfig config) {
    Container c;

    // Repos
    c.saasApplicationRepo = new MemorySaasApplicationRepository();
    c.appSubscriptionRepo = new MemoryAppSubscriptionRepository();
    c.subscriptionJobRepo = new MemorySubscriptionJobRepository();

    // Domain service
    c.subscriptionEngine = new SubscriptionEngine(
        c.saasApplicationRepo,
        c.appSubscriptionRepo,
        c.subscriptionJobRepo);

    // Use cases
    c.saasApplicationsUC = new ManageSaasApplicationsUseCase(c.saasApplicationRepo);
    c.appSubscriptionsUC = new ManageAppSubscriptionsUseCase(c.appSubscriptionRepo, c.subscriptionEngine);
    c.subscriptionJobsUC = new ManageSubscriptionJobsUseCase(c.subscriptionJobRepo);

    // Controllers
    c.saasApplicationController = new SaasApplicationController(c.saasApplicationsUC);
    c.appSubscriptionController = new AppSubscriptionController(c.appSubscriptionsUC);
    c.subscriptionJobController = new SubscriptionJobController(c.subscriptionJobsUC);
    c.healthController          = new HealthController("saas-provisioning");

    return c;
}
