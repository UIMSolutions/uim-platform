/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Matching of the extracted header values with enrichment records: the
/// score of a record is the share of its attributes whose value equals the
/// extracted value of the field with the attribute's key (case and blank
/// insensitive). The best record wins; ties make the match ambiguous.
module uim.platform.document_ai.domain.services.enrichment_matcher;

import uim.platform.document_ai;

mixin(ShowModule!());

@safe:

enum double matchThreshold = 0.8;
enum double ambiguousThreshold = 0.4;

struct EnrichmentMatch {
  EnrichmentDataId matchedId;
  MatchStatus status = MatchStatus.unmatched;
  double score = 0;
  string[] matchedKeys;
}

EnrichmentMatch matchEnrichment(const ExtractedField[] fields, const EnrichmentData[] candidates) {
  import std.uni : icmp;

  string[string] values; // header field name (lower) → normalized value
  foreach (f; fields)
    if (f.rowIndex == 0 && f.value.strip.length)
      values[f.name.toLower] = normalized(f.value);

  EnrichmentMatch best;
  bool tie;
  foreach (c; candidates) {
    if (c.attributes.length == 0)
      continue;
    long hits;
    string[] keys;
    foreach (a; c.attributes) {
      auto eq = a.indexOf('=');
      if (eq <= 0)
        continue;
      auto key = a[0 .. eq].strip.toLower;
      if (auto v = key in values)
        if (*v == normalized(a[eq + 1 .. $])) {
          hits++;
          keys ~= a[0 .. eq].strip;
        }
    }
    auto score = cast(double) hits / c.attributes.length;
    if (score > best.score) {
      best = EnrichmentMatch(c.id, MatchStatus.unmatched, score, keys);
      tie = false;
    } else if (score > 0 && score == best.score)
      tie = true;
  }
  if (best.score >= matchThreshold)
    best.status = tie ? MatchStatus.ambiguous : MatchStatus.matched;
  else if (best.score >= ambiguousThreshold)
    best.status = MatchStatus.ambiguous;
  else
    best = EnrichmentMatch(EnrichmentDataId.init, MatchStatus.unmatched, best.score, null);
  return best;
}

/// "  ACME   Corp " → "acme corp"
private string normalized(string value) {
  return value.strip.toLower.split.join(" ");
}

///
unittest {
  ExtractedField name, city, item;
  name.name = "senderName";
  name.value = "ACME  Corp";
  city.name = "senderCity";
  city.value = "Berlin";
  item.name = "senderName";
  item.value = "ignored";
  item.rowIndex = 1;
  EnrichmentData acme, other;
  acme.id = EnrichmentDataId("acme");
  acme.attributes = ["senderName=acme corp", "senderCity=Berlin"];
  other.id = EnrichmentDataId("other");
  other.attributes = ["senderName=Other", "senderCity=Berlin"];
  auto m = matchEnrichment([name, city, item], [other, acme]);
  assert(m.status == MatchStatus.matched && m.matchedId.value == "acme" && m.score == 1.0, m.to!string);
  acme.attributes = ["senderName=acme corp", "senderCity=Paris"];
  auto half = matchEnrichment([name, city], [acme]);
  assert(half.status == MatchStatus.ambiguous && half.score == 0.5);
  assert(matchEnrichment([name], []).status == MatchStatus.unmatched);
}
