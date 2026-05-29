/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.presentation.http.controllers.overview;

// 
// import uim.platform.management.application.usecases.get_account_overview;
// import uim.platform.management.application.dto;
import uim.platform.management;

mixin(ShowModule!());
@safe:
class OverviewController : PlatformController {
  private GetAccountOverviewUseCase usecase;

  this(GetAccountOverviewUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.get("/api/v1/overview", &handleOverview);
  }

  protected Json getOverviewHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    TenantId tenantId = precheck.tenantId;
    auto gaId = req.params.get("globalAccountId");
    if (gaId.isEmpty)
      return errorResponse("globalAccountId query parameter is required", 400);

    auto ov = usecase.getOverview(tenantId, GlobalAccountId(gaId));

    auto j = Json.emptyObject
      .set("totalSubaccounts", ov.totalSubaccounts)
      .set("activeSubaccounts", ov.activeSubaccounts)
      .set("totalDirectories", ov.totalDirectories)
      .set("totalEntitlements", ov.totalEntitlements)
      .set("totalEnvironments", ov.totalEnvironments)
      .set("totalSubscriptions", ov.totalSubscriptions)
      .set("recentEventsCount", ov.recentEventsCount);

    return successResponse("Account overview retrieved successfully", "Retrieved", 200, j);
  }

  protected void handleOverview(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = getOverviewHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }
}
