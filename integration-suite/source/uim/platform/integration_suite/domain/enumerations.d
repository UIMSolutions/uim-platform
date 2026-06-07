/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration_suite.domain.enumerations;

// mixin(ShowModule!());

@safe:

/// Status of an integration artifact (package, flow, mapping)
enum ArtifactStatus : string {
  draft      = "draft",
  deployed   = "deployed",
  undeployed = "undeployed",
  starting   = "starting",
  stopping   = "stopping",
  error_     = "error"
}

/// Direction of data flow in an integration flow
enum FlowDirection : string {
  inbound       = "inbound",
  outbound      = "outbound",
  bidirectional = "bidirectional"
}

/// Supported adapter/connector types
enum AdapterType : string {
  http_          = "http",
  soap           = "soap",
  rest           = "rest",
  odata          = "odata",
  sftp           = "sftp",
  jdbc           = "jdbc",
  jms            = "jms",
  amqp           = "amqp",
  kafka          = "kafka",
  mail           = "mail",
  successFactors = "successFactors",
  s4hana         = "s4hana",
  ariba          = "ariba",
  openConnector  = "openConnector"
}

/// API policy type for API Management
enum PolicyType : string {
  security    = "security",
  quota       = "quota",
  spikeArrest = "spikeArrest",
  cache       = "cache",
  analytics   = "analytics",
  mediation   = "mediation",
  transform   = "transform",
  routing     = "routing"
}

/// Status of an API proxy
enum ApiProxyStatus : string {
  draft      = "draft",
  published  = "published",
  deprecated_ = "deprecated",
  retired    = "retired"
}

/// Status of a message queue (Event Mesh)
enum QueueStatus : string {
  active    = "active",
  suspended = "suspended",
  deleted_  = "deleted"
}

/// Status of a topic subscription
enum SubscriptionStatus : string {
  active   = "active",
  inactive = "inactive",
  error_   = "error"
}

/// B2B message standards
enum B2bStandard : string {
  edifact      = "EDIFACT",
  x12          = "X12",
  csv_         = "CSV",
  xml_         = "XML",
  json_        = "JSON",
  fixedLength  = "FixedLength",
  hl7          = "HL7",
  idoc         = "IDoc"
}

/// Trading partner type
enum PartnerType : string {
  company        = "company",
  subsidiary     = "subsidiary",
  tradingPartner = "tradingPartner"
}

/// Status of a message/data mapping
enum MappingStatus : string {
  draft      = "draft",
  active     = "active",
  deprecated_ = "deprecated"
}

/// Deployment status for integration flows
enum DeploymentStatus : string {
  pending = "pending",
  running = "running",
  stopped = "stopped",
  failed  = "failed",
  error_  = "error"
}

/// Tenant user role within Integration Suite
enum IntegrationUserRole : string {
  admin                = "admin",
  developer            = "developer",
  viewer               = "viewer",
  integrationDeveloper = "integrationDeveloper",
  apiDeveloper         = "apiDeveloper",
  b2bSpecialist        = "b2bSpecialist"
}
