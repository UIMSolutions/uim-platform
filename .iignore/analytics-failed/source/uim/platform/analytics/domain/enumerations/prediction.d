module uim.platform.analytics.domain.enumerations.prediction;
import uim.platform.analytics;

// mixin(ShowModule!());
@safe:
enum PredictionType {
  // Used for predicting categorical outcomes, where the goal is to classify data points into predefined classes or categories based on input features
  Classification,
  // Used for predicting continuous numerical values, where the goal is to estimate a quantity or value based on input features
  Regression,
  // Used for predicting future values in a time series dataset, where the goal is to forecast future data points based on historical patterns and trends
  TimeSeries,
  // Used for grouping similar data points together based on their features, where the goal is to identify natural clusters or segments within the data without predefined labels
  Clustering,
  // Used for identifying unusual or anomalous data points that deviate significantly from the expected patterns in the data, where the goal is to detect potential outliers, fraud, or other rare events
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
  // Used for predictions that have been created but have not yet started the training process
  Created,
  // Used for predictions that are currently undergoing the training process, where the model is being built and optimized based on the training data
  Training,
  // Used for predictions that have completed the training process and are now ready for evaluation, testing, or deployment
  Ready,
  // Used for predictions that encountered an error during the training process and were not successfully completed, which may require troubleshooting and re-training
  Failed,
  // Used for predictions that have been completed and are no longer active or in use, but are retained for historical reference or archival purposes
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


