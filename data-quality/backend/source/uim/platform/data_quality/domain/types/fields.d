/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// The field values of a data record. Fields keep their insertion order
/// (stable output in OData, CLI and the Fiori app); names are unique.
/// Text form: "name=value" (the value may contain '=').
module uim.platform.data_quality.domain.types.fields;

import uim.platform.data_quality;

mixin(ShowModule!());

@safe:

struct FieldValue {
  string name;
  string value;
}

/// Value of a field ("" if missing).
string fieldOf(const FieldValue[] fields, string name) pure {
  foreach (f; fields)
    if (f.name == name)
      return f.value;
  return "";
}

/// True if the field exists (possibly with an empty value).
bool hasField(const FieldValue[] fields, string name) pure {
  foreach (f; fields)
    if (f.name == name)
      return true;
  return false;
}

/// Set (replace or append) a field.
FieldValue[] withField(const FieldValue[] fields, string name, string value) pure {
  FieldValue[] result;
  bool replaced;
  foreach (f; fields) {
    if (f.name == name) {
      result ~= FieldValue(name, value);
      replaced = true;
    } else
      result ~= FieldValue(f.name, f.value);
  }
  if (!replaced)
    result ~= FieldValue(name, value);
  return result;
}

/// Remove a field.
FieldValue[] withoutField(const FieldValue[] fields, string name) pure {
  FieldValue[] result;
  foreach (f; fields)
    if (f.name != name)
      result ~= FieldValue(f.name, f.value);
  return result;
}

/// "name=value" → FieldValue; throws invalid.
FieldValue parseFieldText(string text) {
  auto t = text.strip;
  auto pos = t.indexOf('=');
  auto name = (pos < 0 ? t : t[0 .. pos]).strip;
  requireFieldName(name);
  return FieldValue(name, pos < 0 ? "" : t[pos + 1 .. $].strip);
}

string fieldText(const FieldValue f) pure {
  return f.name ~ "=" ~ f.value;
}

string[] fieldTexts(const FieldValue[] fields) pure {
  string[] result;
  foreach (f; fields)
    result ~= fieldText(f);
  return result;
}

/// Validated, de-duplicated (last wins) field list.
FieldValue[] checkedFields(const FieldValue[] fields) {
  FieldValue[] result;
  foreach (f; fields) {
    requireFieldName(f.name);
    if (f.value.length > 10_000)
      throw DataQualityException.invalid("Value of field '" ~ f.name ~ "' exceeds 10000 characters");
    result = withField(result, f.name, f.value);
  }
  return result;
}

/// A field map → fields in name order (deterministic).
FieldValue[] fieldsFromMap(const string[string] map) @trusted {
  FieldValue[] result;
  foreach (name; map.keys.sort)
    result ~= FieldValue(name, map[name]);
  return result;
}

///
unittest {
  auto f = [FieldValue("a", "1")];
  f = withField(f, "b", "2");
  f = withField(f, "a", "3");
  assert(fieldOf(f, "a") == "3" && fieldOf(f, "b") == "2" && fieldOf(f, "c") == "");
  assert(fieldTexts(f) == ["a=3", "b=2"] && withoutField(f, "a").length == 1);
  assert(parseFieldText(" url = http://x?a=b ") == FieldValue("url", "http://x?a=b"));
  assert(failsWith(DqErrorKind.invalid, () { parseFieldText("1x=2"); }));
  assert(checkedFields([FieldValue("a", "1"), FieldValue("a", "2")]) == [FieldValue("a", "2")]);
  assert(fieldsFromMap(["z": "1", "a": "2"])[0].name == "a");
}
