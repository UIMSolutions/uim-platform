/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_quality.presentation.http.controllers.dashboard;





// import uim.platform.data_quality.application.usecases.compute_dashboard;


// import uim.platform.data_quality.domain.entities.quality_dashboard;
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

  override protected void handleGetCompute(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto data = precheck.data;
      auto r = ComputeDashboardRequest();
      r.tenantId = tenantId;
      r.datasetId = data.getString("datasetId");
      r.datasetName = data.getString("datasetName");

      auto dashboard = usecase.compute(r);
      res.writeJsonBody(dashboard.toJson, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
