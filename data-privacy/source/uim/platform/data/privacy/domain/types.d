/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.domain.types;

/// Unique identifier type aliases for type safety.
alias DataSubjectId = string;
alias PersonalDataModelId = string;
alias DeletionRequestId = string;
alias BlockingRequestId = string;
alias LegalGroundId = string;
alias RetentionRuleId = string;
alias ConsentRecordId = string;
alias DataRetrievalRequestId = string;
alias TenantId = string;
alias UserId = string;

/// Type of data subject whose personal data is processed.
enum DataSubjectType {
  naturalPerson,
  employee,
  customer,
  vendor,
  partner,
  applicant,
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

/// Legal basis for processing personal data (GDPR Art. 6).
enum LegalBasis {
  consent, // Art. 6(1)(a)
  contract, // Art. 6(1)(b)
  legalObligation, // Art. 6(1)(c)
  vitalInterest, // Art. 6(1)(d)
  publicTask, // Art. 6(1)(e)
  legitimateInterest, // Art. 6(1)(f)
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

/// Status of a consent record.
enum ConsentStatus {
  pending,
  granted,
  revoked,
  expired,
}

/// Status of a data deletion request (GDPR Art. 17).
enum DeletionStatus {
  requested,
  inProgress,
  completed,
  failed,
  blocked,
}

/// Status of a data blocking / restriction request (GDPR Art. 18).
enum BlockingStatus {
  requested,
  active,
  released,
}

/// Status of a data retrieval / access request (GDPR Art. 15).
enum RetrievalStatus {
  requested,
  inProgress,
  completed,
  failed,
}

/// Sensitivity classification for personal data fields.
enum DataSensitivity {
  standard,
  sensitive, // GDPR Art. 9 special categories
  highlyConfidential,
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

/// Retention rule status.
enum RetentionRuleStatus {
  active,
  inactive,
  expired,
}
