/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.analytics.domain.entities.prediction;

import uim.platform.analytics.domain.values.common;
import uim.platform.analytics;

mixin(ShowModule!());
@safe:

/// A Prediction encapsulates a predictive/ML model run (SAC Smart Predict).
class Prediction
{
  EntityId id;
  string name;
  string description;
  EntityId datasetId;
  PredictionType predictionType;
  PredictionConfig config;
  PredictionResult lastResult;
  PredictionStatus predStatus;
  AuditInfo audit;

  this()
  {
  }

  static Prediction create(string name, string description, string datasetId,
      PredictionType ptype, PredictionConfig cfg, string userId)
  {
    auto p = new Prediction();
    p.id = EntityId.generate();
    p.name = name;
    p.description = description;
    p.datasetId = EntityId(datasetId);
    p.predictionType = ptype;
    p.config = cfg;
    p.lastResult = PredictionResult.init;
    p.predStatus = PredictionStatus.Created;
    p.audit = AuditInfo.create(userId);
    return p;
  }

  void markTraining()
  {
    predStatus = PredictionStatus.Training;
  }

  void markReady(PredictionResult result)
  {
    predStatus = PredictionStatus.Ready;
    lastResult = result;
  }

  void markFailed(string error)
  {
    predStatus = PredictionStatus.Failed;
    lastResult.errorMessage = error;
  }
}

enum PredictionType
{
  Classification,
  Regression,
  TimeSeries,
  Clustering,
  AnomalyDetection,
}

enum PredictionStatus
{
  Created,
  Training,
  Ready,
  Failed,
  Archived,
}

struct PredictionConfig
{
  string targetColumn;
  string[] featureColumns;
  int horizonPeriods = 12;
  double trainTestSplit = 0.8;
}

struct PredictionResult
{
  double accuracy = 0.0;
  double rmse = 0.0;
  double confidenceLevel = 0.0;
  string errorMessage;
  string modelSummary;
}
