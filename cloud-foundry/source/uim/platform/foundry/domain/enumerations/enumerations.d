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
OrgStatus[] toOrgStatuses(string[] values) {
  return values.map!(toOrgStatus).array;
}
string toString(OrgStatus value) {
  return value.to!string;
}
string[] toStringArray(OrgStatus[] values) {
  return values.map!toString.array;
}
///
unittest {
  mixin(ShowTest!("OrgStatus"));

  assert("active".toOrgStatus == OrgStatus.active);
  assert("suspended".toOrgStatus == OrgStatus.suspended);

  assert("".toOrgStatus == OrgStatus.active); // Default value for unknown strings is "active"
  assert("unknown".toOrgStatus == OrgStatus.active); // Default value for unknown strings is "active"

  assert(OrgStatus.active.toString == "active");
  assert(OrgStatus.suspended.toString == "suspended");

  assert([OrgStatus.active, OrgStatus.suspended].toStringArray == ["active", "suspended"]);
  assert(["active", "suspended"].toOrgStatuses == [OrgStatus.active, OrgStatus.suspended]);
}

/// Space lifecycle status.
enum SpaceStatus {
  active,
  suspended,
}
SpaceStatus toSpaceStatus(string value) {
  mixin(EnumSwitch("SpaceStatus", "active"));
}
SpaceStatus[] toSpaceStatuses(string[] values) {
  return values.map!(toSpaceStatus).array;
}
string toString(SpaceStatus value) {
  return value.to!string;
}
string[] toStrings(SpaceStatus[] values) {
  return values.map!toString.array;
}
/// 
unittest {
  mixin(ShowTest!("SpaceStatus"));

  assert("active".toSpaceStatus == SpaceStatus.active);
  assert("suspended".toSpaceStatus == SpaceStatus.suspended);

  assert("".toSpaceStatus == SpaceStatus.active); // Default value for unknown strings is "active"
  assert("unknown".toSpaceStatus == SpaceStatus.active); // Default value for unknown strings is "active"

  assert(toString(SpaceStatus.active) == "active");
  assert(toString(SpaceStatus.suspended) == "suspended");

  assert(toStrings([SpaceStatus.active, SpaceStatus.suspended]) == ["active", "suspended"]);
  assert(toSpaceStatuses(["active", "suspended"]) == [SpaceStatus.active, SpaceStatus.suspended]);
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
AppState[] toAppStates(string[] values) {
  return values.map!(toAppState).array;
}
string toString(AppState value) {
  return value.to!string;
}
string[] toStrings(AppState[] values) { 
  return values.map!toString.array;
}
///
unittest {
  mixin(ShowTest!("AppState"));

  assert("stopped".toAppState == AppState.stopped);
  assert("started".toAppState == AppState.started);
  assert("staging".toAppState == AppState.staging);
  assert("crashed".toAppState == AppState.crashed);

  assert("".toAppState == AppState.stopped); // Default value for unknown strings is "stopped"
  assert("unknown".toAppState == AppState.stopped); // Default value for unknown strings is "stopped"

  assert(AppState.stopped.toString == "stopped");
  assert(AppState.started.toString == "started");
  assert(AppState.staging.toString == "staging");
  assert(AppState.crashed.toString == "crashed");

  assert([AppState.stopped, AppState.started, AppState.staging, AppState.crashed].toStrings == ["stopped", "started", "staging", "crashed"]);
  assert(["stopped", "started", "staging", "crashed"].toAppStates == [AppState.stopped, AppState.started, AppState.staging, AppState.crashed]);
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
InstanceState[] toInstanceStates(string[] values) {
  return values.map!(toInstanceState).array;
}
string toString(InstanceState value) {
  return value.to!string;
}
string[] toStrings(InstanceState[] values) {
  return values.map!toString.array;
}
/// 
unittest {
  mixin(ShowTest!("InstanceState"));

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

  assert([InstanceState.running, InstanceState.crashed, InstanceState.starting, InstanceState.down].toStrings == ["running", "crashed", "starting", "down"]);
  assert(["running", "crashed", "starting", "down"].toInstanceStates == [InstanceState.running, InstanceState.crashed, InstanceState.starting, InstanceState.down]);
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
ServiceInstanceStatus[] toServiceInstanceStatuses(string[] values) {
  return values.map!(toServiceInstanceStatus).array;
}
string toString(ServiceInstanceStatus value) {
  return value.to!string;
}
string[] toStrings(ServiceInstanceStatus[] values) {
  return values.map!toString.array;
}
/// 
unittest {
  mixin(ShowTest!("ServiceInstanceStatus"));

  assert("creating".toServiceInstanceStatus == ServiceInstanceStatus.creating);
  assert("active".toServiceInstanceStatus == ServiceInstanceStatus.active);
  assert("updateInProgress".toServiceInstanceStatus == ServiceInstanceStatus.updateInProgress);
  assert("deleteInProgress".toServiceInstanceStatus == ServiceInstanceStatus.deleteInProgress);
  assert("failed".toServiceInstanceStatus == ServiceInstanceStatus.failed);

  assert("".toServiceInstanceStatus == ServiceInstanceStatus.creating); // Default value for unknown strings is "creating"
  assert("unknown".toServiceInstanceStatus == ServiceInstanceStatus.creating); // Default value for unknown strings is "creating"

  assert(ServiceInstanceStatus.creating.toString == "creating");
  assert(ServiceInstanceStatus.active.toString == "active");
  assert(ServiceInstanceStatus.updateInProgress.toString == "updateInProgress");
  assert(ServiceInstanceStatus.deleteInProgress.toString == "deleteInProgress");
  assert(ServiceInstanceStatus.failed.toString == "failed");

  assert([ServiceInstanceStatus.creating, ServiceInstanceStatus.active, ServiceInstanceStatus.updateInProgress, ServiceInstanceStatus.deleteInProgress, ServiceInstanceStatus.failed].toStrings == ["creating", "active", "updateInProgress", "deleteInProgress", "failed"]);
  assert(["creating", "active", "updateInProgress", "deleteInProgress", "failed"].toServiceInstanceStatuses == [ServiceInstanceStatus.creating, ServiceInstanceStatus.active, ServiceInstanceStatus.updateInProgress, ServiceInstanceStatus.deleteInProgress, ServiceInstanceStatus.failed]);
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
BindingStatus[] toBindingStatuses(string[] values) {
  return values.map!(toBindingStatus).array;
}
string toString(BindingStatus value) {
  return value.to!string;
}
string[] toStrings(BindingStatus[] values) {
  return values.map!toString.array;
}
/// 
unittest {
  mixin(ShowTest!("BindingStatus"));

  assert("creating".toBindingStatus == BindingStatus.creating);
  assert("active".toBindingStatus == BindingStatus.active);
  assert("deleteInProgress".toBindingStatus == BindingStatus.deleteInProgress);
  assert("failed".toBindingStatus == BindingStatus.failed);   

  assert("".toBindingStatus == BindingStatus.creating); // Default value for unknown strings is "creating"
  assert("unknown".toBindingStatus == BindingStatus.creating); // Default value for unknown strings is "creating"

  assert(BindingStatus.creating.toString == "creating");
  assert(BindingStatus.active.toString == "active");
  assert(BindingStatus.deleteInProgress.toString == "deleteInProgress");
  assert(BindingStatus.failed.toString == "failed");

  assert([BindingStatus.creating, BindingStatus.active, BindingStatus.failed].toStrings == ["creating", "active", "failed"]);
  assert(["creating", "active", "failed"].toBindingStatuses == [BindingStatus.creating, BindingStatus.active, BindingStatus.failed]);
}

/// Route protocol.
enum RouteProtocol {
  http,
  tcp,
}
RouteProtocol toRouteProtocol(string value) {
  mixin(EnumSwitch("RouteProtocol", "http"));
}
RouteProtocol[] toRouteProtocols(string[] values) {
  return values.map!(toRouteProtocol).array;
}
string toString(RouteProtocol value) {
  return value.to!string;
}
string[] toStrings(RouteProtocol[] values) {
  return values.map!toString.array;
}
/// 
unittest {
  mixin(ShowTest!("RouteProtocol"));

  assert("http".toRouteProtocol == RouteProtocol.http);
  assert("tcp".toRouteProtocol == RouteProtocol.tcp); 

  assert("".toRouteProtocol == RouteProtocol.http); // Default value for unknown strings is "http"
  assert("unknown".toRouteProtocol == RouteProtocol.http); // Default value for unknown strings is "http"

  assert(RouteProtocol.http.toString == "http");
  assert(RouteProtocol.tcp.toString == "tcp");

  assert([RouteProtocol.http, RouteProtocol.tcp].toStrings == ["http", "tcp"]);
  assert(["http", "tcp"].toRouteProtocols == [RouteProtocol.http, RouteProtocol.tcp]);
}

/// Domain ownership scope.
enum DomainScope : string {
  shared_ = "shared",
  private_ = "private",
  internal_ = "internal",
}
DomainScope toDomainScope(string value) {
  switch(value.toLower) {
    case "shared": return DomainScope.shared_;
    case "private": return DomainScope.private_;
    case "internal": return DomainScope.internal_;
    default: return DomainScope.shared_; // Default value for unknown strings is "shared"
  }
}
DomainScope[] toDomainScopes(string[] values) {
  return values.map!(toDomainScope).array;
}
string toString(DomainScope value) {
  return cast(string)value;
}
string[] toStrings(DomainScope[] values) {
  return values.map!toString.array;
}
///
unittest {
  mixin(ShowTest!("DomainScope"));

  assert("shared".toDomainScope == DomainScope.shared_);
  assert("private".toDomainScope == DomainScope.private_);
  assert("internal".toDomainScope == DomainScope.internal_); 

  assert("".toDomainScope == DomainScope.shared_); // Default value for unknown strings is "shared"
  assert("unknown".toDomainScope == DomainScope.shared_); // Default value for unknown strings is "shared"

  assert(DomainScope.shared_.toString == "shared");
  assert(DomainScope.private_.toString == "private"); 
  assert(DomainScope.internal_.toString == "internal");

  assert([DomainScope.shared_, DomainScope.private_, DomainScope.internal_].toStrings == ["shared", "private", "internal"]);
  assert(["shared", "private", "internal"].toDomainScopes == [DomainScope.shared_, DomainScope.private_, DomainScope.internal_]);
}

/// Buildpack origin type.
enum BuildpackType {
  system,
  custom,
}
BuildpackType toBuildpackType(string value) {
  mixin(EnumSwitch("BuildpackType", "system"));
}
BuildpackType[] toBuildpackTypes(string[] values) {
  return values.map!(toBuildpackType).array;
}
string toString(BuildpackType value) {
  return value.to!string;
}
string[] toStrings(BuildpackType[] values) {
  return values.map!toString.array;
}
/// 
unittest {
  mixin(ShowTest!("BuildpackType"));

  assert("system".toBuildpackType == BuildpackType.system);
  assert("custom".toBuildpackType == BuildpackType.custom); 

  assert("".toBuildpackType == BuildpackType.system); // Default value for unknown strings is "system"
  assert("unknown".toBuildpackType == BuildpackType.system); // Default value for unknown strings is "system"

  assert(BuildpackType.system.toString == "system");
  assert(BuildpackType.custom.toString == "custom");

  assert([BuildpackType.system, BuildpackType.custom].toStrings == ["system", "custom"]);
  assert(["system", "custom"].toBuildpackTypes == [BuildpackType.system, BuildpackType.custom]);
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
HealthCheckType[] toHealthCheckTypes(string[] values) {
  return values.map!(toHealthCheckType).array;
}
string toString(HealthCheckType value) {
  return value.to!string;
}
string[] toStrings(HealthCheckType[] values) {
  return values.map!toString.array;
}
///
unittest {
  mixin(ShowTest!("HealthCheckType"));

  assert("http".toHealthCheckType == HealthCheckType.http);
  assert("port".toHealthCheckType == HealthCheckType.port);
  assert("process".toHealthCheckType == HealthCheckType.process);

  assert("".toHealthCheckType == HealthCheckType.http); // Default value for unknown strings is "http"
  assert("unknown".toHealthCheckType == HealthCheckType.http); // Default value for unknown strings is "http"

  assert(HealthCheckType.http.toString == "http");
  assert(HealthCheckType.port.toString == "port");
  assert(HealthCheckType.process.toString == "process");

  assert([HealthCheckType.http, HealthCheckType.port, HealthCheckType.process].toStrings == ["http", "port", "process"]);
  assert(["http", "port", "process"].toHealthCheckTypes == [HealthCheckType.http, HealthCheckType.port, HealthCheckType.process]);
}
