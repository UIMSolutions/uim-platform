/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Key/value labels (AI API "labels" and execution "tags"). In OData and the
/// CLI a label is written as "key=value".
module uim.platform.ai_core.domain.types.labels;

import uim.platform.ai_core;

mixin(ShowModule!());

@safe:

struct Label {
  string key;
  string value;

  string toText() const {
    return key ~ "=" ~ value;
  }
}

/// "k=v" → Label("k", "v"); "k" → Label("k", "").
Label parseLabel(string text) pure {
  auto t = text.strip;
  auto pos = t.indexOf('=');
  return pos < 0 ? Label(t, "") : Label(t[0 .. pos].strip, t[pos + 1 .. $].strip);
}

/// Parse "k=v" texts; later keys win, blanks are dropped.
Label[] parseLabels(const string[] texts) {
  Label[] result;
  foreach (text; texts) {
    if (text.strip.length == 0)
      continue;
    auto l = parseLabel(text);
    result = setLabel(result, l.key, l.value);
  }
  return result;
}

string[] labelTexts(const Label[] labels) {
  return labels.map!(l => l.toText).array;
}

/// Insert or replace a label.
Label[] setLabel(const Label[] labels, string key, string value) {
  Label[] result;
  bool replaced;
  foreach (l; labels) {
    if (l.key == key) {
      result ~= Label(key, value);
      replaced = true;
    } else
      result ~= Label(l.key, l.value);
  }
  if (!replaced)
    result ~= Label(key, value);
  return result;
}

/// Value of a label ("" if missing).
string labelValue(const Label[] labels, string key) {
  foreach (l; labels)
    if (l.key == key)
      return l.value;
  return "";
}

/// AI API label keys: 1-256 printable characters without '=' or spaces
/// (e.g. "ext.ai.sap.com/version"), values up to 5000 characters.
bool isValidLabel(const Label l) pure {
  if (l.key.length == 0 || l.key.length > 256 || l.value.length > 5000)
    return false;
  foreach (c; l.key)
    if (c <= ' ' || c == '=' || c > '~')
      return false;
  return true;
}

///
unittest {
  assert(parseLabel(" a = b ") == Label("a", "b"));
  assert(parseLabel("flag") == Label("flag", ""));
  assert(parseLabels(["a=1", "", "b=2", "a=3"]) == [Label("a", "3"), Label("b", "2")]);
  assert(labelTexts([Label("a", "1")]) == ["a=1"]);
  assert(labelValue([Label("a", "1")], "a") == "1" && labelValue(null, "x") == "");
  assert(isValidLabel(Label("ext.ai.sap.com/version", "1.0")));
  assert(!isValidLabel(Label("bad key", "x")) && !isValidLabel(Label("", "x")));
}
