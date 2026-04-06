/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.presentation.http.json_utils;

// import vibe.data.json;
// import vibe.http.server;




/// Extract an integer field from a Json object.


/// Extract an int field from a Json object.



/// Extract a ushort field from a Json object.
ushort jsonUshort(Json j, string key, ushort default_ = 0) {
  return cast(ushort) jsonLong(j, key, default_);
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



