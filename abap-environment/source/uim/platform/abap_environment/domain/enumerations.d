module uim.platform.abap_environment.domain.enumerations;

import uim.platform.abap_environment;

// mixin(ShowModule!());

@safe:

// ─── System Instance ───
/// ABAP system provisioning plan.
enum SystemPlan : string {
  standard = "standard", // Standard plan with full features and capabilities.
  free_ = "free", // Free plan with limited features and capabilities, suitable for small-scale or personal use.
  development = "development", // Development plan for testing and development purposes, with limited features and capabilities.
  test = "test", // Test plan for testing purposes, with limited features and capabilities.
  production = "production", // Production plan for production use, with full features and capabilities.
}

SystemPlan toSystemPlan(string plan) {
  switch (plan.toLower) {
  case "standard":
    return SystemPlan.standard;
  case "free":
    return SystemPlan.free_;
  case "development":
    return SystemPlan.development;
  case "test":
    return SystemPlan.test;
  case "production":
    return SystemPlan.production;
  default:
    return SystemPlan.standard; // default case
  }
}

SystemPlan[] toSystemPlans(string[] plans) {
  return plans.map!(p => toSystemPlan(p)).array;
}

string toString(SystemPlan plan) {
  final switch (plan) {
  case SystemPlan.standard:
    return "standard";
  case SystemPlan.free_:
    return "free";
  case SystemPlan.development:
    return "development";
  case SystemPlan.test:
    return "test";
  case SystemPlan.production:
    return "production";
  }
}

string[] toStrings(SystemPlan[] plans) {
  return plans.map!(p => toString(p)).array;
}
/// 
unittest {
  mixin(ShowTest!("SystemPlan Enumeration"));

  assert("standard".toSystemPlan == SystemPlan.standard);
  assert("free".toSystemPlan == SystemPlan.free_);
  assert("development".toSystemPlan == SystemPlan.development);
  assert("test".toSystemPlan == SystemPlan.test);
  assert("production".toSystemPlan == SystemPlan.production);
  assert("unknown".toSystemPlan == SystemPlan.standard); // default case

  assert(SystemPlan.standard.toString == "standard");
  assert(SystemPlan.free_.toString == "free");
  assert(SystemPlan.development.toString == "development");
  assert(SystemPlan.test.toString == "test");
  assert(SystemPlan.production.toString == "production");

  assert(toSystemPlans(["standard", "free", "unknown"]) == [
      SystemPlan.standard, SystemPlan.free_, SystemPlan.standard
    ]);
  assert(toStrings([SystemPlan.standard, SystemPlan.free_]) == [
      "standard", "free"
    ]);
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

SystemStatus toSystemStatus(string value) {
  mixin(EnumSwitch("SystemStatus", "active"));
}

SystemStatus[] toSystemStatuses(string[] values) {
  return values.map!toSystemStatus.array;
}

string toString(SystemStatus status) {
  return status.to!string;
}

string[] toStrings(SystemStatus[] statuses) {
  return statuses.map!toString.array;
}
/// 
unittest {
  mixin(ShowTest!("SystemStatus Enumeration"));

  assert("active".toSystemStatus == SystemStatus.active);
  assert("provisioning".toSystemStatus == SystemStatus.provisioning);
  assert("updating".toSystemStatus == SystemStatus.updating);
  assert("suspended".toSystemStatus == SystemStatus.suspended);
  assert("deleting".toSystemStatus == SystemStatus.deleting);
  assert("deleted".toSystemStatus == SystemStatus.deleted);
  assert("error".toSystemStatus == SystemStatus.error);
  assert("unknown".toSystemStatus == SystemStatus.active); // default case

  assert(SystemStatus.active.toString == "active");
  assert(SystemStatus.provisioning.toString == "provisioning");
  assert(SystemStatus.updating.toString == "updating");
  assert(SystemStatus.suspended.toString == "suspended");
  assert(SystemStatus.deleting.toString == "deleting");
  assert(SystemStatus.deleted.toString == "deleted");
  assert(SystemStatus.error.toString == "error");

  assert(["active", "provisioning", "unknown"].toSystemStatuses == [
      SystemStatus.active, SystemStatus.provisioning, SystemStatus.active
    ]);
  assert([SystemStatus.active, SystemStatus.error].toStrings == [
      "active", "error"
    ]);
}

/// Software component type.
enum ComponentType {
  developmentPackage,
  businessConfiguration,
  extensibility,
  customCode,
}

ComponentType toComponentType(string value) {
  mixin(EnumSwitch("ComponentType", "developmentPackage"));
}

ComponentType[] toComponentTypes(string[] values) {
  return values.map!(v => toComponentType(v)).array;
}

string toString(ComponentType type) {
  return type.to!string;
}

string[] toStrings(ComponentType[] types) {
  return types.map!toString.array;
}
///
unittest {
  mixin(ShowTest!("ComponentType Enumeration"));

  assert("developmentPackage".toComponentType == ComponentType.developmentPackage);
  assert("businessConfiguration".toComponentType == ComponentType.businessConfiguration);
  assert("extensibility".toComponentType == ComponentType.extensibility);
  assert("customCode".toComponentType == ComponentType.customCode);
  assert("unknown".toComponentType == ComponentType.developmentPackage); // default case

  assert(ComponentType.developmentPackage.toString == "developmentPackage");
  assert(ComponentType.businessConfiguration.toString == "businessConfiguration");
  assert(ComponentType.extensibility.toString == "extensibility");
  assert(ComponentType.customCode.toString == "customCode");

  assert(toComponentTypes(["developmentPackage", "extensibility", "unknown"]) == [
      ComponentType.developmentPackage, ComponentType.extensibility,
      ComponentType.developmentPackage
    ]);
  assert(toStrings([
      ComponentType.businessConfiguration, ComponentType.customCode
    ]) == ["businessConfiguration", "customCode"]);
}

/// Status of a software component clone / pull.
enum ComponentStatus {
  notCloned,
  cloning,
  cloned,
  pulling,
  error,
}

ComponentStatus toComponentStatus(string value) {
  mixin(EnumSwitch("ComponentStatus", "notCloned"));
}

ComponentStatus[] toComponentStatuses(string[] values) {
  return values.map!(v => toComponentStatus(v)).array;
}

string toString(ComponentStatus status) {
  return status.to!string;
}

string[] toStrings(ComponentStatus[] statuses) {
  return statuses.map!toString.array;
}
///
unittest {
  mixin(ShowTest!("ComponentStatus Enumeration"));

  assert("notCloned".toComponentStatus == ComponentStatus.notCloned);
  assert("cloning".toComponentStatus == ComponentStatus.cloning);
  assert("cloned".toComponentStatus == ComponentStatus.cloned);
  assert("pulling".toComponentStatus == ComponentStatus.pulling);
  assert("error".toComponentStatus == ComponentStatus.error);
  assert("unknown".toComponentStatus == ComponentStatus.notCloned); // default case  

  assert(ComponentStatus.notCloned.toString == "notCloned");
  assert(ComponentStatus.cloning.toString == "cloning");
  assert(ComponentStatus.cloned.toString == "cloned");
  assert(ComponentStatus.pulling.toString == "pulling");
  assert(ComponentStatus.error.toString == "error");

  assert(["notCloned", "cloning", "unknown"].toComponentStatuses == [
      ComponentStatus.notCloned, ComponentStatus.cloning,
      ComponentStatus.notCloned
    ]);
  assert([ComponentStatus.cloned, ComponentStatus.error].toStrings == [
      "cloned", "error"
    ]);
}

/// Branch strategy for a software component.
enum BranchStrategy {
  main,
  release,
  feature,
  correction,
}

BranchStrategy toBranchStrategy(string value) {
  mixin(EnumSwitch("BranchStrategy", "main"));
}

BranchStrategy[] toBranchStrategies(string[] values) {
  return values.map!(v => toBranchStrategy(v)).array;
}

string toString(BranchStrategy strategy) {
  return strategy.to!string;
}

string[] toStrings(BranchStrategy[] strategies) {
  return strategies.map!toString.array;
}
///
unittest {
  mixin(ShowTest!("BranchStrategy Enumeration"));

  assert("main".toBranchStrategy == BranchStrategy.main);
  assert("release".toBranchStrategy == BranchStrategy.release);
  assert("feature".toBranchStrategy == BranchStrategy.feature);
  assert("correction".toBranchStrategy == BranchStrategy.correction);
  assert("unknown".toBranchStrategy == BranchStrategy.main); // default case

  assert(BranchStrategy.main.toString == "main");
  assert(BranchStrategy.release.toString == "release");
  assert(BranchStrategy.feature.toString == "feature");
  assert(BranchStrategy.correction.toString == "correction");

  assert(["main", "feature", "unknown"].toBranchStrategies == [
      BranchStrategy.main, BranchStrategy.feature, BranchStrategy.main
    ]);
  assert([BranchStrategy.release, BranchStrategy.correction].toStrings == [
      "release", "correction"
    ]);
}

// ─── Communication ───
/// Communication direction.
enum CommunicationDirection {
  inbound, // default
  outbound,
}

CommunicationDirection toCommunicationDirection(string value) {
  mixin(EnumSwitch("CommunicationDirection", "inbound"));
}

CommunicationDirection[] toCommunicationDirections(string[] values) {
  return values.map!(v => toCommunicationDirection(v)).array;
}

string toString(CommunicationDirection direction) {
  return direction.to!string;
}

string[] toStrings(CommunicationDirection[] directions) {
  return directions.map!(d => toString(d)).array;
}
///
unittest {
  mixin(ShowTest!("CommunicationDirection Enumeration"));

  assert("inbound".toCommunicationDirection == CommunicationDirection.inbound);
  assert("outbound".toCommunicationDirection == CommunicationDirection.outbound);
  assert("unknown".toCommunicationDirection == CommunicationDirection.inbound); // default case  

  assert(CommunicationDirection.inbound.toString == "inbound");
  assert(CommunicationDirection.outbound.toString == "outbound");

  assert(["inbound", "outbound", "unknown"].toCommunicationDirections == [
      CommunicationDirection.inbound, CommunicationDirection.outbound,
      CommunicationDirection.inbound
    ]);
  assert([CommunicationDirection.inbound, CommunicationDirection.outbound].toStrings == ["inbound", "outbound"]);
}

/// Communication protocol.
enum CommunicationProtocol {
  httpRest,
  httpSoap,
  rfc,
  odataV2,
  odataV4,
}

CommunicationProtocol toCommunicationProtocol(string value) {
  mixin(EnumSwitch("CommunicationProtocol", "httpRest"));
}

CommunicationProtocol[] toCommunicationProtocols(string[] values) {
  return values.map!(v => toCommunicationProtocol(v)).array;
}

string toString(CommunicationProtocol protocol) {
  return protocol.to!string;
}

string[] toStrings(CommunicationProtocol[] protocols) {
  return protocols.map!(p => toString(p)).array;
}
///
unittest {
  mixin(ShowTest!("CommunicationProtocol Enumeration"));

  assert("httpRest".toCommunicationProtocol == CommunicationProtocol.httpRest);
  assert("httpSoap".toCommunicationProtocol == CommunicationProtocol.httpSoap);
  assert("rfc".toCommunicationProtocol == CommunicationProtocol.rfc);
  assert("odataV2".toCommunicationProtocol == CommunicationProtocol.odataV2);
  assert("odataV4".toCommunicationProtocol == CommunicationProtocol.odataV4);
  assert("unknown".toCommunicationProtocol == CommunicationProtocol.httpRest); // default case

  assert(CommunicationProtocol.httpRest.toString == "httpRest");
  assert(CommunicationProtocol.httpSoap.toString == "httpSoap");
  assert(CommunicationProtocol.rfc.toString == "rfc");
  assert(CommunicationProtocol.odataV2.toString == "odataV2");
  assert(CommunicationProtocol.odataV4.toString == "odataV4");

  assert(["httpRest", "rfc", "unknown"].toCommunicationProtocols == [
      CommunicationProtocol.httpRest, CommunicationProtocol.rfc,
      CommunicationProtocol.httpRest
    ]);
  assert([CommunicationProtocol.httpSoap, CommunicationProtocol.odataV2].toStrings == ["httpSoap", "odataV2"]);
}

/// Authentication method used in communication arrangements.
enum CommunicationAuthMethod {
  basicAuthentication, // default
  oauth2ClientCredentials,
  oauth2SAMLBearerAssertion,
  clientCertificate,
  noAuthentication // 
}

CommunicationAuthMethod toCommunicationAuthMethod(string value) {
  mixin(EnumSwitch("CommunicationAuthMethod", "basicAuthentication"));
}

CommunicationAuthMethod[] toCommunicationAuthMethods(string[] values) {
  return values.map!(v => toCommunicationAuthMethod(v)).array;
}

string toString(CommunicationAuthMethod method) {
  return method.to!string;
}

string[] toStrings(CommunicationAuthMethod[] methods) {
  return methods.map!(m => toString(m)).array;
}
///
unittest {
  mixin(ShowTest!("CommunicationAuthMethod Enumeration"));

  assert("basicAuthentication".toCommunicationAuthMethod == CommunicationAuthMethod.basicAuthentication);
  assert("oauth2ClientCredentials".toCommunicationAuthMethod == CommunicationAuthMethod.oauth2ClientCredentials);
  assert("oauth2SAMLBearerAssertion".toCommunicationAuthMethod == CommunicationAuthMethod.oauth2SAMLBearerAssertion);
  assert("clientCertificate".toCommunicationAuthMethod == CommunicationAuthMethod.clientCertificate);
  assert("noAuthentication".toCommunicationAuthMethod == CommunicationAuthMethod.noAuthentication);
  assert("unknown".toCommunicationAuthMethod == CommunicationAuthMethod.basicAuthentication); // default case

  assert(CommunicationAuthMethod.basicAuthentication.toString == "basicAuthentication");
  assert(CommunicationAuthMethod.oauth2ClientCredentials.toString == "oauth2ClientCredentials");
  assert(CommunicationAuthMethod.oauth2SAMLBearerAssertion.toString == "oauth2SAMLBearerAssertion");
  assert(CommunicationAuthMethod.clientCertificate.toString == "clientCertificate");
  assert(CommunicationAuthMethod.noAuthentication.toString == "noAuthentication");

  assert(["basicAuthentication", "clientCertificate", "unknown"].toCommunicationAuthMethods == [
    CommunicationAuthMethod.basicAuthentication,
    CommunicationAuthMethod.clientCertificate,
    CommunicationAuthMethod.basicAuthentication
  ]);
  assert([CommunicationAuthMethod.oauth2ClientCredentials,
      CommunicationAuthMethod.noAuthentication].toStrings == ["oauth2ClientCredentials", "noAuthentication"]);
}

/// Status of a communication arrangement.
enum ArrangementStatus {
  active, // default
  inactive,
  error
}

ArrangementStatus toArrangementStatus(string value) {
  mixin(EnumSwitch("ArrangementStatus", "active"));
}

ArrangementStatus[] toArrangementStatuses(string[] values) {
  return values.map!(v => toArrangementStatus(v)).array;
}

string toString(ArrangementStatus status) {
  return status.to!string;
}

string[] toStrings(ArrangementStatus[] statuses) {
  return statuses.map!toString.array;
}
///
unittest {
  mixin(ShowTest!("ArrangementStatus Enumeration"));

  assert("active".toArrangementStatus == ArrangementStatus.active);
  assert("inactive".toArrangementStatus == ArrangementStatus.inactive);
  assert("error".toArrangementStatus == ArrangementStatus.error);
  assert("unknown".toArrangementStatus == ArrangementStatus.active); // default case

  assert(ArrangementStatus.active.toString == "active");
  assert(ArrangementStatus.inactive.toString == "inactive");
  assert(ArrangementStatus.error.toString == "error");

  assert(["active", "inactive", "unknown"].toArrangementStatuses == [
      ArrangementStatus.active, ArrangementStatus.inactive,
      ArrangementStatus.active
    ]);
  assert([ArrangementStatus.active, ArrangementStatus.error].toStrings == [
      "active", "error"
    ]);
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

BindingType toBindingType(string value) {
  mixin(EnumSwitch("BindingType", "odataV4"));
}

BindingType[] toBindingTypes(string[] values) {
  return values.map!(v => toBindingType(v)).array;
}

string toString(BindingType type) {
  return type.to!string;
}

string[] toStrings(BindingType[] types) {
  return types.map!toString.array;
}
///
unittest {
  mixin(ShowTest!("BindingType Enumeration"));

  assert("odataV4".toBindingType == BindingType.odataV4);
  assert("odataV2".toBindingType == BindingType.odataV2);
  assert("soapHttp".toBindingType == BindingType.soapHttp);
  assert("restHttp".toBindingType == BindingType.restHttp);
  assert("sql".toBindingType == BindingType.sql);
  assert("inboundRfc".toBindingType == BindingType.inboundRfc);
  assert("unknown".toBindingType == BindingType.odataV4); // default case

  assert(BindingType.odataV4.toString == "odataV4");
  assert(BindingType.odataV2.toString == "odataV2");
  assert(BindingType.soapHttp.toString == "soapHttp");
  assert(BindingType.restHttp.toString == "restHttp");
  assert(BindingType.sql.toString == "sql");
  assert(BindingType.inboundRfc.toString == "inboundRfc");

  assert(["odataV4", "restHttp", "unknown"].toBindingTypes == [
      BindingType.odataV4, BindingType.restHttp, BindingType.odataV4
    ]);
  assert([BindingType.soapHttp, BindingType.sql].toStrings == [
      "soapHttp", "sql"
    ]);
}

/// Status of a service binding.
enum BindingStatus : string {
  active = "active",
  inactive = "inactive",
  deprecated_ = "deprecated",
}

BindingStatus toBindingStatus(string value) {
  switch (value.toLower) {
  case "active":
    return BindingStatus.active;
  case "inactive":
    return BindingStatus.inactive;
  case "deprecated":
    return BindingStatus.deprecated_;
  default:
    return BindingStatus.active; // default case
  }
}

BindingStatus[] toBindingStatuses(string[] values) {
  return values.map!(v => toBindingStatus(v)).array;
}

string toString(BindingStatus status) {
  return cast(string)status;
}

string[] toStrings(BindingStatus[] statuses) {
  return statuses.map!toString.array;
}
/// 
unittest {
  mixin(ShowTest!("BindingStatus Enumeration"));

  assert("active".toBindingStatus == BindingStatus.active);
  assert("inactive".toBindingStatus == BindingStatus.inactive);
  assert("deprecated".toBindingStatus == BindingStatus.deprecated_);
  assert("unknown".toBindingStatus == BindingStatus.active); // default case

  assert(BindingStatus.active.toString == "active");
  assert(BindingStatus.inactive.toString == "inactive");
  assert(BindingStatus.deprecated_.toString == "deprecated");

  assert(["active", "deprecated", "unknown"].toBindingStatuses == [
      BindingStatus.active, BindingStatus.deprecated_, BindingStatus.active
    ]);
  assert([BindingStatus.inactive, BindingStatus.deprecated_].toStrings == [
      "inactive", "deprecated"
    ]);
}
// ─── Users and Roles ───
/// Business user status.
enum UserStatus {
  active,
  inactive,
  locked,
  passwordLocked,
}

UserStatus toUserStatus(string value) {
  mixin(EnumSwitch("UserStatus", "active"));
}

UserStatus[] toUserStatuses(string[] values) {
  return values.map!toUserStatus.array;
}

string toString(UserStatus status) {
  return status.to!string;
}

string[] toStrings(UserStatus[] statuses) {
  return statuses.map!toString.array;
}
/// 
unittest {
  mixin(ShowTest!("UserStatus Enumeration"));

  assert("active".toUserStatus == UserStatus.active);
  assert("inactive".toUserStatus == UserStatus.inactive);
  assert("locked".toUserStatus == UserStatus.locked);
  assert("passwordLocked".toUserStatus == UserStatus.passwordLocked);
  assert("unknown".toUserStatus == UserStatus.active); // default case

  assert(UserStatus.active.toString == "active");
  assert(UserStatus.inactive.toString == "inactive");
  assert(UserStatus.locked.toString == "locked");
  assert(UserStatus.passwordLocked.toString == "passwordLocked");

  assert(["active", "locked", "unknown"].toUserStatuses == [
      UserStatus.active, UserStatus.locked, UserStatus.active
    ]);
  assert([UserStatus.inactive, UserStatus.passwordLocked].toStrings == [
      "inactive", "passwordLocked"
    ]);
}

/// Business role type.
enum RoleType {
  unrestricted,
  restricted,
  custom,
}

RoleType toRoleType(string value) {
  mixin(EnumSwitch("RoleType", "unrestricted"));
}

RoleType[] toRoleTypes(string[] values) {
  return values.map!toRoleType.array;
}

string toString(RoleType type) {
  return type.to!string;
}

string[] toStrings(RoleType[] types) {
  return types.map!toString.array;
}
///
unittest {
  mixin(ShowTest!("RoleType Enumeration"));

  assert("unrestricted".toRoleType == RoleType.unrestricted);
  assert("restricted".toRoleType == RoleType.restricted);
  assert("custom".toRoleType == RoleType.custom);
  assert("unknown".toRoleType == RoleType.unrestricted); // default case

  assert(RoleType.unrestricted.toString == "unrestricted");
  assert(RoleType.restricted.toString == "restricted");
  assert(RoleType.custom.toString == "custom");

  assert(["unrestricted", "custom", "unknown"].toRoleTypes == [
      RoleType.unrestricted, RoleType.custom, RoleType.unrestricted
    ]);
  assert([RoleType.restricted, RoleType.custom].toStrings == [
      "restricted", "custom"
    ]);
}

// ─── Transport Management ───
/// Transport request type (CTS-like).
enum TransportType {
  workbench,
  customizing,
  transportOfCopies,
}

TransportType toTransportType(string value) {
  mixin(EnumSwitch("TransportType", "workbench"));
}

TransportType[] toTransportTypes(string[] values) {
  return values.map!toTransportType.array;
}

string toString(TransportType type) {
  return type.to!string;
}

string[] toStrings(TransportType[] types) {
  return types.map!toString.array;
}
/// 
unittest {
  mixin(ShowTest!("TransportType Enumeration"));

  assert("workbench".toTransportType == TransportType.workbench);
  assert("customizing".toTransportType == TransportType.customizing);
  assert("transportOfCopies".toTransportType == TransportType.transportOfCopies);
  assert("unknown".toTransportType == TransportType.workbench); // default case

  assert(TransportType.workbench.toString == "workbench");
  assert(TransportType.customizing.toString == "customizing");
  assert(TransportType.transportOfCopies.toString == "transportOfCopies");

  assert(["workbench", "customizing", "unknown"].toTransportTypes == [
      TransportType.workbench, TransportType.customizing,
      TransportType.workbench
    ]);
  assert([TransportType.workbench, TransportType.transportOfCopies].toStrings == [
      "workbench", "transportOfCopies"
    ]);
}

/// Transport request status.
enum TransportStatus {
  modifiable,
  released,
  imported,
  error,
}

TransportStatus toTransportStatus(string value) {
  mixin(EnumSwitch("TransportStatus", "modifiable"));
}

TransportStatus[] toTransportStatuses(string[] values) {
  return values.map!(v => toTransportStatus(v)).array;
}

string toString(TransportStatus status) {
  return status.to!string;
}

string[] toStrings(TransportStatus[] statuses) {
  return statuses.map!toString.array;
}
///
unittest {
  mixin(ShowTest!("TransportStatus Enumeration"));

  assert("modifiable".toTransportStatus == TransportStatus.modifiable);
  assert("released".toTransportStatus == TransportStatus.released);
  assert("imported".toTransportStatus == TransportStatus.imported);
  assert("error".toTransportStatus == TransportStatus.error);
  assert("unknown".toTransportStatus == TransportStatus.modifiable); // default case

  assert(TransportStatus.modifiable.toString == "modifiable");
  assert(TransportStatus.released.toString == "released");
  assert(TransportStatus.imported.toString == "imported");
  assert(TransportStatus.error.toString == "error");

  assert(["modifiable", "released", "unknown"].toTransportStatuses == [
      TransportStatus.modifiable, TransportStatus.released,
      TransportStatus.modifiable
    ]);
  assert([TransportStatus.imported, TransportStatus.error].toStrings == [
      "imported", "error"
    ]);
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

JobFrequency toJobFrequency(string value) {
  mixin(EnumSwitch("JobFrequency", "once"));
}

JobFrequency[] toJobFrequencies(string[] values) {
  return values.map!(v => toJobFrequency(v)).array;
}

string toString(JobFrequency frequency) {
  return frequency.to!string;
}

string[] toStrings(JobFrequency[] frequencies) {
  return frequencies.map!(f => toString(f)).array;
}
///
unittest {
  mixin(ShowTest!("JobFrequency Enumeration"));

  assert("once".toJobFrequency == JobFrequency.once);
  assert("hourly".toJobFrequency == JobFrequency.hourly);
  assert("daily".toJobFrequency == JobFrequency.daily);
  assert("weekly".toJobFrequency == JobFrequency.weekly);
  assert("monthly".toJobFrequency == JobFrequency.monthly);
  assert("unknown".toJobFrequency == JobFrequency.once); // default case

  assert(JobFrequency.once.toString == "once");
  assert(JobFrequency.hourly.toString == "hourly");
  assert(JobFrequency.daily.toString == "daily");
  assert(JobFrequency.weekly.toString == "weekly");
  assert(JobFrequency.monthly.toString == "monthly");

  assert(["once", "daily", "unknown"].toJobFrequencies == [
      JobFrequency.once, JobFrequency.daily, JobFrequency.once
    ]);
  assert(toStrings([JobFrequency.hourly, JobFrequency.weekly]) == [
      "hourly", "weekly"
    ]);
}

/// Application job execution status.
enum JobStatus {
  scheduled,
  running,
  completed,
  failed,
  canceled,
}

JobStatus toJobStatus(string value) {
  mixin(EnumSwitch("JobStatus", "scheduled"));
}

JobStatus[] toJobStatuses(string[] values) {
  return values.map!(v => toJobStatus(v)).array;
}

string toString(JobStatus status) {
  return status.to!string;
}

string[] toStrings(JobStatus[] statuses) {
  return statuses.map!toString.array;
}
///
unittest {
  mixin(ShowTest!("JobStatus Enumeration"));

  assert("scheduled".toJobStatus == JobStatus.scheduled);
  assert("running".toJobStatus == JobStatus.running);
  assert("completed".toJobStatus == JobStatus.completed);
  assert("failed".toJobStatus == JobStatus.failed);
  assert("canceled".toJobStatus == JobStatus.canceled);
  assert("unknown".toJobStatus == JobStatus.scheduled); // default case

  assert(JobStatus.scheduled.toString == "scheduled");
  assert(JobStatus.running.toString == "running");
  assert(JobStatus.completed.toString == "completed");
  assert(JobStatus.failed.toString == "failed");
  assert(JobStatus.canceled.toString == "canceled");

  assert(["scheduled", "running", "unknown"].toJobStatuses == [
      JobStatus.scheduled, JobStatus.running, JobStatus.scheduled
    ]);
  assert([JobStatus.completed, JobStatus.failed].toStrings == [
      "completed", "failed"
    ]);
}
