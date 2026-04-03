module uim.platform.xyz.domain.services.threshold_evaluator;

import uim.platform.xyz.domain.entities.alert_rule;
import uim.platform.xyz.domain.entities.metric;
import uim.platform.xyz.domain.types;

/// Result of evaluating a metric against an alert rule.
struct EvaluationResult
{
    bool breached;
    AlertSeverity severity;
    string message;
    double currentValue;
    double thresholdValue;
}

/// Domain service: evaluates metric values against alert rule thresholds.
struct ThresholdEvaluator
{
    /// Evaluate a single metric value against an alert rule.
    static EvaluationResult evaluate(double value_, const ref AlertRule rule)
    {
        EvaluationResult result;
        result.currentValue = value_;

        // Check critical threshold first
        if (rule.criticalThreshold != 0 && breaches(value_, rule.criticalThreshold, rule.operator_))
        {
            result.breached = true;
            result.severity = AlertSeverity.critical;
            result.thresholdValue = rule.criticalThreshold;
            result.message = "Critical: " ~ rule.metricName ~ " value " ~
                formatDouble(value_) ~ " " ~ operatorStr(rule.operator_) ~
                " threshold " ~ formatDouble(rule.criticalThreshold);
            return result;
        }

        // Check warning threshold
        if (rule.warningThreshold != 0 && breaches(value_, rule.warningThreshold, rule.operator_))
        {
            result.breached = true;
            result.severity = AlertSeverity.warning;
            result.thresholdValue = rule.warningThreshold;
            result.message = "Warning: " ~ rule.metricName ~ " value " ~
                formatDouble(value_) ~ " " ~ operatorStr(rule.operator_) ~
                " threshold " ~ formatDouble(rule.warningThreshold);
            return result;
        }

        result.breached = false;
        return result;
    }

    /// Compute average of recent metrics for evaluation.
    static double computeAverage(const Metric[] metrics)
    {
        if (metrics.length == 0)
            return 0;

        double sum = 0;
        foreach (ref m; metrics)
            sum += m.value_;
        return sum / cast(double) metrics.length;
    }

    private static bool breaches(double value_, double threshold, ThresholdOperator op)
    {
        final switch (op)
        {
            case ThresholdOperator.greaterThan:     return value_ > threshold;
            case ThresholdOperator.greaterOrEqual:   return value_ >= threshold;
            case ThresholdOperator.lessThan:         return value_ < threshold;
            case ThresholdOperator.lessOrEqual:      return value_ <= threshold;
            case ThresholdOperator.equal:            return value_ == threshold;
            case ThresholdOperator.notEqual:         return value_ != threshold;
        }
    }

    private static string operatorStr(ThresholdOperator op)
    {
        final switch (op)
        {
            case ThresholdOperator.greaterThan:     return ">";
            case ThresholdOperator.greaterOrEqual:   return ">=";
            case ThresholdOperator.lessThan:         return "<";
            case ThresholdOperator.lessOrEqual:      return "<=";
            case ThresholdOperator.equal:            return "==";
            case ThresholdOperator.notEqual:         return "!=";
        }
    }

    private static string formatDouble(double v)
    {
        import std.format : format;
        return format("%.2f", v);
    }
}
