/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.application.use_cases.get_overview;

import uim.platform.logging.domain.ports.log_entry_repository;
import uim.platform.logging.domain.ports.span_repository;
import uim.platform.logging.domain.ports.log_stream_repository;
import uim.platform.logging.domain.ports.dashboard_repository;
import uim.platform.logging.domain.ports.alert_repository;
import uim.platform.logging.domain.ports.pipeline_repository;
import uim.platform.logging.domain.ports.notification_channel_repository;
import uim.platform.logging.domain.types;
import uim.platform.logging.application.dto;

class GetOverviewUseCase : UIMUseCase {
  private LogEntryRepository logRepo;
  private SpanRepository spanRepo;
  private LogStreamRepository streamRepo;
  private DashboardRepository dashboardRepo;
  private AlertRepository alertRepo;
  private PipelineRepository pipelineRepo;
  private NotificationChannelRepository channelRepo;

  this(LogEntryRepository logRepo, SpanRepository spanRepo,
      LogStreamRepository streamRepo, DashboardRepository dashboardRepo,
      AlertRepository alertRepo, PipelineRepository pipelineRepo,
      NotificationChannelRepository channelRepo) {
    this.logRepo = logRepo;
    this.spanRepo = spanRepo;
    this.streamRepo = streamRepo;
    this.dashboardRepo = dashboardRepo;
    this.alertRepo = alertRepo;
    this.pipelineRepo = pipelineRepo;
    this.channelRepo = channelRepo;
  }

  OverviewSummary getSummary(TenantId tenantId) {
    OverviewSummary s;

    s.totalLogEntries = logRepo.countByTenant(tenantId);
    s.totalSpans = spanRepo.countByTenant(tenantId);
    s.totalStreams = cast(long) streamRepo.findByTenant(tenantId).length;
    s.totalDashboards = dashboardRepo.countByTenant(tenantId);
    s.totalAlerts = alertRepo.countByTenant(tenantId);
    s.openAlerts = alertRepo.countByState(tenantId, AlertState.open);
    s.criticalAlerts = cast(long) alertRepo.findBySeverity(tenantId, AlertSeverity.critical).length;
    s.totalPipelines = cast(long) pipelineRepo.findByTenant(tenantId).length;
    s.activePipelines = cast(long) pipelineRepo.findActive(tenantId).length;
    s.totalChannels = channelRepo.countByTenant(tenantId);

    return s;
  }
}
