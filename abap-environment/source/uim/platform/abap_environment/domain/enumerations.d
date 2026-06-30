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

SystemPlan[] toSystemPlan(string[] plans) {
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

string[] toString(SystemPlan[] plans) {
  return plans.map!(p => toString(p)).array;
}
/// 
unittest {
  mixin(ShowTest!("SystemPlan Enumeration"));

  assert(toSystemPlan("standard") == SystemPlan.standard);
  assert(toSystemPlan("free") == SystemPlan.free_);
  assert(toSystemPlan("development") == SystemPlan.development);
  assert(toSystemPlan("test") == SystemPlan.test);
  assert(toSystemPlan("production") == SystemPlan.production);
  assert(toSystemPlan("unknown") == SystemPlan.standard); // default case

  assert(toString(SystemPlan.standard) == "standard");
  assert(toString(SystemPlan.free_) == "free");
  assert(toString(SystemPlan.development) == "development");
  assert(toString(SystemPlan.test) == "test");
  assert(toString(SystemPlan.production) == "production");

  assert(toSystemPlan(["standard", "free", "unknown"]) == [
      SystemPlan.standard, SystemPlan.free_, SystemPlan.standard
    ]);
  assert(toString([SystemPlan.standard, SystemPlan.free_]) == [
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

SystemStatus[] toSystemStatus(string[] values) {
  return values.map!(v => toSystemStatus(v)).array;
}

string toString(SystemStatus status) {
  return status.to!string;
}

string[] toString(SystemStatus[] statuses) {
  return statuses.map!(s => toString(s)).array;
}
/// 
unittest {
  mixin(ShowTest!("SystemStatus Enumeration"));

  assert(toSystemStatus("active") == SystemStatus.active);
  assert(toSystemStatus("provisioning") == SystemStatus.provisioning);
  assert(toSystemStatus("updating") == SystemStatus.updating);
  assert(toSystemStatus("suspended") == SystemStatus.suspended);
  assert(toSystemStatus("deleting") == SystemStatus.deleting);
  assert(toSystemStatus("deleted") == SystemStatus.deleted);
  assert(toSystemStatus("error") == SystemStatus.error);
  assert(toSystemStatus("unknown") == SystemStatus.active); // default case

  assert(toString(SystemStatus.active) == "active");
  assert(toString(SystemStatus.provisioning) == "provisioning");
  assert(toString(SystemStatus.updating) == "updating");
  assert(toString(SystemStatus.suspended) == "suspended");
  assert(toString(SystemStatus.deleting) == "deleting");
  assert(toString(SystemStatus.deleted) == "deleted");
  assert(toString(SystemStatus.error) == "error");

  assert(toSystemStatus(["active", "provisioning", "unknown"]) == [
      SystemStatus.active, SystemStatus.provisioning, SystemStatus.active
    ]);
  assert(toString([SystemStatus.active, SystemStatus.error]) == [
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

ComponentType[] toComponentType(string[] values) {
  return values.map!(v => toComponentType(v)).array;
}

string toString(ComponentType type) {
  return type.to!string;
}

string[] toString(ComponentType[] types) {
  return types.map!(t => toString(t)).array;
}
///
unittest {
  mixin(ShowTest!("ComponentType Enumeration"));

  assert(toComponentType("developmentPackage") == ComponentType.developmentPackage);
  assert(toComponentType("businessConfiguration") == ComponentType.businessConfiguration);
  assert(toComponentType("extensibility") == ComponentType.extensibility);
  assert(toComponentType("customCode") == ComponentType.customCode);
  assert(toComponentType("unknown") == ComponentType.developmentPackage); // default case

  assert(toString(ComponentType.developmentPackage) == "developmentPackage");
  assert(toString(ComponentType.businessConfiguration) == "businessConfiguration");
  assert(toString(ComponentType.extensibility) == "extensibility");
  assert(toString(ComponentType.customCode) == "customCode");

  assert(toComponentType(["developmentPackage", "extensibility", "unknown"]) == [
      ComponentType.developmentPackage, ComponentType.extensibility,
      ComponentType.developmentPackage
    ]);
  assert(toString([
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

ComponentStatus[] toComponentStatus(string[] values) {
  return values.map!(v => toComponentStatus(v)).array;
}

string toString(ComponentStatus status) {
  return status.to!string;
}

string[] toString(ComponentStatus[] statuses) {
  return statuses.map!(s => toString(s)).array;
}
///
unittest {
  mixin(ShowTest!("ComponentStatus Enumeration"));

  assert(toComponentStatus("notCloned") == ComponentStatus.notCloned);
  assert(toComponentStatus("cloning") == ComponentStatus.cloning);
  assert(toComponentStatus("cloned") == ComponentStatus.cloned);
  assert(toComponentStatus("pulling") == ComponentStatus.pulling);
  assert(toComponentStatus("error") == ComponentStatus.error);
  assert(toComponentStatus("unknown") == ComponentStatus.notCloned); // default case  

  assert(toString(ComponentStatus.notCloned) == "notCloned");
  assert(toString(ComponentStatus.cloning) == "cloning");
  assert(toString(ComponentStatus.cloned) == "cloned");
  assert(toString(ComponentStatus.pulling) == "pulling");
  assert(toString(ComponentStatus.error) == "error");

  assert(toComponentStatus(["notCloned", "cloning", "unknown"]) == [
      ComponentStatus.notCloned, ComponentStatus.cloning,
      ComponentStatus.notCloned
    ]);
  assert(toString([ComponentStatus.cloned, ComponentStatus.error]) == [
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

BranchStrategy[] toBranchStrategy(string[] values) {
  return values.map!(v => toBranchStrategy(v)).array;
}

string toString(BranchStrategy strategy) {
  return strategy.to!string;
}

string[] toString(BranchStrategy[] strategies) {
  return strategies.map!(s => toString(s)).array;
}
///
unittest {
  mixin(ShowTest!("BranchStrategy Enumeration"));

  assert(toBranchStrategy("main") == BranchStrategy.main);
  assert(toBranchStrategy("release") == BranchStrategy.release);
  assert(toBranchStrategy("feature") == BranchStrategy.feature);
  assert(toBranchStrategy("correction") == BranchStrategy.correction);
  assert(toBranchStrategy("unknown") == BranchStrategy.main); // default case

  assert(toString(BranchStrategy.main) == "main");
  assert(toString(BranchStrategy.release) == "release");
  assert(toString(BranchStrategy.feature) == "feature");
  assert(toString(BranchStrategy.correction) == "correction");

  assert(toBranchStrategy(["main", "feature", "unknown"]) == [
      BranchStrategy.main, BranchStrategy.feature, BranchStrategy.main
    ]);
  assert(toString([BranchStrategy.release, BranchStrategy.correction]) == [
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

CommunicationDirection[] toCommunicationDirection(string[] values) {
  return values.map!(v => toCommunicationDirection(v)).array;
}

string toString(CommunicationDirection direction) {
  return direction.to!string;
}

string[] toString(CommunicationDirection[] directions) {
  return directions.map!(d => toString(d)).array;
}
///
unittest {
  mixin(ShowTest!("CommunicationDirection Enumeration"));

  assert(toCommunicationDirection("inbound") == CommunicationDirection.inbound);
  assert(toCommunicationDirection("outbound") == CommunicationDirection.outbound);
  assert(toCommunicationDirection("unknown") == CommunicationDirection.inbound); // default case  

  assert(toString(CommunicationDirection.inbound) == "inbound");
  assert(toString(CommunicationDirection.outbound) == "outbound");

  assert(toCommunicationDirection(["inbound", "outbound", "unknown"]) == [
      CommunicationDirection.inbound, CommunicationDirection.outbound,
      CommunicationDirection.inbound
    ]);
  assert(toString([
      CommunicationDirection.inbound, CommunicationDirection.outbound
    ]) == ["inbound", "outbound"]);
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

CommunicationProtocol[] toCommunicationProtocol(string[] values) {
  return values.map!(v => toCommunicationProtocol(v)).array;
}

string toString(CommunicationProtocol protocol) {
  return protocol.to!string;
}

string[] toString(CommunicationProtocol[] protocols) {
  return protocols.map!(p => toString(p)).array;
}
///
unittest {
  mixin(ShowTest!("CommunicationProtocol Enumeration"));

  assert(toCommunicationProtocol("httpRest") == CommunicationProtocol.httpRest);
  assert(toCommunicationProtocol("httpSoap") == CommunicationProtocol.httpSoap);
  assert(toCommunicationProtocol("rfc") == CommunicationProtocol.rfc);
  assert(toCommunicationProtocol("odataV2") == CommunicationProtocol.odataV2);
  assert(toCommunicationProtocol("odataV4") == CommunicationProtocol.odataV4);
  assert(toCommunicationProtocol("unknown") == CommunicationProtocol.httpRest); // default case

  assert(toString(CommunicationProtocol.httpRest) == "httpRest");
  assert(toString(CommunicationProtocol.httpSoap) == "httpSoap");
  assert(toString(CommunicationProtocol.rfc) == "rfc");
  assert(toString(CommunicationProtocol.odataV2) == "odataV2");
  assert(toString(CommunicationProtocol.odataV4) == "odataV4");

  assert(toCommunicationProtocol(["httpRest", "rfc", "unknown"]) == [
      CommunicationProtocol.httpRest, CommunicationProtocol.rfc,
      CommunicationProtocol.httpRest
    ]);
  assert(toString([
      CommunicationProtocol.httpSoap, CommunicationProtocol.odataV2
    ]) == ["httpSoap", "odataV2"]);
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

CommunicationAuthMethod[] toCommunicationAuthMethod(string[] values) {
  return values.map!(v => toCommunicationAuthMethod(v)).array;
}

string toString(CommunicationAuthMethod method) {
  return method.to!string;
}

string[] toString(CommunicationAuthMethod[] methods) {
  return methods.map!(m => toString(m)).array;
}
///
unittest {
  mixin(ShowTest!("CommunicationAuthMethod Enumeration"));

  assert(toCommunicationAuthMethod(
      "basicAuthentication") == CommunicationAuthMethod.basicAuthentication);
  assert(toCommunicationAuthMethod(
      "oauth2ClientCredentials") == CommunicationAuthMethod.oauth2ClientCredentials);
  assert(toCommunicationAuthMethod(
      "oauth2SAMLBearerAssertion") == CommunicationAuthMethod.oauth2SAMLBearerAssertion);
  assert(toCommunicationAuthMethod(
      "clientCertificate") == CommunicationAuthMethod.clientCertificate);
  assert(toCommunicationAuthMethod("noAuthentication") == CommunicationAuthMethod
      .noAuthentication);
  assert(toCommunicationAuthMethod("unknown") == CommunicationAuthMethod.basicAuthentication); // default case

  assert(toString(CommunicationAuthMethod.basicAuthentication) == "basicAuthentication");
  assert(toString(CommunicationAuthMethod.oauth2ClientCredentials) == "oauth2ClientCredentials");
  assert(toString(
      CommunicationAuthMethod.oauth2SAMLBearerAssertion) == "oauth2SAMLBearerAssertion");
  assert(toString(CommunicationAuthMethod.clientCertificate) == "clientCertificate");
  assert(toString(CommunicationAuthMethod.noAuthentication) == "noAuthentication");

  assert(toCommunicationAuthMethod([
      "basicAuthentication", "clientCertificate", "unknown"
    ]) == [
    CommunicationAuthMethod.basicAuthentication,
    CommunicationAuthMethod.clientCertificate,
    CommunicationAuthMethod.basicAuthentication
  ]);
  assert(toString([
      CommunicationAuthMethod.oauth2ClientCredentials,
      CommunicationAuthMethod.noAuthentication
    ]) == ["oauth2ClientCredentials", "noAuthentication"]);
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

ArrangementStatus[] toArrangementStatus(string[] values) {
  return values.map!(v => toArrangementStatus(v)).array;
}

string toString(ArrangementStatus status) {
  return status.to!string;
}

string[] toString(ArrangementStatus[] statuses) {
  return statuses.map!(s => toString(s)).array;
}
///
unittest {
  mixin(ShowTest!("ArrangementStatus Enumeration"));

  assert(toArrangementStatus("active") == ArrangementStatus.active);
  assert(toArrangementStatus("inactive") == ArrangementStatus.inactive);
  assert(toArrangementStatus("error") == ArrangementStatus.error);
  assert(toArrangementStatus("unknown") == ArrangementStatus.active); // default case

  assert(toString(ArrangementStatus.active) == "active");
  assert(toString(ArrangementStatus.inactive) == "inactive");
  assert(toString(ArrangementStatus.error) == "error");

  assert(toArrangementStatus(["active", "inactive", "unknown"]) == [
      ArrangementStatus.active, ArrangementStatus.inactive,
      ArrangementStatus.active
    ]);
  assert(toString([ArrangementStatus.active, ArrangementStatus.error]) == [
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

BindingType[] toBindingType(string[] values) {
  return values.map!(v => toBindingType(v)).array;
}

string toString(BindingType type) {
  return type.to!string;
}

string[] toString(BindingType[] types) {
  return types.map!(t => toString(t)).array;
}
///
unittest {
  mixin(ShowTest!("BindingType Enumeration"));

  assert(toBindingType("odataV4") == BindingType.odataV4);
  assert(toBindingType("odataV2") == BindingType.odataV2);
  assert(toBindingType("soapHttp") == BindingType.soapHttp);
  assert(toBindingType("restHttp") == BindingType.restHttp);
  assert(toBindingType("sql") == BindingType.sql);
  assert(toBindingType("inboundRfc") == BindingType.inboundRfc);
  assert(toBindingType("unknown") == BindingType.odataV4); // default case

  assert(toString(BindingType.odataV4) == "odataV4");
  assert(toString(BindingType.odataV2) == "odataV2");
  assert(toString(BindingType.soapHttp) == "soapHttp");
  assert(toString(BindingType.restHttp) == "restHttp");
  assert(toString(BindingType.sql) == "sql");
  assert(toString(BindingType.inboundRfc) == "inboundRfc");

  assert(toBindingType(["odataV4", "restHttp", "unknown"]) == [
      BindingType.odataV4, BindingType.restHttp, BindingType.odataV4
    ]);
  assert(toString([BindingType.soapHttp, BindingType.sql]) == [
      "soapHttp", "sql"
    ]);
}

/// Status of a service binding.
enum BindingStatus {
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

BindingStatus[] toBindingStatus(string[] values) {
  return values.map!(v => toBindingStatus(v)).array;
}

string toString(BindingStatus status) {
  return cast(string)status;
}

string[] toString(BindingStatus[] statuses) {
  return statuses.map!(s => toString(s)).array;
}
/// 
unittest {
  mixin(ShowTest!("BindingStatus Enumeration"));

  assert(toBindingStatus("active") == BindingStatus.active);
  assert(toBindingStatus("inactive") == BindingStatus.inactive);
  assert(toBindingStatus("deprecated") == BindingStatus.deprecated_);
  assert(toBindingStatus("unknown") == BindingStatus.active); // default case

  assert(toString(BindingStatus.active) == "active");
  assert(toString(BindingStatus.inactive) == "inactive");
  assert(toString(BindingStatus.deprecated_) == "deprecated");

  assert(toBindingStatus(["active", "deprecated", "unknown"]) == [
      BindingStatus.active, BindingStatus.deprecated_, BindingStatus.active
    ]);
  assert(toString([BindingStatus.inactive, BindingStatus.deprecated_]) == [
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

UserStatus[] toUserStatus(string[] values) {
  return values.map!(v => toUserStatus(v)).array;
}

string toString(UserStatus status) {
  return status.to!string;
}

string[] toString(UserStatus[] statuses) {
  return statuses.map!(s => toString(s)).array;
}
/// 
unittest {
  mixin(ShowTest!("UserStatus Enumeration"));

  assert(toUserStatus("active") == UserStatus.active);
  assert(toUserStatus("inactive") == UserStatus.inactive);
  assert(toUserStatus("locked") == UserStatus.locked);
  assert(toUserStatus("passwordLocked") == UserStatus.passwordLocked);
  assert(toUserStatus("unknown") == UserStatus.active); // default case

  assert(toString(UserStatus.active) == "active");
  assert(toString(UserStatus.inactive) == "inactive");
  assert(toString(UserStatus.locked) == "locked");
  assert(toString(UserStatus.passwordLocked) == "passwordLocked");

  assert(toUserStatus(["active", "locked", "unknown"]) == [
      UserStatus.active, UserStatus.locked, UserStatus.active
    ]);
  assert(toString([UserStatus.inactive, UserStatus.passwordLocked]) == [
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

RoleType[] toRoleType(string[] values) {
  return values.map!(v => toRoleType(v)).array;
}

string toString(RoleType type) {
  return type.to!string;
}

string[] toString(RoleType[] types) {
  return types.map!(t => toString(t)).array;
}
///
unittest {
  mixin(ShowTest!("RoleType Enumeration"));

  assert(toRoleType("unrestricted") == RoleType.unrestricted);
  assert(toRoleType("restricted") == RoleType.restricted);
  assert(toRoleType("custom") == RoleType.custom);
  assert(toRoleType("unknown") == RoleType.unrestricted); // default case

  assert(toString(RoleType.unrestricted) == "unrestricted");
  assert(toString(RoleType.restricted) == "restricted");
  assert(toString(RoleType.custom) == "custom");

  assert(toRoleType(["unrestricted", "custom", "unknown"]) == [
      RoleType.unrestricted, RoleType.custom, RoleType.unrestricted
    ]);
  assert(toString([RoleType.restricted, RoleType.custom]) == [
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

TransportType[] toTransportType(string[] values) {
  return values.map!(v => toTransportType(v)).array;
}

string toString(TransportType type) {
  return type.to!string;
}

string[] toString(TransportType[] types) {
  return types.map!(t => toString(t)).array;
}
/// 
unittest {
  mixin(ShowTest!("TransportType Enumeration"));

  assert(toTransportType("workbench") == TransportType.workbench);
  assert(toTransportType("customizing") == TransportType.customizing);
  assert(toTransportType("transportOfCopies") == TransportType.transportOfCopies);
  assert(toTransportType("unknown") == TransportType.workbench); // default case

  assert(toString(TransportType.workbench) == "workbench");
  assert(toString(TransportType.customizing) == "customizing");
  assert(toString(TransportType.transportOfCopies) == "transportOfCopies");

  assert(toTransportType(["workbench", "customizing", "unknown"]) == [
      TransportType.workbench, TransportType.customizing,
      TransportType.workbench
    ]);
  assert(toString([TransportType.workbench, TransportType.transportOfCopies]) == [
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

TransportStatus[] toTransportStatus(string[] values) {
  return values.map!(v => toTransportStatus(v)).array;
}

string toString(TransportStatus status) {
  return status.to!string;
}

string[] toString(TransportStatus[] statuses) {
  return statuses.map!(s => toString(s)).array;
}
///
unittest {
  mixin(ShowTest!("TransportStatus Enumeration"));

  assert(toTransportStatus("modifiable") == TransportStatus.modifiable);
  assert(toTransportStatus("released") == TransportStatus.released);
  assert(toTransportStatus("imported") == TransportStatus.imported);
  assert(toTransportStatus("error") == TransportStatus.error);
  assert(toTransportStatus("unknown") == TransportStatus.modifiable); // default case

  assert(toString(TransportStatus.modifiable) == "modifiable");
  assert(toString(TransportStatus.released) == "released");
  assert(toString(TransportStatus.imported) == "imported");
  assert(toString(TransportStatus.error) == "error");

  assert(toTransportStatus(["modifiable", "released", "unknown"]) == [
      TransportStatus.modifiable, TransportStatus.released,
      TransportStatus.modifiable
    ]);
  assert(toString([TransportStatus.imported, TransportStatus.error]) == [
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

JobFrequency[] toJobFrequency(string[] values) {
  return values.map!(v => toJobFrequency(v)).array;
}

string toString(JobFrequency frequency) {
  return frequency.to!string;
}

string[] toString(JobFrequency[] frequencies) {
  return frequencies.map!(f => toString(f)).array;
}
///
unittest {
  mixin(ShowTest!("JobFrequency Enumeration"));

  assert(toJobFrequency("once") == JobFrequency.once);
  assert(toJobFrequency("hourly") == JobFrequency.hourly);
  assert(toJobFrequency("daily") == JobFrequency.daily);
  assert(toJobFrequency("weekly") == JobFrequency.weekly);
  assert(toJobFrequency("monthly") == JobFrequency.monthly);
  assert(toJobFrequency("unknown") == JobFrequency.once); // default case

  assert(toString(JobFrequency.once) == "once");
  assert(toString(JobFrequency.hourly) == "hourly");
  assert(toString(JobFrequency.daily) == "daily");
  assert(toString(JobFrequency.weekly) == "weekly");
  assert(toString(JobFrequency.monthly) == "monthly");

  assert(toJobFrequency(["once", "daily", "unknown"]) == [
      JobFrequency.once, JobFrequency.daily, JobFrequency.once
    ]);
  assert(toString([JobFrequency.hourly, JobFrequency.weekly]) == [
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

JobStatus[] toJobStatus(string[] values) {
  return values.map!(v => toJobStatus(v)).array;
}

string toString(JobStatus status) {
  return status.to!string;
}

string[] toString(JobStatus[] statuses) {
  return statuses.map!(s => toString(s)).array;
}
///
unittest {
  mixin(ShowTest!("JobStatus Enumeration"));

  assert(toJobStatus("scheduled") == JobStatus.scheduled);
  assert(toJobStatus("running") == JobStatus.running);
  assert(toJobStatus("completed") == JobStatus.completed);
  assert(toJobStatus("failed") == JobStatus.failed);
  assert(toJobStatus("canceled") == JobStatus.canceled);
  assert(toJobStatus("unknown") == JobStatus.scheduled); // default case

  assert(toString(JobStatus.scheduled) == "scheduled");
  assert(toString(JobStatus.running) == "running");
  assert(toString(JobStatus.completed) == "completed");
  assert(toString(JobStatus.failed) == "failed");
  assert(toString(JobStatus.canceled) == "canceled");

  assert(toJobStatus(["scheduled", "running", "unknown"]) == [
      JobStatus.scheduled, JobStatus.running, JobStatus.scheduled
    ]);
  assert(toString([JobStatus.completed, JobStatus.failed]) == [
      "completed", "failed"
    ]);
}
