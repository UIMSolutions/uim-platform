/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

import uim.platform.usage_data;

void main() {
  // Configuration
  auto cfg = ServiceConfig.load();

  // Repositories (in-memory)
  auto usageRecordRepo = new MemoryUsageRecordRepository();
  auto monthlyUsageRepo = new MemoryMonthlyUsageReportRepository();
  auto dailyUsageRepo = new MemoryDailyUsageReportRepository();
  auto monthlyCostRepo = new MemoryMonthlyCostReportRepository();
  auto serviceMetricRepo = new MemoryServiceMetricRepository();

  // Use cases
  auto usageRecordUseCases = new UsageRecordUseCases(usageRecordRepo);
  auto monthlyUsageUseCases = new MonthlyUsageReportUseCases(monthlyUsageRepo);
  auto dailyUsageUseCases = new DailyUsageReportUseCases(dailyUsageRepo);
  auto monthlyCostUseCases = new MonthlyCostReportUseCases(monthlyCostRepo);
  auto serviceMetricUseCases = new ServiceMetricUseCases(serviceMetricRepo);

  // Handlers
  auto usageRecordHandler = new UsageRecordHandler(usageRecordUseCases);
  auto monthlyUsageHandler = new MonthlyUsageReportHandler(monthlyUsageUseCases);
  auto dailyUsageHandler = new DailyUsageReportHandler(dailyUsageUseCases);
  auto monthlyCostHandler = new MonthlyCostReportHandler(monthlyCostUseCases);
  auto serviceMetricHandler = new ServiceMetricHandler(serviceMetricUseCases);
  auto healthHandler = new HealthHandler();

  // Router
  auto router = new URLRouter();
  registerRoutes(router, usageRecordHandler, monthlyUsageHandler, dailyUsageHandler,
    monthlyCostHandler, serviceMetricHandler, healthHandler);

  // Server settings
  auto settings = new HTTPServerSettings();
  settings.bindAddresses = [cfg.host];
  settings.port = cfg.port;

  listenHTTP(settings, router);

  logInfo("Usage Data service listening on %s:%d", cfg.host, cfg.port);
  runApplication();
}
