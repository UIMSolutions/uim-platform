/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.domain.types;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

/// Domain ID types
alias DataSubjectId = string;
alias DataSubjectRequestId = string;
alias PersonalDataRecordId = string;
alias RegisteredApplicationId = string;
alias ProcessingPurposeId = string;
alias ConsentRecordId = string;
alias RetentionRuleId = string;
alias DataProcessingLogId = string;

alias UserId = string;

/// Type of data subject (GDPR)
enum DataSubjectType {
    privatePerson,
    corporateContact,
    employee,
    contractor,
    minor
}

/// Status of a data subject record
enum DataSubjectStatus {
    active,
    inactive,
    blocked,
    erased,
    anonymized
}

/// Type of data subject request (GDPR Art. 15-22)
enum RequestType {
    information,      /// Right of access (Art. 15)
    correction,       /// Right to rectification (Art. 16)
    erasure,          /// Right to erasure / right to be forgotten (Art. 17)
    restriction,      /// Right to restriction of processing (Art. 18)
    portability,      /// Right to data portability (Art. 20)
    objection,        /// Right to object (Art. 21)
    consentWithdrawal /// Withdrawal of consent
}

/// Status of a data subject request
enum RequestStatus {
    submitted,
    acknowledged,
    inReview,
    processing,
    completed,
    rejected,
    cancelled
}

/// Priority of a data subject request
enum RequestPriority {
    low,
    medium,
    high,
    urgent
}

/// Sensitivity level of personal data
enum DataSensitivity {
    standard,         /// Regular personal data
    sensitive,        /// Special categories (Art. 9): health, religion, biometric
    highlyConfidential /// Financial, government ID
}

/// Category of personal data
enum DataCategoryType {
    identification,   /// Name, address, date of birth
    contact,          /// Email, phone, address
    financial,        /// Bank accounts, payment info
    employment,       /// Job title, company, salary
    health,           /// Medical records (Art. 9)
    biometric,        /// Fingerprints, facial recognition (Art. 9)
    location,         /// GPS, IP address
    behavioral,       /// Browsing history, preferences
    communication,    /// Emails, messages
    government,       /// Tax ID, social security, passport
    authentication,   /// Passwords, tokens
    other
}

/// Status of a registered application
enum ApplicationStatus {
    registered,
    active,
    suspended,
    deregistered
}

/// Legal basis for processing (GDPR Art. 6)
enum LegalBasis {
    consent,               /// Art. 6(1)(a) - Data subject consent
    contractualNecessity,  /// Art. 6(1)(b) - Contract performance
    legalObligation,       /// Art. 6(1)(c) - Legal obligation
    vitalInterest,         /// Art. 6(1)(d) - Vital interests
    publicInterest,        /// Art. 6(1)(e) - Public interest
    legitimateInterest     /// Art. 6(1)(f) - Legitimate interests
}

/// Status of a processing purpose
enum PurposeStatus {
    active,
    inactive,
    deprecated_,
    archived
}

/// Consent status
enum ConsentStatus {
    given,
    withdrawn,
    expired,
    pending
}

/// Retention period unit
enum RetentionPeriodUnit {
    days,
    months,
    years
}

/// Retention rule status
enum RetentionRuleStatus {
    active,
    inactive,
    expired
}

/// Type of data processing log entry
enum LogEntryType {
    access,
    creation,
    modification,
    deletion,
    export_,
    transfer,
    anonymization,
    requestProcessing,
    consentChange,
    retentionEnforcement
}

/// Severity of a log entry
enum LogSeverity {
    info,
    warning,
    error,
    critical
}

/// Export format for personal data
enum ExportFormat {
    json,
    csv,
    xml,
    pdf
}
