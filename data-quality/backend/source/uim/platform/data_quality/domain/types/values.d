/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Composite value objects: postal address input/outcome and the
/// statistics of a profiled column.
module uim.platform.data_quality.domain.types.values;

import uim.platform.data_quality;

mixin(ShowModule!());

@safe:

struct AddressInput {
  string line1;
  string line2;
  string city;
  string region;
  string postalCode;
  string country;
}

struct AddressOutcome {
  string line1;
  string line2;
  string city;
  string region;
  string postalCode;
  string country; /// ISO alpha-2 if recognized, else the cleaned input
  bool countryRecognized;
  bool postalCodePlausible;
  AddressQuality quality = AddressQuality.unverifiable;
  string[] changes;
}

/// Profiling statistics of one field.
struct ColumnStats {
  string fieldName;
  ProfiledType detectedType = ProfiledType.empty;
  long totalValues; /// records of the dataset
  long missingCount; /// records without the field or with an empty value
  long distinctCount; /// distinct non-empty values
  long duplicateCount; /// non-empty values that repeat an earlier one
  double completeness = 100; /// filled / total (%)
  double uniqueness = 100; /// distinct / filled (%)
  string minValue; /// numeric minimum for numbers, else lexical
  string maxValue;
  double mean = 0; /// numeric columns only
  bool numeric;
  long minLength;
  long maxLength;
  double avgLength = 0;
  string[] topValues; /// "value (count)", most frequent first
  string[] patterns; /// "Aa99 (count)": letters A/a, digits 9
}
