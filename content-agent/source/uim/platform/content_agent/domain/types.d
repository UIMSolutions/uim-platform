/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.content_agent.domain.types;

import uim.platform.content_agent;

mixin(ShowModule!());

@safe:
/// Unique identifier type aliases for type safety.
struct ContentPackageId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct ContentTypeId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct ContentProviderId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct TransportRequestId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct ExportJobId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct ImportJobId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct TransportQueueId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct ContentActivityId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}



struct SubaccountId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

/// Status of a content package.
enum PackageStatus {
  draft,
  assembled,
  exported,
  inTransport,
  delivered,
  error,
}

/// Content format for package assembly.
enum ContentFormat {
  mtar,
  zip,
  json,
}

/// Status of a content provider.
enum ProviderStatus {
  active,
  inactive,
  error,
  deregistered,
}

/// Content category provided by a content provider.
enum ContentCategory {
  integrationFlow,
  destination,
  apiProxy,
  valueMapping,
  securityArtifact,
  messageMapping,
  scriptCollection,
  dataType,
  messageType,
  numberRange,
  customForm,
  workflow,
  businessRule,
  keyValueMap,
  oauthCredential,
  certificateToUserMapping,
  accessPolicy,
  functionLibrary,
  custom,
}

/// Status of a transport request.
enum TransportStatus {
  created,
  readyForExport,
  exporting,
  exported,
  inQueue,
  importing,
  imported,
  released,
  failed,
  cancelled,
}

/// Status of an export job.
enum ExportStatus {
  pending,
  assembling,
  packaging,
  uploading,
  completed,
  failed,
  cancelled,
}

/// Status of an import job.
enum ImportStatus {
  pending,
  downloading,
  validating,
  deploying,
  completed,
  failed,
  cancelled,
}

/// Transport mode.
enum TransportMode {
  cloudTransportManagement,
  ctsPlus,
  directExport,
  fileDownload,
}

/// Type of transport queue.
enum QueueType {
  cloudTMS,
  ctsPlus,
  local,
}

/// Type of recorded activity.
enum ActivityType {
  packageCreated,
  packageAssembled,
  packageExported,
  packageImported,
  packageDeleted,
  providerRegistered,
  providerDeregistered,
  transportCreated,
  transportReleased,
  transportFailed,
  exportStarted,
  exportCompleted,
  exportFailed,
  importStarted,
  importCompleted,
  importFailed,
  queueConfigured,
}

/// Severity level for activities.
enum ActivitySeverity {
  info,
  warning,
  error,
}
