/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.analytics.domain.values.aggregation;

/// Aggregation functions available for measures.
enum AggregationType {
  Sum,
  Average,
  Count,
  CountDistinct,
  Min,
  Max,
  Median,
  Variance,
  StdDev,
  First,
  Last,
  RunningTotal,
  WeightedAverage,
}
