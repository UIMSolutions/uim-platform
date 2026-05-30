module uim.platform.market_refinitiv.presentation.web.views.market_rate;

import uim.platform.market_refinitiv;


@safe:

class MarketRateWebView {
  private ManageMarketRatesUseCase ratesUC;
  private ManageProvidersUseCase providersUC;

  this(ManageMarketRatesUseCase ratesUC, ManageProvidersUseCase providersUC) {
    this.ratesUC = ratesUC;
    this.providersUC = providersUC;
  }

  void registerRoutes(URLRouter router) {
    router.get("/web/market-refinitiv", &handleDashboard);
    router.get("/web/market-refinitiv/providers", &handleProviders);
  }

  private void handleDashboard(HTTPServerRequest req, HTTPServerResponse res) {
    auto tenantId = TenantId(req.query.get("tenantId", "default"));

    QueryRatesRequest q;
    q.tenantId = tenantId;

    auto rates = ratesUC.query(q);
    auto providers = providersUC.list(tenantId);

    auto html = "<html><head><title>Market Refinitiv Dashboard</title></head><body>" ~
      "<h1>Market Rates Management - Refinitiv Data Option</h1>" ~
      "<p>Tenant: " ~ tenantId.value ~ "</p>" ~
      "<p>Providers: " ~ providers.length.to!string ~ "</p>" ~
      "<p>Rates: " ~ rates.length.to!string ~ "</p>" ~
      "</body></html>";

    res.writeBody(html, cast(int) HTTPStatus.ok, "text/html; charset=utf-8");
  }

  private void handleProviders(HTTPServerRequest req, HTTPServerResponse res) {
    auto tenantId = TenantId(req.query.get("tenantId", "default"));
    auto providers = providersUC.list(tenantId);

    auto rows = "";
    foreach (p; providers) {
      rows ~= "<tr><td>" ~ p.code ~ "</td><td>" ~ p.name ~ "</td><td>" ~ (p.isActive ? "true" : "false") ~ "</td></tr>";
    }

    auto html = "<html><head><title>Providers</title></head><body>" ~
      "<h1>Providers</h1>" ~
      "<table border='1'><tr><th>Code</th><th>Name</th><th>Active</th></tr>" ~ rows ~ "</table>" ~
      "</body></html>";

    res.writeBody(html, cast(int) HTTPStatus.ok, "text/html; charset=utf-8");
  }
}
