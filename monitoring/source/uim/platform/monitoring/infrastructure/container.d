/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.monitoring.infrastructure.container;

import uim.platform.monitoring.infrastructure.config;

// Repositories
import uim.platform.monitoring.infrastructure.persistence.memory.monitored_resources;
import uim.platform.monitoring.infrastructure.persistence.memory.metric_definitions;
import uim.platform.monitoring.infrastructure.persistence.memory.metrics;
import uim.platform.monitoring.infrastructure.persistence.memory.health_checks;
import uim.platform.monitoring.infrastructure.persistence.memory.health_check_results;
import uim.platform.monitoring.infrastructure.persistence.memory.alert_rules;
import uim.platform.monitoring.infrastructure.persistence.memory.alerts;
import uim.platform.monitoring.infrastructure.persistence.memory.notification_channels;

// Use Cases
import uim.platform.monitoring.application.usecases.manage.monitored_resources;
import uim.platform.monitoring.application.usecases.manage.metrics;
import uim.platform.monitoring.application.usecases.manage.health_checks;
import uim.platform.monitoring.application.usecases.manage.alert_rules;
import uim.platform.monitoring.application.usecases.manage.alerts;
import uim.platform.monitoring.application.usecases.manage.notification_channels;
import uim.platform.monitoring.application.usecases.evaluate_metrics;
import uim.platform.monitoring.application.usecases.get_dashboard;

// Controllers
import uim.platform.monitoring.presentation.http.controllers.resource;
import uim.platform.monitoring.presentation.http.controllers.metric;
import uim.platform.monitoring.presentation.http.controllers.metric_definition;
import uim.platform.monitoring.presentation.http.controllers.check;
import uim.platform.monitoring.presentation.http.controllers.alert_rule;
import uim.platform.monitoring.presentation.http.controllers.alert;
import uim.platform.monitoring.presentation.http.controllers.channel;
import uim.platform.monitoring.presentation.http.controllers.dashboard;
// import uim.platform.monitoring;

mixin(ShowModule!());

@safe:
/// Dependency injection container - wires all layers together.
struct Container {
  // Repositories (driven adapters)
  MemoryMonitoredResourceRepository resourceRepo;
  MemoryMetricDefinitionRepository metricDefRepo;
  MemoryMetricRepository metricRepo;
  MemoryHealthCheckRepository checkRepo;
  MemoryHealthCheckResultRepository checkResultRepo;
  MemoryAlertRuleRepository ruleRepo;
  MemoryAlertRepository alertRepo;
  MemoryNotificationChannelRepository channelRepo;

  // Use cases (application layer)
  ManageMonitoredResourcesUseCase manageResources;
  ManageMetricsUseCase manageMetrics;
  ManageHealthChecksUseCase manageChecks;
  ManageAlertRulesUseCase manageRules;
  ManageAlertsUseCase manageAlerts;
  ManageNotificationChannelsUseCase manageChannels;
  EvaluateMetricsUseCase evaluateMetrics;
  GetDashboardUseCase getDashboard;

  // Controllers (driving adapters)
  ResourceController resourceController;
  MetricController metricController;
  MetricDefinitionController metricDefinitionController;
  CheckController checkController;
  AlertRuleController alertRuleController;
  AlertController alertController;
  ChannelController channelController;
  DashboardController dashboardController;
  HealthController healthController;
}

/// Build the full dependency graph.
Container buildContainer(AppConfig config) {
  Container c;

  // Infrastructure adapters
  c.resourceRepo = new MemoryMonitoredResourceRepository();
  c.metricDefRepo = new MemoryMetricDefinitionRepository();
  c.metricRepo = new MemoryMetricRepository();
  c.checkRepo = new MemoryHealthCheckRepository();
  c.checkResultRepo = new MemoryHealthCheckResultRepository();
  c.ruleRepo = new MemoryAlertRuleRepository();
  c.alertRepo = new MemoryAlertRepository();
  c.channelRepo = new MemoryNotificationChannelRepository();

  // Application use cases
  c.manageResources = new ManageMonitoredResourcesUseCase(c.resourceRepo);
  c.manageMetrics = new ManageMetricsUseCase(c.metricRepo, c.metricDefRepo);
  c.manageChecks = new ManageHealthChecksUseCase(c.checkRepo, c.checkResultRepo);
  c.manageRules = new ManageAlertRulesUseCase(c.ruleRepo);
  c.manageAlerts = new ManageAlertsUseCase(c.alertRepo);
  c.manageChannels = new ManageNotificationChannelsUseCase(c.channelRepo);
  c.evaluateMetrics = new EvaluateMetricsUseCase(c.ruleRepo, c.metricRepo, c.manageAlerts);
  c.getDashboard = new GetDashboardUseCase(c.resourceRepo, c.alertRepo,
      c.checkRepo, c.checkResultRepo, c.metricDefRepo, c.channelRepo);

  // Presentation controllers
  c.resourceController = new ResourceController(c.manageResources);
  c.metricController = new MetricController(c.manageMetrics);
  c.metricDefinitionController = new MetricDefinitionController(c.manageMetrics);
  c.checkController = new CheckController(c.manageChecks);
  c.alertRuleController = new AlertRuleController(c.manageRules);
  c.alertController = new AlertController(c.manageAlerts);
  c.channelController = new ChannelController(c.manageChannels);
  c.dashboardController = new DashboardController(c.getDashboard);
  c.healthController = new HealthController("monitoring");

  return c;
}
