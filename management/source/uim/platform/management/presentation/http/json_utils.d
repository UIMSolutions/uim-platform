/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.presentation.http.json_utils;

// import vibe.data.json;
// import vibe.http.server;

import uim.platform.management;

mixin(ShowModule!());
@safe:




/// Extract a long field from a Json object.


/// Extract an int field from a Json object.



// /// Extract a string-to-string map from a Json object.
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

// /// Extract the last path segment as ID from a URI.
// string extractId(string uri) {
//   // import std.string : lastIndexOf;

//   auto qIdx = uri.lastIndexOf('?');
//   auto path = qIdx >= 0 ? uri[0 .. qIdx] : uri;
//   auto idx = path.lastIndexOf('/');
//   if (idx < 0)
//     return path;
//   return path[idx + 1 .. $];
// }

// /// Serialize a string-to-string map to Json.
// Json serializeStrMap(string[string] map) {
//   auto j = Json.emptyObject;
//   foreach (k, v; map)
//     j[k] = Json(v);
//   return j;
// }

// /// Serialize a string array to Json.
// Json serializeStrArray(string[] arr) {
//   auto j = Json.emptyArray;
//   foreach (s; arr)
//     j ~= Json(s);
//   return j;
// }
