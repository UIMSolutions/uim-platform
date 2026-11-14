/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Defensive accessors for JSON objects: missing or mistyped fields fall back
/// to defaults, scalar values are coerced leniently (CLI options are strings).
module uim.platform.portal.helpers.json;

import std.conv : to;
import std.string : toLower, strip, split;
import std.algorithm : map, filter;
import std.array : array;
import vibe.data.json : Json;

@safe:

/// A scalar JSON value as text ("" for null/undefined/objects).
string jsonText(Json v) {
  switch (v.type) {
  case Json.Type.string:
    return v.get!string;
  case Json.Type.int_:
    return v.get!long.to!string;
  case Json.Type.bigInt:
    return v.toString;
  case Json.Type.float_:
    return v.get!double.to!string;
  case Json.Type.bool_:
    return v.get!bool ? "true" : "false";
  default:
    return "";
  }
}

/// Lenient bool: true/false, "true"/"yes"/"on"/"1".
bool jsonBool(Json v, bool fallback = false) {
  if (v.type == Json.Type.bool_)
    return v.get!bool;
  if (v.type == Json.Type.int_)
    return v.get!long != 0;
  if (v.type == Json.Type.string) {
    auto s = v.get!string.strip.toLower;
    if (s == "true" || s == "yes" || s == "on" || s == "1")
      return true;
    if (s == "false" || s == "no" || s == "off" || s == "0")
      return false;
  }
  return fallback;
}

/// Lenient integer: numbers or numeric strings. Invalid strings throw.
long jsonLong(Json v, long fallback = 0) {
  switch (v.type) {
  case Json.Type.int_:
    return v.get!long;
  case Json.Type.float_:
    return cast(long) v.get!double;
  case Json.Type.string:
    auto s = v.get!string.strip;
    return s.length == 0 ? fallback : s.to!long;
  default:
    return fallback;
  }
}

/// A list of strings from a JSON array or a comma separated string.
string[] jsonStrings(Json v) {
  if (v.type == Json.Type.array) {
    string[] result;
    foreach (item; v.get!(Json[])) {
      auto s = jsonText(item);
      if (s.length > 0)
        result ~= s;
    }
    return result;
  }
  if (v.type == Json.Type.string)
    return v.get!string.split(",").map!(s => s.strip).filter!(s => s.length > 0).array;
  return null;
}

/// Field of an object (Json.undefined if missing or not an object).
Json member(Json obj, string key) {
  if (obj.type != Json.Type.object)
    return Json.undefined;
  if (auto v = key in obj)
    return *v;
  return Json.undefined;
}

string fieldString(Json obj, string key, string fallback = "") {
  auto v = member(obj, key);
  auto s = jsonText(v);
  return v.type == Json.Type.undefined || v.type == Json.Type.null_ ? fallback : s;
}

long fieldLong(Json obj, string key, long fallback = 0) {
  return jsonLong(member(obj, key), fallback);
}

bool fieldBool(Json obj, string key, bool fallback = false) {
  return jsonBool(member(obj, key), fallback);
}

string[] fieldStrings(Json obj, string key) {
  return jsonStrings(member(obj, key));
}

/// Shallow merge: keys of `patch` overwrite keys of `base`.
Json mergeJson(Json base, Json patch) {
  auto result = Json.emptyObject;
  if (base.type == Json.Type.object)
    foreach (k, v; base.get!(Json[string]))
      result[k] = v;
  if (patch.type == Json.Type.object)
    foreach (k, v; patch.get!(Json[string]))
      result[k] = v;
  return result;
}

///
unittest {
  auto o = Json.emptyObject;
  o["a"] = "x";
  o["n"] = "42";
  o["b"] = "on";
  o["l"] = "a, b,,c";
  assert(fieldString(o, "a") == "x" && fieldString(o, "zz", "d") == "d");
  assert(fieldLong(o, "n") == 42);
  assert(fieldBool(o, "b"));
  assert(fieldStrings(o, "l") == ["a", "b", "c"]);
  auto p = Json.emptyObject;
  p["a"] = "y";
  assert(mergeJson(o, p)["a"].get!string == "y");
}
