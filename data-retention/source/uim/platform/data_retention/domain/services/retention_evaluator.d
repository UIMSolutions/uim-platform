module uim.platform.data_retention.domain.services.retention_evaluator;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

struct RetentionEvaluator {
    static PurposeCheckResult checkEndOfPurpose(long referenceDate, int residenceDuration,
            PeriodUnit residenceUnit, int retentionDuration, PeriodUnit retentionUnit, long currentTime) {
        long residenceEnd = addPeriod(referenceDate, residenceDuration, residenceUnit);
        long retentionEnd = addPeriod(residenceEnd, retentionDuration, retentionUnit);

        if (currentTime < residenceEnd)
            return PurposeCheckResult.withinResidence;
        if (currentTime < retentionEnd)
            return PurposeCheckResult.withinRetention;
        return PurposeCheckResult.endOfRetention;
    }

    static long addPeriod(long baseTime, int duration, PeriodUnit unit) {
        long seconds = 0;
        final switch (unit) {
            case PeriodUnit.days:
                seconds = duration * 86_400L;
                break;
            case PeriodUnit.weeks:
                seconds = duration * 604_800L;
                break;
            case PeriodUnit.months:
                seconds = duration * 2_592_000L;
                break;
            case PeriodUnit.years:
                seconds = duration * 31_536_000L;
                break;
        }
        return baseTime + seconds;
    }

    static bool isResidenceExpired(long referenceDate, int duration, PeriodUnit unit, long currentTime) {
        return currentTime >= addPeriod(referenceDate, duration, unit);
    }

    static bool isRetentionExpired(long residenceEnd, int duration, PeriodUnit unit, long currentTime) {
        return currentTime >= addPeriod(residenceEnd, duration, unit);
    }
}
