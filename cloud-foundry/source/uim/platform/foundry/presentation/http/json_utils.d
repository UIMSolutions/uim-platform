/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.presentation.http.json_utils;

// import vibe.data.json;
// import vibe.http.server;

import uim.platform.foundry.domain.types;





/// Extract an integer field from a Json object.


/// Extract an int field from a Json object.

/// Extract a ushort field from a Json object.
ushort jsonUshort(Json j, string key, ushort default_ = 0) {
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
  switch (s)
  {
  case "active":
    return OrgStatus.active;
  case "suspended":
    return OrgStatus.suspended;
  default:
    return OrgStatus.active;
  }
}

SpaceStatus parseSpaceStatus(string s) {
  switch (s)
  {
  case "active":
    return SpaceStatus.active;
  case "suspended":
    return SpaceStatus.suspended;
  default:
    return SpaceStatus.active;
  }
}

AppState parseAppState(string s) {
  switch (s)
  {
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
  switch (s)
  {
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
  switch (s)
  {
  case "http":
    return RouteProtocol.http;
  case "tcp":
    return RouteProtocol.tcp;
  default:
    return RouteProtocol.http;
  }
}

DomainScope parseDomainScope(string s) {
  switch (s)
  {
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
  switch (s)
  {
  case "system":
    return BuildpackType.system;
  case "custom":
    return BuildpackType.custom;
  default:
    return BuildpackType.system;
  }
}
