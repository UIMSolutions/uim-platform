/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration_suite.domain.enumerations;

mixin(ShowModule!());

@safe:

/// Status of an integration artifact (package, flow, mapping)
enum ArtifactStatus : string {
  draft = "draft",
  deployed = "deployed",
  undeployed = "undeployed",
  starting = "starting",
  stopping = "stopping",
  error_ = "error"
}

ArtifactStatus toArtifactStatus(string value) {
  switch (value.toLower()) {
  case "draft":
    return ArtifactStatus.draft;
  case "deployed":
    return ArtifactStatus.deployed;
  case "undeployed":
    return ArtifactStatus.undeployed;
  case "starting":
    return ArtifactStatus.starting;
  case "stopping":
    return ArtifactStatus.stopping;
  case "error":
    return ArtifactStatus.error_;
  default:
    return ArtifactStatus.draft;
  }
}

ArtifactStatus[] toArtifactStatuses(string[] values)
  => values.map!toArtifactStatus.array;
string toString(ArtifactStatus value)
  => value.to!string;
string[] toStrings(ArtifactStatus[] values)
  => values.map!toString.array;
///
unittest {
  mixin(ShowTest!("ArtifactStatus"));

  assert("draft".toArtifactStatus == ArtifactStatus.draft);
  assert("deployed".toArtifactStatus == ArtifactStatus.deployed);
  assert("undeployed".toArtifactStatus == ArtifactStatus.undeployed);
  assert("starting".toArtifactStatus == ArtifactStatus.starting);
  assert("stopping".toArtifactStatus == ArtifactStatus.stopping);
  assert("error".toArtifactStatus == ArtifactStatus.error_);

  assert(ArtifactStatus.draft.toString == "draft");
  assert(ArtifactStatus.deployed.toString == "deployed");
  assert(ArtifactStatus.undeployed.toString == "undeployed");
  assert(ArtifactStatus.starting.toString == "starting");
  assert(ArtifactStatus.stopping.toString == "stopping");
  assert(ArtifactStatus.error_.toString == "error");

  assert(["draft", "deployed"].toArtifactStatuses == [
      ArtifactStatus.draft, ArtifactStatus.deployed
    ]);
  assert([ArtifactStatus.draft, ArtifactStatus.deployed].toStrings == [
      "draft", "deployed"
    ]);
}

/// Direction of data flow in an integration flow
enum FlowDirection : string {
  inbound = "inbound",
  outbound = "outbound",
  bidirectional = "bidirectional"
}

FlowDirection toFlowDirection(string value) {
  mixin(EnumSwitch("FlowDirection", "inbound"));
}

FlowDirection[] toFlowDirections(string[] values)
  => values.map!toFlowDirection.array;
string toString(FlowDirection value)
  => value.to!string;
string[] toStrings(FlowDirection[] values)
  => values.map!toString.array;
///
unittest {
  mixin(ShowTest!("FlowDirection"));

  assert("inbound".toFlowDirection == FlowDirection.inbound);
  assert("outbound".toFlowDirection == FlowDirection.outbound);
  assert("bidirectional".toFlowDirection == FlowDirection.bidirectional);

  assert(FlowDirection.inbound.toString == "inbound");
  assert(FlowDirection.outbound.toString == "outbound");
  assert(FlowDirection.bidirectional.toString == "bidirectional");

  assert(["inbound", "outbound"].toFlowDirections == [
      FlowDirection.inbound, FlowDirection.outbound
    ]);
  assert([FlowDirection.inbound, FlowDirection.outbound].toStrings == [
      "inbound", "outbound"
    ]);
}

/// Supported adapter/connector types
enum AdapterType : string {
  http_ = "http",
  soap = "soap",
  rest = "rest",
  odata = "odata",
  sftp = "sftp",
  jdbc = "jdbc",
  jms = "jms",
  amqp = "amqp",
  kafka = "kafka",
  mail = "mail",
  successFactors = "successFactors",
  s4hana = "s4hana",
  ariba = "ariba",
  openConnector = "openConnector"
}

AdapterType toAdapterType(string value) {
  switch (value.toLower()) {
  case "http":
    return AdapterType.http_;
  case "soap":
    return AdapterType.soap;
  case "rest":
    return AdapterType.rest;
  case "odata":
    return AdapterType.odata;
  case "sftp":
    return AdapterType.sftp;
  case "jdbc":
    return AdapterType.jdbc;
  case "jms":
    return AdapterType.jms;
  case "amqp":
    return AdapterType.amqp;
  case "kafka":
    return AdapterType.kafka;
  case "mail":
    return AdapterType.mail;
  case "successfactors":
    return AdapterType.successFactors;
  case "s4hana":
    return AdapterType.s4hana;
  case "ariba":
    return AdapterType.ariba;
  case "openconnector":
    return AdapterType.openConnector;
  default:
    return AdapterType.http_;
  }
}

AdapterType[] toAdapterTypes(string[] values)
  => values.map!toAdapterType.array;
string toString(AdapterType value)
  => cast(string)value;
string[] toStrings(AdapterType[] values)
  => values.map!toString.array;
/// 
unittest {
  mixin(ShowTest!("AdapterType"));

  assert("http".toAdapterType == AdapterType.http_);
  assert("soap".toAdapterType == AdapterType.soap);
  assert("rest".toAdapterType == AdapterType.rest);
  assert("odata".toAdapterType == AdapterType.odata);
  assert("sftp".toAdapterType == AdapterType.sftp);
  assert("jdbc".toAdapterType == AdapterType.jdbc);
  assert("jms".toAdapterType == AdapterType.jms);
  assert("amqp".toAdapterType == AdapterType.amqp);
  assert("kafka".toAdapterType == AdapterType.kafka);
  assert("mail".toAdapterType == AdapterType.mail);
  assert("successFactors".toAdapterType == AdapterType.successFactors);
  assert("s4hana".toAdapterType == AdapterType.s4hana);
  assert("ariba".toAdapterType == AdapterType.ariba);
  assert("openConnector".toAdapterType == AdapterType.openConnector);

  assert(AdapterType.http_.toString == "http");
  assert(AdapterType.soap.toString == "soap");
  assert(AdapterType.rest.toString == "rest");
  assert(AdapterType.odata.toString == "odata");
  assert(AdapterType.sftp.toString == "sftp");
  assert(AdapterType.jdbc.toString == "jdbc");
  assert(AdapterType.jms.toString == "jms");
  assert(AdapterType.amqp.toString == "amqp");
  assert(AdapterType.kafka.toString == "kafka");
  assert(AdapterType.mail.toString == "mail");
  assert(AdapterType.successFactors.toString == "successFactors");
  assert(AdapterType.s4hana.toString == "s4hana");
  assert(AdapterType.ariba.toString == "ariba");
  assert(AdapterType.openConnector.toString == "openConnector");

  assert(["http", "soap"].toAdapterTypes == [
      AdapterType.http_, AdapterType.soap
    ]);
  assert([AdapterType.http_, AdapterType.soap].toStrings == ["http", "soap"]);
}

/// API policy type for API Management
enum PolicyType : string {
  security = "security",
  quota = "quota",
  spikeArrest = "spikeArrest",
  cache = "cache",
  analytics = "analytics",
  mediation = "mediation",
  transform = "transform",
  routing = "routing"
}

PolicyType toPolicyType(string value) {
  mixin(EnumSwitch("PolicyType", "security"));
}

PolicyType[] toPolicyTypes(string[] values)
  => values.map!toPolicyType.array;
string toString(PolicyType value)
  => value.to!string;
string[] toStrings(PolicyType[] values)
  => values.map!toString.array;
/// 
unittest {
  mixin(ShowTest!("PolicyType"));

  assert("security".toPolicyType == PolicyType.security);
  assert("quota".toPolicyType == PolicyType.quota);
  assert("spikeArrest".toPolicyType == PolicyType.spikeArrest);
  assert("cache".toPolicyType == PolicyType.cache);
  assert("analytics".toPolicyType == PolicyType.analytics);
  assert("mediation".toPolicyType == PolicyType.mediation);
  assert("transform".toPolicyType == PolicyType.transform);
  assert("routing".toPolicyType == PolicyType.routing);

  assert(PolicyType.security.toString == "security");
  assert(PolicyType.quota.toString == "quota");
  assert(PolicyType.spikeArrest.toString == "spikeArrest");
  assert(PolicyType.cache.toString == "cache");
  assert(PolicyType.analytics.toString == "analytics");
  assert(PolicyType.mediation.toString == "mediation");
  assert(PolicyType.transform.toString == "transform");
  assert(PolicyType.routing.toString == "routing");

  assert(["security", "quota"].toPolicyTypes == [
      PolicyType.security, PolicyType.quota
    ]);
  assert([PolicyType.security, PolicyType.quota].toStrings == [
      "security", "quota"
    ]);
}

/// Status of an API proxy
enum ApiProxyStatus : string {
  draft = "draft",
  published = "published",
  deprecated_ = "deprecated",
  retired = "retired"
}

ApiProxyStatus toApiProxyStatus(string value) {
  mixin(EnumSwitch("ApiProxyStatus", "draft"));
}

ApiProxyStatus[] toApiProxyStatuses(string[] values)
  => values.map!toApiProxyStatus.array;
string toString(ApiProxyStatus value)
  => value.to!string;
string[] toStrings(ApiProxyStatus[] values)
  => values.map!toString.array;
///
unittest {
  mixin(ShowTest!("ApiProxyStatus"));

  assert("draft".toApiProxyStatus == ApiProxyStatus.draft);
  assert("published".toApiProxyStatus == ApiProxyStatus.published);
  assert("deprecated".toApiProxyStatus == ApiProxyStatus.deprecated_);
  assert("retired".toApiProxyStatus == ApiProxyStatus.retired);

  assert(ApiProxyStatus.draft.toString == "draft");
  assert(ApiProxyStatus.published.toString == "published");
  assert(ApiProxyStatus.deprecated_.toString == "deprecated");
  assert(ApiProxyStatus.retired.toString == "retired");

  assert(["draft", "published"].toApiProxyStatuses == [
      ApiProxyStatus.draft, ApiProxyStatus.published
    ]);
  assert([ApiProxyStatus.draft, ApiProxyStatus.published].toStrings == [
      "draft", "published"
    ]);
}

/// Status of a message queue (Event Mesh)
enum QueueStatus : string {
  active = "active",
  suspended = "suspended",
  deleted_ = "deleted"
}

QueueStatus toQueueStatus(string value) {
  switch (value.toLower()) {
  case "active":
    return QueueStatus.active;
  case "suspended":
    return QueueStatus.suspended;
  case "deleted":
    return QueueStatus.deleted_;
  default:
    return QueueStatus.active;
  }
}

QueueStatus[] toQueueStatuses(string[] values)
  => values.map!toQueueStatus.array;
string toString(QueueStatus value)
  => value.to!string;
string[] toStrings(QueueStatus[] values)
  => values.map!toString.array;
///
unittest {
  mixin(ShowTest!("QueueStatus"));

  assert("active".toQueueStatus == QueueStatus.active);
  assert("suspended".toQueueStatus == QueueStatus.suspended);
  assert("deleted".toQueueStatus == QueueStatus.deleted_);

  assert("".toQueueStatus == QueueStatus.active);
  assert("unknown".toQueueStatus == QueueStatus.active);

  assert(QueueStatus.active.toString == "active");
  assert(QueueStatus.suspended.toString == "suspended");
  assert(QueueStatus.deleted_.toString == "deleted");

  assert(["active", "suspended"].toQueueStatuses == [
      QueueStatus.active, QueueStatus.suspended
    ]);
  assert([QueueStatus.active, QueueStatus.suspended].toStrings == [
      "active", "suspended"
    ]);
}

/// Status of a topic subscription
enum SubscriptionStatus : string {
  active = "active",
  inactive = "inactive",
  error_ = "error"
}
SubscriptionStatus toSubscriptionStatus(string value) {
  switch (value.toLower()) {
  case "active":
    return SubscriptionStatus.active;
  case "inactive":
    return SubscriptionStatus.inactive;
  case "error":
    return SubscriptionStatus.error_;
  default:
    return SubscriptionStatus.active; 
}
SubscriptionStatus[] toSubscriptionStatuses(string[] values)
  => values.map!toSubscriptionStatus.array;
string toString(SubscriptionStatus value)
  => value.to!string;
string[] toStrings(SubscriptionStatus[] values)
  => values.map!toString.array;
///
unittest {
  mixin(ShowTest!("SubscriptionStatus"));

  assert("active".toSubscriptionStatus == SubscriptionStatus.active);
  assert("inactive".toSubscriptionStatus == SubscriptionStatus.inactive);
  assert("error".toSubscriptionStatus == SubscriptionStatus.error_);

  assert("".toSubscriptionStatus == SubscriptionStatus.active);
  assert("unknown".toSubscriptionStatus == SubscriptionStatus.active);

  assert(SubscriptionStatus.active.toString == "active");
  assert(SubscriptionStatus.inactive.toString == "inactive");
  assert(SubscriptionStatus.error_.toString == "error");

  assert(["active", "inactive"].toSubscriptionStatuses == [
      SubscriptionStatus.active, SubscriptionStatus.inactive
    ]);
  assert([SubscriptionStatus.active, SubscriptionStatus.inactive].toStrings == [
      "active", "inactive"
    ]);
}

/// B2B message standards
enum B2bStandard : string {
  edifact = "EDIFACT",
  x12 = "X12",
  csv = "CSV",
  xml = "XML",
  json = "JSON",
  fixedLength = "FixedLength",
  hl7 = "HL7",
  idoc = "IDoc"
}
B2bStandard toB2bStandard(string value) {
  mixin(EnumSwitch("B2bStandard", "edifact"));
}
B2bStandard[] toB2bStandards(string[] values)
  => values.map!toB2bStandard.array;
string toString(B2bStandard value)
  => value.to!string;
string[] toStrings(B2bStandard[] values)
  => values.map!toString.array;
  /// unittest {
  mixin(ShowTest!("B2bStandard"));

  assert("edifact".toB2bStandard == B2bStandard.edifact);
  assert("x12".toB2bStandard == B2bStandard.x12);
  assert("csv".toB2bStandard == B2bStandard.csv);
  assert("xml".toB2bStandard == B2bStandard.xml);
  assert("json".toB2bStandard == B2bStandard.json);
  assert("fixedLength".toB2bStandard == B2bStandard.fixedLength);
  assert("hl7".toB2bStandard == B2bStandard.hl7);
  assert("idoc".toB2bStandard == B2bStandard.idoc); 

  assert("".toB2bStandard == B2bStandard.edifact);
  assert("unknown".toB2bStandard == B2bStandard.edifact);

  assert(B2bStandard.edifact.toString == "EDIFACT");
  assert(B2bStandard.x12.toString == "X12");
  assert(B2bStandard.csv.toString == "CSV");    
  assert(B2bStandard.xml.toString == "XML");
  assert(B2bStandard.json.toString == "JSON");
  assert(B2bStandard.fixedLength.toString == "FixedLength");
  assert(B2bStandard.hl7.toString == "HL7");
  assert(B2bStandard.idoc.toString == "IDoc");  

  assert(["edifact", "x12"].toB2bStandards == [
      B2bStandard.edifact, B2bStandard.x12
    ]);
  assert([B2bStandard.edifact, B2bStandard.x12].toStrings == [
      "EDIFACT", "X12"
    ]);
}

/// Trading partner type
enum PartnerType : string {
  company = "company",
  subsidiary = "subsidiary",
  tradingPartner = "tradingPartner"
}
PartnerType toPartnerType(string value) {
  mixin(EnumSwitch("PartnerType", "company"));
}
PartnerType[] toPartnerTypes(string[] values)
  => values.map!toPartnerType.array;
string toString(PartnerType value)
  => value.to!string;
string[] toStrings(PartnerType[] values)
  => values.map!toString.array;
/// 
unittest {
  mixin(ShowTest!("PartnerType"));

  assert("company".toPartnerType == PartnerType.company);
  assert("subsidiary".toPartnerType == PartnerType.subsidiary);
  assert("tradingPartner".toPartnerType == PartnerType.tradingPartner);

  assert("".toPartnerType == PartnerType.company);
  assert("unknown".toPartnerType == PartnerType.company);

  assert(PartnerType.company.toString == "company");
  assert(PartnerType.subsidiary.toString == "subsidiary");
  assert(PartnerType.tradingPartner.toString == "tradingPartner");

  assert(["company", "subsidiary"].toPartnerTypes == [
      PartnerType.company, PartnerType.subsidiary
    ]);
  assert([PartnerType.company, PartnerType.subsidiary].toStrings == [
      "company", "subsidiary"
    ]);
}

/// Status of a message/data mapping
enum MappingStatus : string {
  draft = "draft",
  active = "active",
  deprecated_ = "deprecated"
} 
MappingStatus toMappingStatus(string value) {
  mixin(EnumSwitch("MappingStatus", "draft"));
}
MappingStatus[] toMappingStatuses(string[] values)
  => values.map!toMappingStatus.array;
string toString(MappingStatus value)
  => value.to!string;
string[] toStrings(MappingStatus[] values)
  => values.map!toString.array;
///
unittest {
  mixin(ShowTest!("MappingStatus"));

  assert("draft".toMappingStatus == MappingStatus.draft); 
  assert("active".toMappingStatus == MappingStatus.active);
  assert("deprecated".toMappingStatus == MappingStatus.deprecated_);

  assert("".toMappingStatus == MappingStatus.draft);
  assert("unknown".toMappingStatus == MappingStatus.draft);

  assert(MappingStatus.draft.toString == "draft");
  assert(MappingStatus.active.toString == "active");
  assert(MappingStatus.deprecated_.toString == "deprecated");

  assert(["draft", "active"].toMappingStatuses == [
      MappingStatus.draft, MappingStatus.active
    ]);
  assert([MappingStatus.draft, MappingStatus.active].toStrings == [
      "draft", "active"
    ]);
}

/// Deployment status for integration flows
enum DeploymentStatus : string {
  pending = "pending",
  running = "running",
  stopped = "stopped",
  failed = "failed",
  error_ = "error"
}
DeploymentStatus toDeploymentStatus(string value) {
  mixin(EnumSwitch("DeploymentStatus", "pending"));
}
DeploymentStatus[] toDeploymentStatuses(string[] values)
  => values.map!toDeploymentStatus.array;
string toString(DeploymentStatus value)
  => value.to!string;
string[] toStrings(DeploymentStatus[] values)
  => values.map!toString.array;
///
unittest {
  mixin(ShowTest!("DeploymentStatus"));

  assert("pending".toDeploymentStatus == DeploymentStatus.pending);
  assert("running".toDeploymentStatus == DeploymentStatus.running);
  assert("stopped".toDeploymentStatus == DeploymentStatus.stopped);
  assert("failed".toDeploymentStatus == DeploymentStatus.failed);
  assert("error".toDeploymentStatus == DeploymentStatus.error_);  

  assert("".toDeploymentStatus == DeploymentStatus.pending);
  assert("unknown".toDeploymentStatus == DeploymentStatus.pending);

  assert(DeploymentStatus.pending.toString == "pending");
  assert(DeploymentStatus.running.toString == "running");
  assert(DeploymentStatus.stopped.toString == "stopped");
  assert(DeploymentStatus.failed.toString == "failed");
  assert(DeploymentStatus.error_.toString == "error");

  assert(["pending", "running"].toDeploymentStatuses == [
      DeploymentStatus.pending, DeploymentStatus.running
    ]);
  assert([DeploymentStatus.pending, DeploymentStatus.running].toStrings == [
      "pending", "running"
    ]);
}

/// Tenant user role within Integration Suite
enum IntegrationUserRole : string {
  admin = "admin",
  developer = "developer",
  viewer = "viewer",
  integrationDeveloper = "integrationDeveloper",
  apiDeveloper = "apiDeveloper",
  b2bSpecialist = "b2bSpecialist"
}
IntegrationUserRole toIntegrationUserRole(string value) {
  mixin(EnumSwitch("IntegrationUserRole", "viewer"));
}
IntegrationUserRole[] toIntegrationUserRoles(string[] values)
  => values.map!toIntegrationUserRole.array;
string toString(IntegrationUserRole value)
  => value.to!string;
string[] toStrings(IntegrationUserRole[] values)  
  => values.map!toString.array;
///
unittest {
  mixin(ShowTest!("IntegrationUserRole"));  

  assert("admin".toIntegrationUserRole == IntegrationUserRole.admin);
  assert("developer".toIntegrationUserRole == IntegrationUserRole.developer);
  assert("viewer".toIntegrationUserRole == IntegrationUserRole.viewer);
  assert("integrationDeveloper".toIntegrationUserRole == IntegrationUserRole.integrationDeveloper);
  assert("apiDeveloper".toIntegrationUserRole == IntegrationUserRole.apiDeveloper);
  assert("b2bSpecialist".toIntegrationUserRole == IntegrationUserRole.b2bSpecialist);

  assert("".toIntegrationUserRole == IntegrationUserRole.viewer);
  assert("unknown".toIntegrationUserRole == IntegrationUserRole.viewer);

  assert(IntegrationUserRole.admin.toString == "admin");
  assert(IntegrationUserRole.developer.toString == "developer");
  assert(IntegrationUserRole.viewer.toString == "viewer");
  assert(IntegrationUserRole.integrationDeveloper.toString == "integrationDeveloper");
  assert(IntegrationUserRole.apiDeveloper.toString == "apiDeveloper");
  assert(IntegrationUserRole.b2bSpecialist.toString == "b2bSpecialist");

  assert(["admin", "developer"].toIntegrationUserRoles == [
      IntegrationUserRole.admin, IntegrationUserRole.developer
    ]);
  assert([IntegrationUserRole.admin, IntegrationUserRole.developer].toStrings == [
      "admin", "developer"
    ]);
}
