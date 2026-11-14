/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.presentation.http.controllers.overview;

// 
import uim.platform.management;

mixin(ShowModule!());
@safe:
class OverviewController : HttpController {
  protected IGetAccountOverviewUseCase usecase;

  this(IGetAccountOverviewUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.get("/api/v1/overview", &handleGetOverview);
  }

  protected Json getOverviewHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    TenantId tenantId = precheck.tenantId;
    auto gaId = req.query.get("globalAccountId", req.params.get("globalAccountId", ""));
    // Without a global account the figures of the whole tenant are returned.
    auto j = gaId.length == 0
      ? usecase.getTenantOverview(tenantId).toJson
      : usecase.getOverview(tenantId, GlobalAccountId(gaId)).toJson;

    return successResponse("Account overview retrieved successfully", "Retrieved", 200, j);
  }

  mixin(HandleTemplate!("handleGetOverview", "getOverviewHandler"));

}
