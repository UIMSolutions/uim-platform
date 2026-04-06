/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms.application.presentation.http.json_utils;

// import vibe.data.json;
// import vibe.http.server;
// 
// import uim.platform.dms.application.domain.types;

import uim.platform.dms.application;

mixin(ShowModule!());
@safe:


/// Extract a long field from a Json object.


/// Extract a bool field from a Json object.
bool jsonBool(Json j, string key, bool default_ = false) {
  if (!j.isObject)
    return default_;
  auto v = key in j;
  if (v is null)
    return default_;
  if ((*v).isBoolean)
    return (*v).get!bool;
  return default_;
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

private long lastIndexOf(string s, char c) {
  for (long i = cast(long) s.length - 1; i >= 0; --i)
    if (s[cast(size_t) i] == c)
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

// --- Enum parsers ---

ContentCategory parseContentCategory(string s) {
  switch (s)
  {
  case "file":
    return ContentCategory.file;
  case "link":
    return ContentCategory.link;
  case "reference":
    return ContentCategory.reference;
  default:
    return ContentCategory.file;
  }
}

ShareType parseShareType(string s) {
  switch (s)
  {
  case "internal":
    return ShareType.internal;
  case "external":
    return ShareType.external;
  case "public":
    return ShareType.public_;
  default:
    return ShareType.internal;
  }
}

PermissionLevel parsePermissionLevel(string s) {
  switch (s)
  {
  case "read":
    return PermissionLevel.read;
  case "write":
    return PermissionLevel.write;
  case "admin":
    return PermissionLevel.admin;
  case "owner":
    return PermissionLevel.owner;
  default:
    return PermissionLevel.read;
  }
}

ResourceType parseResourceType(string s) {
  switch (s)
  {
  case "document":
    return ResourceType.document;
  case "folder":
    return ResourceType.folder;
  case "repository":
    return ResourceType.repository;
  default:
    return ResourceType.document;
  }
}
