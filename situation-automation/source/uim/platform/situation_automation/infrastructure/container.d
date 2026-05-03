/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.situation_automation.infrastructure.container;

import uim.platform.situation_automation;

mixin(ShowModule!());

@safe:
struct Container {
    // Repositories (driven adapters)
    MemorySituationTemplateRepository templateRepo;
    MemorySituationInstanceRepository instanceRepo;
    MemorySituationActionRepository actionRepo;
    MemoryAutomationRuleRepository ruleRepo;
    MemoryEntityTypeRepository entityTypeRepo;
    MemoryDataContextRepository dataContextRepo;
    MemoryNotificationRepository notificationRepo;
    MemoryDashboardRepository dashboardRepo;

    // Use cases (application layer)
    ManageSituationTemplatesUseCase manageTemplates;
    ManageSituationInstancesUseCase manageInstances;
    ManageSituationActionsUseCase manageActions;
    ManageAutomationRulesUseCase manageRules;
    ManageEntityTypesUseCase manageEntityTypes;
    ManageDataContextsUseCase manageDataContexts;
    ManageNotificationsUseCase manageNotifications;
    ManageDashboardsUseCase manageDashboards;

    // Controllers (driving adapters)
    SituationTemplateController templateController;
    SituationInstanceController instanceController;
    SituationActionController actionController;
    AutomationRuleController ruleController;
    EntityTypeController entityTypeController;
    DataContextController dataContextController;
    NotificationController notificationController;
    DashboardController dashboardController;
    HealthController healthController;
}

Container buildContainer(SrvConfig config) {
    Container c;

    // Infrastructure adapters
    c.templateRepo = new MemorySituationTemplateRepository();
    c.instanceRepo = new MemorySituationInstanceRepository();
    c.actionRepo = new MemorySituationActionRepository();
    c.ruleRepo = new MemoryAutomationRuleRepository();
    c.entityTypeRepo = new MemoryEntityTypeRepository();
    c.dataContextRepo = new MemoryDataContextRepository();
    c.notificationRepo = new MemoryNotificationRepository();
    c.dashboardRepo = new MemoryDashboardRepository();

    // Application use cases
    c.manageTemplates = new ManageSituationTemplatesUseCase(c.templateRepo);
    c.manageInstances = new ManageSituationInstancesUseCase(c.instanceRepo);
    c.manageActions = new ManageSituationActionsUseCase(c.actionRepo);
    c.manageRules = new ManageAutomationRulesUseCase(c.ruleRepo);
    c.manageEntityTypes = new ManageEntityTypesUseCase(c.entityTypeRepo);
    c.manageDataContexts = new ManageDataContextsUseCase(c.dataContextRepo);
    c.manageNotifications = new ManageNotificationsUseCase(c.notificationRepo);
    c.manageDashboards = new ManageDashboardsUseCase(c.dashboardRepo);

    // Presentation controllers
    c.templateController = new SituationTemplateController(c.manageTemplates);
    c.instanceController = new SituationInstanceController(c.manageInstances);
    c.actionController = new SituationActionController(c.manageActions);
    c.ruleController = new AutomationRuleController(c.manageRules);
    c.entityTypeController = new EntityTypeController(c.manageEntityTypes);
    c.dataContextController = new DataContextController(c.manageDataContexts);
    c.notificationController = new NotificationController(c.manageNotifications);
    c.dashboardController = new DashboardController(c.manageDashboards);
    c.healthController = new HealthController("situation-automation", "1.0.0");

    return c;
}
