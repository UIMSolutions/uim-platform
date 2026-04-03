module uim.platform.identity.provisioning.presentation.http.json_utils;

// import vibe.data.json;
// import vibe.http.server;
// import std.conv : to;

import uim.platform.identity.provisioning.domain.types;

/// Extract a string field from a Json object.
string jsonStr(Json j, string key)
{
  if (!j.isObject)
    return "";
  auto v = key in j;
  if (v is null)
    return "";
  if ((*v).isString)
    return (*v).get!string;
  return "";
}

/// Extract an integer field from a Json object.
long jsonLong(Json j, string key, long default_ = 0)
{
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
int jsonInt(Json j, string key, int default_ = 0)
{
  return cast(int) jsonLong(j, key, default_);
}

/// Extract the last path segment from a URI (for wildcard routes).
string extractIdFromPath(string uri)
{
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

private long lastIndexOf(string s, char c)
{
  for (long i = cast(long) s.length - 1; i >= 0; --i)
    if (s[cast(size_t) i] == c)
      return i;
  return -1;
}

/// Write a JSON error response.
void writeError(scope HTTPServerResponse res, int status, string message)
{
  auto j = Json.emptyObject;
  j["error"] = Json(message);
  j["status"] = Json(status);
  res.writeJsonBody(j, status);
}

// --- Enum parsers ---

SystemType parseSystemType(string s)
{
  switch (s)
  {
  case "ias":
    return SystemType.ias;
  case "ldap":
    return SystemType.ldap;
  case "sap_hr":
    return SystemType.sap_hr;
  case "scim":
    return SystemType.scim;
  case "csv":
    return SystemType.csv;
  case "azure_ad":
    return SystemType.azure_ad;
  case "custom":
    return SystemType.custom;
  default:
    return SystemType.custom;
  }
}

SystemRole parseSystemRole(string s)
{
  switch (s)
  {
  case "source":
    return SystemRole.source;
  case "target":
    return SystemRole.target;
  case "proxy":
    return SystemRole.proxy;
  default:
    return SystemRole.source;
  }
}

JobType parseJobType(string s)
{
  switch (s)
  {
  case "full":
    return JobType.full;
  case "delta":
    return JobType.delta;
  case "simulate":
    return JobType.simulate;
  default:
    return JobType.full;
  }
}
