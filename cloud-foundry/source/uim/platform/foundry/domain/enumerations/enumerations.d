/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.domain.enumerations.enumerations;

import uim.platform.foundry;

mixin(ShowModule!());

@safe:

/// Organization lifecycle status.
enum OrgStatus {
  active,
  suspended,
}
OrgStatus toOrgStatus(string value) {
  mixin(EnumSwitch("OrgStatus", "active"));
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
  mixin(EnumSwitch("SpaceStatus", "active"));
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
  mixin(EnumSwitch("AppState", "stopped"));
}
AppState[] toAppState(string[] values) {
  return values.map!(toAppState).array;
}
string toString(AppState value) {
  return value.to!string;
}
string[] toStrings(AppState[] values) { 
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
  mixin(EnumSwitch("InstanceState", "down"));
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
unittest {
  mixin(ShowTest!"InstanceState");

  assert("running".toInstanceState == InstanceState.running);
  assert("crashed".toInstanceState == InstanceState.crashed);
  assert("starting".toInstanceState == InstanceState.starting);
  assert("down".toInstanceState == InstanceState.down);

  assert("".toInstanceState == InstanceState.down); // Default value for unknown strings is "down"
  assert("unknown".toInstanceState == InstanceState.down); // Default value for unknown strings is "down"

  assert(toString(InstanceState.running) == "running");
  assert(toString(InstanceState.crashed) == "crashed");
  assert(toString(InstanceState.starting) == "starting");
  assert(toString(InstanceState.down) == "down");

  assert(toStringArray([InstanceState.running, InstanceState.crashed, InstanceState.down]) == ["running", "crashed", "down"]);
  assert(toInstanceStateArray(["running", "crashed", "down"]) == [InstanceState.running, InstanceState.crashed, InstanceState.down]);
} 

/// Service instance provisioning status.
enum ServiceInstanceStatus {
  creating,
  active,
  updateInProgress,
  deleteInProgress,
  failed,
}
ServiceInstanceStatus toServiceInstanceStatus(string value) {
  mixin(EnumSwitch("ServiceInstanceStatus", "creating"));
}
ServiceInstanceStatus[] toServiceInstanceStatus(string[] values) {
  return values.map!(toServiceInstanceStatus).array;
}
string toString(ServiceInstanceStatus value) {
  return value.to!string;
}
string[] toStrings(ServiceInstanceStatus[] values) {
  return values.map!(toString).array;
}
/// 
unittest {
  mixin(ShowTest!"ServiceInstanceStatus");

  assert("creating".toServiceInstanceStatus == ServiceInstanceStatus.creating);
  assert("active".toServiceInstanceStatus == ServiceInstanceStatus.active);
  assert("updateInProgress".toServiceInstanceStatus == ServiceInstanceStatus.updateInProgress);
  assert("deleteInProgress".toServiceInstanceStatus == ServiceInstanceStatus.deleteInProgress);
  assert("failed".toServiceInstanceStatus == ServiceInstanceStatus.failed);

  assert("".toServiceInstanceStatus == ServiceInstanceStatus.creating); // Default value for unknown strings is "creating"
  assert("unknown".toServiceInstanceStatus == ServiceInstanceStatus.creating); // Default value for unknown strings is "creating"

  assert(toString(ServiceInstanceStatus.creating) == "creating");
  assert(toString(ServiceInstanceStatus.active) == "active");
  assert(toString(ServiceInstanceStatus.updateInProgress) == "updateInProgress");
  assert(toString(ServiceInstanceStatus.deleteInProgress) == "deleteInProgress");
  assert(toString(ServiceInstanceStatus.failed) == "failed");

  assert(toString([ServiceInstanceStatus.creating, ServiceInstanceStatus.active, ServiceInstanceStatus.failed]) == ["creating", "active", "failed"]);
  assert(toServiceInstanceStatus(["creating", "active", "failed"]) == [ServiceInstanceStatus.creating, ServiceInstanceStatus.active, ServiceInstanceStatus.failed]);
}

/// Service binding lifecycle status.
enum BindingStatus {
  creating,
  active,
  deleteInProgress,
  failed,
}
BindingStatus toBindingStatus(string value) {
  mixin(EnumSwitch("BindingStatus", "creating"));
}
BindingStatus[] toBindingStatus(string[] values) {
  return values.map!(toBindingStatus).array;
}
string toString(BindingStatus value) {
  return value.to!string;
}
string[] toStrings(BindingStatus[] values) {
  return values.map!(toString).array;
}
/// 
unittest {
  mixin(ShowTest!"BindingStatus");    

  assert("creating".toBindingStatus == BindingStatus.creating);
  assert("active".toBindingStatus == BindingStatus.active);
  assert("deleteInProgress".toBindingStatus == BindingStatus.deleteInProgress);
  assert("failed".toBindingStatus == BindingStatus.failed);   

  assert("".toBindingStatus == BindingStatus.creating); // Default value for unknown strings is "creating"
  assert("unknown".toBindingStatus == BindingStatus.creating); // Default value for unknown strings is "creating"

  assert(toString(BindingStatus.creating) == "creating");
  assert(toString(BindingStatus.active) == "active");
  assert(toString(BindingStatus.deleteInProgress) == "deleteInProgress");
  assert(toString(BindingStatus.failed) == "failed");

  assert(toString([BindingStatus.creating, BindingStatus.active, BindingStatus.failed]) == ["creating", "active", "failed"]);
  assert(toBindingStatus(["creating", "active", "failed"]) == [BindingStatus.creating, BindingStatus.active, BindingStatus.failed]);
}

/// Route protocol.
enum RouteProtocol {
  http,
  tcp,
}
RouteProtocol toRouteProtocol(string value) {
  mixin(EnumSwitch("RouteProtocol", "http"));
}
RouteProtocol[] toRouteProtocol(string[] values) {
  return values.map!(toRouteProtocol).array;
}
string toString(RouteProtocol value) {
  return value.to!string;
}
string[] toStrings(RouteProtocol[] values) {
  return values.map!(toString).array;
}
/// 
unittest {
  mixin(ShowTest!"RouteProtocol");  

  assert("http".toRouteProtocol == RouteProtocol.http);
  assert("tcp".toRouteProtocol == RouteProtocol.tcp); 

  assert("".toRouteProtocol == RouteProtocol.http); // Default value for unknown strings is "http"
  assert("unknown".toRouteProtocol == RouteProtocol.http); // Default value for unknown strings is "http"

  assert(toString(RouteProtocol.http) == "http");
  assert(toString(RouteProtocol.tcp) == "tcp"); 

  assert(toString([RouteProtocol.http, RouteProtocol.tcp]) == ["http", "tcp"]);
  assert(toRouteProtocol(["http", "tcp"]) == [RouteProtocol.http, RouteProtocol.tcp]);
}

/// Domain ownership scope.
enum DomainScope : string{
  shared_ = "shared",
  private_ = "private",
  internal_ = "internal",
}
DomainScope toDomainScope(string value) {
  mixin(EnumSwitch("DomainScope", "shared_"));
}
DomainScope[] toDomainScope(string[] values) {
  return values.map!(toDomainScope).array;
}
string toString(DomainScope value) {
  return value.to!string;
}
string[] toStrings(DomainScope[] values) {
  return values.map!(toString).array;
}
///
unittest {
  mixin(ShowTest!"DomainScope");  

  assert("shared".toDomainScope == DomainScope.shared_);
  assert("private".toDomainScope == DomainScope.private_);
  assert("internal".toDomainScope == DomainScope.internal_); 

  assert("".toDomainScope == DomainScope.shared_); // Default value for unknown strings is "shared"
  assert("unknown".toDomainScope == DomainScope.shared_); // Default value for unknown strings is "shared"

  assert(toString(DomainScope.shared_) == "shared");
  assert(toString(DomainScope.private_) == "private"); 
  assert(toString(DomainScope.internal_) == "internal"); 

  assert(toString([DomainScope.shared_, DomainScope.private_, DomainScope.internal_]) == ["shared", "private", "internal"]);
  assert(toDomainScope(["shared", "private", "internal"]) == [DomainScope.shared_, DomainScope.private_, DomainScope.internal_]);
}

/// Buildpack origin type.
enum BuildpackType {
  system,
  custom,
}
BuildpackType toBuildpackType(string value) {
  mixin(EnumSwitch("BuildpackType", "system"));
}
BuildpackType[] toBuildpackType(string[] values) {
  return values.map!(toBuildpackType).array;
}
string toString(BuildpackType value) {
  return value.to!string;
}
string[] toStrings(BuildpackType[] values) {
  return values.map!(toString).array;
}
/// 
unittest {
  mixin(ShowTest!"BuildpackType");

  assert("system".toBuildpackType == BuildpackType.system);
  assert("custom".toBuildpackType == BuildpackType.custom); 

  assert("".toBuildpackType == BuildpackType.system); // Default value for unknown strings is "system"
  assert("unknown".toBuildpackType == BuildpackType.system); // Default value for unknown strings is "system"

  assert(toString(BuildpackType.system) == "system");
  assert(toString(BuildpackType.custom) == "custom");

  assert(toString([BuildpackType.system, BuildpackType.custom]) == ["system", "custom"]);
  assert(toBuildpackType(["system", "custom"]) == [BuildpackType.system, BuildpackType.custom]);
}

/// Application health check strategy.
enum HealthCheckType {
  http,
  port,
  process,
}
HealthCheckType toHealthCheckType(string value) {
  mixin(EnumSwitch("HealthCheckType", "http"));
}
HealthCheckType[] toHealthCheckType(string[] values) {
  return values.map!(toHealthCheckType).array;
}
string toString(HealthCheckType value) {
  return value.to!string;
}
string[] toStrings(HealthCheckType[] values) {
  return values.map!(toString).array;
}
///
unittest {
  mixin(ShowTest!"HealthCheckType");

  assert("http".toHealthCheckType == HealthCheckType.http);
  assert("port".toHealthCheckType == HealthCheckType.port);
  assert("process".toHealthCheckType == HealthCheckType.process);

  assert("".toHealthCheckType == HealthCheckType.http); // Default value for unknown strings is "http"
  assert("unknown".toHealthCheckType == HealthCheckType.http); // Default value for unknown strings is "http"

  assert(toString(HealthCheckType.http) == "http");
  assert(toString(HealthCheckType.port) == "port");
  assert(toString(HealthCheckType.process) == "process");

  assert(toString([HealthCheckType.http, HealthCheckType.port, HealthCheckType.process]) == ["http", "port", "process"]);
  assert(toHealthCheckType(["http", "port", "process"]) == [HealthCheckType.http, HealthCheckType.port, HealthCheckType.process]);
}
