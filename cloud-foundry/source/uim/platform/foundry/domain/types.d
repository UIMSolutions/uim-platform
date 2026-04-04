/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.domain.types;

/// Unique identifier type aliases for type safety.
alias OrgId = string;
alias SpaceId = string;
alias AppId = string;
alias ServiceInstanceId = string;
alias ServiceBindingId = string;
alias RouteId = string;
alias DomainId = string;
alias BuildpackId = string;
alias TenantId = string;
alias UserId = string;

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
enum DomainScope {
  shared_,
  private_,
  internal_,
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
