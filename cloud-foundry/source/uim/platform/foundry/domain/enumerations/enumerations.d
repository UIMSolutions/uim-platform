/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.domain.enumerations.enumerations;

import uim.platform.foundry;

// mixin(ShowModule!());

@safe:

/// Organization lifecycle status.
enum OrgStatus {
  active,
  suspended,
}

/// Space lifecycle status.
enum SpaceStatus {
  active,
  suspended,
}

/// Application runtime state.
enum AppState {
  stopped,
  started,
  staging,
  crashed,
}

/// Individual application instance state.
enum InstanceState {
  running,
  crashed,
  starting,
  down,
}

/// Service instance provisioning status.
enum ServiceInstanceStatus {
  creating,
  active,
  updateInProgress,
  deleteInProgress,
  failed,
}

/// Service binding lifecycle status.
enum BindingStatus {
  creating,
  active,
  deleteInProgress,
  failed,
}

/// Route protocol.
enum RouteProtocol {
  http,
  tcp,
}

/// Domain ownership scope.
enum DomainScope : string{
  shared_ = "shared",
  private_ = "private",
  internal_ = "internal",
}

/// Buildpack origin type.
enum BuildpackType {
  system,
  custom,
}

/// Application health check strategy.
enum HealthCheckType {
  http,
  port,
  process,
}

HealthCheckType toHealthCheckType(string s) {
  import std.uni : toLower;
  switch (s.toLower()) {
    case "http":    return HealthCheckType.http;
    case "port":    return HealthCheckType.port;
    case "process": return HealthCheckType.process;
    default:        return HealthCheckType.http;
  }
}

string toString(HealthCheckType t) {
  final switch (t) {
    case HealthCheckType.http:    return "http";
    case HealthCheckType.port:    return "port";
    case HealthCheckType.process: return "process";
  }
}

