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
  mixin(EnumSwitch("PackageStatus", "draft"));
}
PackageStatus[] toPackageStatuses(string[] statuses)
  => statuses.map!toPackageStatus.array;

string toString(PackageStatus status)
  => status.to!string;

string[] toStrings(PackageStatus[] statuses)
  => statuses.map!toString.array;

///
unittest {
  mixin(ShowTest!("PackageStatus"));

  assert("draft".toPackageStatus == PackageStatus.draft);
  assert("assembled".toPackageStatus == PackageStatus.assembled);
  assert("exported".toPackageStatus == PackageStatus.exported);
  assert("inTransport".toPackageStatus == PackageStatus.inTransport);
  assert("delivered".toPackageStatus == PackageStatus.delivered);
  assert("error".toPackageStatus == PackageStatus.error);

  assert("".toPackageStatus == PackageStatus.draft);
  assert("unknown".toPackageStatus == PackageStatus.draft);

  assert(PackageStatus.draft.toString == "draft");
  assert(PackageStatus.assembled.toString == "assembled");
  assert(PackageStatus.exported.toString == "exported");
  assert(PackageStatus.inTransport.toString == "inTransport");
  assert(PackageStatus.delivered.toString == "delivered");
  assert(PackageStatus.error.toString == "error");

  assert(["draft", "exported"].toPackageStatuses == [
      PackageStatus.draft, PackageStatus.exported
    ]);
  assert([PackageStatus.draft, PackageStatus.exported].toStrings == ["draft", "exported"]);
}

/// Content format for package assembly.
enum ContentFormat {
  mtar,
  zip,
  json,
}
ContentFormat toContentFormat(string format) {
  mixin(EnumSwitch("ContentFormat", "mtar"));
}
ContentFormat[] toContentFormats(string[] formats)
  => formats.map!toContentFormat.array;

string toString(ContentFormat format)
  => format.to!string;

string[] toStrings(ContentFormat[] formats)
  => formats.map!toString.array;

///
unittest {
  mixin(ShowTest!("ContentFormat"));

  assert("mtar".toContentFormat == ContentFormat.mtar);
  assert("zip".toContentFormat == ContentFormat.zip);
  assert("json".toContentFormat == ContentFormat.json);

  assert("".toContentFormat == ContentFormat.mtar);
  assert("unknown".toContentFormat == ContentFormat.mtar);

  assert(ContentFormat.mtar.toString == "mtar");
  assert(ContentFormat.zip.toString == "zip");
  assert(ContentFormat.json.toString == "json");

  assert(["mtar", "json"].toContentFormats == [
      ContentFormat.mtar, ContentFormat.json
    ]);
  assert([ContentFormat.mtar, ContentFormat.json].toStrings == ["mtar", "json"]);
}

/// Status of a content provider.
enum ProviderStatus {
  active,
  inactive,
  error,
  deregistered,
}
ProviderStatus toProviderStatus(string status) {
  mixin(EnumSwitch("ProviderStatus", "active"));
}
ProviderStatus[] toProviderStatuses(string[] statuses)
  => statuses.map!toProviderStatus.array;

string toString(ProviderStatus status)
  => status.to!string;

string[] toStrings(ProviderStatus[] statuses)
  => statuses.map!toString.array;

///
unittest {
  mixin(ShowTest!("ProviderStatus"));

  assert("active".toProviderStatus == ProviderStatus.active);
  assert("inactive".toProviderStatus == ProviderStatus.inactive);
  assert("error".toProviderStatus == ProviderStatus.error);
  assert("deregistered".toProviderStatus == ProviderStatus.deregistered);

  assert("".toProviderStatus == ProviderStatus.active);
  assert("unknown".toProviderStatus == ProviderStatus.active);

  assert(ProviderStatus.active.toString == "active");
  assert(ProviderStatus.inactive.toString == "inactive");
  assert(ProviderStatus.error.toString == "error");
  assert(ProviderStatus.deregistered.toString == "deregistered");

  assert(["active", "error"].toProviderStatuses == [
      ProviderStatus.active, ProviderStatus.error
    ]);
  assert([ProviderStatus.active, ProviderStatus.error].toStrings == ["active", "error"]);
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
ContentCategory toContentCategory(string value) {
  mixin(EnumSwitch("ContentCategory", "custom"));
}
ContentCategory[] toContentCategories(string[] values)
  => values.map!toContentCategory.array;

string toString(ContentCategory value)
  => value.to!string;

string[] toStrings(ContentCategory[] values)
  => values.map!toString.array;

///
unittest {
  mixin(ShowTest!("ContentCategory"));

  assert("custom".toContentCategory == ContentCategory.custom);
  assert("integrationFlow".toContentCategory == ContentCategory.integrationFlow);
  assert("destination".toContentCategory == ContentCategory.destination);
  assert("apiProxy".toContentCategory == ContentCategory.apiProxy);
  assert("valueMapping".toContentCategory == ContentCategory.valueMapping);
  assert("securityArtifact".toContentCategory == ContentCategory.securityArtifact);
  assert("messageMapping".toContentCategory == ContentCategory.messageMapping);
  assert("scriptCollection".toContentCategory == ContentCategory.scriptCollection);
  assert("dataType".toContentCategory == ContentCategory.dataType);
  assert("messageType".toContentCategory == ContentCategory.messageType);
  assert("numberRange".toContentCategory == ContentCategory.numberRange);
  assert("customForm".toContentCategory == ContentCategory.customForm);
  assert("workflow".toContentCategory == ContentCategory.workflow);
  assert("businessRule".toContentCategory == ContentCategory.businessRule);
  assert("keyValueMap".toContentCategory == ContentCategory.keyValueMap);
  assert("oauthCredential".toContentCategory == ContentCategory.oauthCredential);
  assert("certificateToUserMapping".toContentCategory == ContentCategory.certificateToUserMapping);
  assert("accessPolicy".toContentCategory == ContentCategory.accessPolicy);
  assert("functionLibrary".toContentCategory == ContentCategory.functionLibrary);
  
  assert("".toContentCategory == ContentCategory.functionLibrary);
  assert("unknown".toContentCategory == ContentCategory.functionLibrary);

  assert(ContentCategory.custom.toString == "custom");
  assert(ContentCategory.integrationFlow.toString == "integrationFlow");
  assert(ContentCategory.destination.toString == "destination");
  assert(ContentCategory.apiProxy.toString == "apiProxy");
  assert(ContentCategory.valueMapping.toString == "valueMapping");
  assert(ContentCategory.securityArtifact.toString == "securityArtifact");
  assert(ContentCategory.messageMapping.toString == "messageMapping");
  assert(ContentCategory.scriptCollection.toString == "scriptCollection");
  assert(ContentCategory.dataType.toString == "dataType");
  assert(ContentCategory.messageType.toString == "messageType");
  assert(ContentCategory.numberRange.toString == "numberRange");
  assert(ContentCategory.customForm.toString == "customForm");
  assert(ContentCategory.workflow.toString == "workflow");
  assert(ContentCategory.businessRule.toString == "businessRule");
  assert(ContentCategory.keyValueMap.toString == "keyValueMap");
  assert(ContentCategory.oauthCredential.toString == "oauthCredential");
  assert(ContentCategory.certificateToUserMapping.toString == "certificateToUserMapping");
  assert(ContentCategory.accessPolicy.toString == "accessPolicy");
  assert(ContentCategory.functionLibrary.toString == "functionLibrary");

  assert(["custom", "destination"].toContentCategories == [
      ContentCategory.custom, ContentCategory.destination
    ]);
  assert([ContentCategory.custom, ContentCategory.destination].toStrings == ["custom", "destination"]);
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
  mixin(EnumSwitch("TransportStatus", "created"));
}
TransportStatus[] toTransportStatuses(string[] statuses)
  => statuses.map!toTransportStatus.array;

string toString(TransportStatus status)
  => status.to!string;

string[] toStrings(TransportStatus[] statuses)
  => statuses.map!toString.array;

///
unittest {
  mixin(ShowTest!("TransportStatus"));

  assert("created".toTransportStatus == TransportStatus.created);
  assert("readyForExport".toTransportStatus == TransportStatus.readyForExport);
  assert("exporting".toTransportStatus == TransportStatus.exporting);
  assert("exported".toTransportStatus == TransportStatus.exported);
  assert("inQueue".toTransportStatus == TransportStatus.inQueue);
  assert("importing".toTransportStatus == TransportStatus.importing);
  assert("imported".toTransportStatus == TransportStatus.imported);
  assert("released".toTransportStatus == TransportStatus.released);
  assert("failed".toTransportStatus == TransportStatus.failed);
  assert("cancelled".toTransportStatus == TransportStatus.cancelled);

  assert("".toTransportStatus == TransportStatus.created);
  assert("unknown".toTransportStatus == TransportStatus.created);

  assert(TransportStatus.created.toString == "created");
  assert(TransportStatus.readyForExport.toString == "readyForExport");
  assert(TransportStatus.exporting.toString == "exporting");
  assert(TransportStatus.exported.toString == "exported");
  assert(TransportStatus.inQueue.toString == "inQueue");
  assert(TransportStatus.importing.toString == "importing");
  assert(TransportStatus.imported.toString == "imported");
  assert(TransportStatus.released.toString == "released");
  assert(TransportStatus.failed.toString == "failed");
  assert(TransportStatus.cancelled.toString == "cancelled");

  assert(["created", "exported"].toTransportStatuses == [
      TransportStatus.created, TransportStatus.exported
    ]);
  assert([TransportStatus.created, TransportStatus.exported].toStrings == ["created", "exported"]);
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
  mixin(EnumSwitch("ExportStatus", "pending"));
}

ExportStatus[] toExportStatuses(string[] statuses)
  => statuses.map!toExportStatus.array;

string toString(ExportStatus status)
  => status.to!string;

string[] toStrings(ExportStatus[] statuses)
  => statuses.map!toString.array;

/// 
unittest {
  mixin(ShowTest!("ExportStatus"));

  assert("pending".toExportStatus == ExportStatus.pending);
  assert("assembling".toExportStatus == ExportStatus.assembling);
  assert("packaging".toExportStatus == ExportStatus.packaging);
  assert("uploading".toExportStatus == ExportStatus.uploading);
  assert("completed".toExportStatus == ExportStatus.completed);
  assert("failed".toExportStatus == ExportStatus.failed);
  assert("cancelled".toExportStatus == ExportStatus.cancelled);

  assert("".toExportStatus == ExportStatus.pending);
  assert("unknown".toExportStatus == ExportStatus.pending);

  assert(ExportStatus.pending.toString == "pending");
  assert(ExportStatus.assembling.toString == "assembling");
  assert(ExportStatus.packaging.toString == "packaging");
  assert(ExportStatus.uploading.toString == "uploading");
  assert(ExportStatus.completed.toString == "completed");
  assert(ExportStatus.failed.toString == "failed");
  assert(ExportStatus.cancelled.toString == "cancelled");

  assert(["pending", "completed"].toExportStatuses == [
      ExportStatus.pending, ExportStatus.completed
    ]);
  assert([ExportStatus.pending, ExportStatus.completed].toStrings == ["pending", "completed"]);
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
  mixin(EnumSwitch("ImportStatus", "pending"));
}

ImportStatus[] toImportStatuses(string[] statuses)
  => statuses.map!toImportStatus.array;

string toString(ImportStatus status)
  => status.to!string;

string[] toStrings(ImportStatus[] statuses)
  => statuses.map!toString.array;

///
unittest {
  mixin(ShowTest!("ImportStatus"));

  assert("pending".toImportStatus == ImportStatus.pending);
  assert("downloading".toImportStatus == ImportStatus.downloading);
  assert("validating".toImportStatus == ImportStatus.validating);
  assert("deploying".toImportStatus == ImportStatus.deploying);
  assert("completed".toImportStatus == ImportStatus.completed);
  assert("failed".toImportStatus == ImportStatus.failed);
  assert("cancelled".toImportStatus == ImportStatus.cancelled);

  assert("".toImportStatus == ImportStatus.pending);
  assert("unknown".toImportStatus == ImportStatus.pending);

  assert(ImportStatus.pending.toString == "pending");
  assert(ImportStatus.downloading.toString == "downloading");
  assert(ImportStatus.validating.toString == "validating");
  assert(ImportStatus.deploying.toString == "deploying");
  assert(ImportStatus.completed.toString == "completed");
  assert(ImportStatus.failed.toString == "failed");
  assert(ImportStatus.cancelled.toString == "cancelled");

  assert(["pending", "completed"].toImportStatuses == [
      ImportStatus.pending, ImportStatus.completed
    ]);
  assert([ImportStatus.pending, ImportStatus.completed].toStrings == ["pending", "completed"]);
}

/// Transport mode.
enum TransportMode {
  cloudTransportManagement,
  ctsPlus,
  directExport,
  fileDownload,
}
TransportMode toTransportMode(string value) {
  mixin(EnumSwitch("TransportMode", "cloudTransportManagement"));
}

TransportMode[] toTransportModes(string[] values)
  => values.map!toTransportMode.array;

string toString(TransportMode value)
  => value.to!string;

string[] toStrings(TransportMode[] values)
  => values.map!toString.array;

/// 
unittest {
  mixin(ShowTest!("TransportMode"));

  assert("cloudTransportManagement".toTransportMode == TransportMode.cloudTransportManagement);
  assert("ctsPlus".toTransportMode == TransportMode.ctsPlus);
  assert("directExport".toTransportMode == TransportMode.directExport);
  assert("fileDownload".toTransportMode == TransportMode.fileDownload);

  assert("".toTransportMode == TransportMode.cloudTransportManagement);
  assert("unknown".toTransportMode == TransportMode.cloudTransportManagement);

  assert(TransportMode.cloudTransportManagement.toString == "cloudTransportManagement");
  assert(TransportMode.ctsPlus.toString == "ctsPlus");
  assert(TransportMode.directExport.toString == "directExport");
  assert(TransportMode.fileDownload.toString == "fileDownload");

  assert(["cloudTransportManagement", "fileDownload"].toTransportModes == [
      TransportMode.cloudTransportManagement, TransportMode.fileDownload
    ]);
  assert([TransportMode.cloudTransportManagement, TransportMode.fileDownload].toStrings == [
      "cloudTransportManagement", "fileDownload"
    ]);
}

/// Type of transport queue.
enum QueueType {
  cloudTMS,
  ctsPlus,
  local,
}
QueueType toQueueType(string value) {
  mixin(EnumSwitch("QueueType", "cloudTMS"));
}

QueueType[] toQueueTypes(string[] values)
  => values.map!toQueueType.array;

string toString(QueueType value)
  => value.to!string;

string[] toStrings(QueueType[] values)
  => values.map!toString.array;

///
unittest {
  mixin(ShowTest!("QueueType"));

  assert("cloudTMS".toQueueType == QueueType.cloudTMS);
  assert("ctsPlus".toQueueType == QueueType.ctsPlus);
  assert("local".toQueueType == QueueType.local);

  assert("".toQueueType == QueueType.cloudTMS);
  assert("unknown".toQueueType == QueueType.cloudTMS);

  assert(QueueType.cloudTMS.toString == "cloudTMS");
  assert(QueueType.ctsPlus.toString == "ctsPlus");
  assert(QueueType.local.toString == "local");

  assert(["cloudTMS", "local"].toQueueTypes == [
      QueueType.cloudTMS, QueueType.local
    ]);
  assert([QueueType.cloudTMS, QueueType.local].toStrings == [
      "cloudTMS", "local"
    ]);
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
ActivityType toActivityType(string value) {
  mixin(EnumSwitch("ActivityType", "packageCreated"));
}

ActivityType[] toActivityTypes(string[] values)
  => values.map!toActivityType.array;

string toString(ActivityType value)
  => value.to!string;

string[] toStrings(ActivityType[] values)
  => values.map!toString.array;

///
unittest {
  mixin(ShowTest!("ActivityType"));

  assert("packageCreated".toActivityType == ActivityType.packageCreated);
  assert("packageAssembled".toActivityType == ActivityType.packageAssembled);
  assert("packageExported".toActivityType == ActivityType.packageExported);
  assert("packageImported".toActivityType == ActivityType.packageImported);
  assert("packageDeleted".toActivityType == ActivityType.packageDeleted);
  assert("providerRegistered".toActivityType == ActivityType.providerRegistered);
  assert("providerDeregistered".toActivityType == ActivityType.providerDeregistered);
  assert("transportCreated".toActivityType == ActivityType.transportCreated);
  assert("transportReleased".toActivityType == ActivityType.transportReleased);
  assert("transportFailed".toActivityType == ActivityType.transportFailed);
  assert("exportStarted".toActivityType == ActivityType.exportStarted);
  assert("exportCompleted".toActivityType == ActivityType.exportCompleted);
  assert("exportFailed".toActivityType == ActivityType.exportFailed);
  assert("importStarted".toActivityType == ActivityType.importStarted);
  assert("importCompleted".toActivityType == ActivityType.importCompleted);
  assert("importFailed".toActivityType == ActivityType.importFailed);
  assert("queueConfigured".toActivityType == ActivityType.queueConfigured);

  assert("".toActivityType == ActivityType.packageCreated);
  assert("unknown".toActivityType == ActivityType.packageCreated);

  assert(ActivityType.packageCreated.toString == "packageCreated");
  assert(ActivityType.packageAssembled.toString == "packageAssembled");
  assert(ActivityType.packageExported.toString == "packageExported");
  assert(ActivityType.packageImported.toString == "packageImported");
  assert(ActivityType.packageDeleted.toString == "packageDeleted");
  assert(ActivityType.providerRegistered.toString == "providerRegistered");
  assert(ActivityType.providerDeregistered.toString == "providerDeregistered");
  assert(ActivityType.transportCreated.toString == "transportCreated");
  assert(ActivityType.transportReleased.toString == "transportReleased");
  assert(ActivityType.transportFailed.toString == "transportFailed");
  assert(ActivityType.exportStarted.toString == "exportStarted");
  assert(ActivityType.exportCompleted.toString == "exportCompleted");
  assert(ActivityType.exportFailed.toString == "exportFailed");
  assert(ActivityType.importStarted.toString == "importStarted");
  assert(ActivityType.importCompleted.toString == "importCompleted");
  assert(ActivityType.importFailed.toString == "importFailed");
  assert(ActivityType.queueConfigured.toString == "queueConfigured");

  assert(["packageCreated", "exportCompleted"].toActivityTypes == [
      ActivityType.packageCreated, ActivityType.exportCompleted
    ]);

  assert([ActivityType.packageCreated, ActivityType.exportCompleted].toStrings == [
      "packageCreated", "exportCompleted"
    ]);
}

/// Severity level for activities.
enum ActivitySeverity {
  info,
  warning,
  error,
}
ActivitySeverity toActivitySeverity(string value) {
  mixin(EnumSwitch("ActivitySeverity", "info"));
}

ActivitySeverity[] toActivitySeverities(string[] values)
  => values.map!toActivitySeverity.array;

string toString(ActivitySeverity value)
  => value.to!string;

string[] toStrings(ActivitySeverity[] values)
  => values.map!toString.array;

///
unittest {
  mixin(ShowTest!("ActivitySeverity"));

  assert("info".toActivitySeverity == ActivitySeverity.info);
  assert("warning".toActivitySeverity == ActivitySeverity.warning);
  assert("error".toActivitySeverity == ActivitySeverity.error);

  assert("".toActivitySeverity == ActivitySeverity.info);
  assert("unknown".toActivitySeverity == ActivitySeverity.info);

  assert(ActivitySeverity.info.toString == "info");
  assert(ActivitySeverity.warning.toString == "warning");
  assert(ActivitySeverity.error.toString == "error");

  assert(["info", "error"].toActivitySeverities == [
      ActivitySeverity.info, ActivitySeverity.error
    ]);
  assert([ActivitySeverity.info, ActivitySeverity.error].toStrings == ["info", "error"]);
}
