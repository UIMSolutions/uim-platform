/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.xyz.infrastructure.container;

import uim.platform.xyz.infrastructure.config;

// Repositories
import uim.platform.xyz.infrastructure.persistence.memory.environment_repo;
import uim.platform.xyz.infrastructure.persistence.memory.namespace_repo;
import uim.platform.xyz.infrastructure.persistence.memory.function_repo;
import uim.platform.xyz.infrastructure.persistence.memory.api_rule_repo;
import uim.platform.xyz.infrastructure.persistence.memory.service_instance_repo;
import uim.platform.xyz.infrastructure.persistence.memory.service_binding_repo;
import uim.platform.xyz.infrastructure.persistence.memory.event_subscription_repo;
import uim.platform.xyz.infrastructure.persistence.memory.module_repo;
import uim.platform.xyz.infrastructure.persistence.memory.application_repo;

// Domain services
import uim.platform.xyz.domain.services.module_dependency_resolver;
import uim.platform.xyz.domain.services.function_validator;

// Use Cases
import uim.platform.xyz.application.usecases.manage_environments;
import uim.platform.xyz.application.usecases.manage_namespaces;
import uim.platform.xyz.application.usecases.manage_functions;
import uim.platform.xyz.application.usecases.manage_api_rules;
import uim.platform.xyz.application.usecases.manage_service_instances;
import uim.platform.xyz.application.usecases.manage_service_bindings;
import uim.platform.xyz.application.usecases.manage_event_subscriptions;
import uim.platform.xyz.application.usecases.manage_modules;
import uim.platform.xyz.application.usecases.manage_applications;

// Controllers
import uim.platform.xyz.presentation.http.environment;
import uim.platform.xyz.presentation.http.namespace;
import uim.platform.xyz.presentation.http.function;
import uim.platform.xyz.presentation.http.api_rule;
import uim.platform.xyz.presentation.http.service_instance;
import uim.platform.xyz.presentation.http.service_binding;
import uim.platform.xyz.presentation.http.event_subscription;
import uim.platform.xyz.presentation.http.module ;
import uim.platform.xyz.presentation.http.application;
import uim.platform.xyz.presentation.http.health;



/// Dependency injection container — wires all layers together.
struct Container {
    
    // Repositories (driven adapters)
    MemoryEnvironmentRepository envRepo;

    MemoryNamespaceRepository nsRepo;
    MemoryFunctionRepository fnRepo;
    MemoryApiRuleRepository apiRuleRepo;
    MemoryServiceInstanceRepository siRepo;
    MemoryServiceBindingRepository sbRepo;
    MemoryEventSubscriptionRepository eventSubRepo;
    MemoryModuleRepository moduleRepo;
    MemoryApplicationRepository appRepo;

    // Domain services
    ModuleDependencyResolver depResolver;
    FunctionValidator fnValidator;

    // Use cases (application layer)
    ManageEnvironmentsUseCase manageEnvironments;
    ManageNamespacesUseCase manageNamespaces;
    ManageFunctionsUseCase manageFunctions;
    ManageApiRulesUseCase manageApiRules;
    ManageServiceInstancesUseCase manageServiceInstances;
    ManageServiceBindingsUseCase manageServiceBindings;
    ManageEventSubscriptionsUseCase manageEventSubscriptions;
    ManageModulesUseCase manageModules;
    ManageApplicationsUseCase manageApplications;

    // Controllers (driving adapters)
    EnvironmentController environmentController;
    NamespaceController namespaceController;
    FunctionController functionController;
    ApiRuleController apiRuleController;
    ServiceInstanceController serviceInstanceController;
    ServiceBindingController serviceBindingController;
    EventSubscriptionController eventSubscriptionController;
    ModuleController moduleController;
    ApplicationController applicationController;
    HealthController healthController;
}

/// Build the full dependency graph.
Container buildContainer(AppConfig config) {
    Container c;

    // Infrastructure adapters
    c.envRepo = new MemoryEnvironmentRepository();
    c.nsRepo = new MemoryNamespaceRepository();
    c.fnRepo = new MemoryFunctionRepository();
    c.apiRuleRepo = new MemoryApiRuleRepository();
    c.siRepo = new MemoryServiceInstanceRepository();
    c.sbRepo = new MemoryServiceBindingRepository();
    c.eventSubRepo = new MemoryEventSubscriptionRepository();
    c.moduleRepo = new MemoryModuleRepository();
    c.appRepo = new MemoryApplicationRepository();

    // Domain services
    c.depResolver = new ModuleDependencyResolver();
    c.fnValidator = new FunctionValidator();

    // Application use cases
    c.manageEnvironments = new ManageEnvironmentsUseCase(c.envRepo);
    c.manageNamespaces = new ManageNamespacesUseCase(c.nsRepo);
    c.manageFunctions = new ManageFunctionsUseCase(c.fnRepo, c.fnValidator);
    c.manageApiRules = new ManageApiRulesUseCase(c.apiRuleRepo);
    c.manageServiceInstances = new ManageServiceInstancesUseCase(c.siRepo);
    c.manageServiceBindings = new ManageServiceBindingsUseCase(c.sbRepo);
    c.manageEventSubscriptions = new ManageEventSubscriptionsUseCase(c.eventSubRepo);
    c.manageModules = new ManageModulesUseCase(c.moduleRepo, c.depResolver);
    c.manageApplications = new ManageApplicationsUseCase(c.appRepo);

    // Presentation controllers
    c.environmentController = new EnvironmentController(c.manageEnvironments);
    c.namespaceController = new NamespaceController(c.manageNamespaces);
    c.functionController = new FunctionController(c.manageFunctions);
    c.apiRuleController = new ApiRuleController(c.manageApiRules);
    c.serviceInstanceController = new ServiceInstanceController(c.manageServiceInstances);
    c.serviceBindingController = new ServiceBindingController(c.manageServiceBindings);
    c.eventSubscriptionController = new EventSubscriptionController(c.manageEventSubscriptions);
    c.moduleController = new ModuleController(c.manageModules);
    c.applicationController = new ApplicationController(c.manageApplications);
    c.healthController = new HealthController("kyma-runtime");

    return c;
}
