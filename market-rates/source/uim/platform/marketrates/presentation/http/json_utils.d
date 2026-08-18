/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.marketrates.presentation.http.json_utils;
import uim.platform.marketrates;

mixin(ShowModule!());

@safe:

bool jsonBool(Json j, string key, bool def = false) {
  if (j.type != Json.Type.object) return def;
  auto v = j[key];
  if (v.isBoolean) return v.get!bool;
  return def;
}

int jsonInt(Json j, string key, int def = 0) {
  if (j.type != Json.Type.object) return def;
  auto v = j[key];
  if (v.isInteger) return cast(int) v.get!long;
  return def;
}

double jsonDouble(Json j, string key, double def = 0.0) {
  if (j.type != Json.Type.object) return def;
  auto v = j[key];
  if (v.isFloat) return v.get!double;
  if (v.isInteger)   return cast(double) v.get!long;
  return def;
}

string[] jsonStrArray(Json j, string key) {
  string[] result;
  if (j.type != Json.Type.object) return result;
  auto v = j[key];
  if (v.type != Json.Type.array) return result;
  foreach (el; v.byValue)
    if (el.isString)
      result ~= el.get!string;
  return result;
}

