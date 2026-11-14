/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Value helpers for key/value properties (labels, custom properties, parameters).
module uim.platform.management.domain.types.properties;

import uim.platform.management;

mixin(ShowModule!());

@safe:

/// string[string] → JSON object.
Json propertiesToJson(const string[string] properties) {
  auto j = Json.emptyObject;
  foreach (key, value; properties)
    j[key] = value;
  return j;
}

/// string[] → JSON array.
Json listToJson(const string[] values) {
  auto j = Json.emptyArray;
  foreach (v; values)
    j ~= Json(v);
  return j;
}

/// JSON object → string[string] (non-string values are stringified, other types ignored).
string[string] propertiesFromJson(Json value) {
  string[string] result;
  if (value.type != Json.Type.object)
    return result;
  foreach (key, v; value.get!(Json[string]))
    result[key] = v.type == Json.Type.string ? v.get!string : v.toString;
  return result;
}

/// JSON array → string[] (only string items).
string[] listFromJson(Json value) {
  string[] result;
  if (value.type != Json.Type.array)
    return result;
  foreach (v; value.get!(Json[]))
    if (v.type == Json.Type.string)
      result ~= v.get!string;
  return result;
}

///
unittest {
  mixin(ShowTest!("properties"));

  auto j = propertiesToJson(["a": "1"]);
  assert(propertiesFromJson(j) == ["a": "1"]);
  assert(listFromJson(listToJson(["x", "y"])) == ["x", "y"]);
  assert(propertiesFromJson(Json(3)).length == 0);
}
