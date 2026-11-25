/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Confidence of extracted values: bands and document summaries.
module uim.platform.document_ai.domain.services.confidence;

import uim.platform.document_ai;

mixin(ShowModule!());

@safe:

/// high >= max(threshold + 0.2, 0.9) > medium >= threshold > low
ConfidenceLevel confidenceLevel(double confidence, double threshold) pure {
  if (confidence < threshold)
    return ConfidenceLevel.low;
  return confidence >= max(threshold + 0.2, 0.9) ? ConfidenceLevel.high : ConfidenceLevel.medium;
}

/// Summary of the values of a document.
struct ConfidenceSummary {
  double overall = 0; /// mean confidence (0 if no values)
  int fields; /// values
  int lineItems; /// distinct line item rows
  int low; /// values below the threshold or missing required values
  int corrected;
}

ConfidenceSummary summarize(const ExtractedField[] fields, double threshold) {
  ConfidenceSummary s;
  double sum = 0;
  bool[int] rows;
  foreach (f; fields) {
    s.fields++;
    sum += f.confidence;
    if (f.rowIndex > 0)
      rows[f.rowIndex] = true;
    if (f.corrected)
      s.corrected++;
    else if (f.confidence < threshold || f.isMissing)
      s.low++;
  }
  s.lineItems = cast(int) rows.length;
  s.overall = s.fields ? sum / s.fields : 0;
  return s;
}

///
unittest {
  assert(confidenceLevel(0.95, 0.7) == ConfidenceLevel.high);
  assert(confidenceLevel(0.8, 0.7) == ConfidenceLevel.medium);
  assert(confidenceLevel(0.5, 0.7) == ConfidenceLevel.low);
  ExtractedField a, b, c;
  a.confidence = 0.9;
  b.confidence = 0.3;
  b.rowIndex = 1;
  c.confidence = 1.0;
  c.corrected = true;
  c.rowIndex = 2;
  auto s = summarize([a, b, c], 0.7);
  assert(s.fields == 3 && s.low == 1 && s.corrected == 1 && s.lineItems == 2);
  assert(s.overall > 0.73 && s.overall < 0.74);
}
