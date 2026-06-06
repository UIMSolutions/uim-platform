/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.presentation.http.controllers.overview;

// import uim.platform.html_repository.application.usecases.get_overview;
// import uim.platform.html_repository.application.dto;

import uim.platform.html_repository;

mixin(ShowModule!());

@safe:

class OverviewController : HttpController {
  private GetOverviewUseCase usecase;

  this(GetOverviewUseCase usecase) {
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

    auto tenantId = precheck.tenantId;

    auto summary = usecase.getSummary(tenantId);

    auto response = Json.emptyObject
      .set("totalApps", summary.totalApps)
      .set("totalVersions", summary.totalVersions)
      .set("totalFiles", summary.totalFiles)
      .set("totalInstances", summary.totalInstances)
      .set("totalDeployments", summary.totalDeployments)
      .set("totalRoutes", summary.totalRoutes)
      .set("totalCacheEntries", summary.totalCacheEntries)
      .set("cacheHitRate", summary.cacheHitRate)
      .set("totalStorageBytes", summary.totalStorageBytes);

    return successResponse("Overview retrieved successfully", 200, response);
  }
  
  protected void handleGetOverview(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = getOverviewHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }
}
