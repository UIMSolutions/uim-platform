/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.marketrates.infrastructure.container;
import uim.platform.marketrates;

// mixin(ShowModule!());

@safe:

struct Container {
  // Repositories (driven adapters)
  MarketRateRepository rateRepo;
  ProviderRepository   providerRepo;
  AuditLogRepository   auditRepo;

  // Use cases (application core)
  ManageMarketRatesUseCase ratesUseCase;
  ManageProvidersUseCase   providersUseCase;
  ManageAuditLogsUseCase   auditUseCase;

  // Controllers (driving adapters)
  MarketRateController marketRateController;
  AuditLogController   auditLogController;
  HealthController     healthController;
}

Container buildContainer(AppConfig cfg) {
  Container c;

  // 1. Repositories
  c.rateRepo     = new MemoryMarketRateRepository();
  c.providerRepo = new MemoryProviderRepository();
  c.auditRepo    = new MemoryAuditLogRepository();

  // 2. Use cases
  c.ratesUseCase     = new ManageMarketRatesUseCase(c.rateRepo, c.auditRepo);
  c.providersUseCase = new ManageProvidersUseCase(c.providerRepo);
  c.auditUseCase     = new ManageAuditLogsUseCase(c.auditRepo);

  // 3. Controllers
  c.marketRateController = new MarketRateController(c.ratesUseCase, c.providersUseCase);
  c.auditLogController   = new AuditLogController(c.auditUseCase);
  c.healthController     = new HealthController();

  return c;
}
