module uim.platform.market_refinitiv.presentation.gui.widgets.market_rate;

import uim.platform.market_refinitiv;

@safe:

class MarketRateWidget {
  private ManageMarketRatesUseCase ratesUC;
  private ManageProvidersUseCase providersUC;

  this(ManageMarketRatesUseCase ratesUC, ManageProvidersUseCase providersUC) {
    this.ratesUC = ratesUC;
    this.providersUC = providersUC;
  }

  Json buildModel(TenantId tenantId) {
    QueryRatesRequest q;
    q.tenantId = tenantId;

    auto rates = ratesUC.query(q);
    auto providers = providersUC.list(tenantId);

    auto providerItems = Json.emptyArray;
    foreach (p; providers) providerItems ~= p.toJson();

    return Json.emptyObject
      .set("view", "market-refinitiv-widget")
      .set("tenantId", tenantId.value)
      .set("providerCount", cast(long) providers.length)
      .set("rateCount", cast(long) rates.length)
      .set("providers", providerItems);
  }
}
