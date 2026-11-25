/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// "key=value" pairs (document labels, enrichment attributes). Stored and
/// exchanged as strings so that every adapter (OData collections, CLI
/// options, GUI entries) can edit them as plain text.
module uim.platform.document_ai.domain.types.pairs;

import uim.platform.document_ai;

mixin(ShowModule!());

@safe:

struct KeyValue {
  string key;
  string value;
}

/// "vendor = ACME" → KeyValue("vendor", "ACME"); throws invalid without "=".
KeyValue parsePair(string text, string what = "Entry") {
  auto t = text.strip;
  auto eq = t.indexOf('=');
  if (eq <= 0)
    throw DaiException.invalid(what ~ " '" ~ text ~ "' must have the form key=value");
  auto k = t[0 .. eq].strip;
  requireMaxLength(k, 100, what ~ " key");
  return KeyValue(k, t[eq + 1 .. $].strip);
}

/// Validate and normalize ("a = 1" → "a=1"); keys must be unique (case insensitive).
string[] normalizePairs(const string[] entries, string what = "Entry") {
  import std.uni : icmp;

  string[] result;
  KeyValue[] seen;
  foreach (e; entries) {
    if (e.strip.length == 0)
      continue;
    auto kv = parsePair(e, what);
    foreach (s; seen)
      if (icmp(s.key, kv.key) == 0)
        throw DaiException.invalid(what ~ " key '" ~ kv.key ~ "' is given twice");
    seen ~= kv;
    result ~= kv.key ~ "=" ~ kv.value;
  }
  return result;
}

/// The value of a key ("" if missing; keys case insensitive).
string pairValue(const string[] entries, string key) {
  import std.uni : icmp;

  foreach (e; entries) {
    auto eq = e.indexOf('=');
    if (eq > 0 && icmp(e[0 .. eq].strip, key) == 0)
      return e[eq + 1 .. $].strip;
  }
  return "";
}

///
unittest {
  assert(normalizePairs([" a = 1", "", "b=x=y"]) == ["a=1", "b=x=y"]);
  assert(pairValue(["A=1", "b=2"], "a") == "1" && pairValue(["a=1"], "c") == "");
  assert(failsWith(DaiErrorKind.invalid, () { normalizePairs(["novalue"]); }));
  assert(failsWith(DaiErrorKind.invalid, () { normalizePairs(["a=1", "A=2"]); }));
}
