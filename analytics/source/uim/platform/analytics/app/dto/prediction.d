module uim.platform.analytics.app.dto.prediction;

import std.conv : to;
import uim.platform.analytics.domain.entities.prediction;
import uim.platform.analytics;

mixin(ShowModule!());
@safe:
struct CreatePredictionRequest {
  string name;
  string description;
  string datasetId;
  string predictionType;
  string targetColumn;
  string[] featureColumns;
  string userId;
}

struct PredictionResponse {
  string id;
  string name;
  string description;
  string datasetId;
  string predictionType;
  string status;
  double accuracy;
  double rmse;
  string modelSummary;

  static PredictionResponse fromEntity(Prediction p) {
    if (p is null)
      return PredictionResponse.init;

    return PredictionResponse(
      p.id.value,
      p.name,
      p.description,
      p.datasetId.value,
      p.predictionType.to!string,
      p.predStatus.to!string,
      p.lastResult.accuracy,
      p.lastResult.rmse,
      p.lastResult.modelSummary,
    );
  }
}
