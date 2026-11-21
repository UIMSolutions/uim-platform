/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// A group of records of a dataset that are probably duplicates. The first
/// candidate is the anchor record (score 100); resolving the group selects
/// the surviving "golden" record.
module uim.platform.data_quality.domain.entities.match_group;

import uim.platform.data_quality;

mixin(ShowModule!());

@safe:

struct MatchCandidate {
  RecordId recordId;
  double score = 0; /// similarity to the anchor (0 … 100)
  MatchConfidence confidence = MatchConfidence.low;
}

struct MatchGroup {
  mixin TenantEntity!MatchGroupId;

  DatasetId datasetId;
  MatchStrategy strategy = MatchStrategy.fuzzy;
  double threshold = 85;
  string[] matchFields;
  MatchCandidate[] candidates;
  RecordId survivorRecordId;
  bool resolved;
  long detectedAt;
  long resolvedAt;

  size_t size() const {
    return candidates.length;
  }

  /// Highest similarity of a non-anchor candidate.
  double bestScore() const {
    double best = 0;
    foreach (c; candidates.length > 1 ? candidates[1 .. $] : null)
      if (c.score > best)
        best = c.score;
    return best;
  }

  bool contains(RecordId record) const {
    foreach (c; candidates)
      if (c.recordId == record)
        return true;
    return false;
  }

  /// Record ids of the duplicates (every candidate except the survivor).
  RecordId[] duplicates() const {
    RecordId[] result;
    auto survivor = survivorRecordId.isNull && candidates.length ? candidates[0].recordId : survivorRecordId;
    foreach (c; candidates)
      if (c.recordId != survivor)
        result ~= c.recordId;
    return result;
  }

  void resolve(RecordId survivor, long now) {
    if (resolved)
      throw DataQualityException.ruleViolation("Match group '" ~ id.value ~ "' is already resolved");
    if (!contains(survivor))
      throw DataQualityException.invalid("Record '" ~ survivor.value ~ "' is not a candidate of match group '" ~ id.value ~ "'");
    survivorRecordId = survivor;
    resolved = true;
    resolvedAt = now;
  }
}

///
unittest {
  MatchGroup g;
  g.id = MatchGroupId("g1");
  g.candidates = [MatchCandidate(RecordId("a"), 100), MatchCandidate(RecordId("b"), 92), MatchCandidate(RecordId("c"), 88)];
  assert(g.size == 3 && g.bestScore == 92 && g.duplicates == [RecordId("b"), RecordId("c")]);
  assert(failsWith(DqErrorKind.invalid, () { g.resolve(RecordId("x"), 1); }));
  g.resolve(RecordId("b"), 1);
  assert(g.duplicates == [RecordId("a"), RecordId("c")]);
  assert(failsWith(DqErrorKind.ruleViolation, () { g.resolve(RecordId("b"), 2); }));
}
