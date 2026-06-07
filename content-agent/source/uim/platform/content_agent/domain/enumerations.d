/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.content_agent.domain.enumerations;

import uim.platform.content_agent;

// mixin(ShowModule!());

@safe:


/// Status of a content package.
enum PackageStatus {
  draft,
  assembled,
  exported,
  inTransport,
  delivered,
  error,
}

PackageStatus toPackageStatus(string status) {
  switch (status) {
    case "draft": return PackageStatus.draft;
    case "assembled": return PackageStatus.assembled;
    case "exported": return PackageStatus.exported;
    case "intransport": return PackageStatus.inTransport;
    case "delivered": return PackageStatus.delivered;
    case "error": return PackageStatus.error;
    default: return PackageStatus.draft; // default
  }
}

/// Content format for package assembly.
enum ContentFormat {
  mtar,
  zip,
  json,
}
ContentFormat toContentFormat(string format) {
  switch (format) {
    case "mtar": return ContentFormat.mtar;
    case "zip": return ContentFormat.zip;
    case "json": return ContentFormat.json;
    default: return ContentFormat.mtar; // default
  }
}

/// Status of a content provider.
enum ProviderStatus {
  active,
  inactive,
  error,
  deregistered,
}
ProviderStatus toProviderStatus(string status) {
  switch (status) {
    case "active": return ProviderStatus.active;
    case "inactive": return ProviderStatus.inactive;
    case "error": return ProviderStatus.error;
    case "deregistered": return ProviderStatus.deregistered;
    default: return ProviderStatus.inactive; // default
  }
}

/// Content category provided by a content provider.
enum ContentCategory {
  custom,
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
}
ContentCategory toContentCategory(string s) {
  switch (s.toLower()) {
    case "custom": return ContentCategory.custom;
    case "integrationflow": return ContentCategory.integrationFlow;
    case "destination": return ContentCategory.destination;
    case "apiproxy": return ContentCategory.apiProxy;
    case "valuemapping": return ContentCategory.valueMapping;
    case "securityartifact": return ContentCategory.securityArtifact;
    case "messagemapping": return ContentCategory.messageMapping;
    case "scriptcollection": return ContentCategory.scriptCollection;
    case "datatype": return ContentCategory.dataType;
    case "messagetype": return ContentCategory.messageType;
    case "numberrange": return ContentCategory.numberRange;
    case "customform": return ContentCategory.customForm;
    case "workflow": return ContentCategory.workflow;
    case "businessrule": return ContentCategory.businessRule;
    case "keyvaluemap": return ContentCategory.keyValueMap;
    case "oauthcredential": return ContentCategory.oauthCredential;
    case "certificatetousermapping": return ContentCategory.certificateToUserMapping;
    case "accesspolicy": return ContentCategory.accessPolicy;
    case "functionlibrary": return ContentCategory.functionLibrary;
    default: return ContentCategory.custom; // default
  }
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

ActivityType toActivityType(string s) {
  switch (s.toLower) {
    case "packagecreated": return ActivityType.packageCreated;
    case "packageassembled": return ActivityType.packageAssembled;
    case "packageexported": return ActivityType.packageExported;
    case "packageimported": return ActivityType.packageImported;
    case "packagedeleted": return ActivityType.packageDeleted;
    case "providerregistered": return ActivityType.providerRegistered;
    case "providerderegistered": return ActivityType.providerDeregistered;
    case "transportcreated": return ActivityType.transportCreated;
    case "transportreleased": return ActivityType.transportReleased;
    case "transportfailed": return ActivityType.transportFailed;
    case "exportstarted": return ActivityType.exportStarted;
    case "exportcompleted": return ActivityType.exportCompleted;
    case "exportfailed": return ActivityType.exportFailed;
    case "importstarted": return ActivityType.importStarted;
    case "importcompleted": return ActivityType.importCompleted;
    case "importfailed": return ActivityType.importFailed;
    case "queueconfigured": return ActivityType.queueConfigured;
    default: return ActivityType.packageCreated; // default
  }
}

/// Severity level for activities.
enum ActivitySeverity {
  info,
  warning,
  error,
}
