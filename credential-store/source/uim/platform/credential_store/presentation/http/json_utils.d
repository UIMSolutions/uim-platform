/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.credential_store.presentation.http.json_utils;



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
