module uim.platform.analytics.domain.enumerations.prediction;

enum PredictionType {
  Classification,
  Regression,
  TimeSeries,
  Clustering,
  AnomalyDetection,
}

enum PredictionStatus {
  Created,
  Training,
  Ready,
  Failed,
  Archived,
}

struct PredictionConfig {
  string targetColumn;
  string[] featureColumns;
  int horizonPeriods = 12;
  double trainTestSplit = 0.8;
}

struct PredictionResult {
  double accuracy = 0.0;
  double rmse = 0.0;
  double confidenceLevel = 0.0;
  string errorMessage;
  string modelSummary;
}
