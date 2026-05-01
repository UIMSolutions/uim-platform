/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.presentation.http.controllers.overview;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// 
// import uim.platform.management.application.usecases.get_account_overview;
// import uim.platform.management.application.dto;
import uim.platform.management;

mixin(ShowModule!());
@safe:
class OverviewController : PlatformController {
  private GetAccountOverviewUseCase uc;

  this(GetAccountOverviewUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.get("/api/v1/overview", &handleOverview);
  }

  private void handleOverview(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto gaId = req.params.get("globalAccountId");
      if (gaId.isEmpty) {
        writeError(res, 400, "globalAccountId query parameter is required");
        return;
      }

      auto ov = uc.getOverview(gaId);

      auto j = Json.emptyObject
      .set("totalSubaccounts", ov.totalSubaccounts)
      .set("activeSubaccounts", ov.activeSubaccounts)
      .set("totalDirectories", ov.totalDirectories)
      .set("totalEntitlements", ov.totalEntitlements)
      .set("totalEnvironments", ov.totalEnvironments)
      .set("totalSubscriptions", ov.totalSubscriptions)
      .set("recentEventsCount", ov.recentEventsCount);

      res.writeJsonBody(j, 200);
    }
    catch (Exception e)
      writeError(res, 500, "Internal server error");
  }
}
