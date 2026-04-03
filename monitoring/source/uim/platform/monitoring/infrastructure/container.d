/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.monitoring.infrastructure.container;

import uim.platform.monitoring.infrastructure.config;

// Repositories
import uim.platform.monitoring.infrastructure.persistence.memory.monitored_resource_repo;
import uim.platform.monitoring.infrastructure.persistence.memory.metric_definition_repo;
import uim.platform.monitoring.infrastructure.persistence.memory.metric_repo;
import uim.platform.monitoring.infrastructure.persistence.memory.health_check_repo;
import uim.platform.monitoring.infrastructure.persistence.memory.health_check_result_repo;
import uim.platform.monitoring.infrastructure.persistence.memory.alert_rule_repo;
import uim.platform.monitoring.infrastructure.persistence.memory.alert_repo;
import uim.platform.monitoring.infrastructure.persistence.memory.notification_channel_repo;

// Use Cases
import application.usecases.manage_monitored_resources;
import application.usecases.manage_metrics;
import application.usecases.manage_health_checks;
import application.usecases.manage_alert_rules;
import application.usecases.manage_alerts;
import application.usecases.manage_notification_channels;
import application.usecases.evaluate_metrics;
import application.usecases.get_dashboard;

// Controllers
import presentation.http.resource;
import presentation.http.metric;
import presentation.http.metric_definition;
import presentation.http.check;
import presentation.http.alert_rule;
import presentation.http.alert;
import presentation.http.channel;
import presentation.http.dashboard;
import presentation.http.health;

/// Dependency injection container - wires all layers together.
struct Container
{
    // Repositories (driven adapters)
    InMemoryMonitoredResourceRepository resourceRepo;
    InMemoryMetricDefinitionRepository metricDefRepo;
    InMemoryMetricRepository metricRepo;
    InMemoryHealthCheckRepository checkRepo;
    InMemoryHealthCheckResultRepository checkResultRepo;
    InMemoryAlertRuleRepository ruleRepo;
    InMemoryAlertRepository alertRepo;
    InMemoryNotificationChannelRepository channelRepo;

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
Container buildContainer(AppConfig config)
{
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
    c.getDashboard = new GetDashboardUseCase(c.resourceRepo, c.alertRepo, c.checkRepo, c.checkResultRepo, c.metricDefRepo, c.channelRepo);

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
