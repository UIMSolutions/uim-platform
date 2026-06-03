module uim.platform.analytics.presentation.gui.controller;

import std.conv : to;
import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;
import uim.platform.analytics.application.usecases.manage_assets;
import uim.platform.analytics.presentation.gui.model;
import uim.platform.analytics.presentation.gui.view;

class GuiController {
  private ManageAssetsUseCase useCase;
  private GuiView view;

  this(ManageAssetsUseCase useCase) {
    this.useCase = useCase;
    this.view = GuiView();
  }

  void registerRoutes(URLRouter router) {
    router.get("/gui", &handleGui);
  }

  private void handleGui(HTTPServerRequest req, HTTPServerResponse res) {
    auto tenantId = req.query.get("tenantId", "default");
    auto assets = useCase.listAssets(tenantId);

    GuiModel model;
    model.heading = "Analytics GUI";
    model.subtitle = "Visual shell with MVC separation for GUI channel";
    model.tiles = [
      "Tenant: " ~ tenantId,
      "Total Assets: " ~ assets.length.to!string,
      "Storage-agnostic use case orchestration",
      "Ready for richer widget integration"
    ];

    res.writeBody(view.render(model), 200, "text/html; charset=utf-8");
  }
}
