/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.monitoring.application.usecases.get_dashboard;

// import uim.platform.monitoring.application.dto;
// import uim.platform.monitoring.domain.entities.alert;
// import uim.platform.monitoring.domain.entities.health_check_result;
// import uim.platform.monitoring.domain.entities.monitored_resource;
// import uim.platform.monitoring.domain.ports.repositories.alerts;
// import uim.platform.monitoring.domain.ports.repositories.health_checks;
// import uim.platform.monitoring.domain.ports.repositories.health_check_results;
// import uim.platform.monitoring.domain.ports.repositories.metric_definitions;
// import uim.platform.monitoring.domain.ports.repositories.monitored_resources;
// import uim.platform.monitoring.domain.ports.repositories.notification_channels;
// import uim.platform.monitoring.domain.types;
import uim.platform.monitoring;

mixin(ShowModule!());

@safe:
/// Application service: aggregates monitoring data for dashboard overview.
class GetDashboardUseCase : UIMUseCase {
  private MonitoredResourceRepository resourceRepo;
  private AlertRepository alertRepo;
  private HealthCheckRepository checkRepo;
  private HealthCheckResultRepository checkResultRepo;
  private MetricDefinitionRepository metricDefRepo;
  private NotificationChannelRepository channelRepo;

  this(MonitoredResourceRepository resourceRepo, AlertRepository alertRepo,
      HealthCheckRepository checkRepo, HealthCheckResultRepository checkResultRepo,
      MetricDefinitionRepository metricDefRepo, NotificationChannelRepository channelRepo) {
    this.resourceRepo = resourceRepo;
    this.alertRepo = alertRepo;
    this.checkRepo = checkRepo;
    this.checkResultRepo = checkResultRepo;
    this.metricDefRepo = metricDefRepo;
    this.channelRepo = channelRepo;
  }

  DashboardSummary getSummary(string tenantId) {
    return getSummary(TenantId(tenantId));
  }

  DashboardSummary getSummary(TenantId tenantId) {
    DashboardSummary summary;

    // Resources
    auto resources = resourceRepo.findByTenant(tenantId);
    summary.totalResources = resources.length;
    foreach (r; resources) {
      if (r.state == ResourceState.started)
        summary.healthyResources++;
      else if (r.state == ResourceState.error || r.state == ResourceState.stopped)
        summary.unhealthyResources++;
    }

    // Alerts
    auto alerts = alertRepo.findByTenant(tenantId);
    summary.totalAlerts = alerts.length;
    foreach (a; alerts) {
      if (a.state == AlertState.open)
        summary.openAlerts++;
      if (a.severity == AlertSeverity.critical || a.severity == AlertSeverity.fatal)
        summary.criticalAlerts++;
    }

    // Checks
    auto checks = checkRepo.findByTenant(tenantId);
    summary.totalChecks = checks.length;
    foreach (c; checks) {
      if (c.isEnabled) {
        auto latest = checkResultRepo.findLatestByCheck(tenantId, c.id);
        if (!latest.id.isEmpty && (latest.status == CheckStatus.critical
            || latest.status == CheckStatus.warning))
          summary.failingChecks++;
      }
    }

    // Metric definitions
    auto defs = metricDefRepo.findByTenant(tenantId);
    summary.totalMetricDefinitions = defs.length;

    // Channels
    auto channels = channelRepo.findByTenant(tenantId);
    summary.totalChannels = channels.length;

    return summary;
  }
}
