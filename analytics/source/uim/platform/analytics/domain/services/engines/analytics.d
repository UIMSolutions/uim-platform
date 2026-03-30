module uim.platform.analytics.domain.services.engines.analytics;

import uim.platform.analytics.domain.values.aggregation;

/// Domain service: performs analytical computations on raw data rows.
struct AnalyticsEngine {

    /// Aggregate a column of numeric values using the given function.
    static double aggregate(double[] values, AggregationType aggType) {
        if (values.length == 0)
            return 0.0;

        final switch (aggType) {
            case AggregationType.Sum:
                return sum(values);
            case AggregationType.Average:
                return sum(values) / values.length;
            case AggregationType.Count:
                return cast(double) values.length;
            case AggregationType.CountDistinct:
                return cast(double) unique(values).length;
            case AggregationType.Min:
                return minVal(values);
            case AggregationType.Max:
                return maxVal(values);
            case AggregationType.Median:
                return median(values);
            case AggregationType.Variance:
                return variance(values);
            case AggregationType.StdDev:
                import std.math : sqrt;
                return sqrt(variance(values));
            case AggregationType.First:
                return values[0];
            case AggregationType.Last:
                return values[$ - 1];
            case AggregationType.RunningTotal:
                return sum(values); // simplified
            case AggregationType.WeightedAverage:
                return sum(values) / values.length; // simplified — needs weights
        }
    }

    static double sum(double[] v) {
        double s = 0;
        foreach (x; v) s += x;
        return s;
    }

    static double minVal(double[] v) {
        double m = v[0];
        foreach (x; v) if (x < m) m = x;
        return m;
    }

    static double maxVal(double[] v) {
        double m = v[0];
        foreach (x; v) if (x > m) m = x;
        return m;
    }

    static double median(double[] v) {
        import std.algorithm : sort;
        auto sorted = v.dup;
        sorted.sort();
        auto n = sorted.length;
        if (n % 2 == 1)
            return sorted[n / 2];
        return (sorted[n / 2 - 1] + sorted[n / 2]) / 2.0;
    }

    static double variance(double[] v) {
        double avg = sum(v) / v.length;
        double s = 0;
        foreach (x; v) s += (x - avg) * (x - avg);
        return s / v.length;
    }

    static double[] unique(double[] v) {
        double[] result;
        bool[double] seen;
        foreach (x; v) {
            if (x !in seen) {
                seen[x] = true;
                result ~= x;
            }
        }
        return result;
    }
}
