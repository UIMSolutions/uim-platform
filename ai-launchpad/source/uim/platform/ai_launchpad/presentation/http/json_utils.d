/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.presentation.http.json_utils;

import uim.platform.ai_launchpad;

string jsonStr(Json j, string key) {
  if (j.type != Json.Type.object) return "";
  auto v = key in j;
  if (v is null) return "";
  if ((*v).type == Json.Type.string) return (*v).get!string;
  return "";
}

bool jsonBool(Json j, string key) {
  if (j.type != Json.Type.object) return false;
  auto v = key in j;
  if (v is null) return false;
  if ((*v).type == Json.Type.bool_) return (*v).get!bool;
  return false;
}

int jsonInt(Json j, string key) {
  if (j.type != Json.Type.object) return 0;
  auto v = key in j;
  if (v is null) return 0;
  if ((*v).type == Json.Type.int_) return cast(int)(*v).get!long;
  return 0;
}

long jsonLong(Json j, string key) {
  if (j.type != Json.Type.object) return 0;
  auto v = key in j;
  if (v is null) return 0;
  if ((*v).type == Json.Type.int_) return (*v).get!long;
  return 0;
}

double jsonDouble(Json j, string key) {
  if (j.type != Json.Type.object) return 0.0;
  auto v = key in j;
  if (v is null) return 0.0;
  if ((*v).type == Json.Type.float_) return (*v).get!double;
  if ((*v).type == Json.Type.int_) return cast(double)(*v).get!long;
  return 0.0;
}

string[] jsonStrArray(Json j, string key) {
  if (j.type != Json.Type.object) return [];
  auto v = key in j;
  if (v is null) return [];
  if ((*v).type != Json.Type.array) return [];
  string[] result;
  foreach (ref elem; *v) {
    if (elem.type == Json.Type.string) result ~= elem.get!string;
  }
  return result;
}

string[][] jsonPairArray(Json j, string key) {
  if (j.type != Json.Type.object) return [];
  auto v = key in j;
  if (v is null) return [];
  if ((*v).type != Json.Type.array) return [];
  string[][] result;
  foreach (ref elem; *v) {
    if (elem.type == Json.Type.object) {
      auto k = "key" in elem;
      auto val = "value" in elem;
      if (k !is null && val !is null) {
        result ~= [(*k).get!string, (*val).get!string];
      }
    } else if (elem.type == Json.Type.array) {
      string[] pair;
      foreach (ref item; elem) {
        if (item.type == Json.Type.string) pair ~= item.get!string;
      }
      if (pair.length >= 2) result ~= pair;
    }
  }
  return result;
}

string[][] jsonMessageArray(Json j, string key) {
  if (j.type != Json.Type.object) return [];
  auto v = key in j;
  if (v is null) return [];
  if ((*v).type != Json.Type.array) return [];
  string[][] result;
  foreach (ref elem; *v) {
    if (elem.type == Json.Type.object) {
      auto role = "role" in elem;
      auto content = "content" in elem;
      if (role !is null && content !is null) {
        result ~= [(*role).get!string, (*content).get!string];
      }
    }
  }
  return result;
}

Json toJsonArray(string[] arr) {
  auto jarr = Json.emptyArray;
  foreach (ref s; arr) {
    jarr ~= Json(s);
  }
  return jarr;
}

void writeError(scope HTTPServerResponse res, int status, string message) {
  auto j = Json.emptyObject;
  j["error"] = Json(message);
  res.writeJsonBody(j, status);
}

string extractIdFromPath(string path) {
  import std.string : lastIndexOf;
  auto idx = path.lastIndexOf('/');
  if (idx >= 0 && idx + 1 < path.length)
    return path[idx + 1 .. $];
  return "";
}
