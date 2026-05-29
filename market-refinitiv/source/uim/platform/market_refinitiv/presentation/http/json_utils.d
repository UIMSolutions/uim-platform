/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.market_refinitiv.presentation.http.json_utils;
import uim.platform.market_refinitiv;

mixin(ShowModule!());

@safe:

// Safe string extraction from JSON
string jsonStr(Json j, string key, string def = "") {
  if (j.type != Json.Type.object) return def;
  auto v = j[key];
  if (v.type == Json.Type.string) return v.get!string;
  return def;
}

bool jsonBool(Json j, string key, bool def = false) {
  if (j.type != Json.Type.object) return def;
  auto v = j[key];
  if (v.type == Json.Type.bool_) return v.get!bool;
  return def;
}

int jsonInt(Json j, string key, int def = 0) {
  if (j.type != Json.Type.object) return def;
  auto v = j[key];
  if (v.type == Json.Type.int_) return cast(int) v.get!long;
  return def;
}

double jsonDouble(Json j, string key, double def = 0.0) {
  if (j.type != Json.Type.object) return def;
  auto v = j[key];
  if (v.type == Json.Type.float_) return v.get!double;
  if (v.type == Json.Type.int_)   return cast(double) v.get!long;
  return def;
}

string[] jsonStrArray(Json j, string key) {
  string[] result;
  if (j.type != Json.Type.object) return result;
  auto v = j[key];
  if (v.type != Json.Type.array) return result;
  foreach (el; v.byValue)
    if (el.type == Json.Type.string)
      result ~= el.get!string;
  return result;
}

// Extract the last path segment (used as an ID)
string extractIdFromPath(HTTPServerRequest req) {
  import std.conv : to;
  auto p = req.requestPath.to!string;
  import std.algorithm : findSplitBefore;
  import std.string : lastIndexOf;
  auto idx = lastIndexOf(p, '/');
  if (idx < 0) return p;
  return p[idx + 1 .. $];
}

// Standard error response
void writeError(HTTPServerResponse res, int status, string message) {
  auto j = Json.emptyObject;
  j["error"]   = Json(message);
  j["status"]  = Json(status);
  res.writeJsonBody(j, cast(int) status);
}
