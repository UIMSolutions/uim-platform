/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_quality.presentation.http.controllers.dashboard;





// import uim.platform.data_quality.application.usecases.compute_dashboard;
// import uim.platform.data_quality.application.dto;
// import uim.platform.data_quality.domain.types;
// import uim.platform.data_quality.domain.entities.quality_dashboard;
import uim.platform.data_quality;

mixin(ShowModule!());

@safe:
class DashboardController : PlatformController {
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

  private static Json serializeDashboard(const QualityDashboard d) {
    // Record metrics
    auto records = Json.emptyObject;
    records["total"] = Json(d.totalRecords);
    records["valid"] = Json(d.validRecords);
    records["invalid"] = Json(d.invalidRecords);
    records["duplicates"] = Json(d.duplicateRecords);
    records["cleansed"] = Json(d.cleansedRecords);

    // Scores
    auto scores = Json.emptyObject;
    scores["overall"] = Json(d.overallScore);
    scores["completeness"] = Json(d.completenessScore);
    scores["validity"] = Json(d.validityScore);
    scores["uniqueness"] = Json(d.uniquenessScore);
    scores["consistency"] = Json(d.consistencyScore);
    scores["accuracy"] = Json(d.accuracyScore);

    // Violations by severity
    auto sevArr = Json.emptyArray;
    foreach (s; d.violationsBySeverity) {
      sevArr ~= Json.emptyObject
        .set("severity", s.severity.to!string)
        .set("count", s.count);
    }

    return Json.emptyObject
      .set("tenantId", d.tenantId)
      .set("datasetId", d.datasetId)
      .set("datasetName", d.datasetName)
      .set("records", records)
      .set("scores", scores)
      .set("rating", d.rating.to!string)
      .set("violationCount", d.violationCount)
      .set("violationsBySeverity", sevArr)
      .set("computedAt", d.computedAt);
  }
}
