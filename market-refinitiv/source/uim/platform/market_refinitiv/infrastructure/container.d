/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.market_refinitiv.infrastructure.container;
import uim.platform.market_refinitiv;

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

  // MVC presentation components
  MarketRateCliCommand cliCommand;
  MarketRateWebView    webView;
  MarketRateWidget     guiWidget;
}

Container buildContainer(AppConfig cfg) {
  Container c;

  // 1. Repositories
  switch (cfg.storageBackend) {
    case "FILE":
      c.rateRepo     = new FileMarketRateRepository(cfg.fileStoragePath);
      c.providerRepo = new FileProviderRepository(cfg.fileStoragePath);
      c.auditRepo    = new FileAuditLogRepository(cfg.fileStoragePath);
      break;
    case "MONGODB":
      c.rateRepo     = new MongoDbMarketRateRepository(cfg.mongoUri, cfg.mongoDb);
      c.providerRepo = new MongoDbProviderRepository(cfg.mongoUri, cfg.mongoDb);
      c.auditRepo    = new MongoDbAuditLogRepository(cfg.mongoUri, cfg.mongoDb);
      break;
    case "MEMORY":
      c.rateRepo     = new MemoryMarketRateRepository();
      c.providerRepo = new MemoryProviderRepository();
      c.auditRepo    = new MemoryAuditLogRepository();
      break;
    default:
      c.rateRepo     = new MemoryMarketRateRepository();
      c.providerRepo = new MemoryProviderRepository();
      c.auditRepo    = new MemoryAuditLogRepository();
      break;
  }

  // 2. Use cases
  c.ratesUseCase     = new ManageMarketRatesUseCase(c.rateRepo, c.auditRepo);
  c.providersUseCase = new ManageProvidersUseCase(c.providerRepo);
  c.auditUseCase     = new ManageAuditLogsUseCase(c.auditRepo);

  // 3. Controllers
  c.marketRateController = new MarketRateController(c.ratesUseCase, c.providersUseCase);
  c.auditLogController   = new AuditLogController(c.auditUseCase);
  c.healthController     = new HealthController();

  // 4. MVC presentation components
  c.cliCommand = new MarketRateCliCommand(c.ratesUseCase, c.providersUseCase, c.auditUseCase);
  c.webView    = new MarketRateWebView(c.ratesUseCase, c.providersUseCase);
  c.guiWidget  = new MarketRateWidget(c.ratesUseCase, c.providersUseCase);

  return c;
}
