/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Domain service: the scorecard of a dataset.
///
/// A dimension score is the share of records without a score relevant
/// (warning or worse) violation of a rule of that dimension:
///   completeness  required rules — averaged with the profiled field completeness
///   validity      format, range, length, enumeration rules
///   uniqueness    unique rules — and records that are open duplicates
///   consistency   cross field and custom rules
///   accuracy      reference data rules
/// Dimensions without rules (and without profile / duplicate data) score 100.
module uim.platform.data_quality.domain.services.quality_scorer;

import uim.platform.data_quality;

mixin(ShowModule!());

@safe:

struct ScoreInput {
  size_t recordCount;
  const(Violation)[] violations;
  const(ColumnProfile)[] columns; /// latest profile (may be empty)
  const(RecordId)[] duplicateRecords; /// non-surviving members of open match groups
}

class QualityScorer {
  QualityScores score(const ScoreInput input) @trusted {
    QualityScores s;
    if (input.recordCount == 0)
      return s;
    bool[string][QualityDimension] failing;
    foreach (v; input.violations)
      if (v.affectsScore)
        failing[v.dimension][v.recordId.value] = true;

    double dimension(QualityDimension d) {
      auto entry = d in failing;
      auto failed = entry ? (*entry).length : 0;
      return percentage(input.recordCount - (failed > input.recordCount ? input.recordCount : failed), input.recordCount);
    }

    s.validity = dimension(QualityDimension.validity);
    s.consistency = dimension(QualityDimension.consistency);
    s.accuracy = dimension(QualityDimension.accuracy);

    // completeness: rule based and profile based measure, averaged when both exist
    auto ruleCompleteness = dimension(QualityDimension.completeness);
    if (input.columns.length) {
      double sum = 0;
      foreach (c; input.columns)
        sum += c.stats.completeness;
      auto profiled = sum / input.columns.length;
      s.completeness = QualityDimension.completeness in failing ? roundScore((ruleCompleteness + profiled) / 2) : roundScore(profiled);
    } else
      s.completeness = ruleCompleteness;

    // uniqueness: records with unique violations or open duplicates
    bool[string] notUnique;
    if (auto u = QualityDimension.uniqueness in failing)
      foreach (id, _; *u)
        notUnique[id] = true;
    foreach (id; input.duplicateRecords)
      notUnique[id.value] = true;
    auto n = notUnique.length > input.recordCount ? input.recordCount : notUnique.length;
    s.uniqueness = percentage(input.recordCount - n, input.recordCount);
    return s;
  }
}

///
unittest {
  Violation v(string record, RuleType type, RuleSeverity severity = RuleSeverity.error) {
    Violation x;
    x.recordId = RecordId(record);
    x.ruleType = type;
    x.severity = severity;
    return x;
  }

  auto scorer = new QualityScorer;
  assert(scorer.score(ScoreInput(0)).overall == 100);

  auto s = scorer.score(ScoreInput(4, [v("1", RuleType.format), v("1", RuleType.range), v("2", RuleType.required),
      v("3", RuleType.custom, RuleSeverity.info)], null, [RecordId("4")]));
  assert(s.validity == 75 && s.completeness == 75 && s.consistency == 100 && s.uniqueness == 75 && s.accuracy == 100);
  assert(s.overall == 81.25 && s.rating == QualityRating.good);

  ColumnProfile c;
  c.stats.completeness = 50;
  auto p = scorer.score(ScoreInput(4, null, [c], null));
  assert(p.completeness == 50);
}
