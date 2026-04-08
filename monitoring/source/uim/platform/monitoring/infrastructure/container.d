/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.monitoring.infrastructure.container;

import uim.platform.monitoring.infrastructure.config;

// Repositories
import uim.platform.monitoring.infrastructure.persistence.memory.monitored_resource;
import uim.platform.monitoring.infrastructure.persistence.memory.metric_definition;
import uim.platform.monitoring.infrastructure.persistence.memory.metric;
import uim.platform.monitoring.infrastructure.persistence.memory.health_check;
import uim.platform.monitoring.infrastructure.persistence.memory.health_check_result;
import uim.platform.monitoring.infrastructure.persistence.memory.alert_rule;
import uim.platform.monitoring.infrastructure.persistence.memory.alert;
import uim.platform.monitoring.infrastructure.persistence.memory.notification_channel;

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
import uim.platform.monitoring.presentation.http.resource;
import uim.platform.monitoring.presentation.http.metric;
import uim.platform.monitoring.presentation.http.metric_definition;
import uim.platform.monitoring.presentation.http.check;
import uim.platform.monitoring.presentation.http.alert_rule;
import uim.platform.monitoring.presentation.http.alert;
import uim.platform.monitoring.presentation.http.channel;
import uim.platform.monitoring.presentation.http.dashboard;
import uim.platform.monitoring.presentation.http.health;

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
