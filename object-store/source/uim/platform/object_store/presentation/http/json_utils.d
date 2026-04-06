/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.object_store.presentation.http.json_utils;

// import vibe.data.json;
// import vibe.http.server;





/// Extract an integer field from a Json object.


/// Extract an int field from a Json object.

/// Write a JSON error response.
void writeError(scope HTTPServerResponse res, int status, string message) {
  auto j = Json.emptyObject;
  j["error"] = Json(message);
  j["status"] = Json(cast(long) status);
  res.writeJsonBody(j, status);
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
  foreach (pair; splitBy(qs, '&'))
  {
    auto epos = pair.indexOf('=');
    if (epos > 0 && pair[0 .. epos] == key)
      return pair[epos + 1 .. $];
  }
  return "";
}

private long lastIndexOfChar(string s, char c) {
  for (long i = cast(long) s.length - 1; i >= 0; i--)
    if (s[cast(size_t) i] == c)
      return i;
  return -1;
}

private string[] splitBy(string s, char delim) {
  string[] result;
  size_t start = 0;
  foreach (i, ch; s)
  {
    if (ch == delim)
    {
      result ~= s[start .. i];
      start = i + 1;
    }
  }
  if (start <= s.length)
    result ~= s[start .. $];
  return result;
}
