/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_autoscaler.infrastructure.container;

// import uim.platform.application_autoscaler.infrastructure.config;

// Repositories
// import uim.platform.application_autoscaler.infrastructure.persistence.memory.bindings;
// import uim.platform.application_autoscaler.infrastructure.persistence.memory.custom_metrics;
// import uim.platform.application_autoscaler.infrastructure.persistence.memory.policies;
// import uim.platform.application_autoscaler.infrastructure.persistence.memory.scaling_history;

// Domain services
// import uim.platform.application_autoscaler.domain.services.scaling_evaluator;

// Use cases
// import uim.platform.application_autoscaler.application.usecases.manage.bindings;
// import uim.platform.application_autoscaler.application.usecases.manage.custom_metrics;
// import uim.platform.application_autoscaler.application.usecases.manage.policies;
// import uim.platform.application_autoscaler.application.usecases.manage.scaling_engine;
// import uim.platform.application_autoscaler.application.usecases.manage.scaling_history;

// Controllers
// import uim.platform.application_autoscaler.presentation.http.controllers.bindings;
// import uim.platform.application_autoscaler.presentation.http.controllers.custom_metrics;
// import uim.platform.application_autoscaler.presentation.http.controllers.policies;
// import uim.platform.application_autoscaler.presentation.http.controllers.scaling_engine;
// import uim.platform.application_autoscaler.presentation.http.controllers.scaling_history;
// import uim.platform.service.presentation.controllers.health;

import uim.platform.application_autoscaler;

// mixin(ShowModule!());

@safe: 
struct Container {
  // Repositories (driven adapters)
  MemoryScalingPolicyRepository  policyRepo;
  MemoryAppBindingRepository     bindingRepo;
  MemoryCustomMetricRepository   customMetricRepo;
  MemoryScalingHistoryRepository historyRepo;

  // Domain services
  ScalingEvaluatorService evaluator;

  // Use cases (application layer)
  ManageScalingPoliciesUseCase  managePolicies;
  ManageAppBindingsUseCase      manageBindings;
  ManageCustomMetricsUseCase    manageCustomMetrics;
  ScalingEngineUseCase          scalingEngine;
  ManageScalingHistoryUseCase   manageHistory;

  // Controllers (driving adapters)
  ScalingPolicyController  policyController;
  AppBindingController     bindingController;
  CustomMetricController   customMetricController;
  ScalingEngineController  scalingEngineController;
  ScalingHistoryController historyController;
  HealthController         healthController;
}

Container buildContainer(SrvConfig config) {
  Container c;

  // Infrastructure — repositories
  c.policyRepo       = new MemoryScalingPolicyRepository();
  c.bindingRepo      = new MemoryAppBindingRepository();
  c.customMetricRepo = new MemoryCustomMetricRepository();
  c.historyRepo      = new MemoryScalingHistoryRepository();

  // Domain services
  c.evaluator = new ScalingEvaluatorService();

  // Application use cases
  c.managePolicies      = new ManageScalingPoliciesUseCase(c.policyRepo);
  c.manageBindings      = new ManageAppBindingsUseCase(c.bindingRepo);
  c.manageCustomMetrics = new ManageCustomMetricsUseCase(c.customMetricRepo);
  c.scalingEngine       = new ScalingEngineUseCase(c.policyRepo, c.bindingRepo, c.historyRepo, c.evaluator);
  c.manageHistory       = new ManageScalingHistoryUseCase(c.historyRepo);

  // Presentation controllers
  c.policyController       = new ScalingPolicyController(c.managePolicies);
  c.bindingController      = new AppBindingController(c.manageBindings);
  c.customMetricController = new CustomMetricController(c.manageCustomMetrics);
  c.scalingEngineController= new ScalingEngineController(c.scalingEngine);
  c.historyController      = new ScalingHistoryController(c.manageHistory);
  c.healthController       = new HealthController("application-autoscaler");

  return c;
}
