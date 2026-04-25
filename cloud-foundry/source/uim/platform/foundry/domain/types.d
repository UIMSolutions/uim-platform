/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.domain.types;

import uim.platform.foundry;

mixin(ShowModule!());

@safe:
/// Unique identifier type aliases for type safety.
struct OrgId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct SpaceId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct AppId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct ServiceInstanceId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct ServiceBindingId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct RouteId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct CfDomainId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct BuildpackId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

/// Organization lifecycle status.
enum OrgStatus {
  active,
  suspended,
}

OrgStatus parseOrgStatus(string status) {
  switch (status) {
  case "active":
    return OrgStatus.active;
  case "suspended":
    return OrgStatus.suspended;
  default:
    return OrgStatus.active;
  }
}

/// Space lifecycle status.
enum SpaceStatus {
  active,
  suspended,
}

SpaceStatus parseSpaceStatus(string status) {
  switch (status) {
  case "active":
    return SpaceStatus.active;
  case "suspended":
    return SpaceStatus.suspended;
  default:
    return SpaceStatus.active;
  }
}

/// Application runtime state.
enum AppState {
  stopped,
  started,
  staging,
  crashed,
}

AppState parseAppState(string state) {
  switch (state) {
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

RouteProtocol parseRouteProtocol(string s) {
  switch (s) {
  case "http":
    return RouteProtocol.http;
  case "tcp":
    return RouteProtocol.tcp;
  default:
    return RouteProtocol.http;
  }
}

/// Domain ownership scope.
enum DomainScope {
  shared_,
  private_,
  internal_,
}

DomainScope parseDomainScope(string scope_) {
  switch (scope_) {
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
/// Buildpack origin type.
enum BuildpackType {
  system,
  custom,
}

BuildpackType parseBuildpackType(string s) {
  switch (s) {
  case "system":
    return BuildpackType.system;
  case "custom":
    return BuildpackType.custom;
  default:
    return BuildpackType.system;
  }
}

/// Application health check strategy.
enum HealthCheckType {
  http,
  port,
  process,
}

HealthCheckType parseHealthCheckType(string s) {
  switch (s) {
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
