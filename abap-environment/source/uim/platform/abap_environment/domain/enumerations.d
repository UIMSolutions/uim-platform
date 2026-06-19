module uim.platform.abap_environment.domain.enumerations;

import uim.platform.abap_environment;

// // mixin(ShowModule!());

@safe:

// ─── System Instance ───
/// ABAP system provisioning plan.
enum SystemPlan {
  standard,
  free_,
  development,
  test,
  production,
}

SystemPlan toSystemPlan(string plan) {
  const map = [
    "standard": SystemPlan.standard,
    "free": SystemPlan.free_,
    "development": SystemPlan.development,
    "test": SystemPlan.test,
    "production": SystemPlan.production,
  ];
  return map.get(plan.toLower, SystemPlan.standard);
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

SystemStatus toSystemStatus(string status) {
  switch (status.toLower) {
    static foreach (member; __traits(allMembers, SystemStatus)) {
  case member:
      return __traits(getMember, SystemStatus, member);
    }
  default:
    return SystemStatus.provisioning;
  }
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
  odataV4,
  odataV2,
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
