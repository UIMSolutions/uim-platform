/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.content_agent.domain.enumerations;

import uim.platform.content_agent;
mixin(ShowModule!());

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
ContentCategory toContentCategory(string value, bool ignoreCase = true) {
  switch (ignoreCase ? value.toLower() : value) {
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
TransportStatus toTransportStatus(string status) {
  const map = [
    "created": TransportStatus.created,
    "readyforexport": TransportStatus.readyForExport,
    "exporting": TransportStatus.exporting,
    "exported": TransportStatus.exported,
    "inqueue": TransportStatus.inQueue,
    "importing": TransportStatus.importing,
    "imported": TransportStatus.imported,
    "released": TransportStatus.released,
    "failed": TransportStatus.failed,
    "cancelled": TransportStatus.cancelled
  ];
  return map.get(status.toLower, TransportStatus.created);
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
ExportStatus toExportStatus(string status) {
  const map = [
    "pending": ExportStatus.pending,
    "assembling": ExportStatus.assembling,
    "packaging": ExportStatus.packaging,
    "uploading": ExportStatus.uploading,
    "completed": ExportStatus.completed,
    "failed": ExportStatus.failed,
    "cancelled": ExportStatus.cancelled
  ];
  return map.get(status.toLower, ExportStatus.pending);
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
ImportStatus toImportStatus(string status) {
  const map = [
    "pending": ImportStatus.pending,
    "downloading": ImportStatus.downloading,
    "validating": ImportStatus.validating,
    "deploying": ImportStatus.deploying,
    "completed": ImportStatus.completed,
    "failed": ImportStatus.failed,
    "cancelled": ImportStatus.cancelled
  ];
  return map.get(status.toLower, ImportStatus.pending);
}
/// Transport mode.
enum TransportMode {
  cloudTransportManagement,
  ctsPlus,
  directExport,
  fileDownload,
}
TransportMode toTransportMode(string s) {
  const map = [
    "cloudtransportmanagement": TransportMode.cloudTransportManagement,
    "ctsplus": TransportMode.ctsPlus,
    "direxport": TransportMode.directExport,
    "filedownload": TransportMode.fileDownload
  ];
  return map.get(s.toLower, TransportMode.cloudTransportManagement);
}
/// Type of transport queue.
enum QueueType {
  cloudTMS,
  ctsPlus,
  local,
}
QueueType toQueueType(string s) {
  const map = [
    "cloudtms": QueueType.cloudTMS,
    "ctsplus": QueueType.ctsPlus,
    "local": QueueType.local
  ];
  return map.get(s.toLower, QueueType.cloudTMS);
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
  const map = [
    "packagecreated": ActivityType.packageCreated,
    "packageassembled": ActivityType.packageAssembled,
    "packageexported": ActivityType.packageExported,
    "packageimported": ActivityType.packageImported,
    "packagedeleted": ActivityType.packageDeleted,
    "providerregistered": ActivityType.providerRegistered,
    "providerderegistered": ActivityType.providerDeregistered,
    "transportcreated": ActivityType.transportCreated,
    "transportreleased": ActivityType.transportReleased,
    "transportfailed": ActivityType.transportFailed,
    "exportstarted": ActivityType.exportStarted,
    "exportcompleted": ActivityType.exportCompleted,
    "exportfailed": ActivityType.exportFailed,
    "importstarted": ActivityType.importStarted,
    "importcompleted": ActivityType.importCompleted,
    "importfailed": ActivityType.importFailed,
    "queueconfigured": ActivityType.queueConfigured
  ];
  return map.get(s.toLower, ActivityType.packageCreated);
}

/// Severity level for activities.
enum ActivitySeverity {
  info,
  warning,
  error,
}
ActivitySeverity toActivitySeverity(string s) {
  const map = [
    "info": ActivitySeverity.info,
    "warning": ActivitySeverity.warning,
    "error": ActivitySeverity.error
  ];
  return map.get(s.toLower, ActivitySeverity.info);
}
