/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_enviroment.domain.types;

/// Unique identifier type aliases for type safety.
alias SystemInstanceId = string;
alias SoftwareComponentId = string;
alias CommunicationArrangementId = string;
alias ServiceBindingId = string;
alias BusinessUserId = string;
alias BusinessRoleId = string;
alias TransportRequestId = string;
alias ApplicationJobId = string;
alias TenantId = string;
alias SubaccountId = string;
alias ServiceDefinitionId = string;
alias CommunicationScenarioId = string;

// ─── System Instance ───

/// ABAP system provisioning plan.
enum SystemPlan {
  standard,
  free_,
  development,
  test,
  production,
}

/// Lifecycle status of an ABAP system instance.
enum SystemStatus {
  provisioning,
  active,
  updating,
  suspended,
  deleting,
  deleted,
  error,
}

/// Software component type.
enum ComponentType {
  developmentPackage,
  businessConfiguration,
  extensibility,
  customCode,
}

/// Status of a software component clone / pull.
enum ComponentStatus {
  notCloned,
  cloning,
  cloned,
  pulling,
  error,
}

/// Branch strategy for a software component.
enum BranchStrategy {
  main,
  release,
  feature,
  correction,
}

// ─── Communication ───

/// Communication direction.
enum CommunicationDirection {
  inbound,
  outbound,
}

/// Communication protocol.
enum CommunicationProtocol {
  httpRest,
  httpSoap,
  rfc,
  odataV2,
  odataV4,
}

/// Authentication method used in communication arrangements.
enum CommunicationAuthMethod {
  basicAuthentication,
  oauth2ClientCredentials,
  oauth2SAMLBearerAssertion,
  clientCertificate,
  noAuthentication,
}

/// Status of a communication arrangement.
enum ArrangementStatus {
  active,
  inactive,
  error,
}

// ─── Service Binding ───

/// Binding type for service exposure.
enum BindingType {
  odataV2,
  odataV4,
  soapHttp,
  restHttp,
  sql,
  inboundRfc,
}

/// Status of a service binding.
enum BindingStatus {
  active,
  inactive,
  deprecated_,
}

// ─── Users and Roles ───

/// Business user status.
enum UserStatus {
  active,
  inactive,
  locked,
  passwordLocked,
}

/// Business role type.
enum RoleType {
  unrestricted,
  restricted,
  custom,
}

// ─── Transport Management ───

/// Transport request type (CTS-like).
enum TransportType {
  workbench,
  customizing,
  transportOfCopies,
}

/// Transport request status.
enum TransportStatus {
  modifiable,
  released,
  imported,
  error,
}

// ─── Application Jobs ───

/// Job scheduling frequency.
enum JobFrequency {
  once,
  hourly,
  daily,
  weekly,
  monthly,
}

/// Application job execution status.
enum JobStatus {
  scheduled,
  running,
  completed,
  failed,
  canceled,
}
