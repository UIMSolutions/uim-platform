/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.analytics.domain.enumerations.prediction;
import uim.platform.analytics;

mixin(ShowModule!());
@safe:
enum PredictionType {
  // Used for predicting categorical outcomes, where the goal is to classify data points into predefined classes or categories based on input features
  classification,
  // Used for predicting continuous numerical values, where the goal is to estimate a quantity or value based on input features
  regression,
  // Used for predicting future values in a time series dataset, where the goal is to forecast future data points based on historical patterns and trends
  timeSeries,
  // Used for grouping similar data points together based on their features, where the goal is to identify natural clusters or segments within the data without predefined labels
  clustering,
  // Used for identifying unusual or anomalous data points that deviate significantly from the expected patterns in the data, where the goal is to detect potential outliers, fraud, or other rare events
  anomalyDetection,
}
PredictionType toPredictionType(string type) {
  mixin(EnumSwitch("PredictionType", "classification"));
}
PredictionType[] toPredictionTypes(string[] types) {
  return types.map!(toPredictionType).array;
}
string toString(PredictionType type) {
  return type.to!string;
}
string[] toStrings(PredictionType[] types) {
  return types.map!toString.array;
}
///
unittest {
  mixin(ShowTest!("PredictionType"));

  assert(PredictionType.classification.toString == "classification");
  assert(PredictionType.regression.toString == "regression");
  assert(PredictionType.timeSeries.toString == "timeSeries");
  assert(PredictionType.clustering.toString == "clustering");
  assert(PredictionType.anomalyDetection.toString == "anomalyDetection");

  assert("classification".toPredictionType == PredictionType.classification);
  assert("regression".toPredictionType == PredictionType.regression);
  assert("timeSeries".toPredictionType == PredictionType.timeSeries);
  assert("clustering".toPredictionType == PredictionType.clustering);
  assert("anomalyDetection".toPredictionType == PredictionType.anomalyDetection);

  assert("unknown".toPredictionType == PredictionType.classification); // Default case
  assert("".toPredictionType == PredictionType.classification); // Default case

  assert(["classification", "regression", "timeSeries", "clustering", "anomalyDetection"].toPredictionTypes ==
         [PredictionType.classification, PredictionType.regression, PredictionType.timeSeries, PredictionType.clustering, PredictionType.anomalyDetection]);
  assert(toString([PredictionType.classification, PredictionType.regression, PredictionType.timeSeries, PredictionType.clustering, PredictionType.anomalyDetection]) ==
         ["classification", "regression", "timeSeries", "clustering", "anomalyDetection"]);
}

enum PredictionStatus {
  // Used for predictions that have been created but have not yet started the training process
  created,
  // Used for predictions that are currently undergoing the training process, where the model is being built and optimized based on the training data
  training,
  // Used for predictions that have completed the training process and are now ready for evaluation, testing, or deployment
  ready,
  // Used for predictions that encountered an error during the training process and were not successfully completed, which may require troubleshooting and re-training
  failed,
  // Used for predictions that have been completed and are no longer active or in use, but are retained for historical reference or archival purposes
  archived,
}
PredictionStatus toPredictionStatus(string status) {
  mixin(EnumSwitch("PredictionStatus", "created"));
}
PredictionStatus[] toPredictionStatuses(string[] statuses) {
  return statuses.map!(toPredictionStatus).array;
}
string toString(PredictionStatus status) {
  return status.to!string;
}
string[] toStrings(PredictionStatus[] statuses) {
  return statuses.map!toString.array;
}
///
unittest {
  mixin(ShowTest!("PredictionStatus")); 

  assert(PredictionStatus.created.toString == "created");
  assert(PredictionStatus.training.toString == "training");
  assert(PredictionStatus.ready.toString == "ready");
  assert(PredictionStatus.failed.toString == "failed");
  assert(PredictionStatus.archived.toString == "archived"); 

  assert("created".toPredictionStatus == PredictionStatus.created);
  assert("training".toPredictionStatus == PredictionStatus.training);
  assert("ready".toPredictionStatus == PredictionStatus.ready);
  assert("failed".toPredictionStatus == PredictionStatus.failed);
  assert("archived".toPredictionStatus == PredictionStatus.archived); 

  assert("unknown".toPredictionStatus == PredictionStatus.created); // Default case
  assert("".toPredictionStatus == PredictionStatus.created); // Default case

  assert(["created", "training", "ready", "failed", "archived"].toPredictionStatuses ==
         [PredictionStatus.created, PredictionStatus.training, PredictionStatus.ready, PredictionStatus.failed, PredictionStatus.archived]);
  assert(toString([PredictionStatus.created, PredictionStatus.training, PredictionStatus.ready, PredictionStatus.failed, PredictionStatus.archived]) ==
         ["created", "training", "ready", "failed", "archived"]);
}


