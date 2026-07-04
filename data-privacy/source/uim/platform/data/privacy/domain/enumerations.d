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
DataSubjectType toDataSubjectType(string str) {
  switch (str.toLower) {
  case "employee":
    return DataSubjectType.employee;
  case "customer":
    return DataSubjectType.customer;
  case "vendor":
    return DataSubjectType.vendor;
  case "partner":
    return DataSubjectType.partner;
  case "applicant":
    return DataSubjectType.applicant;
  default:
    return DataSubjectType.naturalPerson; // default
  }
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
PersonalDataCategory toPersonalDataCategory(string s) {
  switch (s.toLower) {
  case "contact":
    return PersonalDataCategory.contact;
  case "financial":
    return PersonalDataCategory.financial;
  case "health":
    return PersonalDataCategory.health;
  case "biometric":
    return PersonalDataCategory.biometric;
  case "ethnic":
    return PersonalDataCategory.ethnic;
  case "political":
    return PersonalDataCategory.political;
  case "religious":
    return PersonalDataCategory.religious;
  case "tradeunion":
    return PersonalDataCategory.tradeUnion;
  case "genetic":
    return PersonalDataCategory.genetic;
  case "criminal":
    return PersonalDataCategory.criminal;
  case "location":
    return PersonalDataCategory.location;
  case "behavioral":
    return PersonalDataCategory.behavioral;
  default:
    return PersonalDataCategory.identification; // default
  }
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
LegalBasis toLegalBasis(string s) {
  switch (s.toLower()) {
  case "contract":
    return LegalBasis.contract;
  case "legalobligation":
    return LegalBasis.legalObligation;
  case "vitalinterest":
    return LegalBasis.vitalInterest;
  case "publictask":
    return LegalBasis.publicTask;
  case "legitimateinterest":
    return LegalBasis.legitimateInterest;
  default:
    return LegalBasis.consent; // default
  }
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

ProcessingPurpose toProcessingPurpose(string str) {
  switch (str.toLower) {
  case "servicedelivery":
    return ProcessingPurpose.serviceDelivery;
  case "marketing":
    return ProcessingPurpose.marketing;
  case "analytics":
    return ProcessingPurpose.analytics;
  case "compliance":
    return ProcessingPurpose.compliance;
  case "humanresources":
    return ProcessingPurpose.humanResources;
  case "customersupport":
    return ProcessingPurpose.customerSupport;
  case "billing":
    return ProcessingPurpose.billing;
  case "security":
    return ProcessingPurpose.security;
  case "research":
    return ProcessingPurpose.research;
  default:
    return ProcessingPurpose.serviceDelivery; // default
  }
}

/// Status of a consent record.
enum ConsentStatus {
  pending,
  granted,
  revoked,
  expired,
}
ConsentStatus toConsentStatus(string s) {
  switch (s.toLower()) {
  case "granted":
    return ConsentStatus.granted;
  case "revoked":
    return ConsentStatus.revoked;
  case "expired":
    return ConsentStatus.expired;
  default:
    return ConsentStatus.pending; // default
  }
}

/// Status of a data deletion request (GDPR Art. 17).
enum DeletionStatus {
  requested,
  inProgress,
  completed,
  failed,
  blocked,
}
DeletionStatus toDeletionStatus(string s) {
  switch (s.toLower()) {
  case "inprogress":
    return DeletionStatus.inProgress;
  case "completed":
    return DeletionStatus.completed;
  case "failed":
    return DeletionStatus.failed;
  case "blocked":
    return DeletionStatus.blocked;
  default:
    return DeletionStatus.requested; // default
  }
}
/// Status of a data blocking / restriction request (GDPR Art. 18).
enum BlockingStatus {
  requested,
  active,
  released,
}
BlockingStatus toBlockingStatus(string s) {
  switch (s.toLower()) {
  case "active":
    return BlockingStatus.active;
  case "released":
    return BlockingStatus.released;
  default:
    return BlockingStatus.requested; // default
  }
}
/// Status of a data retrieval / access request (GDPR Art. 15).
enum RetrievalStatus {
  requested,
  inProgress,
  completed,
  failed,
}
RetrievalStatus toRetrievalStatus(string s) {
  switch (s.toLower()) {
  case "inprogress":
    return RetrievalStatus.inProgress;
  case "completed":
    return RetrievalStatus.completed;
  case "failed":
    return RetrievalStatus.failed;
  default:
    return RetrievalStatus.requested; // default
  }
}
/// Sensitivity classification for personal data fields.
enum DataSensitivity {
  standard,
  sensitive, // GDPR Art. 9 special categories
  highlyConfidential,
}
DataSensitivity toDataSensitivity(string s) {
  switch (s.toLower()) {
  case "sensitive":
    return DataSensitivity.sensitive;
  case "highlyconfidential":
    return DataSensitivity.highlyConfidential;
  default:
    return DataSensitivity.standard; // default
  }
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
RequestType toRequestType(string s) {
  switch (s.toLower()) {
  case "deletion":
    return RequestType.deletion;
  case "rectification":
    return RequestType.rectification;
  case "portability":
    return RequestType.portability;
  case "restriction":
    return RequestType.restriction;
  case "objection":
    return RequestType.objection;
  default:
    return RequestType.access; // default
  }
}
/// Retention rule status.
enum RetentionRuleStatus {
  active,
  inactive,
  expired,
}

RetentionRuleStatus toRetentionRuleStatus(string value) {
  switch (value.toLower()) {
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
CorrectionStatus toCorrectionStatus(string s) {
  switch (s.toLower()) {
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
ArchiveStatus toArchiveStatus(string s) {
  switch (s.toLower()) {
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
PortabilityStatus toPortabilityStatus(string s) {
  switch (s.toLower()) {
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
DestructionStatus toDestructionStatus(string s) {
  switch (s.toLower()) {
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
PurposeRecordStatus toPurposeRecordStatus(string s) {
  switch (s.toLower()) {
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
ConsentPurposeStatus toConsentPurposeStatus(string s) {
  switch (s.toLower()) {
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
RuleSetStatus toRuleSetStatus(string s) {
  switch (s.toLower()) {
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
InformationReportStatus toInformationReportStatus(string s) {
  switch (s.toLower()) {
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
ExportFormat toExportFormat(string s) {
  switch (s.toLower()) {
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
BusinessContextStatus toBusinessContextStatus(string s) {
  switch (s.toLower()) {
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
AnonymizationMethod toAnonymizationMethod(string s) {
  switch (s.toLower()) {
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
AnonymizationConfigStatus toAnonymizationConfigStatus(string s) {
  switch (s.toLower()) {
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
RuleOperator toRuleOperator(string s) {
  switch (s.toLower()) {
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
