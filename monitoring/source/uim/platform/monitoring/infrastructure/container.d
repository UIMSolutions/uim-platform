module infrastructure.container;

import infrastructure.config;

// Repositories
import infrastructure.persistence.memory.monitored_resource_repo;
import infrastructure.persistence.memory.metric_definition_repo;
import infrastructure.persistence.memory.metric_repo;
import infrastructure.persistence.memory.health_check_repo;
import infrastructure.persistence.memory.health_check_result_repo;
import infrastructure.persistence.memory.alert_rule_repo;
import infrastructure.persistence.memory.alert_repo;
import infrastructure.persistence.memory.notification_channel_repo;

// Use Cases
import application.use_cases.manage_monitored_resources;
import application.use_cases.manage_metrics;
import application.use_cases.manage_health_checks;
import application.use_cases.manage_alert_rules;
import application.use_cases.manage_alerts;
import application.use_cases.manage_notification_channels;
import application.use_cases.evaluate_metrics;
import application.use_cases.get_dashboard;

// Controllers
import presentation.http.resource_controller;
import presentation.http.metric_controller;
import presentation.http.metric_definition_controller;
import presentation.http.check_controller;
import presentation.http.alert_rule_controller;
import presentation.http.alert_controller;
import presentation.http.channel_controller;
import presentation.http.dashboard_controller;
import presentation.http.health_controller;

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
    c.healthController = new HealthController();

    return c;
}
