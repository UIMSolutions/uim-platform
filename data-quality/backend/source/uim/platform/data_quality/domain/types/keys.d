/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Identifier rules, composite keys and dataset patterns.
///
/// Everything that lives inside a dataset (records, violations, match
/// groups, column profiles, snapshots, cleansing jobs) is addressed by the
/// composite key "<datasetId>~<id>". Ids therefore never contain '~' or ':'
/// (':' separates record and rule in violation ids).
module uim.platform.data_quality.domain.types.keys;

import uim.platform.data_quality;

mixin(ShowModule!());

@safe:

enum char keySeparator = '~';
enum size_t maxIdLength = 64;

/// Composite key of a dataset scoped resource.
string resourceKey(string datasetId, string id) pure {
  return datasetId ~ keySeparator ~ id;
}

/// Split a composite key; false if the key is malformed.
bool splitResourceKey(string key, out string datasetId, out string id) pure {
  auto pos = key.indexOf(keySeparator);
  if (pos <= 0 || pos + 1 >= key.length)
    return false;
  datasetId = key[0 .. pos];
  id = key[pos + 1 .. $];
  return true;
}

/// [A-Za-z0-9] followed by up to 63 of [A-Za-z0-9._-].
bool isValidId(string id) pure {
  if (id.length == 0 || id.length > maxIdLength)
    return false;
  foreach (i, c; id) {
    auto alnum = (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9');
    if (i == 0 && !alnum)
      return false;
    if (!alnum && c != '.' && c != '_' && c != '-')
      return false;
  }
  return true;
}

void requireId(string id, string what) {
  if (!isValidId(id))
    throw DataQualityException.invalid(what ~ " '" ~ id ~ "' is invalid (1-64 characters: letters, digits, '.', '_', '-'; "
        ~ "starting with a letter or digit)");
}

/// Field names: a letter or '_' followed by up to 63 of [A-Za-z0-9._-].
bool isValidFieldName(string name) pure {
  if (name.length == 0 || name.length > maxIdLength)
    return false;
  auto c0 = name[0];
  if (!((c0 >= 'a' && c0 <= 'z') || (c0 >= 'A' && c0 <= 'Z') || c0 == '_'))
    return false;
  return isValidId("x" ~ name[1 .. $]);
}

void requireFieldName(string name, string what = "Field name") {
  if (!isValidFieldName(name))
    throw DataQualityException.invalid(what ~ " '" ~ name ~ "' is invalid (a letter or '_' followed by letters, digits, '.', '_', '-')");
}

/// Glob match of a dataset pattern: '*' any sequence, '?' one character;
/// an empty pattern matches every dataset. Case insensitive.
bool datasetMatches(string pattern, string datasetId) pure {
  import std.uni : toLower;

  auto p = pattern.strip;
  if (p.length == 0 || p == "*")
    return true;
  return globMatch(p.toLower, datasetId.toLower);
}

private bool globMatch(string p, string s) pure {
  size_t pi, si, star = size_t.max, mark;
  while (si < s.length) {
    if (pi < p.length && (p[pi] == '?' || p[pi] == s[si])) {
      pi++;
      si++;
    } else if (pi < p.length && p[pi] == '*') {
      star = pi++;
      mark = si;
    } else if (star != size_t.max) {
      pi = star + 1;
      si = ++mark;
    } else
      return false;
  }
  while (pi < p.length && p[pi] == '*')
    pi++;
  return pi == p.length;
}

///
unittest {
  string d, i;
  assert(splitResourceKey(resourceKey("customers", "c1"), d, i) && d == "customers" && i == "c1");
  assert(!splitResourceKey("nokey", d, i) && !splitResourceKey("~x", d, i) && !splitResourceKey("x~", d, i));
  assert(isValidId("c-1.a_b") && !isValidId("-a") && !isValidId("a~b") && !isValidId("a:b") && !isValidId(""));
  assert(isValidFieldName("email") && isValidFieldName("_x.y") && !isValidFieldName("1a") && !isValidFieldName("a b"));
  assert(datasetMatches("", "x") && datasetMatches("cust*", "Customers") && datasetMatches("c?st", "cust"));
  assert(!datasetMatches("cust*", "suppliers") && datasetMatches("*ers", "suppliers"));
}
