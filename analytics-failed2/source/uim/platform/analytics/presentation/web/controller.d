module uim.platform.analytics.presentation.web.controller;

import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;
import uim.platform.analytics.application.usecases.manage_assets;
import uim.platform.analytics.presentation.web.model;
import uim.platform.analytics.presentation.web.view;

class WebController {
  private ManageAssetsUseCase useCase;
  private WebView view;

  this(ManageAssetsUseCase useCase) {
    this.useCase = useCase;
    this.view = WebView();
  }

  void registerRoutes(URLRouter router) {
    router.get("/web", &handleDashboard);
  }

  private void handleDashboard(HTTPServerRequest req, HTTPServerResponse res) {
    auto tenantId = req.query.get("tenantId", "default");
    auto assets = useCase.listAssets(tenantId);

    WebDashboardModel model;
    model.title = "Analytics Web Console";
    model.tenantId = precheck.tenantId;
    model.assetCount = assets.length;
    model.highlights = [
      "Data preparation metadata",
      "Story and dashboard lifecycle",
      "Publication status tracking"
    ];

    res.writeBody(view.renderDashboard(model), 200, "text/html; charset=utf-8");
  }
}
