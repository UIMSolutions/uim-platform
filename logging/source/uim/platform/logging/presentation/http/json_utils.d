/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.presentation.http.json_utils;

// import vibe.data.json;
// import vibe.http.server;

import uim.platform.logging;






int jsonInt(Json j, string key, int default_ = 0) {
  return cast(int) jsonLong(j, key, default_);
}

string[] jsonStrArray(Json j, string key) {
  if (!j.isObject)
    return [];
  auto v = key in j;
  if (v is null || (*v).type != Json.Type.array)
    return [];

  string[] result;
  foreach (item; *v) {
    if (item.isString)
      result ~= item.get!string;
  }
  return result;
}

Json toJsonArray(const(string[]) arr) {
  auto jarr = Json.emptyArray;
  foreach (s; arr)
    jarr ~= Json(s);
  return jarr;
}

string[string] jsonStrMap(Json j, string key) {
  if (!j.isObject)
    return null;
  auto v = key in j;
  if (v is null || (*v).type != Json.Type.object)
    return null;

  string[string] result;
  foreach (string k, val; *v) {
    if (val.isString)
      result[k] = val.get!string;
  }
  return result;
}

void writeError(scope HTTPServerResponse res, int statusCode, string message) {
  auto j = Json.emptyObject;
  j["error"] = Json(message);
  res.writeJsonBody(j, cast(ushort) statusCode);
}

string extractIdFromPath(string uri) {
  auto qpos = uri.indexOf('?');
  string path = qpos >= 0 ? uri[0 .. qpos] : uri;

  if (path.length > 0 && path[$ - 1] == '/')
    path = path[0 .. $ - 1];

  auto spos = lastIndexOf(path, '/');
  if (spos >= 0 && spos + 1 < path.length)
    return path[spos + 1 .. $];
  return path;
}
