/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.presentation.http.json_utils;

import uim.platform.document_ai;

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
    return [];
  auto v = key in j;
  if (v is null)
    return [];
  if ((*v).type != Json.Type.array)
    return [];
  string[] result;
  foreach (item; *v) {
    if (item.isString)
      result ~= item.get!string;
  }
  return result;
}

string[][] jsonKeyValuePairs(Json j, string key) {
  if (!j.isObject)
    return [];
  auto v = key in j;
  if (v is null)
    return [];
  if ((*v).type != Json.Type.array)
    return [];
  string[][] result;
  foreach (item; *v) {
    if (item.isObject) {
      auto k = item.getString("key");
      auto val = item.getString("value");
      if (k.length > 0)
        result ~= [k, val];
    }
  }
  return result;
}

string[][] jsonFieldArray(Json j, string key) {
  if (!j.isObject)
    return [];
  auto v = key in j;
  if (v is null)
    return [];
  if ((*v).type != Json.Type.array)
    return [];
  string[][] result;
  foreach (item; *v) {
    if (item.isObject) {
      auto name = item.getString("name");
      auto label = item.getString("label");
      auto type = item.getString("type");
      auto req = getBoolean(item, "required") ? "true" : "false";
      if (name.length > 0)
        result ~= [name, label, type, req];
    }
  }
  return result;
}

string[][] jsonRegionArray(Json j, string key) {
  import std.conv : to;

  if (!j.isObject)
    return [];
  auto v = key in j;
  if (v is null)
    return [];
  if ((*v).type != Json.Type.array)
    return [];
  string[][] result;
  foreach (item; *v) {
    if (item.isObject) {
      auto fieldName = item.getString("fieldName");
      auto page = jsonInt(item, "page").to!string;
      auto x = jsonDouble(item, "x").to!string;
      auto y = jsonDouble(item, "y").to!string;
      auto width = jsonDouble(item, "width").to!string;
      auto height = jsonDouble(item, "height").to!string;
      if (fieldName.length > 0)
        result ~= [fieldName, page, x, y, width, height];
    }
  }
  return result;
}

Json toJsonArray(string[] arr) {
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
