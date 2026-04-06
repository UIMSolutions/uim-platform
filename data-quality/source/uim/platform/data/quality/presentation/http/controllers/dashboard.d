/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.quality.presentation.http.dashboard;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import std.conv : to;

import uim.platform.data.quality.application.usecases.compute_dashboard;
import uim.platform.data.quality.application.dto;
import uim.platform.data.quality.domain.types;
import uim.platform.data.quality.domain.entities.quality_dashboard;

class DashboardController {
  private ComputeDashboardUseCase uc;

  this(ComputeDashboardUseCase uc)
  {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router)
  {
    router.post("/api/v1/dashboard", &handleCompute);
  }

  private void handleCompute(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto j = req.json;
      auto r = ComputeDashboardRequest();
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.datasetId = j.getString("datasetId");
      r.datasetName = j.getString("datasetName");

      auto dashboard = uc.compute(r);
      res.writeJsonBody(serializeDashboard(dashboard), 200);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private static Json serializeDashboard(ref const QualityDashboard d)
  {
    auto j = Json.emptyObject;
    j["tenantId"] = Json(d.tenantId);
    j["datasetId"] = Json(d.datasetId);
    j["datasetName"] = Json(d.datasetName);

    // Record metrics
    auto records = Json.emptyObject;
    records["total"] = Json(d.totalRecords);
    records["valid"] = Json(d.validRecords);
    records["invalid"] = Json(d.invalidRecords);
    records["duplicates"] = Json(d.duplicateRecords);
    records["cleansed"] = Json(d.cleansedRecords);
    j["records"] = records;

    // Scores
    auto scores = Json.emptyObject;
    scores["overall"] = Json(d.overallScore);
    scores["completeness"] = Json(d.completenessScore);
    scores["validity"] = Json(d.validityScore);
    scores["uniqueness"] = Json(d.uniquenessScore);
    scores["consistency"] = Json(d.consistencyScore);
    scores["accuracy"] = Json(d.accuracyScore);
    j["scores"] = scores;

    j["rating"] = Json(d.rating.to!string);
    j["violationCount"] = Json(d.violationCount);

    // Violations by severity
    auto sevArr = Json.emptyArray;
    foreach (ref s; d.violationsBySeverity)
    {
      auto sj = Json.emptyObject;
      sj["severity"] = Json(s.severity.to!string);
      sj["count"] = Json(s.count);
      sevArr ~= sj;
    }
    j["violationsBySeverity"] = sevArr;

    j["computedAt"] = Json(d.computedAt);

    return j;
  }
}
