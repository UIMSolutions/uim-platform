/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Quality scores of a dataset along the five data quality dimensions.
/// Every score is a percentage (0 … 100). The overall score is the
/// weighted mean: completeness 25 %, validity 30 %, uniqueness 20 %,
/// consistency 15 %, accuracy 10 %.
module uim.platform.data_quality.domain.types.scores;

import uim.platform.data_quality;

mixin(ShowModule!());

@safe:

enum double completenessWeight = 0.25;
enum double validityWeight = 0.30;
enum double uniquenessWeight = 0.20;
enum double consistencyWeight = 0.15;
enum double accuracyWeight = 0.10;

struct QualityScores {
  double completeness = 100;
  double validity = 100;
  double uniqueness = 100;
  double consistency = 100;
  double accuracy = 100;

  double overall() const pure {
    return roundScore(completeness * completenessWeight + validity * validityWeight + uniqueness * uniquenessWeight
        + consistency * consistencyWeight + accuracy * accuracyWeight);
  }

  QualityRating rating() const pure {
    return ratingOf(overall);
  }
}

/// Percentage of part in total (100 for an empty total), 2 decimals.
double percentage(size_t part, size_t total) pure {
  return total == 0 ? 100.0 : roundScore(cast(double) part * 100.0 / cast(double) total);
}

/// Round to two decimals and clamp to [0, 100].
double roundScore(double value) pure {
  import std.math : round;

  if (value != value) // NaN
    return 0;
  auto v = value < 0 ? 0 : value > 100 ? 100 : value;
  return round(v * 100.0) / 100.0;
}

///
unittest {
  QualityScores s;
  assert(s.overall == 100 && s.rating == QualityRating.excellent);
  s.validity = 50;
  assert(s.overall == 85 && s.rating == QualityRating.good);
  assert(percentage(1, 3) == 33.33 && percentage(0, 0) == 100);
  assert(roundScore(120) == 100 && roundScore(-1) == 0);
}
