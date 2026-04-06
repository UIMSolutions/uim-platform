/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.presentation.http.json_utils;

// import vibe.data.json;
// import vibe.http.server;

import uim.platform.auditlog;


/// Extract a string array from a Json object.
string[] jsonStrArray(Json j, string key) {
  if (!j.isObject)
    return null;
  auto v = key in j;
  if (v is null || (*v).type != Json.Type.array)
    return null;

  string[] result;
  foreach (item; *v)
  {
    if (item.isString)
      result ~= item.get!string;
  }
  return result;
}

/// Extract the last path segment from a URI (for wildcard routes).
string extractIdFromPath(string uri) {
  // import std.string : indexOf;

  auto qpos = uri.indexOf('?');
  string path = qpos >= 0 ? uri[0 .. qpos] : uri;

  if (path.length > 0 && path[$ - 1] == '/')
    path = path[0 .. $ - 1];

  auto spos = path.lastIndexOf('/');
  if (spos >= 0 && spos + 1 < path.length)
    return path[spos + 1 .. $];
  return path;
}



/// Write a JSON error response.
void writeError(scope HTTPServerResponse res, int status, string message) {
  auto j = Json.emptyObject;
  j["error"] = Json(message);
  j["status"] = Json(status);
  res.writeJsonBody(j, status);
}
