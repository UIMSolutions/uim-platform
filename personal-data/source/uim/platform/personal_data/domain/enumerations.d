/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.domain.enumerations;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:
/// Type of data subject (GDPR)
enum DataSubjectType {
    privatePerson,
    corporateContact,
    employee,
    contractor,
    minor
}

DataSubjectType toDataSubjectType(string value) {
    mixin(EnumSwitch("DataSubjectType", "privatePerson"));
}

DataSubjectType[] toDataSubjectTypes(string[] arr) {
    return arr.map!toDataSubjectType.array;
}

string toString(DataSubjectType t) {
    return t.to!string;
}

string[] toStrings(DataSubjectType[] arr) {
    return arr.map!toString.array;
}

///
unittest {
    mixin(ShowTest!("DataSubjectType"));

    assert("privatePerson".toDataSubjectType == DataSubjectType.privatePerson);
    assert("corporateContact".toDataSubjectType == DataSubjectType.corporateContact);
    assert("employee".toDataSubjectType == DataSubjectType.employee);
    assert("contractor".toDataSubjectType == DataSubjectType.contractor);
    assert("minor".toDataSubjectType == DataSubjectType.minor);

    assert("".toDataSubjectType == DataSubjectType.privatePerson);
    assert("unknown".toDataSubjectType == DataSubjectType.privatePerson);

    assert(DataSubjectType.privatePerson.toString == "privatePerson");
    assert(DataSubjectType.corporateContact.toString == "corporateContact");
    assert(DataSubjectType.employee.toString == "employee");   
    assert(DataSubjectType.contractor.toString == "contractor");
    assert(DataSubjectType.minor.toString == "minor");

    assert([DataSubjectType.privatePerson, DataSubjectType.employee].toStrings == ["privatePerson", "employee"]);
    assert(["privatePerson", "employee"].toDataSubjectTypes == [DataSubjectType.privatePerson, DataSubjectType.employee]);
}

/// Status of a data subject record
enum DataSubjectStatus {
    active,
    inactive,
    blocked,
    erased,
    anonymized
}

DataSubjectStatus toDataSubjectStatus(string value) {
    mixin(EnumSwitch("DataSubjectStatus", "active"));
}

DataSubjectStatus[] toDataSubjectStatuses(string[] arr) {
    return arr.map!toDataSubjectStatus.array;
}

string toString(DataSubjectStatus s) {
    return s.to!string;
}

string[] toStrings(DataSubjectStatus[] arr) {
    return arr.map!toString.array;
}

///
unittest {
    mixin(ShowTest!("DataSubjectStatus"));

    assert("active".toDataSubjectStatus == DataSubjectStatus.active);
    assert("inactive".toDataSubjectStatus == DataSubjectStatus.inactive);
    assert("blocked".toDataSubjectStatus == DataSubjectStatus.blocked);
    assert("erased".toDataSubjectStatus == DataSubjectStatus.erased);
    assert("anonymized".toDataSubjectStatus == DataSubjectStatus.anonymized);

    assert("".toDataSubjectStatus == DataSubjectStatus.active);
    assert("unknown".toDataSubjectStatus == DataSubjectStatus.active);

    assert(DataSubjectStatus.active.toString == "active");
    assert(DataSubjectStatus.inactive.toString == "inactive");
    assert(DataSubjectStatus.blocked.toString == "blocked");
    assert(DataSubjectStatus.erased.toString == "erased");
    assert(DataSubjectStatus.anonymized.toString == "anonymized");

    assert([DataSubjectStatus.active, DataSubjectStatus.blocked].toStrings == ["active", "blocked"]);
    assert(["active", "blocked"].toDataSubjectStatuses == [DataSubjectStatus.active, DataSubjectStatus.blocked]);
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

RequestType toRequestType(string value) {
    mixin(EnumSwitch("RequestType", "information"));
}

RequestType[] toRequestTypes(string[] arr) {
    return arr.map!toRequestType.array;
}

string toString(RequestType t) {
    return t.to!string;
}

string[] toStrings(RequestType[] arr) {
    return arr.map!toString.array;
}

///
unittest {
    mixin(ShowTest!("RequestType"));

    assert("information".toRequestType == RequestType.information);
    assert("correction".toRequestType == RequestType.correction);
    assert("erasure".toRequestType == RequestType.erasure);
    assert("restriction".toRequestType == RequestType.restriction);
    assert("portability".toRequestType == RequestType.portability);
    assert("objection".toRequestType == RequestType.objection);
    assert("consentWithdrawal".toRequestType == RequestType.consentWithdrawal);

    assert("".toRequestType == RequestType.information);
    assert("unknown".toRequestType == RequestType.information);

    assert(RequestType.information.toString == "information");
    assert(RequestType.correction.toString == "correction");
    assert(RequestType.erasure.toString == "erasure");
    assert(RequestType.restriction.toString == "restriction");
    assert(RequestType.portability.toString == "portability");
    assert(RequestType.objection.toString == "objection");
    assert(RequestType.consentWithdrawal.toString == "consentWithdrawal");

    assert([RequestType.information, RequestType.erasure].toStrings == ["information", "erasure"]);
    assert(["information", "erasure"].toRequestTypes == [RequestType.information, RequestType.erasure]);
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

RequestStatus toRequestStatus(string value) {
    mixin(EnumSwitch("RequestStatus", "submitted"));
}

RequestStatus[] toRequestStatuses(string[] arr) {
    return arr.map!toRequestStatus.array;
}

string toString(RequestStatus s) {
    return s.to!string;
}

string[] toStrings(RequestStatus[] arr) {
    return arr.map!toString.array;
}

/// 
unittest {
    mixin(ShowTest!("RequestStatus"));

    assert("submitted".toRequestStatus == RequestStatus.submitted);
    assert("acknowledged".toRequestStatus == RequestStatus.acknowledged);
    assert("inReview".toRequestStatus == RequestStatus.inReview);
    assert("processing".toRequestStatus == RequestStatus.processing);
    assert("completed".toRequestStatus == RequestStatus.completed);
    assert("rejected".toRequestStatus == RequestStatus.rejected);
    assert("cancelled".toRequestStatus == RequestStatus.cancelled);

    assert("".toRequestStatus == RequestStatus.submitted);
    assert("unknown".toRequestStatus == RequestStatus.submitted);

    assert(RequestStatus.submitted.toString == "submitted");
    assert(RequestStatus.acknowledged.toString == "acknowledged");
    assert(RequestStatus.inReview.toString == "inReview");
    assert(RequestStatus.processing.toString == "processing");
    assert(RequestStatus.completed.toString == "completed");
    assert(RequestStatus.rejected.toString == "rejected");
    assert(RequestStatus.cancelled.toString == "cancelled");

    assert([RequestStatus.submitted, RequestStatus.processing].toStrings == ["submitted", "processing"]);
    assert(["submitted", "processing"].toRequestStatuses == [RequestStatus.submitted, RequestStatus.processing]);
}

/// Priority of a data subject request
enum RequestPriority {
    low,
    medium,
    high,
    urgent
}

RequestPriority toRequestPriority(string value) {
    mixin(EnumSwitch("RequestPriority", "medium"));
}

RequestPriority[] toRequestPriorities(string[] arr) {
    return arr.map!toRequestPriority.array;
}

string toString(RequestPriority p) {
    return p.to!string;
}

string[] toStrings(RequestPriority[] arr) {
    return arr.map!toString.array;
}

/// 
unittest {
    mixin(ShowTest!("RequestPriority"));

    assert("low".toRequestPriority == RequestPriority.low);
    assert("medium".toRequestPriority == RequestPriority.medium);
    assert("high".toRequestPriority == RequestPriority.high);
    assert("urgent".toRequestPriority == RequestPriority.urgent);

    assert("".toRequestPriority == RequestPriority.medium);
    assert("unknown".toRequestPriority == RequestPriority.medium);

    assert(RequestPriority.low.toString == "low");
    assert(RequestPriority.medium.toString == "medium");
    assert(RequestPriority.high.toString == "high");
    assert(RequestPriority.urgent.toString == "urgent");

    assert([RequestPriority.low, RequestPriority.high].toStrings == ["low", "high"]);
    assert(["low", "high"].toRequestPriorities == [RequestPriority.low, RequestPriority.high]);
}

/// Sensitivity level of personal data
enum DataSensitivity {
    standard,         /// Regular personal data
    sensitive,        /// Special categories (Art. 9): health, religion, biometric
    highlyConfidential /// Financial, government ID
}

DataSensitivity toDataSensitivity(string value) {
    mixin(EnumSwitch("DataSensitivity", "standard"));
}

DataSensitivity[] toDataSensitivities(string[] arr) {
    return arr.map!toDataSensitivity.array;
}

string toString(DataSensitivity s) {
    return s.to!string;
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

DataCategoryType toDataCategoryType(string value) {
    mixin(EnumSwitch("DataCategoryType", "other"));
}

DataCategoryType[] toDataCategoryTypes(string[] arr) {
    return arr.map!toDataCategoryType.array;
}

string toString(DataCategoryType c) {
    return c.to!string;
}

string[] toStrings(DataCategoryType[] categories) {
    return categories.map!toString.array;
}

/// 
unittest {
    mixin(ShowTest!("DataCategoryType"));

    assert("identification".toDataCategoryType == DataCategoryType.identification);
    assert("contact".toDataCategoryType == DataCategoryType.contact);
    assert("financial".toDataCategoryType == DataCategoryType.financial);
    assert("employment".toDataCategoryType == DataCategoryType.employment);
    assert("health".toDataCategoryType == DataCategoryType.health);
    assert("biometric".toDataCategoryType == DataCategoryType.biometric);
    assert("location".toDataCategoryType == DataCategoryType.location);
    assert("behavioral".toDataCategoryType == DataCategoryType.behavioral);
    assert("communication".toDataCategoryType == DataCategoryType.communication);
    assert("government".toDataCategoryType == DataCategoryType.government);
    assert("authentication".toDataCategoryType == DataCategoryType.authentication);
    assert("other".toDataCategoryType == DataCategoryType.other);

    assert("".toDataCategoryType == DataCategoryType.other);
    assert("unknown".toDataCategoryType == DataCategoryType.other);

    assert(DataCategoryType.identification.toString == "identification");
    assert(DataCategoryType.contact.toString == "contact");
    assert(DataCategoryType.financial.toString == "financial");
    assert(DataCategoryType.employment.toString == "employment");
    assert(DataCategoryType.health.toString == "health");
    assert(DataCategoryType.biometric.toString == "biometric");
    assert(DataCategoryType.location.toString == "location");
    assert(DataCategoryType.behavioral.toString == "behavioral");
    assert(DataCategoryType.communication.toString == "communication");
    assert(DataCategoryType.government.toString == "government");
    assert(DataCategoryType.authentication.toString == "authentication");
    assert(DataCategoryType.other.toString == "other");

    assert([DataCategoryType.identification, DataCategoryType.contact].toStrings == ["identification", "contact"]);
    assert(["identification", "contact"].toDataCategoryTypes == [DataCategoryType.identification, DataCategoryType.contact]);
}

/// Status of a registered application
enum ApplicationStatus {
    registered,
    active,
    suspended,
    deregistered
}

ApplicationStatus toApplicationStatus(string value) {
    mixin(EnumSwitch("ApplicationStatus", "registered"));
}

ApplicationStatus[] toApplicationStatuses(string[] arr) {
    return arr.map!toApplicationStatus.array;
}

string toString(ApplicationStatus s) {
    return s.to!string;
}

string[] toStrings(ApplicationStatus[] statuses) {
    return statuses.map!toString.array;
}

/// 
unittest {
    mixin(ShowTest!("ApplicationStatus"));

    assert("registered".toApplicationStatus == ApplicationStatus.registered);
    assert("active".toApplicationStatus == ApplicationStatus.active);
    assert("suspended".toApplicationStatus == ApplicationStatus.suspended);
    assert("deregistered".toApplicationStatus == ApplicationStatus.deregistered);

    assert("".toApplicationStatus == ApplicationStatus.registered);
    assert("unknown".toApplicationStatus == ApplicationStatus.registered);

    assert(ApplicationStatus.registered.toString == "registered");
    assert(ApplicationStatus.active.toString == "active");
    assert(ApplicationStatus.suspended.toString == "suspended");
    assert(ApplicationStatus.deregistered.toString == "deregistered");

    assert([ApplicationStatus.registered, ApplicationStatus.active].toStrings == ["registered", "active"]);
    assert(["registered", "active"].toApplicationStatuses == [ApplicationStatus.registered, ApplicationStatus.active]);
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

LegalBasis toLegalBasis(string value) {
    mixin(EnumSwitch("LegalBasis", "consent"));
}

LegalBasis[] toLegalBases(string[] arr) {
    return arr.map!toLegalBasis.array;
}

string toString(LegalBasis b) {
    return b.to!string;
}

string[] toStrings(LegalBasis[] bases) {
    return bases.map!toString.array;
}

///
unittest {
    mixin(ShowTest!("LegalBasis"));

    assert("consent".toLegalBasis == LegalBasis.consent);
    assert("contractualNecessity".toLegalBasis == LegalBasis.contractualNecessity);
    assert("legalObligation".toLegalBasis == LegalBasis.legalObligation);
    assert("vitalInterest".toLegalBasis == LegalBasis.vitalInterest);
    assert("publicInterest".toLegalBasis == LegalBasis.publicInterest);
    assert("legitimateInterest".toLegalBasis == LegalBasis.legitimateInterest);

    assert("".toLegalBasis == LegalBasis.consent);
    assert("unknown".toLegalBasis == LegalBasis.consent);

    assert(LegalBasis.consent.toString == "consent");
    assert(LegalBasis.contractualNecessity.toString == "contractualNecessity");
    assert(LegalBasis.legalObligation.toString == "legalObligation");
    assert(LegalBasis.vitalInterest.toString == "vitalInterest");
    assert(LegalBasis.publicInterest.toString == "publicInterest");
    assert(LegalBasis.legitimateInterest.toString == "legitimateInterest");

    assert([LegalBasis.consent, LegalBasis.legalObligation].toStrings == ["consent", "legalObligation"]);
    assert(["consent", "legalObligation"].toLegalBases == [LegalBasis.consent, LegalBasis.legalObligation]);
}

/// Status of a processing purpose
enum PurposeStatus : string {
    active = "active",
    inactive = "inactive",
    deprecated_ = "deprecated",
    archived = "archived"
}

PurposeStatus toPurposeStatus(string value) {
   switch(value.toLower) {
        case "active": return PurposeStatus.active;
        case "inactive": return PurposeStatus.inactive;
        case "deprecated": return PurposeStatus.deprecated_;
        case "archived": return PurposeStatus.archived;
        default: return PurposeStatus.active; // Default to active if unknown
    }   
}

PurposeStatus[] toPurposeStatuses(string[] arr) {
    return arr.map!toPurposeStatus.array;
}

string toString(PurposeStatus s) {
    return cast(string)s;
}   

string[] toStrings(PurposeStatus[] statuses) {
    return statuses.map!toString.array;
}

/// 
unittest {
    mixin(ShowTest!("PurposeStatus"));

    assert("active".toPurposeStatus == PurposeStatus.active);
    assert("inactive".toPurposeStatus == PurposeStatus.inactive);
    assert("deprecated".toPurposeStatus == PurposeStatus.deprecated_);
    assert("archived".toPurposeStatus == PurposeStatus.archived);

    assert("".toPurposeStatus == PurposeStatus.active);
    assert("unknown".toPurposeStatus == PurposeStatus.active);

    assert(PurposeStatus.active.toString == "active");
    assert(PurposeStatus.inactive.toString == "inactive");
    assert(PurposeStatus.deprecated_.toString == "deprecated");
    assert(PurposeStatus.archived.toString == "archived");

    assert([PurposeStatus.active, PurposeStatus.inactive].toStrings == ["active", "inactive"]);
    assert(["active", "inactive"].toPurposeStatuses == [PurposeStatus.active, PurposeStatus.inactive]);
}

/// Consent status
enum ConsentStatus {
    given,
    withdrawn,
    expired,
    pending
}

ConsentStatus toConsentStatus(string value) {
    mixin(EnumSwitch("ConsentStatus", "pending"));
}

ConsentStatus[] toConsentStatuses(string[] arr) {
    return arr.map!toConsentStatus.array;
}

string toString(ConsentStatus s) {
    return s.to!string;
}

string[] toStrings(ConsentStatus[] statuses) {
    return statuses.map!toString.array;
}

/// 
unittest {
    mixin(ShowTest!("ConsentStatus"));

    assert("given".toConsentStatus == ConsentStatus.given);
    assert("withdrawn".toConsentStatus == ConsentStatus.withdrawn);
    assert("expired".toConsentStatus == ConsentStatus.expired);
    assert("pending".toConsentStatus == ConsentStatus.pending);

    assert("".toConsentStatus == ConsentStatus.pending);
    assert("unknown".toConsentStatus == ConsentStatus.pending);

    assert(ConsentStatus.given.toString == "given");
    assert(ConsentStatus.withdrawn.toString == "withdrawn");
    assert(ConsentStatus.expired.toString == "expired");
    assert(ConsentStatus.pending.toString == "pending");

    assert([ConsentStatus.given, ConsentStatus.expired].toStrings == ["given", "expired"]);
    assert(["given", "expired"].toConsentStatuses == [ConsentStatus.given, ConsentStatus.expired]);
}

/// Retention period unit
enum RetentionPeriodUnit {
    days,
    months,
    years
}

RetentionPeriodUnit toRetentionPeriodUnit(string value) {
    mixin(EnumSwitch("RetentionPeriodUnit", "days"));
}

RetentionPeriodUnit[] toRetentionPeriodUnits(string[] arr) {
    return arr.map!toRetentionPeriodUnit.array;
}

string toString(RetentionPeriodUnit u) {
    return u.to!string;
}

string[] toStrings(RetentionPeriodUnit[] units) {
    return units.map!toString.array;
}

///
unittest {
    mixin(ShowTest!("RetentionPeriodUnit"));

    assert("days".toRetentionPeriodUnit == RetentionPeriodUnit.days);
    assert("months".toRetentionPeriodUnit == RetentionPeriodUnit.months);
    assert("years".toRetentionPeriodUnit == RetentionPeriodUnit.years);

    assert("".toRetentionPeriodUnit == RetentionPeriodUnit.days);
    assert("unknown".toRetentionPeriodUnit == RetentionPeriodUnit.days);

    assert(RetentionPeriodUnit.days.toString == "days");
    assert(RetentionPeriodUnit.months.toString == "months");
    assert(RetentionPeriodUnit.years.toString == "years");

    assert([RetentionPeriodUnit.days, RetentionPeriodUnit.years].toStrings == ["days", "years"]);
    assert(["days", "years"].toRetentionPeriodUnits == [RetentionPeriodUnit.days, RetentionPeriodUnit.years]);
}

/// Retention rule status
enum RetentionRuleStatus {
    active,
    inactive,
    expired
}

RetentionRuleStatus toRetentionRuleStatus(string value) {
    mixin(EnumSwitch("RetentionRuleStatus", "active"));
}

RetentionRuleStatus[] toRetentionRuleStatuses(string[] arr) {
    return arr.map!toRetentionRuleStatus.array;
}
string toString(RetentionRuleStatus s) {
    return s.to!string;
}

string[] toStrings(RetentionRuleStatus[] statuses) {
    return statuses.map!toString.array;
}

///
unittest {
    mixin(ShowTest!("RetentionRuleStatus"));

    assert("active".toRetentionRuleStatus == RetentionRuleStatus.active);
    assert("inactive".toRetentionRuleStatus == RetentionRuleStatus.inactive);
    assert("expired".toRetentionRuleStatus == RetentionRuleStatus.expired);

    assert("".toRetentionRuleStatus == RetentionRuleStatus.active);
    assert("unknown".toRetentionRuleStatus == RetentionRuleStatus.active);

    assert(RetentionRuleStatus.active.toString == "active");
    assert(RetentionRuleStatus.inactive.toString == "inactive");
    assert(RetentionRuleStatus.expired.toString == "expired");

    assert([RetentionRuleStatus.active, RetentionRuleStatus.expired].toStrings == ["active", "expired"]);
    assert(["active", "expired"].toRetentionRuleStatuses == [RetentionRuleStatus.active, RetentionRuleStatus.expired]);
}


/// Type of data processing log entry
enum LogEntryType : string {
    access = "access",
    creation = "creation",
    modification = "modification",
    deletion = "deletion",
    export_ = "export",
    transfer = "transfer",
    anonymization = "anonymization",
    requestProcessing = "requestProcessing",
    consentChange = "consentChange",
    retentionEnforcement = "retentionEnforcement"
}

LogEntryType toLogEntryType(string value) {
    switch(value.toLower) {
        case "access": return LogEntryType.access;
        case "creation": return LogEntryType.creation;
        case "modification": return LogEntryType.modification;
        case "deletion": return LogEntryType.deletion;
        case "export": return LogEntryType.export_;
        case "transfer": return LogEntryType.transfer;
        case "anonymization": return LogEntryType.anonymization;
        case "requestprocessing": return LogEntryType.requestProcessing;
        case "consentchange": return LogEntryType.consentChange;
        case "retentionenforcement": return LogEntryType.retentionEnforcement;
        default: return LogEntryType.access; // Default to access if unknown
    }
}

LogEntryType[] toLogEntryTypes(string[] arr) {
    return arr.map!toLogEntryType.array;
}

string toString(LogEntryType t) {
    return cast(string)t;
}

string[] toStrings(LogEntryType[] types) {
    return types.map!toString.array;
}

/// 
unittest {
    mixin(ShowTest!("LogEntryType"));

    assert("access".toLogEntryType == LogEntryType.access);
    assert("creation".toLogEntryType == LogEntryType.creation);
    assert("modification".toLogEntryType == LogEntryType.modification);
    assert("deletion".toLogEntryType == LogEntryType.deletion);
    assert("export".toLogEntryType == LogEntryType.export_);
    assert("transfer".toLogEntryType == LogEntryType.transfer);
    assert("anonymization".toLogEntryType == LogEntryType.anonymization);
    assert("requestProcessing".toLogEntryType == LogEntryType.requestProcessing);
    assert("consentChange".toLogEntryType == LogEntryType.consentChange);
    assert("retentionEnforcement".toLogEntryType == LogEntryType.retentionEnforcement);

    assert("".toLogEntryType == LogEntryType.access);
    assert("unknown".toLogEntryType == LogEntryType.access);

    assert(LogEntryType.access.toString == "access");
    assert(LogEntryType.creation.toString == "creation");
    assert(LogEntryType.modification.toString == "modification");
    assert(LogEntryType.deletion.toString == "deletion");
    assert(LogEntryType.export_.toString == "export");
    assert(LogEntryType.transfer.toString == "transfer");
    assert(LogEntryType.anonymization.toString == "anonymization");
    assert(LogEntryType.requestProcessing.toString == "requestProcessing"); 
    assert(LogEntryType.consentChange.toString == "consentChange");
    assert(LogEntryType.retentionEnforcement.toString == "retentionEnforcement");

    assert([LogEntryType.access, LogEntryType.deletion].toStrings == ["access", "deletion"]);
    assert(["access", "deletion"].toLogEntryTypes == [LogEntryType.access, LogEntryType.deletion]);
}   

/// Severity of a log entry
enum LogSeverity {
    info,
    warning,
    error,
    critical
}

LogSeverity toLogSeverity(string value) {
    mixin(EnumSwitch("LogSeverity", "info"));
}

LogSeverity[] toLogSeverities(string[] arr) {
    return arr.map!toLogSeverity.array;
}

string toString(LogSeverity s) {
    return s.to!string;
}

string[] toStrings(LogSeverity[] severities) {
    return severities.map!toString.array;
}

///
unittest {
    mixin(ShowTest!("LogSeverity"));

    assert("info".toLogSeverity == LogSeverity.info);
    assert("warning".toLogSeverity == LogSeverity.warning);
    assert("error".toLogSeverity == LogSeverity.error);
    assert("critical".toLogSeverity == LogSeverity.critical);

    assert("".toLogSeverity == LogSeverity.info);
    assert("unknown".toLogSeverity == LogSeverity.info);

    assert(LogSeverity.info.toString == "info");
    assert(LogSeverity.warning.toString == "warning");
    assert(LogSeverity.error.toString == "error");
    assert(LogSeverity.critical.toString == "critical");

    assert([LogSeverity.info, LogSeverity.error].toStrings == ["info", "error"]);
    assert(["info", "error"].toLogSeverities == [LogSeverity.info, LogSeverity.error]);
}

/// Export format for personal data
enum ExportFormat {
    json,
    csv,
    xml,
    pdf
}

ExportFormat toExportFormat(string value) {
    mixin(EnumSwitch("ExportFormat", "json"));
}

ExportFormat[] toExportFormat(string[] arr) {
    return arr.map!toExportFormat.array;
}

string toString(ExportFormat f) {
    return f.to!string;
}

string[] toStrings(ExportFormat[] formats) {
    return formats.map!toString.array;
}

///
unittest {
    mixin(ShowTest!("ExportFormat"));

    assert("json".toExportFormat == ExportFormat.json);
    assert("csv".toExportFormat == ExportFormat.csv);
    assert("xml".toExportFormat == ExportFormat.xml);
    assert("pdf".toExportFormat == ExportFormat.pdf);

    assert("".toExportFormat == ExportFormat.json);
    assert("unknown".toExportFormat == ExportFormat.json);

    assert(ExportFormat.json.toString == "json");
    assert(ExportFormat.csv.toString == "csv");
    assert(ExportFormat.xml.toString == "xml");
    assert(ExportFormat.pdf.toString == "pdf");

    assert([ExportFormat.json, ExportFormat.pdf].toStrings == ["json", "pdf"]);
    assert(["json", "pdf"].toExportFormat == [ExportFormat.json, ExportFormat.pdf]);
}
