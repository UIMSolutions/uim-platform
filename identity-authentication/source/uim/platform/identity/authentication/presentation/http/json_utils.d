/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.presentation.http.json_utils;

// import vibe.data.json;
// // import std.traits;

import uim.platform.identity_authentication;

mixin(ShowModule!());
@safe:
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

/// Read a string field from JSON, or return default.
string jsonStr(Json j, string key) {
  if (j.type == Json.Type.object) {
    auto val = key in j;
    if (val !is null && (*val).isString)
      return (*val).get!string;
  }
  return "";
}

/// Read a string array from JSON.
string[] jsonStrArray(Json j, string key) {
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
