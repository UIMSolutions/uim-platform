/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.domain.types;
import uim.platform.abap_environment;

mixin(ShowModule!());

@safe:
/// Unique identifier type aliases for type safety.
struct SystemInstanceId  {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}
struct SoftwareComponentId  {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}
struct CommunicationArrangementId  {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}
struct ServiceBindingId  {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}
struct BusinessUserId  {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}
struct BusinessRoleId  {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}
struct TransportRequestId  {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}
struct TransportTaskId  {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}
struct ApplicationJobId  {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}
struct SubaccountId  {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}
struct ServiceDefinitionId  {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}
struct CommunicationScenarioId  {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

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
  active,
  provisioning,
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
  inbound, // default
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
  basicAuthentication, // default
  oauth2ClientCredentials,    
  oauth2SAMLBearerAssertion,  
  clientCertificate,
  noAuthentication // 
}

/// Status of a communication arrangement.
enum ArrangementStatus {
  active, // default
  inactive, 
  error
}

// ─── Service Binding ───

/// Binding type for service exposure.
enum BindingType {
  odataV2, // default
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
