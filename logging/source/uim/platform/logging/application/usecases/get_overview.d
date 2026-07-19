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

unittest {
  // Setup Mock Repositories
  auto logRepo = new MemoryLogEntryRepository();
  auto spanRepo = new MemorySpanRepository();
  auto streamRepo = new MemoryLogStreamRepository();
  auto dashboardRepo = new MemoryDashboardRepository();
  auto alertRepo = new MemoryAlertRepository();
  auto pipelineRepo = new MemoryPipelineRepository();
  auto channelRepo = new MemoryNotificationChannelRepository();

  auto usecase = new GetOverviewUseCase(
    logRepo,
    spanRepo,
    streamRepo,
    dashboardRepo,
    alertRepo,
    pipelineRepo,
    channelRepo
  );
  auto tenantId = TenantId("test-tenant");

  // Seed Test Data
  // 1 Log Entry
  auto log = LogEntry(tenantId); //, UserId("test-user"));
  logRepo.save(log);

  // 1 Span
  auto span = Span(tenantId); //, UserId("test-user"));
  spanRepo.save(span);

  // 1 Stream
  auto stream = LogStream(tenantId); //, UserId("test-user"));
  stream.name = "default";
  streamRepo.save(stream);

  // 1 Dashboard
  auto dashboard = Dashboard(tenantId); //, UserId("test-user"));
  dashboard.name = "Main View";
  dashboardRepo.save(dashboard);

  // 2 Alerts: 1 Open + Critical, 1 Resolved + Low
  auto alert1 = Alert(tenantId); //, UserId("test-user"));
  alert1.state = AlertState.open; 
  alert1.severity = AlertSeverity.critical;
  alertRepo.save(alert1);
  
  auto alert2 = Alert(tenantId); //, UserId("test-user"));
  alert2.state = AlertState.resolved; 
  alert2.severity = AlertSeverity.warning;
  alertRepo.save(alert2);

  // 2 Pipelines: 1 Active, 1 Inactive
  auto p1 = Pipeline(tenantId); //, UserId("test-user"));
  p1.isActive = true;
  p1.name = "Active Pipe";
  pipelineRepo.save(p1);
  
  auto p2 = Pipeline(tenantId); //, UserId("test-user"));
  p2.isActive = false;
  p2.name = "Inactive Pipe";
  pipelineRepo.save(p2);

  // 1 Channel
  auto channel = NotificationChannel(tenantId); //, UserId("test-user"));
  channel.name = "Email Admin";
  channelRepo.save(channel);

  // Execute
  auto summary = usecase.getSummary(tenantId);

  // Assertions
  assert(summary.totalLogEntries == 1);
  assert(summary.totalSpans == 1);
  assert(summary.totalStreams == 1);
  assert(summary.totalDashboards == 1);
  assert(summary.totalAlerts == 2);
  assert(summary.openAlerts == 1);
  assert(summary.criticalAlerts == 1);
  assert(summary.totalPipelines == 2);
  assert(summary.activePipelines == 1);
  assert(summary.totalChannels == 1);
}