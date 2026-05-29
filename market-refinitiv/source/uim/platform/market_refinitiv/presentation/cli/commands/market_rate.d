module uim.platform.market_refinitiv.presentation.cli.commands.market_rate;

import uim.platform.market_refinitiv;

@safe:

class MarketRateCliCommand {
  private ManageMarketRatesUseCase ratesUC;
  private ManageProvidersUseCase providersUC;
  private ManageAuditLogsUseCase auditUC;

  this(
    ManageMarketRatesUseCase ratesUC,
    ManageProvidersUseCase providersUC,
    ManageAuditLogsUseCase auditUC
  ) {
    this.ratesUC = ratesUC;
    this.providersUC = providersUC;
    this.auditUC = auditUC;
  }

  Json listRates(string tenantId, string providerCode = "") {
    QueryRatesRequest req;
    req.tenantId = TenantId(tenantId);
    req.providerCode = providerCode;
    auto rates = ratesUC.query(req);

    auto items = Json.emptyArray;
    foreach (r; rates) items ~= r.toJson();

    return Json.emptyObject
      .set("layer", "cli")
      .set("entity", "market-rates")
      .set("count", cast(long) rates.length)
      .set("items", items);
  }

  Json listProviders(string tenantId) {
    auto providers = providersUC.list(TenantId(tenantId));
    auto items = Json.emptyArray;
    foreach (p; providers) items ~= p.toJson();

    return Json.emptyObject
      .set("layer", "cli")
      .set("entity", "providers")
      .set("count", cast(long) providers.length)
      .set("items", items);
  }

  Json listAudit(string tenantId, string providerCode = "") {
    auto entries = providerCode.length > 0
      ? auditUC.listByProvider(TenantId(tenantId), providerCode)
      : auditUC.list(TenantId(tenantId));

    auto items = Json.emptyArray;
    foreach (e; entries) items ~= e.toJson();

    return Json.emptyObject
      .set("layer", "cli")
      .set("entity", "audit")
      .set("count", cast(long) entries.length)
      .set("items", items);
  }
}
