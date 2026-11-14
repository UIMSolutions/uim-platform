/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Quality estimation of translations.
module uim.platform.translation.domain.services.quality;

import uim.platform.translation;

mixin(ShowModule!());

@safe:

/// Quality level of a score (0–100).
QualityLevel qualityLevelOf(int score) pure nothrow {
  if (score <= 0)
    return QualityLevel.unknown;
  if (score >= 90)
    return QualityLevel.excellent;
  if (score >= 75)
    return QualityLevel.good;
  if (score >= 60)
    return QualityLevel.adequate;
  return QualityLevel.poor;
}

/// Final score of a translation: the provider's estimate, +2 per enforced
/// glossary term (verified terminology), −20 if the translation exceeds the
/// text's maximum length. Clamped to 1–100.
int adjustQuality(int providerScore, int glossaryHits, size_t translatedLength, int maxLength) pure nothrow {
  long score = providerScore + 2L * glossaryHits;
  if (maxLength > 0 && translatedLength > maxLength)
    score -= 20;
  return cast(int)(score < 1 ? 1 : score > 100 ? 100 : score);
}

/// Average of the positive scores (0 if none).
int averageQuality(const int[] scores) pure nothrow {
  long sum, n;
  foreach (s; scores)
    if (s > 0) {
      sum += s;
      n++;
    }
  return n == 0 ? 0 : cast(int)((sum + n / 2) / n);
}

///
unittest {
  assert(qualityLevelOf(95) == QualityLevel.excellent);
  assert(qualityLevelOf(75) == QualityLevel.good);
  assert(qualityLevelOf(61) == QualityLevel.adequate);
  assert(qualityLevelOf(10) == QualityLevel.poor);
  assert(qualityLevelOf(0) == QualityLevel.unknown);
  assert(adjustQuality(80, 3, 10, 0) == 86);
  assert(adjustQuality(80, 0, 50, 40) == 60);
  assert(adjustQuality(99, 5, 1, 0) == 100);
  assert(averageQuality([80, 90, 0]) == 85);
}
