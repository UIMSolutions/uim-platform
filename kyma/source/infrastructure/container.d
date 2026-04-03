/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module infrastructure.container;

import infrastructure.config;

// Repositories
import infrastructure.persistence.memory.environment_repo;
import infrastructure.persistence.memory.namespace_repo;
import infrastructure.persistence.memory.function_repo;
import infrastructure.persistence.memory.api_rule_repo;
import infrastructure.persistence.memory.service_instance_repo;
import infrastructure.persistence.memory.service_binding_repo;
import infrastructure.persistence.memory.event_subscription_repo;
import infrastructure.persistence.memory.module_repo;
import infrastructure.persistence.memory.application_repo;

// Domain services
import domain.services.module_dependency_resolver;
import domain.services.function_validator;

// Use Cases
import application.usecases.manage_environments;
import application.usecases.manage_namespaces;
import application.usecases.manage_functions;
import application.usecases.manage_api_rules;
import application.usecases.manage_service_instances;
import application.usecases.manage_service_bindings;
import application.usecases.manage_event_subscriptions;
import application.usecases.manage_modules;
import application.usecases.manage_applications;

// Controllers
import presentation.http.environment;
import presentation.http.namespace;
import presentation.http.function;
import presentation.http.api_rule;
import presentation.http.service_instance;
import presentation.http.service_binding;
import presentation.http.event_subscription;
import presentation.http.module ;
import presentation.http.application;
import presentation.http.health;



/// Dependency injection container — wires all layers together.
struct Container {
    
    // Repositories (driven adapters)
    InMemoryEnvironmentRepository envRepo;

    InMemoryNamespaceRepository nsRepo;
    InMemoryFunctionRepository fnRepo;
    InMemoryApiRuleRepository apiRuleRepo;
    InMemoryServiceInstanceRepository siRepo;
    InMemoryServiceBindingRepository sbRepo;
    InMemoryEventSubscriptionRepository eventSubRepo;
    InMemoryModuleRepository moduleRepo;
    InMemoryApplicationRepository appRepo;

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
