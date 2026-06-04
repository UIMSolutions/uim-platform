module uim.platform.analytics.domain.enumerations.prediction;
import uim.platform.analytics;

mixin(ShowModule!());
@safe:
enum PredictionType {
  Classification,
  Regression,
  TimeSeries,
  Clustering,
  AnomalyDetection,
}
PredictionType toPredictionType(string type) {
  const map = [
    "classification": PredictionType.Classification,
    "regression": PredictionType.Regression,
    "timeseries": PredictionType.TimeSeries,
    "clustering": PredictionType.Clustering,
    "anomalydetection": PredictionType.AnomalyDetection,
  ];
  return map.get(type.toLower, PredictionType.Regression);
}

enum PredictionStatus {
  Created,
  Training,
  Ready,
  Failed,
  Archived,
}
PredictionStatus toPredictionStatus(string status) {
  const map = [
    "created": PredictionStatus.Created,
    "training": PredictionStatus.Training,
    "ready": PredictionStatus.Ready,
    "failed": PredictionStatus.Failed,
    "archived": PredictionStatus.Archived,
  ];
  return map.get(status.toLower, PredictionStatus.Created);
}


