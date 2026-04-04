/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.infrastructure.container;

import uim.platform.logging.infrastructure.config;

// Repositories
import uim.platform.logging.infrastructure.persistence.memory.log_entry_repo;
import uim.platform.logging.infrastructure.persistence.memory.log_stream_repo;
import uim.platform.logging.infrastructure.persistence.memory.span_repo;
import uim.platform.logging.infrastructure.persistence.memory.dashboard_repo;
import uim.platform.logging.infrastructure.persistence.memory.retention_policy_repo;
import uim.platform.logging.infrastructure.persistence.memory.alert_rule_repo;
import uim.platform.logging.infrastructure.persistence.memory.alert_repo;
import uim.platform.logging.infrastructure.persistence.memory.notification_channel_repo;
import uim.platform.logging.infrastructure.persistence.memory.pipeline_repo;
import uim.platform.logging.infrastructure.persistence.memory.ingestion_token_repo;

// Use Cases
import uim.platform.logging.application.usecases.ingest_logs;
import uim.platform.logging.application.usecases.ingest_traces;
import uim.platform.logging.application.usecases.search_logs;
import uim.platform.logging.application.usecases.manage.log_streams;
import uim.platform.logging.application.usecases.manage.dashboards;
import uim.platform.logging.application.usecases.manage.retention_policies;
import uim.platform.logging.application.usecases.manage.alert_rules;
import uim.platform.logging.application.usecases.manage.alerts;
import uim.platform.logging.application.usecases.manage.notification_channels;
import uim.platform.logging.application.usecases.manage.pipelines;
import uim.platform.logging.application.usecases.get_overview;

// Controllers
import uim.platform.logging.presentation.http.controllers.log;
import uim.platform.logging.presentation.http.controllers.trace;
import uim.platform.logging.presentation.http.controllers.search;
import uim.platform.logging.presentation.http.controllers.stream;
import uim.platform.logging.presentation.http.controllers.dashboard;
import uim.platform.logging.presentation.http.controllers.retention;
import uim.platform.logging.presentation.http.controllers.alert_rule;
import uim.platform.logging.presentation.http.controllers.alert;
import uim.platform.logging.presentation.http.controllers.channel;
import uim.platform.logging.presentation.http.controllers.pipeline;
import uim.platform.logging.presentation.http.controllers.overview;
import uim.platform.logging.presentation.http.controllers.health;

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
  Container c;

  // Infrastructure adapters
  c.logEntryRepo = new MemoryLogEntryRepository();
  c.logStreamRepo = new MemoryLogStreamRepository();
  c.spanRepo = new MemorySpanRepository();
  c.dashboardRepo = new MemoryDashboardRepository();
  c.retentionRepo = new MemoryRetentionPolicyRepository();
  c.alertRuleRepo = new MemoryAlertRuleRepository();
  c.alertRepo = new MemoryAlertRepository();
  c.channelRepo = new MemoryNotificationChannelRepository();
  c.pipelineRepo = new MemoryPipelineRepository();
  c.tokenRepo = new MemoryIngestionTokenRepository();

  // Application use cases
  c.ingestLogs = new IngestLogsUseCase(c.logEntryRepo, c.logStreamRepo);
  c.ingestTraces = new IngestTracesUseCase(c.spanRepo);
  c.searchLogs = new SearchLogsUseCase(c.logEntryRepo);
  c.manageStreams = new ManageLogStreamsUseCase(c.logStreamRepo);
  c.manageDashboards = new ManageDashboardsUseCase(c.dashboardRepo);
  c.manageRetention = new ManageRetentionPoliciesUseCase(c.retentionRepo);
  c.manageAlertRules = new ManageAlertRulesUseCase(c.alertRuleRepo);
  c.manageAlerts = new ManageAlertsUseCase(c.alertRepo);
  c.manageChannels = new ManageNotificationChannelsUseCase(c.channelRepo);
  c.managePipelines = new ManagePipelinesUseCase(c.pipelineRepo);
  c.getOverview = new GetOverviewUseCase(
      c.logEntryRepo, c.spanRepo, c.logStreamRepo, c.dashboardRepo,
      c.alertRepo, c.pipelineRepo, c.channelRepo);

  // Presentation controllers
  c.logController = new LogController(c.ingestLogs);
  c.traceController = new TraceController(c.ingestTraces);
  c.searchController = new SearchController(c.searchLogs);
  c.streamController = new StreamController(c.manageStreams);
  c.dashboardController = new DashboardController(c.manageDashboards);
  c.retentionController = new RetentionController(c.manageRetention);
  c.alertRuleController = new AlertRuleController(c.manageAlertRules);
  c.alertController = new AlertController(c.manageAlerts);
  c.channelController = new ChannelController(c.manageChannels);
  c.pipelineController = new PipelineController(c.managePipelines);
  c.overviewController = new OverviewController(c.getOverview);
  c.healthController = new HealthController("logging");

  return c;
}
