/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.domain.services.enrichment_matcher;

// import uim.platform.document_ai.domain.types;
// import uim.platform.document_ai.domain.entities.extraction_result;
// import uim.platform.document_ai.domain.entities.enrichment_data;
import uim.platform.document_ai;

mixin(ShowModule!());

@safe:
struct EnrichmentMatchResult {
  EnrichmentDataId matchedId;
  EnrichmentMatchStatus status;
  double matchScore;
  string[] matchedFields;
}

EnrichmentMatchResult matchEnrichmentData(ExtractionResult result, EnrichmentData[] candidates) {
  if (candidates.length == 0)
    return EnrichmentMatchResult("", EnrichmentMatchStatus.unmatched, 0.0, []);

  EnrichmentMatchResult best;
  best.status = EnrichmentMatchStatus.unmatched;
  best.matchScore = 0.0;

  foreach (candidate; candidates) {
    double score = 0.0;
    string[] matched;
    int totalFields = 0;

    foreach (ef; candidate.fields) {
      totalFields++;
      foreach (hf; result.headerFields) {
        if (hf.name == ef.key && hf.value == ef.value) {
          score += 1.0;
          matched ~= ef.key;
          break;
        }
      }
    }

    if (totalFields > 0)
      score = score / cast(double) totalFields;

    if (score > best.matchScore) {
      best.matchedId = candidate.id;
      best.matchScore = score;
      best.matchedFields = matched;
    }
  }

  if (best.matchScore >= 0.8)
    best.status = EnrichmentMatchStatus.matched;
  else if (best.matchScore >= 0.4)
    best.status = EnrichmentMatchStatus.ambiguous;
  else
    best.status = EnrichmentMatchStatus.unmatched;

  return best;
}
