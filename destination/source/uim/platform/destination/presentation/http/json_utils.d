/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.destination.presentation.http.json_utils;

// import vibe.data.json;
// import vibe.http.server;

/// Extract a string field from a Json object.
string jsonStr(Json j, string key) {
  if (!j.isObject)
    return "";
  auto v = key in j;
  if (v is null)
    return "";
  if ((*v).isString)
    return (*v).get!string;
  return "";
}

/// Extract a boolean field from a Json object.
bool jsonBool(Json j, string key, bool default_ = false) {
  if (!j.isObject)
    return default_;
  auto v = key in j;
  if (v is null)
    return default_;
  if ((*v).isBoolean)
    return (*v).get!bool;
  return default_;
}

/// Extract a double field from a Json object.


/// Extract an integer field from a Json object.


/// Extract an int field from a Json object.
int jsonInt(Json j, string key, int default_ = 0) {
  return cast(int) jsonLong(j, key, default_);
}

/// Extract a string array from a Json object.
string[] jsonStrArray(Json j, string key) {
  if (!j.isObject)
    return [];
  auto v = key in j;
  if (v is null || (*v).type != Json.Type.array)
    return [];

  string[] result;
  foreach (item; *v)
  {
    if (item.isString)
      result ~= item.get!string;
  }
  return result;
}

/// Extract a string[string] map from a Json object.
string[string] jsonStrMap(Json j, string key) {
  if (!j.isObject)
    return (string[string]).init;
  auto v = key in j;
  if (v is null || (*v).type != Json.Type.object)
    return (string[string]).init;

  string[string] result;
  foreach (string k, val; *v)
  {
    if (val.isString)
      result[k] = val.get!string;
  }
  return result;
}

/// Convert a string array to a Json array.
Json toJsonArray(const(string[]) arr) {
  auto jarr = Json.emptyArray;
  foreach (s; arr)
    jarr ~= Json(s);
  return jarr;
}

/// Convert a string[string] map to a Json object.
Json toJsonObject(const(string[string]) map) {
  auto jobj = Json.emptyObject;
  foreach (k, v; map)
    jobj[k] = Json(v);
  return jobj;
}

/// Write a JSON error response.
void writeError(scope HTTPServerResponse res, int statusCode, string message) {
  auto j = Json.emptyObject;
  j["error"] = Json(message);
  res.writeJsonBody(j, cast(ushort) statusCode);
}

/// Extract ID from the last segment of a request URI path.
string extractIdFromPath(string uri) {
  // import std.string : lastIndexOf;
  auto qpos = lastIndexOf(uri, '?');
  auto path = qpos >= 0 ? uri[0 .. qpos] : uri;
  auto pos = lastIndexOf(path, '/');
  if (pos >= 0 && pos + 1 < path.length)
    return path[pos + 1 .. $];
  return "";
}
