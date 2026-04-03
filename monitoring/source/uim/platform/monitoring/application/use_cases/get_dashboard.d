/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.monitoring.application.usecases.get_dashboard;

import uim.platform.monitoring.application.dto;
import uim.platform.monitoring.domain.entities.alert;
import uim.platform.monitoring.domain.entities.health_check_result;
import uim.platform.monitoring.domain.entities.monitored_resource;
import uim.platform.monitoring.domain.ports.alert_repository;
import uim.platform.monitoring.domain.ports.health_check_repository;
import uim.platform.monitoring.domain.ports.health_check_result_repository;
import uim.platform.monitoring.domain.ports.metric_definition_repository;
import uim.platform.monitoring.domain.ports.monitored_resource_repository;
import uim.platform.monitoring.domain.ports.notification_channel_repository;
import uim.platform.monitoring.domain.types;

/// Application service: aggregates monitoring data for dashboard overview.
class GetDashboardUseCase
{
  private MonitoredResourceRepository resourceRepo;
  private AlertRepository alertRepo;
  private HealthCheckRepository checkRepo;
  private HealthCheckResultRepository checkResultRepo;
  private MetricDefinitionRepository metricDefRepo;
  private NotificationChannelRepository channelRepo;

  this(MonitoredResourceRepository resourceRepo, AlertRepository alertRepo,
      HealthCheckRepository checkRepo, HealthCheckResultRepository checkResultRepo,
      MetricDefinitionRepository metricDefRepo, NotificationChannelRepository channelRepo)
  {
    this.resourceRepo = resourceRepo;
    this.alertRepo = alertRepo;
    this.checkRepo = checkRepo;
    this.checkResultRepo = checkResultRepo;
    this.metricDefRepo = metricDefRepo;
    this.channelRepo = channelRepo;
  }

  DashboardSummary getSummary(TenantId tenantId)
  {
    DashboardSummary summary;

    // Resources
    auto resources = resourceRepo.findByTenant(tenantId);
    summary.totalResources = cast(long) resources.length;
    foreach (ref r; resources)
    {
      if (r.state == ResourceState.started)
        summary.healthyResources++;
      else if (r.state == ResourceState.error || r.state == ResourceState.stopped)
        summary.unhealthyResources++;
    }

    // Alerts
    auto alerts = alertRepo.findByTenant(tenantId);
    summary.totalAlerts = cast(long) alerts.length;
    foreach (ref a; alerts)
    {
      if (a.state == AlertState.open)
        summary.openAlerts++;
      if (a.severity == AlertSeverity.critical || a.severity == AlertSeverity.fatal)
        summary.criticalAlerts++;
    }

    // Checks
    auto checks = checkRepo.findByTenant(tenantId);
    summary.totalChecks = cast(long) checks.length;
    foreach (ref c; checks)
    {
      if (c.isEnabled)
      {
        auto latest = checkResultRepo.findLatestByCheck(tenantId, c.id);
        if (latest.id.length > 0 && (latest.status == CheckStatus.critical
            || latest.status == CheckStatus.warning))
          summary.failingChecks++;
      }
    }

    // Metric definitions
    auto defs = metricDefRepo.findByTenant(tenantId);
    summary.totalMetricDefinitions = cast(long) defs.length;

    // Channels
    auto channels = channelRepo.findByTenant(tenantId);
    summary.totalChannels = cast(long) channels.length;

    return summary;
  }
}
