/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.service.helpers.json_utils;

import uim.platform.service;

mixin(ShowModule!());

@safe:

/// Extract an integer field from a Json object.
long jsonLong(Json j, string key, long defaultValue = 0) {
  if (!j.isObject)
    return defaultValue;

  if (key !in j)
    return defaultValue;

  auto v = j[key];
  return v.isInteger ? v.get!long : defaultValue;
}

/// Extract an int field from a Json object.
int jsonInt(Json j, string key, int default_ = 0) {
  return cast(int)jsonLong(j, key, default_);
}

/// Extract a ushort field from a Json object.
ushort getUshort(Json j, string key, ushort default_ = 0) {
  return cast(ushort)jsonLong(j, key, default_);
}

double jsonDouble(Json j, string key) {
  if (!j.hasKey(key))
    return 0.0;

  auto v = j[key];
  if (v.isFloat)
    return v.get!double;

  if (v.isInteger)
    return cast(double)v.get!long;
  return 0.0;
}
/// Extract a string array from a Json object.
string[] getStringArray(Json json, string key) {
  if (!json.hasKey(key) || json[key] == Json(null))
    return null;

  auto v = json[key];
  if (!v.isArray)
    return null;

  auto arr = v.toArray;
  auto result = appender!(string[]);
  result.reserve(arr.length);

  foreach (item; arr) {
    if (item.isString)
      result ~= item.get!string;
  }
  return result[];
}

string[][] jsonKeyValuePairs(Json json, string key) {
  if (!json.hasKey(key))
    return null;

  auto v = json[key];
  if (v == Json(null) || !v.isArray)
    return null;

  auto arr = v.toArray;
  auto result = appender!(string[][]);
  result.reserve(arr.length);

  foreach (item; arr) {
    if (item.isObject) {
      if (!item.hasKey("key") || !item.hasKey("value"))
        continue;

      result ~= [item["key"].get!string, item["value"].get!string];
    } else if (item.isArray) {
      auto elems = item.toArray;
      auto pair = appender!(string[]);
      pair.reserve(elems.length);
      foreach (elem; elems) {
        if (elem.isString)
          pair ~= elem.get!string;
      }
      if (pair[].length >= 2)
        result ~= pair[];
    }
  }
  return result[];
}

/// Convert a string array to a Json array. Alias for toJsonArray.
Json stringsToJsonArray(string[] arr) {
  return toJsonArray(arr);
}

string[][] jsonPairArray(Json j, string key) {
  if (!j.isObject)
    return [];
  auto v = j[key];
  if (!v.isArray)
    return [];
  auto arr = v.toArray;
  auto result = appender!(string[][]);
  result.reserve(arr.length);
  foreach (elem; arr) {
    if (elem.isObject) {
      auto k = "key" in elem;
      auto val = "value" in elem;
      if (k !is null && val !is null) {
        result ~= [(*k).get!string, (*val).get!string];
      }
    } else if (elem.isArray) {
      auto items = elem.toArray;
      auto pair = appender!(string[]);
      pair.reserve(items.length);
      foreach (item; items) {
        if (item.isString)
          pair ~= item.get!string;
      }
      if (pair[].length >= 2)
        result ~= pair[];
    }
  }
  return result[];
}

string[][] jsonMessageArray(Json j, string key) {
  if (!j.isObject)
    return null;
  auto v = j[key];
  if (!v.isArray)
    return null;

  auto arr = v.toArray;
  auto result = appender!(string[][]);
  result.reserve(arr.length);
  foreach (elem; arr) {
    if (elem.isObject) {
      auto role = "role" in elem;
      auto content = "content" in elem;
      if (role !is null && content !is null) {
        result ~= [(*role).get!string, (*content).get!string];
      }
    }
  }
  return result[];
}
/// Extract the last path segment from a URI (for wildcard routes).
string extractIdFromPath(string uri) {
  import std.string : lastIndexOf, indexOf;

  // Strip query string
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

string extractIdFromPath(string uri, string resource) {
  // import std.string : split;
  auto parts = uri.split("/");
  foreach (i, part; parts)
    if (part == resource && i + 1 < parts.length) {
      auto c = parts[i + 1];
      if (c != "publish" && c.length > 0)
        return c;
    }
  return "";
}
/// Write a JSON error response.
void writeError(scope HTTPServerResponse res, int status, string message) {
  auto error = Json.emptyObject;
  error["error"] = Json(message);
  error["status"] = Json(status);
  // j["code"] = Json(code);
  res.writeJsonBody(error, status);
}

/* void writeError(scope HTTPServerResponse res, int status, string message) {
  auto j = Json.emptyObject;
  j["error"] = Json.emptyObject;
  j["error"]["message"] = Json(message);
  j["error"]["code"] = Json(status);
  res.writeJsonBody(j, status);
} */

/// Alias for extractIdFromPath (without query-string stripping).
string extractIdFromPath2(string path) {
  return extractIdFromPath(path);
}
///
unittest {
  assert(extractIdFromPath("/v1/tenants/abc123") == "abc123");
  assert(extractIdFromPath("/v1/tenants/abc123/") == "abc123");
  assert(extractIdFromPath("/v1/tenants/abc123?foo=bar") == "abc123");
  assert(extractIdFromPath("single") == "single");

  assert(getString(parseJsonString(`{"name": "test"}`), "name") == "test");
  assert(getString(parseJsonString(`{"name": "test"}`), "missing") == "");

  assert(getStringArray(parseJsonString(`{"tags": ["a", "b"]}`), "tags") == [
      "a", "b"
    ]);
  assert(getStringArray(parseJsonString(`{}`), "tags") is null);
}

Json toJsonArray(string[] arr) {
  return arr.map!(s => Json(s)).array.Json;
}

string[string] jsonStrMap(Json j, string key) {
  if (!j.isObject)
    return null;

  auto v = j[key];
  if (!v.isObject)
    return null;

  string[string] result;
  foreach (string k, val; v.toMap) {
    if (val.isString)
      result[k] = val.get!string;
  }
  return result;
}

string extractId(string uri) {
  // import std.string : lastIndexOf;
  auto idx = uri.lastIndexOf('/');
  if (idx >= 0 && idx + 1 < uri.length)
    return uri[idx + 1 .. $];
  return "";
}

/*
private string extractId(scope HTTPServerRequest req) {
  // import std.conv : to;
  // import std.string : split;
  auto path = req.requestURI;
  auto parts = path.split("/");
  // /api/v1/dashboards/{id}...
  foreach (i, part; parts) {
    if (part == "dashboards" && i + 1 < parts.length) {
      auto candidate = parts[i + 1];
      // Skip sub-resource keywords
      if (candidate != "publish" && candidate != "pages" && candidate.length > 0)
        return candidate;
    }
  }
  return "";
}
*/

/// Convert a string array to a Json array.
Json toJsonArray(const(string[]) arr) {
  auto j = Json.emptyArray;
  foreach (s; arr)
    j ~= Json(s);
  return j;
}

/// Extract a query parameter from the URI.
string queryParam(scope HTTPServerRequest req, string key) {
  auto val = req.headers.get("X-Query-" ~ key, "");
  if (val.length > 0)
    return val;

  // Parse from query string
  auto uri = req.requestURI;
  // import std.string : indexOf;
  auto qpos = uri.indexOf('?');
  if (qpos < 0)
    return "";

  auto qs = uri[qpos + 1 .. $];
  foreach (pair; splitBy(qs, '&')) {
    auto epos = pair.indexOf('=');
    if (epos > 0 && pair[0 .. epos] == key)
      return pair[epos + 1 .. $];
  }
  return "";
}

private long lastIndexOfChar(string s, char c) {
  for (long i = s.length - 1; i >= 0; i--)
    if (s[cast(size_t)i] == c)
      return i;
  return -1;
}

private string[] splitBy(string s, char delim) {
  string[] result;
  size_t start = 0;
  foreach (i, ch; s) {
    if (ch == delim) {
      result ~= s[start .. i];
      start = i + 1;
    }
  }
  if (start <= s.length)
    result ~= s[start .. $];
  return result;
}

/// Serialize a struct to JSON.
Json toJsonValue(T)(T val) {
  auto j = Json.emptyObject;
  static foreach (i, field; T.tupleof) {
    {
      enum name = __traits(identifier, T.tupleof[i]);
      alias FT = typeof(field);
      static if (is(FT == string))
        j[name] = Json(val.tupleof[i]);
      else static if (is(FT == bool))
        j[name] = Json(val.tupleof[i]);
      else static if (is(FT == long) || is(FT == int) || is(FT == uint) || is(FT == ulong))
        j[name] = Json(val.tupleof[i]);
      else static if (is(FT == string[])) {
        auto arr = Json.emptyArray;
        foreach (s; val.tupleof[i])
          arr ~= Json(s);
        j[name] = arr;
      } else static if (is(FT == enum)) {
        // import std.conv : to;
        j[name] = Json(val.tupleof[i].to!string);
      } else static if (is(FT == string[string])) {
        auto obj = Json.emptyObject;
        foreach (k, v; val.tupleof[i])
          obj[k] = Json(v);
        j[name] = obj;
      } else static if (isArray!FT && !is(FT == string)) {
        auto arr = Json.emptyArray;
        foreach (item; val.tupleof[i])
          arr ~= toJsonValue(item);
        j[name] = arr;
      }
    }
  }
  return j;
}

/// Serialize an array of structs.
Json toJsonArray(T)(T[] items) {
  auto arr = Json.emptyArray;
  foreach (item; items)
    arr ~= toJsonValue(item);
  return arr;
}

/// Read a uint field from JSON.
uint jsonUint(Json j, string key, uint default_ = 0) {
  return cast(uint)jsonLong(j, key, default_);
}

/// Read an int field from JSON.

/// Read a string array from JSON.
string[] getStringArray(Json j, string key, string[] defaultArray = null) {
  if (!j.isObject)
    return defaultArray;

  if (key !in j)
    return defaultArray;

  auto val = j[key];
  if (!val.isArray)
    return defaultArray;

  return val.toArray
    .filter!(item => item.isString)
    .map!(item => item.get!string)
    .array;
}

/// Parse an enum from a JSON string field.
T jsonEnum(T)(Json j, string key, T default_ = T.init) {
  auto str = j.getString(key);
  if (str.length == 0)
    return default_;
  // import std.conv : to;
  try
    return str.to!T;
  catch (Exception)
    return default_;
}

/// Write a standard JSON error response.
void writeApiError(scope HTTPServerResponse res, int status, string detail) {
  auto response = Json.emptyObject;
  response["error"] = Json(detail);
  response["status"] = Json(status);
  res.writeJsonBody(response, status);
}

/// Serialize a struct to JSON.
Json toJsonValue(T)(T val) {
  auto j = Json.emptyObject;
  static foreach (i, field; T.tupleof) {
    {
      enum name = __traits(identifier, T.tupleof[i]);
      alias FT = typeof(field);
      static if (is(FT == string))
        j[name] = Json(val.tupleof[i]);
      else static if (is(FT == bool))
        j[name] = Json(val.tupleof[i]);
      else static if (is(FT == long) || is(FT == int) || is(FT == uint) || is(FT == ulong))
        j[name] = Json(val.tupleof[i]);
      else static if (is(FT == string[])) {
        auto arr = Json.emptyArray;
        foreach (s; val.tupleof[i])
          arr ~= Json(s);
        j[name] = arr;
      }
      else static if (is(FT == enum)) {
        // import std.conv : to;
        j[name] = Json(val.tupleof[i].to!string);
      }
      else static if (is(FT == string[string])) {
        auto obj = Json.emptyObject;
        foreach (k, v; val.tupleof[i])
          obj[k] = Json(v);
        j[name] = obj;
      }
      else static if (isArray!FT && !is(FT == string)) {
        auto arr = Json.emptyArray;
        foreach (item; val.tupleof[i])
          arr ~= toJsonValue(item);
        j[name] = arr;
      }
    }
  }
  return j;
}

/// Serialize an array of structs.
Json toJsonArray(T)(T[] items) {
  auto arr = Json.emptyArray;
  foreach (item; items)
    arr ~= toJsonValue(item);
  return arr;
}

/// Read an integer field from JSON.
long jsonLong(Json j, string key, long default_ = 0) {
  if (j.type == Json.Type.object) {
    auto val = key in j;
    if (val !is null && (*val).isInteger)
      return (*val).get!long;
  }
  return default_;
}

/// Read a uint field from JSON.
uint jsonUint(Json j, string key, uint default_ = 0) {
  return cast(uint) jsonLong(j, key, default_);
}

/// Read a string array from JSON.
string[] getStringArray(Json j, string key) {
  string[] result;
  if (j.type == Json.Type.object) {
    auto val = key in j;
    if (val !is null && (*val).type == Json.Type.array) {
      foreach (item; *val) {
        if (item.isString)
          result ~= item.get!string;
      }
    }
  }
  return result;
}

/// Extract ID from the last segment of a URL path.
string extractIdFromPath(string path) {
  // import std.string : lastIndexOf;
  auto idx = path.lastIndexOf('/');
  if (idx >= 0 && idx + 1 < path.length)
    return path[idx + 1 .. $];
  return "";
}
string[] getStringArray(Json j, string key) {
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

Json toJsonArray(string[] arr) {
  auto jarr = Json.emptyArray;
  foreach (s; arr)
    jarr ~= Json(s);
  return jarr;
}

// string extractIdFromPath(string path) {
//   import std.string : lastIndexOf;

//   auto idx = lastIndexOf(path, '/');
//   if (idx >= 0 && idx + 1 < path.length)
//     return path[idx + 1 .. $];
//   return "";
// }

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



string[] getStringArray(Json j, string key) {
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

/// Parse array of [key, value] pairs from JSON array of objects with "key"/"value" fields
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
/// Serialize a struct to a Json value.
Json toJsonValue(T)(T obj) if (is(T == struct)) {
  return serializeToJson(obj);
}

/// Serialize an array of structs to a Json array.
Json toJsonArray(T)(T[] arr) if (is(T == struct)) {
  auto jArr = Json.emptyArray;
  foreach (item; arr)
    jArr ~= serializeToJson(item);
  return jArr;
}

/// Helper: standard JSON error response body.
Json errorJson(string message, int code = 400) {
  return Json.emptyObject
    .set("error", message)
    .set("code", code);
}

/// Helper: envelope a result with metadata.
Json envelopeJson(string key, Json data) {
  auto j = Json.emptyObject;
  j[key] = data;
  return j;
}

// /// Extract a string array from a Json object.
// string[] getStringArray(Json j, string key) {
//   if (!j.isObject)
//     return null;
//   auto v = key in j;
//   if (v is null || (*v).type != Json.Type.array)
//     return null;

//   string[] result;
//   foreach (item; *v) {
//     if (item.isString)
//       result ~= item.get!string;
//   }
//   return result;
// }

/// Extract a ushort field from a Json object.
ushort getUshort(Json j, string key, ushort default_ = 0) {
  return cast(ushort) jsonLong(j, key, default_);
}

/// Convert a string array to a Json array.
Json toJsonArray(const(string[]) arr) {
  auto j = Json.emptyArray;
  foreach (s; arr)
    j ~= Json(s);
  return j;
}

// --- Enum parsers ---

OrgStatus parseOrgStatus(string s) {
  switch (s) {
  case "active":
    return OrgStatus.active;
  case "suspended":
    return OrgStatus.suspended;
  default:
    return OrgStatus.active;
  }
}

SpaceStatus parseSpaceStatus(string s) {
  switch (s) {
  case "active":
    return SpaceStatus.active;
  case "suspended":
    return SpaceStatus.suspended;
  default:
    return SpaceStatus.active;
  }
}

AppState parseAppState(string s) {
  switch (s) {
  case "stopped":
    return AppState.stopped;
  case "started":
    return AppState.started;
  case "crashed":
    return AppState.crashed;
  case "staging":
    return AppState.staging;
  default:
    return AppState.stopped;
  }
}

HealthCheckType parseHealthCheckType(string s) {
  switch (s) {
  case "http":
    return HealthCheckType.http;
  case "port":
    return HealthCheckType.port;
  case "process":
    return HealthCheckType.process;
  default:
    return HealthCheckType.port;
  }
}

RouteProtocol parseRouteProtocol(string s) {
  switch (s) {
  case "http":
    return RouteProtocol.http;
  case "tcp":
    return RouteProtocol.tcp;
  default:
    return RouteProtocol.http;
  }
}

DomainScope parseDomainScope(string s) {
  switch (s) {
  case "shared":
    return DomainScope.shared_;
  case "private":
    return DomainScope.private_;
  case "internal":
    return DomainScope.internal_;
  default:
    return DomainScope.shared_;
  }
}

BuildpackType parseBuildpackType(string s) {
  switch (s) {
  case "system":
    return BuildpackType.system;
  case "custom":
    return BuildpackType.custom;
  default:
    return BuildpackType.system;
  }
}
/// Extract the last path segment from a URI (for wildcard routes).
string extractIdFromPath(string uri) {
  // import std.string : indexOf;

  auto qpos = uri.indexOf('?');
  string path = qpos >= 0 ? uri[0 .. qpos] : uri;

  if (path.length > 0 && path[$ - 1] == '/')
    path = path[0 .. $ - 1];

  auto spos = lastIndexOf(path, '/');
  if (spos >= 0 && spos + 1 < path.length)
    return path[spos + 1 .. $];
  return path;
}




// --- Enum parsers ---

DataType parseDataType(string s) {
  switch (s) {
  case "product":
    return DataType.product;
  case "material":
    return DataType.material;
  case "customer":
    return DataType.customer;
  case "supplier":
    return DataType.supplier;
  case "custom":
    return DataType.custom;
  default:
    return DataType.custom;
  }
}

ModelType parseModelType(string s) {
  switch (s) {
  case "classification":
    return ModelType.classification;
  case "regression":
    return ModelType.regression;
  case "recommendation":
    return ModelType.recommendation;
  default:
    return ModelType.classification;
  }
}
/// Extract a double field from a Json object.
double jsonDouble(Json j, string key, double default_ = 0.0) {
  if (!j.isObject)
    return default_;
  auto v = key in j;
  if (v is null)
    return default_;
  if ((*v).type == Json.Type.float_)
    return (*v).get!double;
  if ((*v).isInteger)
    return cast(double)(*v).get!long;
  return default_;
}



/// Extract a string-to-string map from a Json object field.
string[string] jsonStrMap(Json j, string key) {
  if (!j.isObject)
    return (string[string]).init;
  auto v = key in j;
  if (v is null || (*v).type != Json.Type.object)
    return (string[string]).init;

  string[string] result;
  foreach (string k, val; *v) {
    if (val.isString)
      result[k] = val.get!string;
  }
  return result;
}

/// Extract a string[][] (array of string arrays) from a Json object.
string[][] getStringArrayArray(Json j, string key) {
  if (!j.isObject)
    return [];
  auto v = key in j;
  if (v is null || (*v).type != Json.Type.array)
    return [];

  string[][] result;
  foreach (item; *v) {
    if (item.type == Json.Type.array) {
      string[] inner;
      foreach (sub; item)
        if (sub.isString)
          inner ~= sub.get!string;
      result ~= inner;
    }
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

  auto spos = lastIndexOfChar(path, '/');
  if (spos >= 0 && spos + 1 < path.length)
    return path[spos + 1 .. $];
  return path;
}

private long lastIndexOfChar(string s, char c) {
  for (long i = s.length - 1; i >= 0; --i)
    if (s[cast(size_t) i] == c)
      return i;
  return -1;
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



string[] getStringArray(Json j, string key) {
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
/// Extract a string[string] map from a Json object.
// string[string] jsonStrMap(Json j, string key) {
//   if (!j.isObject)
//     return (string[string]).init;
//   auto v = key in j;
//   if (v is null || (*v).type != Json.Type.object)
//     return (string[string]).init;

//   string[string] result;
//   foreach (string k, val; *v) {
//     if (val.isString)
//       result[k] = val.get!string;
//   }
//   return result;
// }

/// Convert a string array to a Json array.


/// Convert a string[string] map to a Json object.
// Json toJsonObject(const(string[string]) map) {
//   auto jobj = Json.emptyObject;
//   foreach (k, v; map)
//     jobj[k] = Json(v);
//   return jobj;
// }

// /// Write a JSON error response.


// /// Extract ID from the last segment of a request URI path.
// string extractIdFromPath(string uri) {
//   // import std.string : lastIndexOf;
//   auto qpos = lastIndexOf(uri, '?');
//   auto path = qpos >= 0 ? uri[0 .. qpos] : uri;
//   auto pos = lastIndexOf(path, '/');
//   if (pos >= 0 && pos + 1 < path.length)
//     return path[pos + 1 .. $];
//   return "";
// }
