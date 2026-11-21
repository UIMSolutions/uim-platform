/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Domain service: finds groups of probable duplicates.
///
/// Values are compared in their match form (lower case, no diacritics or
/// punctuation). The record score is the mean of the field scores of the
/// match fields that are filled in at least one of the two records; records
/// without any filled match field are never grouped.
///
/// Optimizations: match forms and Soundex codes are computed once per
/// record; "exact" and "phonetic" group by hash key in O(n); "fuzzy" and
/// "composite" compare pairwise, skipping pairs whose length difference
/// already rules out the threshold.
module uim.platform.data_quality.domain.services.duplicate_detector;

import uim.platform.data_quality;

mixin(ShowModule!());

@safe:

struct MatchInput {
  RecordId recordId;
  FieldValue[] fields;
}

/// A detected group; candidates[0] is the anchor (score 100).
struct DetectedGroup {
  MatchCandidate[] candidates;
}

class DuplicateDetector {
  DetectedGroup[] detect(const MatchInput[] records, const string[] matchFields, MatchStrategy strategy, double threshold) {
    if (matchFields.length == 0 || records.length < 2)
      return null;
    auto prepared = prepare(records, matchFields);
    final switch (strategy) {
    case MatchStrategy.exact:
      return byKey(prepared, (const ref Prepared p) => p.normalized.join("\x1f"));
    case MatchStrategy.phonetic:
      return byKey(prepared, (const ref Prepared p) => p.phonetic.join("\x1f"));
    case MatchStrategy.fuzzy, MatchStrategy.composite:
      return pairwise(prepared, strategy, threshold);
    }
  }

  /// Similarity (0 … 100) of two records over the match fields.
  double similarity(const FieldValue[] a, const FieldValue[] b, const string[] matchFields, MatchStrategy strategy) {
    auto p = prepare([MatchInput(RecordId("a"), a.dup), MatchInput(RecordId("b"), b.dup)], matchFields);
    return score(p[0], p[1], strategy);
  }

  // ── internals ────────────────────────────────────────────────────────────

  protected struct Prepared {
    RecordId recordId;
    string[] normalized; /// per match field
    string[] phonetic; /// per match field
    size_t[] lengths; /// characters per match field
    bool empty;
  }

  protected static Prepared[] prepare(const MatchInput[] records, const string[] matchFields) {
    Prepared[] result;
    foreach (r; records) {
      Prepared p;
      p.recordId = r.recordId;
      p.empty = true;
      foreach (f; matchFields) {
        auto n = normalizeForMatch(fieldOf(r.fields, f));
        p.normalized ~= n;
        p.phonetic ~= soundexWords(n);
        p.lengths ~= charLength(n);
        if (n.length)
          p.empty = false;
      }
      result ~= p;
    }
    return result;
  }

  protected static DetectedGroup[] byKey(Prepared[] prepared, scope string delegate(const ref Prepared) @safe keyOf) @trusted {
    size_t[][string] buckets;
    string[] order;
    foreach (i, ref p; prepared) {
      if (p.empty)
        continue;
      auto k = keyOf(p);
      if (k !in buckets)
        order ~= k;
      buckets[k] ~= i;
    }
    DetectedGroup[] groups;
    foreach (k; order) {
      auto members = buckets[k];
      if (members.length < 2)
        continue;
      DetectedGroup g;
      foreach (i; members)
        g.candidates ~= MatchCandidate(prepared[i].recordId, 100, MatchConfidence.exact);
      groups ~= g;
    }
    return groups;
  }

  protected static DetectedGroup[] pairwise(Prepared[] prepared, MatchStrategy strategy, double threshold) {
    auto grouped = new bool[prepared.length];
    DetectedGroup[] groups;
    foreach (i; 0 .. prepared.length) {
      if (grouped[i] || prepared[i].empty)
        continue;
      DetectedGroup g;
      foreach (j; i + 1 .. prepared.length) {
        if (grouped[j] || prepared[j].empty)
          continue;
        if (strategy == MatchStrategy.fuzzy && upperBound(prepared[i], prepared[j]) < threshold)
          continue;
        auto s = score(prepared[i], prepared[j], strategy);
        if (s >= threshold) {
          if (g.candidates.length == 0)
            g.candidates ~= MatchCandidate(prepared[i].recordId, 100, MatchConfidence.exact);
          g.candidates ~= MatchCandidate(prepared[j].recordId, s, confidenceOf(s));
          grouped[j] = true;
        }
      }
      if (g.candidates.length > 1) {
        grouped[i] = true;
        groups ~= g;
      }
    }
    return groups;
  }

  /// Upper bound of the fuzzy score from the value lengths alone: Jaro is
  /// at most (2 + short/long) / 3, plus the Winkler prefix bonus of at most
  /// 0.4 · (1 − Jaro). Pairs below the threshold are skipped unscored.
  protected static double upperBound(const ref Prepared a, const ref Prepared b) pure {
    double total = 0;
    size_t compared;
    foreach (i; 0 .. a.lengths.length) {
      auto x = a.lengths[i], y = b.lengths[i];
      if (x == 0 && y == 0)
        continue;
      compared++;
      if (x == 0 || y == 0)
        continue;
      double ratio = x < y ? cast(double) x / y : cast(double) y / x;
      double jaro = (2.0 + ratio) / 3.0;
      total += (jaro + 0.4 * (1.0 - jaro)) * 100.0;
    }
    return compared == 0 ? 0 : total / compared;
  }

  protected static double score(const ref Prepared a, const ref Prepared b, MatchStrategy strategy) {
    double total = 0;
    size_t compared;
    foreach (i; 0 .. a.normalized.length) {
      auto x = a.normalized[i], y = b.normalized[i];
      if (x.length == 0 && y.length == 0)
        continue;
      compared++;
      final switch (strategy) {
      case MatchStrategy.exact:
        total += x == y ? 100 : 0;
        break;
      case MatchStrategy.phonetic:
        total += a.phonetic[i] == b.phonetic[i] && a.phonetic[i].length ? 100 : 0;
        break;
      case MatchStrategy.fuzzy:
        total += jaroWinkler(x, y) * 100;
        break;
      case MatchStrategy.composite:
        total += jaroWinkler(x, y) * 60 + (a.phonetic[i] == b.phonetic[i] && a.phonetic[i].length ? 40 : 0);
        break;
      }
    }
    return compared == 0 ? 0 : roundScore(total / compared);
  }
}

///
unittest {
  auto d = new DuplicateDetector;
  auto records = [
    MatchInput(RecordId("1"), [FieldValue("name", "Jürgen Müller"), FieldValue("city", "Berlin")]),
    MatchInput(RecordId("2"), [FieldValue("name", "Juergen Mueller"), FieldValue("city", "Berlin")]),
    MatchInput(RecordId("3"), [FieldValue("name", "Anna Schmidt"), FieldValue("city", "Hamburg")]),
    MatchInput(RecordId("4"), [FieldValue("name", "jurgen muller"), FieldValue("city", "berlin")]),
    MatchInput(RecordId("5"), [FieldValue("name", ""), FieldValue("city", "")]),
    MatchInput(RecordId("6"), [FieldValue("name", ""), FieldValue("city", "")])
  ];
  auto exact = d.detect(records, ["name", "city"], MatchStrategy.exact, 100);
  assert(exact.length == 1 && exact[0].candidates.length == 2); // 1 and 4; empties never match
  assert(exact[0].candidates[1].recordId == RecordId("4"));

  auto fuzzy = d.detect(records, ["name", "city"], MatchStrategy.fuzzy, 85);
  assert(fuzzy.length == 1 && fuzzy[0].candidates.length == 3, fuzzy.length.to!string);
  assert(fuzzy[0].candidates[1].confidence != MatchConfidence.exact || fuzzy[0].candidates[1].score == 100);

  auto phonetic = d.detect(records, ["name"], MatchStrategy.phonetic, 100);
  assert(phonetic.length == 1 && phonetic[0].candidates.length == 3);

  assert(d.similarity([FieldValue("n", "Meyer")], [FieldValue("n", "Maier")], ["n"], MatchStrategy.composite) >= 80);
  assert(d.detect(records, [], MatchStrategy.fuzzy, 80).length == 0);
}
