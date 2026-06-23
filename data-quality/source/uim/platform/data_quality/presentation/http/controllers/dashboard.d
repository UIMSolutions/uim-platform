/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_quality.presentation.http.controllers.dashboard;

import uim.platform.service;
import uim.platform.data_quality;

// mixin(ShowModule!());

@safe:
class DashboardController : HttpController {
  private ComputeDashboardUseCase usecase;

  this(ComputeDashboardUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/dashboard", &handleCompute);
  }

protected Json computeHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;
    auto r = ComputeDashboardRequest();
    r.tenantId = tenantId;
    r.datasetId = data.getString("datasetId");
    r.datasetName = data.getString("datasetName");

    auto dashboard = usecase.compute(r);
    if (dashboard.hasError)
      return errorResponse(dashboard.message, 400);

    return successResponse("Dashboard computed successfully", 200, dashboard.toJson);
  }

  mixin(HandleTemplate!("handleCompute", "computeHandler"));

}
