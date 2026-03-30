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
