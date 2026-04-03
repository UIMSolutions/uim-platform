/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.analytics.infrastructure.web.routes;

// import vibe.http.router;
// import uim.platform.analytics.infrastructure.web.handlers;
// import uim.platform.analytics.infrastructure.web.middleware;
import uim.platform.analytics;

mixin(ShowModule!());
@safe:
/// Register all REST API routes on the given router.
void registerRoutes(URLRouter router, DashboardHandler dashboards,
    StoryHandler stories, DatasetHandler datasets, WidgetHandler widgets,
    PlanningHandler planning, PredictionHandler predictions,
    DataSourceHandler dataSources, HealthHandler health)
{

  // Middleware
  router.any("*", &corsMiddleware);
  router.any("*", &requestLogger);

  // Health
  router.get("/api/v1/health", &health.check);

  // Dashboards
  router.get("/api/v1/dashboards", &dashboards.getAll);
  router.post("/api/v1/dashboards", &dashboards.create);
  router.get("/api/v1/dashboards/*", &dashboards.getOne);
  router.post("/api/v1/dashboards/*/pages", &dashboards.addPage);
  router.post("/api/v1/dashboards/*/publish", &dashboards.publish);
  router.delete_("/api/v1/dashboards/*", &dashboards.remove);

  // Stories
  router.get("/api/v1/stories", &stories.getAll);
  router.post("/api/v1/stories", &stories.create);
  router.get("/api/v1/stories/*", &stories.getOne);
  router.post("/api/v1/stories/*/publish", &stories.publish);
  router.delete_("/api/v1/stories/*", &stories.remove);

  // Datasets (Models)
  router.get("/api/v1/datasets", &datasets.getAll);
  router.post("/api/v1/datasets", &datasets.create);
  router.get("/api/v1/datasets/*", &datasets.getOne);
  router.delete_("/api/v1/datasets/*", &datasets.remove);

  // Widgets (Visualizations)
  router.get("/api/v1/widgets", &widgets.getAll);
  router.post("/api/v1/widgets", &widgets.create);
  router.get("/api/v1/widgets/*", &widgets.getOne);
  router.delete_("/api/v1/widgets/*", &widgets.remove);

  // Planning
  router.get("/api/v1/planning", &planning.getAll);
  router.post("/api/v1/planning", &planning.create);
  router.get("/api/v1/planning/*", &planning.getOne);
  router.post("/api/v1/planning/*/lock", &planning.lockModel);
  router.post("/api/v1/planning/*/approve", &planning.approveModel);
  router.delete_("/api/v1/planning/*", &planning.remove);

  // Predictions (Smart Predict)
  router.get("/api/v1/predictions", &predictions.getAll);
  router.post("/api/v1/predictions", &predictions.create);
  router.get("/api/v1/predictions/*", &predictions.getOne);
  router.post("/api/v1/predictions/*/train", &predictions.train);
  router.delete_("/api/v1/predictions/*", &predictions.remove);

  // Data Sources (Connections)
  router.get("/api/v1/datasources", &dataSources.getAll);
  router.post("/api/v1/datasources", &dataSources.create);
  router.get("/api/v1/datasources/*", &dataSources.getOne);
  router.post("/api/v1/datasources/*/test", &dataSources.testConn);
  router.delete_("/api/v1/datasources/*", &dataSources.remove);
}
