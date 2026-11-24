/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// A residence or retention period ("10 years", "6 months"), added with
/// calendar arithmetic.
module uim.platform.data_retention.domain.types.periods;

import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

/// Upper bound of a period in days (≈ 150 years), a sanity limit.
enum long maxPeriodDays = 55_000;

struct RetentionPeriod {
  int duration; /// 0 = no period (e.g. delete right at the end of residence)
  PeriodUnit unit = PeriodUnit.years;

  /// The point in time duration × unit after stdTime.
  long addTo(long stdTime) const {
    final switch (unit) {
    case PeriodUnit.days:
      return plusDays(stdTime, duration);
    case PeriodUnit.weeks:
      return plusDays(stdTime, 7L * duration);
    case PeriodUnit.months:
      return plusMonths(stdTime, duration);
    case PeriodUnit.years:
      return plusYears(stdTime, duration);
    }
  }

  /// Approximate length in days (comparison, limits).
  long approximateDays() const pure {
    final switch (unit) {
    case PeriodUnit.days:
      return duration;
    case PeriodUnit.weeks:
      return 7L * duration;
    case PeriodUnit.months:
      return 31L * duration;
    case PeriodUnit.years:
      return 366L * duration;
    }
  }

  void validate(string what) const {
    if (duration < 0)
      throw DataRetentionException.invalid(what ~ " must not be negative");
    if (approximateDays > maxPeriodDays)
      throw DataRetentionException.invalid(what ~ " is too long (at most 150 years)");
  }

  /// "10 years", "1 month", "0 days"
  string text() const {
    auto u = cast(string) unit;
    return format("%d %s", duration, duration == 1 ? u[0 .. $ - 1] : u);
  }
}

///
unittest {
  auto start = parseIsoTime("2026-01-31");
  assert(isoDateText(RetentionPeriod(1, PeriodUnit.months).addTo(start)) == "2026-02-28");
  assert(isoDateText(RetentionPeriod(10, PeriodUnit.years).addTo(start)) == "2036-01-31");
  assert(isoDateText(RetentionPeriod(2, PeriodUnit.weeks).addTo(start)) == "2026-02-14");
  assert(RetentionPeriod(0, PeriodUnit.days).addTo(start) == start);
  assert(RetentionPeriod(1, PeriodUnit.years).text == "1 year" && RetentionPeriod(6, PeriodUnit.months).text == "6 months");
  assert(failsWith(DrErrorKind.invalid, () { RetentionPeriod(-1).validate("Retention"); }));
  assert(failsWith(DrErrorKind.invalid, () { RetentionPeriod(200).validate("Retention"); }));
  RetentionPeriod(150, PeriodUnit.years).validate("Retention");
}
