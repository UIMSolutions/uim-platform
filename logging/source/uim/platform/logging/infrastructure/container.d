/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.infrastructure.container;

// import uim.platform.logging.infrastructure.config;

// // Repositories
// import uim.platform.logging.infrastructure.persistence.memory.log_entry;
// import uim.platform.logging.infrastructure.persistence.memory.log_stream;
// import uim.platform.logging.infrastructure.persistence.memory.span;
// import uim.platform.logging.infrastructure.persistence.memory.dashboard;
// import uim.platform.logging.infrastructure.persistence.memory.retention_policy;
// import uim.platform.logging.infrastructure.persistence.memory.alert_rule;
// import uim.platform.logging.infrastructure.persistence.memory.alert;
// import uim.platform.logging.infrastructure.persistence.memory.notification_channel;
// import uim.platform.logging.infrastructure.persistence.memory.pipeline;
// import uim.platform.logging.infrastructure.persistence.memory.ingestion_token;

// // Use Cases
// import uim.platform.logging.application.usecases.ingest_logs;
// import uim.platform.logging.application.usecases.ingest_traces;
// import uim.platform.logging.application.usecases.search_logs;
// import uim.platform.logging.application.usecases.manage.log_streams;
// import uim.platform.logging.application.usecases.manage.dashboards;
// import uim.platform.logging.application.usecases.manage.retention_policies;
// import uim.platform.logging.application.usecases.manage.alert_rules;
// import uim.platform.logging.application.usecases.manage.alerts;
// import uim.platform.logging.application.usecases.manage.notification_channels;
// import uim.platform.logging.application.usecases.manage.pipelines;
// import uim.platform.logging.application.usecases.get_overview;

// // Controllers
// import uim.platform.logging.presentation.http.controllers.log;
// import uim.platform.logging.presentation.http.controllers.trace;
// import uim.platform.logging.presentation.http.controllers.search;
// import uim.platform.logging.presentation.http.controllers.stream;
// import uim.platform.logging.presentation.http.controllers.dashboard;
// import uim.platform.logging.presentation.http.controllers.retention;
// import uim.platform.logging.presentation.http.controllers.alert_rule;
// import uim.platform.logging.presentation.http.controllers.alert;
// import uim.platform.logging.presentation.http.controllers.channel;
// import uim.platform.logging.presentation.http.controllers.pipeline;
// import uim.platform.logging.presentation.http.controllers.overview;
// import uim.platform.logging.presentation.http.controllers.health;

import uim.platform.logging;

mixin(ShowModule!());

@safe:

struct Container {
  // Repositories (driven adapters)
  MemoryLogEntryRepository logEntryRepo;
  MemoryLogStreamRepository logStreamRepo;
  MemorySpanRepository spanRepo;
  MemoryDashboardRepository dashboardRepo;
  MemoryRetentionPolicyRepository retentionRepo;
  MemoryAlertRuleRepository alertRuleRepo;
  MemoryAlertRepository alertRepo;
  MemoryNotificationChannelRepository channelRepo;
  MemoryPipelineRepository pipelineRepo;
  MemoryIngestionTokenRepository tokenRepo;

  // Use cases (application layer)
  IngestLogsUseCase ingestLogs;
  IngestTracesUseCase ingestTraces;
  SearchLogsUseCase searchLogs;
  ManageLogStreamsUseCase manageStreams;
  ManageDashboardsUseCase manageDashboards;
  ManageRetentionPoliciesUseCase manageRetention;
  ManageAlertRulesUseCase manageAlertRules;
  ManageAlertsUseCase manageAlerts;
  ManageNotificationChannelsUseCase manageChannels;
  ManagePipelinesUseCase managePipelines;
  GetOverviewUseCase getOverview;

  // Controllers (driving adapters)
  LogController logController;
  TraceController traceController;
  SearchController searchController;
  StreamController streamController;
  DashboardController dashboardController;
  RetentionController retentionController;
  AlertRuleController alertRuleController;
  AlertController alertController;
  ChannelController channelController;
  PipelineController pipelineController;
  OverviewController overviewController;
  HealthController healthController;
}

Container buildContainer(AppConfig config) {
  Container container;

  // Infrastructure adapters
  container.logEntryRepo = new MemoryLogEntryRepository();
  container.logStreamRepo = new MemoryLogStreamRepository();
  container.spanRepo = new MemorySpanRepository();
  container.dashboardRepo = new MemoryDashboardRepository();
  container.retentionRepo = new MemoryRetentionPolicyRepository();
  container.alertRuleRepo = new MemoryAlertRuleRepository();
  container.alertRepo = new MemoryAlertRepository();
  container.channelRepo = new MemoryNotificationChannelRepository();
  container.pipelineRepo = new MemoryPipelineRepository();
  container.tokenRepo = new MemoryIngestionTokenRepository();

  // Application use cases
  container.ingestLogs = new IngestLogsUseCase(container.logEntryRepo, container.logStreamRepo);
  container.ingestTraces = new IngestTracesUseCase(container.spanRepo);
  container.searchLogs = new SearchLogsUseCase(container.logEntryRepo);
  container.manageStreams = new ManageLogStreamsUseCase(container.logStreamRepo);
  container.manageDashboards = new ManageDashboardsUseCase(container.dashboardRepo);
  container.manageRetention = new ManageRetentionPoliciesUseCase(container.retentionRepo);
  container.manageAlertRules = new ManageAlertRulesUseCase(container.alertRuleRepo);
  container.manageAlerts = new ManageAlertsUseCase(container.alertRepo);
  container.manageChannels = new ManageNotificationChannelsUseCase(container.channelRepo);
  container.managePipelines = new ManagePipelinesUseCase(container.pipelineRepo);
  container.getOverview = new GetOverviewUseCase(
    container.logEntryRepo, container.spanRepo, container.logStreamRepo, container.dashboardRepo,
    container.alertRepo, container.pipelineRepo, container.channelRepo);

  // Presentation controllers
  container.logController = new LogController(container.ingestLogs);
  container.traceController = new TraceController(container.ingestTraces);
  container.searchController = new SearchController(container.searchLogs);
  container.streamController = new StreamController(container.manageStreams);
  container.dashboardController = new DashboardController(container.manageDashboards);
  container.retentionController = new RetentionController(container.manageRetention);
  container.alertRuleController = new AlertRuleController(container.manageAlertRules);
  container.alertController = new AlertController(container.manageAlerts);
  container.channelController = new ChannelController(container.manageChannels);
  container.pipelineController = new PipelineController(container.managePipelines);
  container.overviewController = new OverviewController(container.getOverview);
  container.healthController = new HealthController("logging");

  return container;
}
