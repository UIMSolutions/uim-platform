/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.application.usecases.get_overview;

// import uim.platform.logging.domain.ports.repositories.log_entrys;
// import uim.platform.logging.domain.ports.repositories.spans;
// import uim.platform.logging.domain.ports.repositories.log_streams;
// import uim.platform.logging.domain.ports.repositories.dashboards;
// import uim.platform.logging.domain.ports.repositories.alerts;
// import uim.platform.logging.domain.ports.repositories.pipelines;
// import uim.platform.logging.domain.ports.repositories.notification_channels;
// import uim.platform.logging.domain.types;
// import uim.platform.logging.application.dto;
import uim.platform.logging;

mixin(ShowModule!());

@safe:
class GetOverviewUseCase { // TODO: UIMUseCase {
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
    s.totalStreams = streamRepo.findByTenant(tenantId).length;
    s.totalDashboards = dashboardRepo.countByTenant(tenantId);
    s.totalAlerts = alertRepo.countByTenant(tenantId);
    s.openAlerts = alertRepo.countByState(tenantId, AlertState.open);
    s.criticalAlerts = alertRepo.findBySeverity(tenantId, AlertSeverity.critical).length;
    s.totalPipelines = pipelineRepo.findByTenant(tenantId).length;
    s.activePipelines = pipelineRepo.findActive(tenantId).length;
    s.totalChannels = channelRepo.countByTenant(tenantId);

    return s;
  }
}
