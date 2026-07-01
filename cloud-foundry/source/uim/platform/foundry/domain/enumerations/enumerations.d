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
OrgStatus toOrgStatus(string value) {
  mixin(EnumSwitch!"OrgStatus", "active");
}
OrgStatus[] toOrgStatus(string[] values) {
  return values.map!(toOrgStatus).array;
}
string toString(OrgStatus value) {
  return value.to!string;
}
string[] toStringArray(OrgStatus[] values) {
  return values.map!(toString).array;
}
///
unittest {
  mixin(ShowTest!"OrgStatus");

  assert("active".toOrgStatus == OrgStatus.active);
  assert("suspended".toOrgStatus == OrgStatus.suspended);

  assert("".toOrgStatus == OrgStatus.active); // Default value for unknown strings is "active"
  assert("unknown".toOrgStatus == OrgStatus.active); // Default value for unknown strings is "active"

  assert(toString(OrgStatus.active) == "active");
  assert(toString(OrgStatus.suspended) == "suspended");

  assert(toStringArray([OrgStatus.active, OrgStatus.suspended]) == ["active", "suspended"]);
  assert(toOrgStatusArray(["active", "suspended"]) == [OrgStatus.active, OrgStatus.suspended]);
}

/// Space lifecycle status.
enum SpaceStatus {
  active,
  suspended,
}
SpaceStatus toSpaceStatus(string value) {
  mixin(EnumSwitch!"SpaceStatus", "active");
}
SpaceStatus[] toSpaceStatus(string[] values) {
  return values.map!(toSpaceStatus).array;
}
string toString(SpaceStatus value) {
  return value.to!string;
}
string[] toStringArray(SpaceStatus[] values) {
  return values.map!(toString).array;
}
/// 
unittest {
  mixin(ShowTest!"SpaceStatus");

  assert("active".toSpaceStatus == SpaceStatus.active);
  assert("suspended".toSpaceStatus == SpaceStatus.suspended);

  assert("".toSpaceStatus == SpaceStatus.active); // Default value for unknown strings is "active"
  assert("unknown".toSpaceStatus == SpaceStatus.active); // Default value for unknown strings is "active"

  assert(toString(SpaceStatus.active) == "active");
  assert(toString(SpaceStatus.suspended) == "suspended");

  assert(toStringArray([SpaceStatus.active, SpaceStatus.suspended]) == ["active", "suspended"]);
  assert(toSpaceStatusArray(["active", "suspended"]) == [SpaceStatus.active, SpaceStatus.suspended]);
}

/// Application runtime state.
enum AppState {
  stopped,
  started,
  staging,
  crashed,
}
AppState toAppState(string value) {
  mixin(EnumSwitch!"AppState", "stopped");
}
AppState[] toAppState(string[] values) {
  return values.map!(toAppState).array;
}
string toString(AppState value) {
  return value.to!string;
}
string[] toString(AppState[] values) { 
  return values.map!(toString).array;
}
///
unittest {
  mixin(ShowTest!"AppState");

  assert("stopped".toAppState == AppState.stopped);
  assert("started".toAppState == AppState.started);
  assert("staging".toAppState == AppState.staging);
  assert("crashed".toAppState == AppState.crashed);

  assert("".toAppState == AppState.stopped); // Default value for unknown strings is "stopped"
  assert("unknown".toAppState == AppState.stopped); // Default value for unknown strings is "stopped"

  assert(toString(AppState.stopped) == "stopped");
  assert(toString(AppState.started) == "started");
  assert(toString(AppState.staging) == "staging");
  assert(toString(AppState.crashed) == "crashed");

  assert(toStringArray([AppState.stopped, AppState.started, AppState.crashed]) == ["stopped", "started", "crashed"]);
  assert(toAppStateArray(["stopped", "started", "crashed"]) == [AppState.stopped, AppState.started, AppState.crashed]);
}

/// Individual application instance state.
enum InstanceState {
  running,
  crashed,
  starting,
  down,
}
InstanceState toInstanceState(string value) {
  mixin(EnumSwitch!"InstanceState", "down");
}
InstanceState[] toInstanceState(string[] values) {
  return values.map!(toInstanceState).array;
}
string toString(InstanceState value) {
  return value.to!string;
}
string[] toStringArray(InstanceState[] values) {
  return values.map!(toString).array;
}
/// 
unittest 

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

