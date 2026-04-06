/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.service.helpers.json_utils;

// import vibe.data.json;
// import vibe.http.server;

/// Extract a string field from a Json object.
string jsonStr(Json j, string key) {
  return j.getString(key, "");
}

/// Extract a boolean field from a Json object.
bool jsonBool(Json j, string key, bool default_ = false) {
  return j.getBoolean(key, default_);
}

/// Extract an integer field from a Json object.
long jsonLong(Json j, string key, long default_ = 0) {
  if (!j.isObject)
    return default_;

  auto v = key in j;
  if (v is null)
    return default_;

  if ((*v).isInteger)
    return (*v).get!long;

  return default_;
}

/// Extract an int field from a Json object.
int jsonInt(Json j, string key, int default_ = 0) {
  return cast(int)jsonLong(j, key, default_);
}

/// Extract a ushort field from a Json object.
ushort jsonUshort(Json j, string key, ushort default_ = 0) {
  return cast(ushort)jsonLong(j, key, default_);
}

double jsonDouble(Json j, string key) {
  if (j.type != Json.Type.object)
    return 0.0;

  auto v = key in j;
  if (v is null)
    return 0.0;

  if ((*v).type == Json.Type.float_)
    return (*v).get!double;

  if ((*v).type == Json.Type.int_)
    return cast(double)(*v).get!long;
  return 0.0;
}
/// Extract a string array from a Json object.
string[] jsonStrArray(Json j, string key) {
  if (!j.isObject)
    return null;

  auto v = key in j;
  if (v is null || !(*v).isArray)
    return null;

  string[] result;
  foreach (item; *v) {
    if (item.isString)
      result ~= item.get!string;
  }
  return result;
}

string[][] jsonPairArray(Json j, string key) {
  if (j.type != Json.Type.object)
    return [];
  auto v = key in j;
  if (v is null)
    return [];
  if (!(*v).isArray)
    return [];
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
        if (item.type == Json.Type.string)
          pair ~= item.get!string;
      }
      if (pair.length >= 2)
        result ~= pair;
    }
  }
  return result;
}

string[][] jsonMessageArray(Json j, string key) {
  if (j.type != Json.Type.object)
    return [];
  auto v = key in j;
  if (v is null)
    return [];
  if (!(*v).isArray)
    return [];
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
/// Extract the last path segment from a URI (for wildcard routes).
string extractIdFromPath(string uri) {
  // Strip query string
  // import std.string : indexOf;
  auto qpos = uri.indexOf('?');
  string path = qpos >= 0 ? uri[0 .. qpos] : uri;

  // Strip trailing slash
  if (path.length > 0 && path[$ - 1] == '/')
    path = path[0 .. $ - 1];

  // Find last slash
  auto spos = path.lastIndexOf('/');
  if (spos >= 0 && spos + 1 < path.length)
    return path[spos + 1 .. $];
  return path;
}

private long lastIndexOf(string s, char c) {
  for (long i = cast(long)s.length - 1; i >= 0; --i)
    if (s[cast(size_t)i] == c)
      return i;
  return -1;
}

/// Write a JSON error response.
void writeError(scope HTTPServerResponse res, int status, string message) {
  auto j = Json.emptyObject;
  j["error"] = Json(message);
  j["status"] = Json(status);
  res.writeJsonBody(j, status);
}

string extractIdFromPath2(string path) {
  import std.string : lastIndexOf;

  auto idx = path.lastIndexOf('/');
  if (idx >= 0 && idx + 1 < path.length)
    return path[idx + 1 .. $];
  return "";
}

Json toJsonArray(string[] arr) {
  auto jarr = Json.emptyArray;
  foreach (ref s; arr) {
    jarr ~= Json(s);
    return jarr;
  }
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
