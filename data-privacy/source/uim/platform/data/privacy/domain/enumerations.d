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

  assert([DataSubjectType.naturalPerson, DataSubjectType.employee].toStrings == ["naturalPerson", "employee"]);
  assert(["naturalPerson", "employee"].toDataSubjectTypes == [DataSubjectType.naturalPerson, DataSubjectType.employee]);
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

  assert([PersonalDataCategory.identification, PersonalDataCategory.contact].toStrings == ["identification", "contact"]);
  assert(["identification", "contact"].toPersonalDataCategories == [PersonalDataCategory.identification, PersonalDataCategory.contact]);
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
  return values.map!(v => toLegalBasis(v, ignoreCase)).array;
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

  assert([LegalBasis.consent, LegalBasis.contract].toStrings == ["consent", "contract"]);
  assert(["consent", "contract"].toLegalBases == [LegalBasis.consent, LegalBasis.contract]);
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
toProcessingPurpose[] toProcessingPurposes(string[] values) {
  return values.map!(v => toProcessingPurpose(v, ignoreCase)).array;
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

  assert([ProcessingPurpose.serviceDelivery, ProcessingPurpose.marketing].toStrings == ["serviceDelivery", "marketing"]);
  assert(["serviceDelivery", "marketing"].toProcessingPurposes == [ProcessingPurpose.serviceDelivery, ProcessingPurpose.marketing]);
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
  return values.map!(v => toConsentStatus(v, ignoreCase)).array;
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

  assert([ConsentStatus.pending, ConsentStatus.granted].toStrings == ["pending", "granted"]);
  assert(["pending", "granted"].toConsentStatuses == [ConsentStatus.pending, ConsentStatus.granted]);
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
  return values.map!(v => toDeletionStatus(v, ignoreCase)).array;
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

  assert([DeletionStatus.requested, DeletionStatus.inProgress].toStrings == ["requested", "inProgress"]);
  assert(["requested", "inProgress"].toDeletionStatuses == [DeletionStatus.requested, DeletionStatus.inProgress]);    
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
  return values.map!(v => toBlockingStatus(v, ignoreCase)).array;
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

  assert([BlockingStatus.requested, BlockingStatus.active].toStrings == ["requested", "active"]);
  assert(["requested", "active"].toBlockingStatuses == [BlockingStatus.requested, BlockingStatus.active]);
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
  return values.map!(v => toRetrievalStatus(v, ignoreCase)).array;
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

  assert([RetrievalStatus.requested, RetrievalStatus.inProgress].toStrings == ["requested", "inProgress"]);
  assert(["requested", "inProgress"].toRetrievalStatuses == [RetrievalStatus.requested, RetrievalStatus.inProgress]);
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
  return values.map!(v => toDataSensitivity(v, ignoreCase)).array;
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

  assert([DataSensitivity.standard, DataSensitivity.sensitive].toStrings == ["standard", "sensitive"]);
  assert(["standard", "sensitive"].toDataSensitivities == [DataSensitivity.standard, DataSensitivity.sensitive]);
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
  return values.map!(v => toRequestType(v, ignoreCase)).array;
}
string toString(RequestType type) {
  return type.to!string;
}
string[] toStrings(RequestType[] types) {
  return types.map!toString.array;

/// Retention rule status.
enum RetentionRuleStatus {
  active,
  inactive,
  expired,
}

RetentionRuleStatus toRetentionRuleStatus(string value) {
  switch (ignoreCase ? value.toLower() : value) {
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
  switch (ignoreCase ? value.toLower() : value) {
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
  switch (ignoreCase ? value.toLower() : value) {
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
  switch (ignoreCase ? value.toLower() : value) {
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
  switch (ignoreCase ? value.toLower() : value) {
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
  switch (ignoreCase ? value.toLower() : value) {
  case "expiring":
    return PurposeRecordStatus.expiring;
  case "expired":
    return PurposeRecordStatus.expired;
  case "deactivated":
    return PurposeRecordStatus.deactivated;
  default:
    return PurposeRecordStatus.active; // default
  }
}
/// Status of a consent purpose configuration.
enum ConsentPurposeStatus {
  draft,
  active,
  inactive,
  deprecated_,
}
ConsentPurposeStatus toConsentPurposeStatus(string value) {
  switch (ignoreCase ? value.toLower() : value) {
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
/// Status of a rule set.
enum RuleSetStatus {
  draft,
  active,
  inactive,
}
RuleSetStatus toRuleSetStatus(string value) {
  switch (ignoreCase ? value.toLower() : value) {
  case "draft":
    return RuleSetStatus.draft;
  case "inactive":
    return RuleSetStatus.inactive;
  default:
    return RuleSetStatus.active; // default
  }
}
/// Status of an information report.
enum InformationReportStatus {
  requested,
  generating,
  completed,
  failed,
}
InformationReportStatus toInformationReportStatus(string value) {
  switch (ignoreCase ? value.toLower() : value) {
  case "generating":
    return InformationReportStatus.generating;
  case "completed":
    return InformationReportStatus.completed;
  case "failed":
    return InformationReportStatus.failed;
  default:
    return InformationReportStatus.requested; // default
  }
}
/// Export format for information reports.
enum ExportFormat {
  pdf,
  json,
  xml,
  csv,
}
ExportFormat toExportFormat(string value) {
  switch (ignoreCase ? value.toLower() : value) {
  case "json":
    return ExportFormat.json;
  case "xml":
    return ExportFormat.xml;  
  case "csv":
    return ExportFormat.csv;
  default:    return ExportFormat.pdf; // default
  }
}
/// Status of a business context version.
enum BusinessContextStatus {
  draft,
  active,
  inactive,
}
BusinessContextStatus toBusinessContextStatus(string value) {
  switch (ignoreCase ? value.toLower() : value) {
  case "draft":
    return BusinessContextStatus.draft;
  case "inactive":
    return BusinessContextStatus.inactive;
  default:
    return BusinessContextStatus.active; // default
  }
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
  switch (ignoreCase ? value.toLower() : value) {
  case "generalization":
    return AnonymizationMethod.generalization;
  case "suppression":
    return AnonymizationMethod.suppression;
  case "pseudonymization":
    return AnonymizationMethod.pseudonymization;
  case "tokenization":
    return AnonymizationMethod.tokenization;
  case "noise":
    return AnonymizationMethod.noise;
  default:
    return AnonymizationMethod.masking; // default
  }
}
/// Status of an anonymization config.
enum AnonymizationConfigStatus {
  draft,
  active,
  inactive,
}
AnonymizationConfigStatus toAnonymizationConfigStatus(string value) {
  switch (ignoreCase ? value.toLower() : value) {
  case "draft":
    return AnonymizationConfigStatus.draft;
  case "inactive":
    return AnonymizationConfigStatus.inactive;
  default:
    return AnonymizationConfigStatus.active; // default
  }
} 
/// Rule operator for rule set conditions.
enum RuleOperator {
  equals,
  notEquals,
  contains,
  startsWith,
  endsWith,
  greaterThan,
  lessThan,
  in_,
  notIn,
}
RuleOperator toRuleOperator(string value) {
  switch (ignoreCase ? value.toLower() : value) {
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
