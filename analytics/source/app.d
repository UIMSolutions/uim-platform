/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

// import vibe.http.router;
// import vibe.http.server;
// import vibe.core.core;
// import vibe.core.log;
// 
// // Infrastructure — persistence adapters (driven / outgoing)
// import uim.platform.analytics.infrastructure.persistence.memory;
// // Infrastructure — external service adapters
// import uim.platform.analytics.infrastructure.adapters;
// // Infrastructure — web layer
// import uim.platform.analytics.infrastructure.web.routes;
// import uim.platform.analytics.infrastructure.web.handlers;
// // Infrastructure — configuration
// import uim.platform.analytics.infrastructure.config;
// 
// // Application — use cases
// import uim.platform.analytics.app.usecases;

import uim.platform.analytics;

@safe:

version (unittest) {
} else {
  void main() {
    auto cfg = ServiceConfig.load();

    // ──────────────────────────────────────────────
    //  Composition Root — wire hexagonal architecture
    // ──────────────────────────────────────────────

    // 1. Outgoing adapters (driven side — persistence)
    auto dashboardRepo = new MemoryDashboardRepository();
    auto storyRepo = new MemoryStoryRepository();
    auto datasetRepo = new MemoryDatasetRepository();
    auto widgetRepo = new MemoryWidgetRepository();
    auto dataSourceRepo = new MemoryDataSourceRepository();
    auto planningRepo = new MemoryPlanningRepository();
    auto predictionRepo = new MemoryPredictionRepository();

    // 2. Outgoing adapters (driven side — external services)
    auto dataConnector = new StubDataConnector();
    auto notification = new ConsoleNotificationAdapter();
    auto exporter = new CsvExportAdapter();

    // 3. Application layer — use cases (core hexagon)
    auto dashboardUC = new DashboardUseCases(dashboardRepo);
    auto storyUC = new StoryUseCases(storyRepo);
    auto datasetUC = new DatasetUseCases(datasetRepo);
    auto widgetUC = new WidgetUseCases(widgetRepo);
    auto planningUC = new PlanningUseCases(planningRepo);
    auto predictionUC = new PredictionUseCases(predictionRepo);
    auto dataSourceUC = new DataSourceUseCases(dataSourceRepo, dataConnector);

    // 4. Incoming adapters (driving side — REST handlers)
    auto dashboardH = new DashboardHandler(dashboardUC);
    auto storyH = new StoryHandler(storyUC);
    auto datasetH = new DatasetHandler(datasetUC);
    auto widgetH = new WidgetHandler(widgetUC);
    auto planningH = new PlanningHandler(planningUC);
    auto predictionH = new PredictionHandler(predictionUC);
    auto dataSourceH = new DataSourceHandler(dataSourceUC);
    auto healthH = new HealthHandler();

    // 5. HTTP Router — register all routes
    auto router = new URLRouter();
    registerRoutes(router, dashboardH, storyH, datasetH, widgetH, planningH,
      predictionH, dataSourceH, healthH);

    // 6. HTTP Server
    auto settings = new HTTPServerSettings;
    settings.port = cfg.port;
    settings.bindAddresses = [cfg.host];

    auto listener = listenHTTP(settings, router);

    logInfo("═══════════════════════════════════════════════════");
    logInfo("  UIM Analytics Service started");
    logInfo("  Listening on %s:%d", cfg.host, cfg.port);
    logInfo("  API base: http://%s:%d/api/v1/", cfg.host, cfg.port);
    logInfo("═══════════════════════════════════════════════════");
    logInfo("  Endpoints:");
    logInfo("    GET  /api/v1/health");
    logInfo("    CRUD /api/v1/dashboards");
    logInfo("    CRUD /api/v1/stories");
    logInfo("    CRUD /api/v1/datasets");
    logInfo("    CRUD /api/v1/widgets");
    logInfo("    CRUD /api/v1/planning");
    logInfo("    CRUD /api/v1/predictions");
    logInfo("    CRUD /api/v1/datasources");
    logInfo("═══════════════════════════════════════════════════");

    runApplication();
  }
}
