/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.domain.enumerations;

import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:

/// Type of data subject whose personal data is processed.
enum DataSubjectType {
  naturalPerson,
  employee,
  customer,
  vendor,
  partner,
  applicant,
}

DataSubjectType toDataSubjectType(string value) {
  mixin(EnumSwitch("DataSubjectType", "naturalPerson"));
}

DataSubjectType[] toDataSubjectTypes(string[] values) {
  return values.map!(v => toDataSubjectType(v)).array;
}

string toString(DataSubjectType type) {
  return type.to!string;
}

string[] toStrings(DataSubjectType[] types) {
  return types.map!(t => t.to!string).array;
}
///
unittest {
  mixin(ShowTest!("DataSubjectType"));

  assert("naturalPerson".toDataSubjectType == DataSubjectType.naturalPerson);
  assert("employee".toDataSubjectType == DataSubjectType.employee);
  assert("customer".toDataSubjectType == DataSubjectType.customer);
  assert("vendor".toDataSubjectType == DataSubjectType.vendor);
  assert("partner".toDataSubjectType == DataSubjectType.partner);
  assert("applicant".toDataSubjectType == DataSubjectType.applicant);

  assert("".toDataSubjectType == DataSubjectType.naturalPerson);
  assert("unknown".toDataSubjectType == DataSubjectType.naturalPerson);

  assert(DataSubjectType.naturalPerson.toString == "naturalPerson");
  assert(DataSubjectType.employee.toString == "employee");
  assert(DataSubjectType.customer.toString == "customer");
  assert(DataSubjectType.vendor.toString == "vendor");
  assert(DataSubjectType.partner.toString == "partner");
  assert(DataSubjectType.applicant.toString == "applicant");

  assert([DataSubjectType.naturalPerson, DataSubjectType.employee].toStrings == ["naturalPerson", "employee"
    ]);
  assert(["naturalPerson", "employee"].toDataSubjectTypes == [DataSubjectType.naturalPerson, DataSubjectType.employee
    ]);
}

/// Categories of personal data (GDPR Art. 9 special categories marked).
enum PersonalDataCategory {
  identification, // name, ID number, date of birth
  contact, // address, email, phone
  financial, // bank account, salary, tax
  health, // Art. 9 special category
  biometric, // Art. 9 special category
  ethnic, // Art. 9 special category
  political, // Art. 9 special category
  religious, // Art. 9 special category
  tradeUnion, // Art. 9 special category
  genetic, // Art. 9 special category
  criminal, // Art. 10
  location, // GPS, IP-based geolocation
  behavioral, // browsing, purchase history
}

PersonalDataCategory toPersonalDataCategory(string value) {
  mixin(EnumSwitch("PersonalDataCategory", "identification"));
}

PersonalDataCategory[] toPersonalDataCategories(string[] values) {
  return values.map!(v => toPersonalDataCategory(v)).array;
}

string toString(PersonalDataCategory category) {
  return category.to!string;
}

string[] toStrings(PersonalDataCategory[] categories) {
  return categories.map!(c => c.to!string).array;
}
///
unittest {
  mixin(ShowTest!("PersonalDataCategory"));

  assert("identification".toPersonalDataCategory == PersonalDataCategory.identification);
  assert("contact".toPersonalDataCategory == PersonalDataCategory.contact);
  assert("financial".toPersonalDataCategory == PersonalDataCategory.financial);
  assert("health".toPersonalDataCategory == PersonalDataCategory.health);
  assert("biometric".toPersonalDataCategory == PersonalDataCategory.biometric);
  assert("ethnic".toPersonalDataCategory == PersonalDataCategory.ethnic);
  assert("political".toPersonalDataCategory == PersonalDataCategory.political);
  assert("religious".toPersonalDataCategory == PersonalDataCategory.religious);
  assert("tradeUnion".toPersonalDataCategory == PersonalDataCategory.tradeUnion);
  assert("genetic".toPersonalDataCategory == PersonalDataCategory.genetic);
  assert("criminal".toPersonalDataCategory == PersonalDataCategory.criminal);
  assert("location".toPersonalDataCategory == PersonalDataCategory.location);
  assert("behavioral".toPersonalDataCategory == PersonalDataCategory.behavioral);

  assert("".toPersonalDataCategory == PersonalDataCategory.identification);
  assert("unknown".toPersonalDataCategory == PersonalDataCategory.identification);

  assert(PersonalDataCategory.identification.toString == "identification");
  assert(PersonalDataCategory.contact.toString == "contact");
  assert(PersonalDataCategory.financial.toString == "financial");
  assert(PersonalDataCategory.health.toString == "health");
  assert(PersonalDataCategory.biometric.toString == "biometric");
  assert(PersonalDataCategory.ethnic.toString == "ethnic");
  assert(PersonalDataCategory.political.toString == "political");
  assert(PersonalDataCategory.religious.toString == "religious");
  assert(PersonalDataCategory.tradeUnion.toString == "tradeUnion");
  assert(PersonalDataCategory.genetic.toString == "genetic");
  assert(PersonalDataCategory.criminal.toString == "criminal");
  assert(PersonalDataCategory.location.toString == "location");
  assert(PersonalDataCategory.behavioral.toString == "behavioral");

  assert([PersonalDataCategory.identification, PersonalDataCategory.contact].toStrings == ["identification", "contact"
    ]);
  assert(["identification", "contact"].toPersonalDataCategories == [PersonalDataCategory.identification, PersonalDataCategory.contact
    ]);
}

/// Legal basis for processing personal data (GDPR Art. 6).
enum LegalBasis {
  consent, // Art. 6(1)(a)
  contract, // Art. 6(1)(b)
  legalObligation, // Art. 6(1)(c)
  vitalInterest, // Art. 6(1)(d)
  publicTask, // Art. 6(1)(e)
  legitimateInterest, // Art. 6(1)(f)
}

LegalBasis toLegalBasis(string value) {
  mixin(EnumSwitch("LegalBasis", "consent"));
}

LegalBasis[] toLegalBases(string[] values) {
  return values.map!toLegalBasis.array;
}

string toString(LegalBasis basis) {
  return basis.to!string;
}

string[] toStrings(LegalBasis[] bases) {
  return bases.map!toString.array;
}
///
unittest {
  mixin(ShowTest!("LegalBasis"));

  assert("consent".toLegalBasis == LegalBasis.consent);
  assert("contract".toLegalBasis == LegalBasis.contract);
  assert("legalObligation".toLegalBasis == LegalBasis.legalObligation);
  assert("vitalInterest".toLegalBasis == LegalBasis.vitalInterest);
  assert("publicTask".toLegalBasis == LegalBasis.publicTask);
  assert("legitimateInterest".toLegalBasis == LegalBasis.legitimateInterest);

  assert("".toLegalBasis == LegalBasis.consent);
  assert("unknown".toLegalBasis == LegalBasis.consent);

  assert(LegalBasis.consent.toString == "consent");
  assert(LegalBasis.contract.toString == "contract");
  assert(LegalBasis.legalObligation.toString == "legalObligation");
  assert(LegalBasis.vitalInterest.toString == "vitalInterest");
  assert(LegalBasis.publicTask.toString == "publicTask");
  assert(LegalBasis.legitimateInterest.toString == "legitimateInterest");

  assert([LegalBasis.consent, LegalBasis.contract].toStrings == ["consent", "contract"
    ]);
  assert(["consent", "contract"].toLegalBases == [LegalBasis.consent, LegalBasis.contract
    ]);
}

/// Purpose for which personal data is processed.
enum ProcessingPurpose {
  serviceDelivery,
  marketing,
  analytics,
  compliance,
  humanResources,
  customerSupport,
  billing,
  security,
  research,
}

ProcessingPurpose toProcessingPurpose(string value) {
  mixin(EnumSwitch("ProcessingPurpose", "serviceDelivery"));
}

ProcessingPurpose[] toProcessingPurposes(string[] values) {
  return values.map!toProcessingPurpose.array;
}

string toString(ProcessingPurpose purpose) {
  return purpose.to!string;
}

string[] toStrings(ProcessingPurpose[] purposes) {
  return purposes.map!toString.array;
}
/// 
unittest {
  mixin(ShowTest!("ProcessingPurpose"));

  assert("serviceDelivery".toProcessingPurpose == ProcessingPurpose.serviceDelivery);
  assert("marketing".toProcessingPurpose == ProcessingPurpose.marketing);
  assert("analytics".toProcessingPurpose == ProcessingPurpose.analytics);
  assert("compliance".toProcessingPurpose == ProcessingPurpose.compliance);
  assert("humanResources".toProcessingPurpose == ProcessingPurpose.humanResources);
  assert("customerSupport".toProcessingPurpose == ProcessingPurpose.customerSupport);
  assert("billing".toProcessingPurpose == ProcessingPurpose.billing);
  assert("security".toProcessingPurpose == ProcessingPurpose.security);
  assert("research".toProcessingPurpose == ProcessingPurpose.research);

  assert("".toProcessingPurpose == ProcessingPurpose.serviceDelivery);
  assert("unknown".toProcessingPurpose == ProcessingPurpose.serviceDelivery);

  assert(ProcessingPurpose.serviceDelivery.toString == "serviceDelivery");
  assert(ProcessingPurpose.marketing.toString == "marketing");
  assert(ProcessingPurpose.analytics.toString == "analytics");
  assert(ProcessingPurpose.compliance.toString == "compliance");
  assert(ProcessingPurpose.humanResources.toString == "humanResources");
  assert(ProcessingPurpose.customerSupport.toString == "customerSupport");
  assert(ProcessingPurpose.billing.toString == "billing");
  assert(ProcessingPurpose.security.toString == "security");
  assert(ProcessingPurpose.research.toString == "research");

  assert([ProcessingPurpose.serviceDelivery, ProcessingPurpose.marketing].toStrings == ["serviceDelivery", "marketing"
    ]);
  assert(["serviceDelivery", "marketing"].toProcessingPurposes == [ProcessingPurpose.serviceDelivery, ProcessingPurpose.marketing
    ]);
}

/// Status of a consent record.
enum ConsentStatus {
  pending,
  granted,
  revoked,
  expired,
}

ConsentStatus toConsentStatus(string value) {
  mixin(EnumSwitch("ConsentStatus", "pending"));
}

ConsentStatus[] toConsentStatuses(string[] values) {
  return values.map!toConsentStatus.array;
}

string toString(ConsentStatus status) {
  return status.to!string;
}

string[] toStrings(ConsentStatus[] statuses) {
  return statuses.map!toString.array;
}

unittest {
  mixin(ShowTest!("ConsentStatus"));

  assert("pending".toConsentStatus == ConsentStatus.pending);
  assert("granted".toConsentStatus == ConsentStatus.granted);
  assert("revoked".toConsentStatus == ConsentStatus.revoked);
  assert("expired".toConsentStatus == ConsentStatus.expired);

  assert("".toConsentStatus == ConsentStatus.pending);
  assert("unknown".toConsentStatus == ConsentStatus.pending);

  assert(ConsentStatus.pending.toString == "pending");
  assert(ConsentStatus.granted.toString == "granted");
  assert(ConsentStatus.revoked.toString == "revoked");
  assert(ConsentStatus.expired.toString == "expired");

  assert([ConsentStatus.pending, ConsentStatus.granted].toStrings == ["pending", "granted"
    ]);
  assert(["pending", "granted"].toConsentStatuses == [ConsentStatus.pending, ConsentStatus.granted
    ]);
}

/// Status of a data deletion request (GDPR Art. 17).
enum DeletionStatus {
  requested,
  inProgress,
  completed,
  failed,
  blocked,
}

DeletionStatus toDeletionStatus(string value) {
  mixin(EnumSwitch("DeletionStatus", "requested"));
}

DeletionStatus[] toDeletionStatuses(string[] values) {
  return values.map!toDeletionStatus.array;
}

string toString(DeletionStatus status) {
  return status.to!string;
}

string[] toStrings(DeletionStatus[] statuses) {
  return statuses.map!toString.array;
}
///
unittest {
  mixin(ShowTest!("DeletionStatus"));

  assert("requested".toDeletionStatus == DeletionStatus.requested);
  assert("inProgress".toDeletionStatus == DeletionStatus.inProgress);
  assert("completed".toDeletionStatus == DeletionStatus.completed);
  assert("failed".toDeletionStatus == DeletionStatus.failed);
  assert("blocked".toDeletionStatus == DeletionStatus.blocked);

  assert("".toDeletionStatus == DeletionStatus.requested);
  assert("unknown".toDeletionStatus == DeletionStatus.requested);

  assert(DeletionStatus.requested.toString == "requested");
  assert(DeletionStatus.inProgress.toString == "inProgress");
  assert(DeletionStatus.completed.toString == "completed");
  assert(DeletionStatus.failed.toString == "failed");
  assert(DeletionStatus.blocked.toString == "blocked");

  assert([DeletionStatus.requested, DeletionStatus.inProgress].toStrings == ["requested", "inProgress"
    ]);
  assert(["requested", "inProgress"].toDeletionStatuses == [DeletionStatus.requested, DeletionStatus.inProgress
    ]);
}

/// Status of a data blocking / restriction request (GDPR Art. 18).
enum BlockingStatus {
  requested,
  active,
  released,
}

BlockingStatus toBlockingStatus(string value) {
  mixin(EnumSwitch("BlockingStatus", "requested"));
}

BlockingStatus[] toBlockingStatuses(string[] values) {
  return values.map!toBlockingStatus.array;
}

string toString(BlockingStatus status) {
  return status.to!string;
}

string[] toStrings(BlockingStatus[] statuses) {
  return statuses.map!toString.array;
}
/// 
unittest {
  mixin(ShowTest!("BlockingStatus"));

  assert("requested".toBlockingStatus == BlockingStatus.requested);
  assert("active".toBlockingStatus == BlockingStatus.active);
  assert("released".toBlockingStatus == BlockingStatus.released);

  assert("".toBlockingStatus == BlockingStatus.requested);
  assert("unknown".toBlockingStatus == BlockingStatus.requested);

  assert(BlockingStatus.requested.toString == "requested");
  assert(BlockingStatus.active.toString == "active");
  assert(BlockingStatus.released.toString == "released");

  assert([BlockingStatus.requested, BlockingStatus.active].toStrings == ["requested", "active"
    ]);
  assert(["requested", "active"].toBlockingStatuses == [BlockingStatus.requested, BlockingStatus.active
    ]);
}

/// Status of a data retrieval / access request (GDPR Art. 15).
enum RetrievalStatus {
  requested,
  inProgress,
  completed,
  failed,
}

RetrievalStatus toRetrievalStatus(string value) {
  mixin(EnumSwitch("RetrievalStatus", "requested"));
}

RetrievalStatus[] toRetrievalStatuses(string[] values) {
  return values.map!toRetrievalStatus.array;
}

string toString(RetrievalStatus status) {
  return status.to!string;
}

string[] toStrings(RetrievalStatus[] statuses) {
  return statuses.map!toString.array;
}
///
unittest {
  mixin(ShowTest!("RetrievalStatus"));

  assert("requested".toRetrievalStatus == RetrievalStatus.requested);
  assert("inProgress".toRetrievalStatus == RetrievalStatus.inProgress);
  assert("completed".toRetrievalStatus == RetrievalStatus.completed);
  assert("failed".toRetrievalStatus == RetrievalStatus.failed);

  assert("".toRetrievalStatus == RetrievalStatus.requested);
  assert("unknown".toRetrievalStatus == RetrievalStatus.requested);

  assert(RetrievalStatus.requested.toString == "requested");
  assert(RetrievalStatus.inProgress.toString == "inProgress");
  assert(RetrievalStatus.completed.toString == "completed");
  assert(RetrievalStatus.failed.toString == "failed");

  assert([RetrievalStatus.requested, RetrievalStatus.inProgress].toStrings == ["requested", "inProgress"
    ]);
  assert(["requested", "inProgress"].toRetrievalStatuses == [RetrievalStatus.requested, RetrievalStatus.inProgress
    ]);
}

/// Sensitivity classification for personal data fields.
enum DataSensitivity {
  standard,
  sensitive, // GDPR Art. 9 special categories
  highlyConfidential,
}

DataSensitivity toDataSensitivity(string value) {
  mixin(EnumSwitch("DataSensitivity", "standard"));
}

DataSensitivity[] toDataSensitivities(string[] values) {
  return values.map!toDataSensitivity.array;
}

string toString(DataSensitivity sensitivity) {
  return sensitivity.to!string;
}

string[] toStrings(DataSensitivity[] sensitivities) {
  return sensitivities.map!toString.array;
}
///
unittest {
  mixin(ShowTest!("DataSensitivity"));

  assert("standard".toDataSensitivity == DataSensitivity.standard);
  assert("sensitive".toDataSensitivity == DataSensitivity.sensitive);
  assert("highlyConfidential".toDataSensitivity == DataSensitivity.highlyConfidential);

  assert("".toDataSensitivity == DataSensitivity.standard);
  assert("unknown".toDataSensitivity == DataSensitivity.standard);

  assert(DataSensitivity.standard.toString == "standard");
  assert(DataSensitivity.sensitive.toString == "sensitive");
  assert(DataSensitivity.highlyConfidential.toString == "highlyConfidential");

  assert([DataSensitivity.standard, DataSensitivity.sensitive].toStrings == ["standard", "sensitive"
    ]);
  assert(["standard", "sensitive"].toDataSensitivities == [DataSensitivity.standard, DataSensitivity.sensitive
    ]);
}

/// Type of data subject rights request.
enum RequestType {
  access, // Art. 15
  deletion, // Art. 17
  rectification, // Art. 16
  portability, // Art. 20
  restriction, // Art. 18
  objection, // Art. 21
}

RequestType toRequestType(string value) {
  mixin(EnumSwitch("RequestType", "access"));
}

RequestType[] toRequestTypes(string[] values) {
  return values.map!toRequestType.array;
}

string toString(RequestType type) {
  return type.to!string;
}

string[] toStrings(RequestType[] types) {
  return types.map!toString.array;
}

/// Retention rule status.
enum RetentionRuleStatus {
  active,
  inactive,
  expired,
}

RetentionRuleStatus toRetentionRuleStatus(string value) {
  switch (value.toLower) {
  case "inactive":
    return RetentionRuleStatus.inactive;
  case "expired":
    return RetentionRuleStatus.expired;
  default:
    return RetentionRuleStatus.active; // default
  }
}

/// Status of a correction request (GDPR Art. 16).
enum CorrectionStatus {
  requested,
  inProgress,
  completed,
  rejected,
}

CorrectionStatus toCorrectionStatus(string value) {
  switch (value.toLower) {
  case "inprogress":
    return CorrectionStatus.inProgress;
  case "completed":
    return CorrectionStatus.completed;
  case "rejected":
    return CorrectionStatus.rejected;
  default:
    return CorrectionStatus.requested; // default
  }
}
/// Status of an archive request.
enum ArchiveStatus {
  scheduled,
  inProgress,
  completed,
  failed,
}

ArchiveStatus toArchiveStatus(string value) {
  switch (value.toLower) {
  case "scheduled":
    return ArchiveStatus.scheduled;
  case "inprogress":
    return ArchiveStatus.inProgress;
  case "completed":
    return ArchiveStatus.completed;
  case "failed":
    return ArchiveStatus.failed;
  default:
    return ArchiveStatus.scheduled; // default
  }
}
/// Status of a portability request.
enum PortabilityStatus {
  requested,
  inProgress,
  completed,
  failed,
}

PortabilityStatus toPortabilityStatus(string value) {
  switch (value.toLower) {
  case "inprogress":
    return PortabilityStatus.inProgress;
  case "completed":
    return PortabilityStatus.completed;
  case "failed":
    return PortabilityStatus.failed;
  default:
    return PortabilityStatus.requested; // default
  }
}
/// Status of a destruction request.
enum DestructionStatus {
  scheduled,
  inProgress,
  completed,
  failed,
}

DestructionStatus toDestructionStatus(string value) {
  switch (value.toLower) {
  case "scheduled":
    return DestructionStatus.scheduled;
  case "inprogress":
    return DestructionStatus.inProgress;
  case "completed":
    return DestructionStatus.completed;
  case "failed":
    return DestructionStatus.failed;
  default:
    return DestructionStatus.scheduled; // default
  }
}
/// Status of a purpose record.
enum PurposeRecordStatus {
  active,
  expiring,
  expired,
  deactivated,
}

PurposeRecordStatus toPurposeRecordStatus(string value) {
  mixin(EnumSwitch("PurposeRecordStatus", "active"));
}

PurposeRecordStatus[] toPurposeRecordStatuses(string[] values) {
  return values.map!toPurposeRecordStatus.array;
}

string toString(PurposeRecordStatus status) {
  return status.to!string;
}

string[] toStrings(PurposeRecordStatus[] statuses) {
  return statuses.map!toString.array;
}

///
unittest {
  mixin(ShowTest!("PurposeRecordStatus"));

  assert("active".toPurposeRecordStatus == PurposeRecordStatus.active);
  assert("expiring".toPurposeRecordStatus == PurposeRecordStatus.expiring);
  assert("expired".toPurposeRecordStatus == PurposeRecordStatus.expired);
  assert("deactivated".toPurposeRecordStatus == PurposeRecordStatus.deactivated);

  assert("".toPurposeRecordStatus == PurposeRecordStatus.active);
  assert("unknown".toPurposeRecordStatus == PurposeRecordStatus.active);

  assert(PurposeRecordStatus.active.toString == "active");
  assert(PurposeRecordStatus.expiring.toString == "expiring");
  assert(PurposeRecordStatus.expired.toString == "expired");
  assert(PurposeRecordStatus.deactivated.toString == "deactivated");

  assert([PurposeRecordStatus.active, PurposeRecordStatus.expiring].toStrings == ["active", "expiring"
    ]);
  assert(["active", "expiring"].toPurposeRecordStatuses == [PurposeRecordStatus.active, PurposeRecordStatus.expiring
    ]);
}

/// Status of a consent purpose configuration.
enum ConsentPurposeStatus : string {
  draft = "draft",
  active = "active",
  inactive = "inactive",
  deprecated_ = "deprecated",
}

ConsentPurposeStatus toConsentPurposeStatus(string value) {
  switch (value.toLower) {
  case "draft":
    return ConsentPurposeStatus.draft;
  case "inactive":
    return ConsentPurposeStatus.inactive;
  case "deprecated":
    return ConsentPurposeStatus.deprecated_;
  default:
    return ConsentPurposeStatus.active; // default
  }
}

ConsentPurposeStatus [] toConsentPurposeStatuses(string[] values) {
  return values.map!toConsentPurposeStatus.array;
}

string toString(ConsentPurposeStatus status) {
  return cast(string) status;
}

string[] toStrings(ConsentPurposeStatus[] statuses) {
  return statuses.map!toString.array;
}

///
unittest {
  mixin(ShowTest!("ConsentPurposeStatus"));

  assert("draft".toConsentPurposeStatus == ConsentPurposeStatus.draft);
  assert("active".toConsentPurposeStatus == ConsentPurposeStatus.active);
  assert("inactive".toConsentPurposeStatus == ConsentPurposeStatus.inactive);
  assert("deprecated".toConsentPurposeStatus == ConsentPurposeStatus.deprecated_);

  assert("".toConsentPurposeStatus == ConsentPurposeStatus.active);
  assert("unknown".toConsentPurposeStatus == ConsentPurposeStatus.active);

  assert(ConsentPurposeStatus.draft.toString == "draft");
  assert(ConsentPurposeStatus.active.toString == "active");
  assert(ConsentPurposeStatus.inactive.toString == "inactive");
  assert(ConsentPurposeStatus.deprecated_.toString == "deprecated");

  assert([ConsentPurposeStatus.draft, ConsentPurposeStatus.active].toStrings == ["draft", "active"
    ]);
  assert(["draft", "active"].toConsentPurposeStatuses == [ConsentPurposeStatus.draft, ConsentPurposeStatus.active
    ]);
}

/// Status of a rule set.
enum RuleSetStatus {
  draft,
  active,
  inactive,
}

RuleSetStatus toRuleSetStatus(string value) {
  mixin(EnumSwitch("RuleSetStatus", "draft"));
}

RuleSetStatus[] toRuleSetStatuses(string[] values) {
  return values.map!toRuleSetStatus.array;
}

string toString(RuleSetStatus status) {
  return status.to!string;
}

string[] toStrings(RuleSetStatus[] statuses) {
  return statuses.map!toString.array;
}

/// 
unittest {
  mixin(ShowTest!("RuleSetStatus"));

  assert("draft".toRuleSetStatus == RuleSetStatus.draft);
  assert("active".toRuleSetStatus == RuleSetStatus.active);
  assert("inactive".toRuleSetStatus == RuleSetStatus.inactive);

  assert("".toRuleSetStatus == RuleSetStatus.draft);
  assert("unknown".toRuleSetStatus == RuleSetStatus.draft);

  assert(RuleSetStatus.draft.toString == "draft");
  assert(RuleSetStatus.active.toString == "active");
  assert(RuleSetStatus.inactive.toString == "inactive");

  assert([RuleSetStatus.draft, RuleSetStatus.active].toStrings == ["draft", "active"
    ]);
  assert(["draft", "active"].toRuleSetStatuses == [RuleSetStatus.draft, RuleSetStatus.active
    ]);
}

/// Status of an information report.
enum InformationReportStatus {
  requested,
  generating,
  completed,
  failed,
}

InformationReportStatus toInformationReportStatus(string value) {
  mixin(EnumSwitch("InformationReportStatus", "requested"));
}

InformationReportStatus[] toInformationReportStatuses(string[] values) {
  return values.map!toInformationReportStatus.array;
}

string toString(InformationReportStatus status) {
  return status.to!string;
}

string[] toStrings(InformationReportStatus[] statuses) {
  return statuses.map!toString.array;
}
///
unittest {
  mixin(ShowTest!("InformationReportStatus"));

  assert("requested".toInformationReportStatus == InformationReportStatus.requested);
  assert("generating".toInformationReportStatus == InformationReportStatus.generating);
  assert("completed".toInformationReportStatus == InformationReportStatus.completed);
  assert("failed".toInformationReportStatus == InformationReportStatus.failed);

  assert("".toInformationReportStatus == InformationReportStatus.requested);
  assert("unknown".toInformationReportStatus == InformationReportStatus.requested);

  assert(InformationReportStatus.requested.toString == "requested");
  assert(InformationReportStatus.generating.toString == "generating");
  assert(InformationReportStatus.completed.toString == "completed");
  assert(InformationReportStatus.failed.toString == "failed");

  assert([InformationReportStatus.requested, InformationReportStatus.generating].toStrings == ["requested", "generating"
    ]);
  assert(["requested", "generating"].toInformationReportStatuses == [InformationReportStatus.requested, InformationReportStatus.generating
    ]);
}

/// Export format for information reports.
enum ExportFormat {
  pdf,
  json,
  xml,
  csv,
}

ExportFormat toExportFormat(string value) {
  mixin(EnumSwitch("ExportFormat", "pdf"));
}

ExportFormat[] toExportFormat(string[] values) {
  return values.map!toExportFormat.array;
}

string toString(ExportFormat format) {
  return format.to!string;
}

string[] toStrings(ExportFormat[] formats) {
  return formats.map!toString.array;
}

/// 
unittest {
  mixin(ShowTest!("ExportFormat"));

  assert("pdf".toExportFormat == ExportFormat.pdf);
  assert("json".toExportFormat == ExportFormat.json);
  assert("xml".toExportFormat == ExportFormat.xml);
  assert("csv".toExportFormat == ExportFormat.csv);

  assert("".toExportFormat == ExportFormat.pdf);
  assert("unknown".toExportFormat == ExportFormat.pdf);

  assert(ExportFormat.pdf.toString == "pdf");
  assert(ExportFormat.json.toString == "json");
  assert(ExportFormat.xml.toString == "xml");
  assert(ExportFormat.csv.toString == "csv");

  assert([ExportFormat.pdf, ExportFormat.json].toStrings == ["pdf", "json"
    ]);
  assert(["pdf", "json"].toExportFormat == [ExportFormat.pdf, ExportFormat.json
    ]);
}

/// Status of a business context version.
enum BusinessContextStatus {
  draft,
  active,
  inactive,
}

BusinessContextStatus toBusinessContextStatus(string value) {
  mixin(EnumSwitch("BusinessContextStatus", "draft"));
}

BusinessContextStatus[] toBusinessContextStatuses(string[] values) {
  return values.map!toBusinessContextStatus.array;
}

string toString(BusinessContextStatus status) {
  return status.to!string;
}

string[] toStrings(BusinessContextStatus[] statuses) {
  return statuses.map!toString.array;
}

///
unittest {
  mixin(ShowTest!("BusinessContextStatus"));

  assert("draft".toBusinessContextStatus == BusinessContextStatus.draft);
  assert("active".toBusinessContextStatus == BusinessContextStatus.active);
  assert("inactive".toBusinessContextStatus == BusinessContextStatus.inactive);

  assert("".toBusinessContextStatus == BusinessContextStatus.draft);
  assert("unknown".toBusinessContextStatus == BusinessContextStatus.draft);

  assert(BusinessContextStatus.draft.toString == "draft");
  assert(BusinessContextStatus.active.toString == "active");
  assert(BusinessContextStatus.inactive.toString == "inactive");

  assert([BusinessContextStatus.draft, BusinessContextStatus.active].toStrings == ["draft", "active"
    ]);
  assert(["draft", "active"].toBusinessContextStatuses == [BusinessContextStatus.draft, BusinessContextStatus.active
    ]);
}

/// Anonymization method.
enum AnonymizationMethod {
  masking,
  generalization,
  suppression,
  pseudonymization,
  tokenization,
  noise,
}

AnonymizationMethod toAnonymizationMethod(string value) {
  mixin(EnumSwitch("AnonymizationMethod", "masking"));
}

AnonymizationMethod[] toAnonymizationMethods(string[] values) {
  return values.map!toAnonymizationMethod.array;
}

string toString(AnonymizationMethod method) {
  return method.to!string;
}

string[] toStrings(AnonymizationMethod[] methods) {
  return methods.map!toString.array;
}

///
unittest {
  mixin(ShowTest!("AnonymizationMethod"));

  assert("masking".toAnonymizationMethod == AnonymizationMethod.masking);
  assert("generalization".toAnonymizationMethod == AnonymizationMethod.generalization);
  assert("suppression".toAnonymizationMethod == AnonymizationMethod.suppression);
  assert("pseudonymization".toAnonymizationMethod == AnonymizationMethod.pseudonymization);
  assert("tokenization".toAnonymizationMethod == AnonymizationMethod.tokenization);
  assert("noise".toAnonymizationMethod == AnonymizationMethod.noise);

  assert("".toAnonymizationMethod == AnonymizationMethod.masking);
  assert("unknown".toAnonymizationMethod == AnonymizationMethod.masking);

  assert(AnonymizationMethod.masking.toString == "masking");
  assert(AnonymizationMethod.generalization.toString == "generalization");
  assert(AnonymizationMethod.suppression.toString == "suppression");
  assert(AnonymizationMethod.pseudonymization.toString == "pseudonymization");
  assert(AnonymizationMethod.tokenization.toString == "tokenization");
  assert(AnonymizationMethod.noise.toString == "noise");

  assert([AnonymizationMethod.masking, AnonymizationMethod.generalization].toStrings == ["masking", "generalization"
    ]);
  assert(["masking", "generalization"].toAnonymizationMethods == [AnonymizationMethod.masking, AnonymizationMethod.generalization
    ]);
}


/// Status of an anonymization config.
enum AnonymizationConfigStatus {
  draft,
  active,
  inactive,
}

AnonymizationConfigStatus toAnonymizationConfigStatus(string value) {
  mixin(EnumSwitch("AnonymizationConfigStatus", "draft"));
}

AnonymizationConfigStatus[] toAnonymizationConfigStatuses(string[] values) {
  return values.map!toAnonymizationConfigStatus.array;
}

string toString(AnonymizationConfigStatus status) {
  return status.to!string;
}

string[] toStrings(AnonymizationConfigStatus[] statuses) {
  return statuses.map!toString.array;
}

///
unittest {
  mixin(ShowTest!("AnonymizationConfigStatus"));

  assert("draft".toAnonymizationConfigStatus == AnonymizationConfigStatus.draft);
  assert("active".toAnonymizationConfigStatus == AnonymizationConfigStatus.active);
  assert("inactive".toAnonymizationConfigStatus == AnonymizationConfigStatus.inactive);

  assert("".toAnonymizationConfigStatus == AnonymizationConfigStatus.draft);
  assert("unknown".toAnonymizationConfigStatus == AnonymizationConfigStatus.draft);

  assert(AnonymizationConfigStatus.draft.toString == "draft");
  assert(AnonymizationConfigStatus.active.toString == "active");
  assert(AnonymizationConfigStatus.inactive.toString == "inactive");

  assert([AnonymizationConfigStatus.draft, AnonymizationConfigStatus.active].toStrings == ["draft", "active"
    ]);
  assert(["draft", "active"].toAnonymizationConfigStatuses == [AnonymizationConfigStatus.draft, AnonymizationConfigStatus.active
    ]);
}

/// Rule operator for rule set conditions.
enum RuleOperator : string {
  equals = "equals",
  notEquals = "notEquals",
  contains = "contains",
  startsWith = "startsWith",
  endsWith = "endsWith",
  greaterThan = "greaterThan",
  lessThan = "lessThan",
  in_ = "in",
  notIn = "notIn",
}

RuleOperator toRuleOperator(string value) {
  switch (value.toLower) {
  case "notequals":
    return RuleOperator.notEquals;
  case "contains":
    return RuleOperator.contains;
  case "startswith":
    return RuleOperator.startsWith;
  case "endswith":
    return RuleOperator.endsWith;
  case "greaterthan":
    return RuleOperator.greaterThan;
  case "lessthan":
    return RuleOperator.lessThan;
  case "in":
    return RuleOperator.in_;
  case "notin":
    return RuleOperator.notIn;
  default:
    return RuleOperator.equals; // default
  }
}

RuleOperator[] toRuleOperators(string[] values) {
  return values.map!toRuleOperator.array;
}

string toString(RuleOperator op) {
  return cast(string) op;
}

string[] toStrings(RuleOperator[] ops) {
  return ops.map!toString.array;
}

///
unittest {
  mixin(ShowTest!("RuleOperator"));

  assert("equals".toRuleOperator == RuleOperator.equals);
  assert("notEquals".toRuleOperator == RuleOperator.notEquals);
  assert("contains".toRuleOperator == RuleOperator.contains);
  assert("startsWith".toRuleOperator == RuleOperator.startsWith);
  assert("endsWith".toRuleOperator == RuleOperator.endsWith);
  assert("greaterThan".toRuleOperator == RuleOperator.greaterThan);
  assert("lessThan".toRuleOperator == RuleOperator.lessThan);
  assert("in".toRuleOperator == RuleOperator.in_);
  assert("notIn".toRuleOperator == RuleOperator.notIn);

  assert("".toRuleOperator == RuleOperator.equals);
  assert("unknown".toRuleOperator == RuleOperator.equals);

  assert(RuleOperator.equals.toString == "equals");
  assert(RuleOperator.notEquals.toString == "notEquals");
  assert(RuleOperator.contains.toString == "contains");
  assert(RuleOperator.startsWith.toString == "startsWith");
  assert(RuleOperator.endsWith.toString == "endsWith");
  assert(RuleOperator.greaterThan.toString == "greaterThan");
  assert(RuleOperator.lessThan.toString == "lessThan");
  assert(RuleOperator.in_.toString == "in");
  assert(RuleOperator.notIn.toString == "notIn");

  assert([RuleOperator.equals, RuleOperator.notEquals].toStrings == ["equals", "notEquals"
    ]);
  assert(["equals", "notEquals"].toRuleOperators == [RuleOperator.equals, RuleOperator.notEquals
    ]);
}
