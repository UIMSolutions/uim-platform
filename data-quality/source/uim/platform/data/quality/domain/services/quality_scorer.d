module uim.platform.data.quality.domain.services.quality_scorer;

import uim.platform.data.quality.domain.types;
import uim.platform.data.quality.domain.entities.quality_dashboard;
import uim.platform.data.quality.domain.entities.validation_result;
import uim.platform.data.quality.domain.entities.data_profile;

import std.datetime.systime : Clock;

/// Domain service - computes quality scores and dashboard metrics.
class QualityScorer
{
    /// Compute a quality dashboard from validation results and profile data.
    QualityDashboard computeDashboard(
        TenantId tenantId,
        DatasetId datasetId,
        string datasetName,
        ValidationResult[] results,
        DataProfile* profile)
    {
        QualityDashboard d;
        d.tenantId = tenantId;
        d.datasetId = datasetId;
        d.datasetName = datasetName;
        d.totalRecords = cast(long) results.length;

        long valid = 0;
        long invalid = 0;
        int totalViolations = 0;
        int[4] severityCounts;  // info, warning, error, critical

        foreach (ref r; results)
        {
            if (r.violations.length == 0)
                ++valid;
            else
                ++invalid;

            foreach (ref v; r.violations)
            {
                ++totalViolations;
                final switch (v.severity)
                {
                case RuleSeverity.info:     ++severityCounts[0]; break;
                case RuleSeverity.warning:  ++severityCounts[1]; break;
                case RuleSeverity.error:    ++severityCounts[2]; break;
                case RuleSeverity.critical: ++severityCounts[3]; break;
                }
            }
        }

        d.validRecords = valid;
        d.invalidRecords = invalid;
        d.violationCount = totalViolations;

        // Validity score
        d.validityScore = d.totalRecords > 0
            ? (cast(double) valid / d.totalRecords) * 100.0
            : 100.0;

        // Completeness and uniqueness from profile
        if (profile !is null)
        {
            d.completenessScore = computeCompleteness(profile.columns);
            d.uniquenessScore = computeUniqueness(profile.columns);
        }
        else
        {
            d.completenessScore = 100.0;
            d.uniquenessScore = 100.0;
        }

        d.consistencyScore = d.validityScore; // simplified
        d.accuracyScore = d.validityScore;     // simplified

        // Overall = weighted average
        d.overallScore = d.completenessScore * 0.25
            + d.validityScore * 0.30
            + d.uniquenessScore * 0.20
            + d.consistencyScore * 0.15
            + d.accuracyScore * 0.10;

        d.rating = scoreToRating(d.overallScore);

        // Severity breakdown
        d.violationsBySeverity = [
            RuleSeverityCount(RuleSeverity.info, severityCounts[0]),
            RuleSeverityCount(RuleSeverity.warning, severityCounts[1]),
            RuleSeverityCount(RuleSeverity.error, severityCounts[2]),
            RuleSeverityCount(RuleSeverity.critical, severityCounts[3]),
        ];

        d.computedAt = Clock.currStdTime();

        return d;
    }

    private static double computeCompleteness(ColumnProfile[] columns)
    {
        if (columns.length == 0)
            return 100.0;
        double total = 0.0;
        foreach (ref c; columns)
            total += c.completeness;
        return total / columns.length;
    }

    private static double computeUniqueness(ColumnProfile[] columns)
    {
        if (columns.length == 0)
            return 100.0;
        double total = 0.0;
        foreach (ref c; columns)
            total += c.uniqueness;
        return total / columns.length;
    }

    static QualityRating scoreToRating(double score)
    {
        if (score >= 95.0) return QualityRating.excellent;
        if (score >= 80.0) return QualityRating.good;
        if (score >= 60.0) return QualityRating.fair;
        if (score >= 40.0) return QualityRating.poor;
        return QualityRating.critical;
    }
}
