/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.usage_data.infrastructure.web.routes;

import uim.platform.usage_data;

mixin(ShowModule!());
@safe:

void registerRoutes(
  URLRouter router,
  UsageRecordHandler records,
  MonthlyUsageReportHandler monthly,
  DailyUsageReportHandler daily,
  MonthlyCostReportHandler costs,
  ServiceMetricHandler metrics,
  HealthHandler health,
) {
  // Health
  router.get("/api/v1/health", &health.check);

  // Usage records
  router.get("/api/v1/usage-data/usage-records", &records.getAll);
  router.post("/api/v1/usage-data/usage-records", &records.submit);
  router.get("/api/v1/usage-data/usage-records/*", &records.getOne);
  router.delete_("/api/v1/usage-data/usage-records/*", &records.remove);

  // Monthly usage reports
  router.get("/api/v1/usage-data/reports/monthly", &monthly.getAll);
  router.post("/api/v1/usage-data/reports/monthly", &monthly.create);
  router.get("/api/v1/usage-data/reports/monthly/*", &monthly.getOne);
  router.delete_("/api/v1/usage-data/reports/monthly/*", &monthly.remove);

  // Daily usage reports
  router.get("/api/v1/usage-data/reports/daily", &daily.getAll);
  router.post("/api/v1/usage-data/reports/daily", &daily.create);
  router.get("/api/v1/usage-data/reports/daily/*", &daily.getOne);
  router.delete_("/api/v1/usage-data/reports/daily/*", &daily.remove);

  // Monthly cost reports
  router.get("/api/v1/usage-data/reports/costs", &costs.getAll);
  router.post("/api/v1/usage-data/reports/costs", &costs.create);
  router.get("/api/v1/usage-data/reports/costs/*", &costs.getOne);
  router.delete_("/api/v1/usage-data/reports/costs/*", &costs.remove);

  // Service metrics
  router.get("/api/v1/usage-data/metrics", &metrics.getAll);
  router.post("/api/v1/usage-data/metrics", &metrics.create);
  router.get("/api/v1/usage-data/metrics/*", &metrics.getOne);
  router.delete_("/api/v1/usage-data/metrics/*", &metrics.remove);
}
