/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana.presentation.http.json_utils;

import uim.platform.hana;

mixin(ShowModule!());

@safe:

string getString(Json j, string key) {
  if (!j.isObject)
    return "";
  auto v = key in j;
  if (v is null)
    return "";
  if ((*v).isString)
    return (*v).get!string;
  return "";
}

bool getBoolean(Json j, string key, bool default_ = false) {
  if (!j.isObject)
    return default_;
  auto v = key in j;
  if (v is null)
    return default_;
  if ((*v).isBoolean)
    return (*v).get!bool;
  return default_;
}

int jsonInt(Json j, string key, int default_ = 0) {
  if (!j.isObject)
    return default_;
  auto v = key in j;
  if (v is null)
    return default_;
  if ((*v).isInteger)
    return cast(int)(*v).get!long;
  return default_;
}



double jsonDouble(Json j, string key, double default_ = 0.0) {
  if (!j.isObject)
    return default_;
  auto v = key in j;
  if (v is null)
    return default_;
  if ((*v).isFloat)
    return (*v).get!double;
  if ((*v).isInteger)
    return cast(double)(*v).get!long;
  return default_;
}

string[] jsonStrArray(Json j, string key) {
  if (!j.isObject)
    return null;

  if (!j.hasKey(key))
    return null;

  auto v = j[key];
  if (!v.isArray)
    return null;

  string[] result;
  foreach (item; v.toArray) {
    if (item.isString)
      result ~= item.get!string;
  }
  return result;
}

string[][] jsonKeyValuePairs(Json j, string key) {
  if (!j.isObject)
    return null;

  if (!j.hasKey(key))
    return null;
  
  auto v = j[key];
  if (!v.isArray)
    return null;
  
  string[][] result;
  foreach (item; v.toArray) {
    if (item.isObject) {
      auto k = item.getString("key");
      auto val = item.getString("value");
      if (k.length > 0)
        result ~= [k, val];
    }
  }
  return result;
}

Json stringsToJsonArray(string[] arr) {
  auto jarr = Json.emptyArray;
  foreach (s; arr)
    jarr ~= Json(s);
  return jarr;
}

string extractIdFromPath(string path) {
  import std.string : lastIndexOf;

  auto idx = lastIndexOf(path, '/');
  if (idx >= 0 && idx + 1 < path.length)
    return path[idx + 1 .. $];
  return "";
}
