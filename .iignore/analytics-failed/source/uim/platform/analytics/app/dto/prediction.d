/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.analytics.app.dto.prediction;
// 
// import uim.platform.analytics.domain.entities.prediction;
import uim.platform.analytics;

mixin(ShowModule!());
@safe:
struct CreatePredictionRequest {
  TenantId tenantId;
  ResourceGroupId resourceGroupId;

  string name;
  string description;
  DatasetId datasetId;
  string predictionType;
  string targetColumn;
  string[] featureColumns;
  UserId userId;
}

Json toJson(CreatePredictionRequest request) {
  return serializeToJson(request);
}

struct PredictionResponse {
  TenantId tenantId;
  PredictionId predictionId;
  ResourceGroupId resourceGroupId;

  string name;
  string description;
  DatasetId datasetId;
  string predictionType;
  string status;
  double accuracy;
  double rmse;
  string modelSummary;

  static PredictionResponse fromEntity(Prediction p) {
    if (p.isNull)
      return PredictionResponse.init;

    return PredictionResponse(p.tenantId, p.id, p.resourceGroupId, p.name, p.description,
      p.datasetId, p.predictionType.to!string,
      p.predStatus.to!string, p.lastResult.accuracy, p.lastResult.rmse,
      p.lastResult.modelSummary);
  }

  Json toJson() const {
    return Json.emptyObject
      .set("tenantId", tenantId.value)
      .set("predictionId", predictionId.value)
      .set("resource_group_id", resourceGroupId.value)
      .set("name", name)
      .set("description", description)
      .set("dataset_id", datasetId.value)
      .set("prediction_type", predictionType)
      .set("status", status)
      .set("accuracy", accuracy)
      .set("rmse", rmse)
      .set("model_summary", modelSummary);
  }
}
