/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_retention.domain.enumerations;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

/// Status of a business purpose rule
enum BusinessPurposeStatus : string {
    inactive    = "inactive",
    active      = "active",
    deprecated_ = "deprecated"
}

BusinessPurposeStatus toBusinessPurposeStatus(string value) {
    switch (name.toLower()) {
        case "inactive": return BusinessPurposeStatus.inactive;
        case "active": return BusinessPurposeStatus.active;
        case "deprecated": return BusinessPurposeStatus.deprecated_;
        default: return BusinessPurposeStatus.inactive;
    }
}
BusinessPurposeStatus[] toBusinessPurposeStatuses(string[] names) {
    return names.map!toBusinessPurposeStatus.array;
}
string toString(BusinessPurposeStatus status) {
    return cast(string)status;
}
string[] toStrings(BusinessPurposeStatus[] statuses) {
    return statuses.map!toString.array;
}
///
unittest {
    mixin(ShowTest!("BusinessPurposeStatus"));

    assert("inactive".toBusinessPurposeStatus == BusinessPurposeStatus.inactive);
    assert("active".toBusinessPurposeStatus == BusinessPurposeStatus.active);
    assert("deprecated".toBusinessPurposeStatus == BusinessPurposeStatus.deprecated_);

    assert("".toBusinessPurposeStatus == BusinessPurposeStatus.inactive);
    assert("unknown".toBusinessPurposeStatus == BusinessPurposeStatus.inactive);

    assert(toString(BusinessPurposeStatus.inactive) == "inactive");
    assert(toString(BusinessPurposeStatus.active) == "active");
    assert(toString(BusinessPurposeStatus.deprecated_) == "deprecated");

    assert(toStrings([BusinessPurposeStatus.inactive, BusinessPurposeStatus.active]) == ["inactive", "active"]);
    assert(toBusinessPurposeStatuses(["inactive", "active"]) == [BusinessPurposeStatus.inactive, BusinessPurposeStatus.active]);
}   

/// Type of legal ground for data processing
enum LegalGroundType {
    consent,
    contract,
    legalObligation,
    vitalInterest,
    publicInterest,
    legitimateInterest
}

LegalGroundType toLegalGroundType(string value) {
    mixin(EnumSwitch("LegalGroundType", "consent"));
}
LegalGroundType[] toLegalGroundTypes(string[] names) {
    return names.map!toLegalGroundType.array;
}
string toString(LegalGroundType type) {
    return type.to!string;
}
string[] toStrings(LegalGroundType[] types) {
    return types.map!toString.array;
}
///
unittest {
    mixin(ShowTest!("LegalGroundType"));

    assert("consent".toLegalGroundType == LegalGroundType.consent);
    assert("contract".toLegalGroundType == LegalGroundType.contract);
    assert("legalObligation".toLegalGroundType == LegalGroundType.legalObligation);
    assert("vitalInterest".toLegalGroundType == LegalGroundType.vitalInterest);
    assert("publicInterest".toLegalGroundType == LegalGroundType.publicInterest);
    assert("legitimateInterest".toLegalGroundType == LegalGroundType.legitimateInterest);

    assert("".toLegalGroundType == LegalGroundType.consent);
    assert("unknown".toLegalGroundType == LegalGroundType.consent);

    assert(toString(LegalGroundType.consent) == "consent");
    assert(toString(LegalGroundType.contract) == "contract");
    assert(toString(LegalGroundType.legalObligation) == "legalObligation");
    assert(toString(LegalGroundType.vitalInterest) == "vitalInterest");
    assert(toString(LegalGroundType.publicInterest) == "publicInterest");
    assert(toString(LegalGroundType.legitimateInterest) == "legitimateInterest");

    assert(toStrings([LegalGroundType.consent, LegalGroundType.contract]) == ["consent", "contract"]);
    assert(toLegalGroundTypes(["consent", "contract"]) == [LegalGroundType.consent, LegalGroundType.contract]);
}

/// Period unit for retention and residence durations
enum PeriodUnit {
    days,
    weeks,
    months,
    years
}

PeriodUnit toPeriodUnit(string value) {
    mixin(EnumSwitch("PeriodUnit", "days"));
}
PeriodUnit[] toPeriodUnits(string[] names) {
    return names.map!toPeriodUnit.array;
}
string toString(PeriodUnit unit) {
    return unit.to!string;
}
string[] toStrings(PeriodUnit[] units) {
    return units.map!toString.array;
}
/// 
unittest {
    mixin(ShowTest!("PeriodUnit"));

    assert("days".toPeriodUnit == PeriodUnit.days);
    assert("weeks".toPeriodUnit == PeriodUnit.weeks);
    assert("months".toPeriodUnit == PeriodUnit.months);
    assert("years".toPeriodUnit == PeriodUnit.years);

    assert("".toPeriodUnit == PeriodUnit.days);
    assert("unknown".toPeriodUnit == PeriodUnit.days);

    assert(toString(PeriodUnit.days) == "days");
    assert(toString(PeriodUnit.weeks) == "weeks");
    assert(toString(PeriodUnit.months) == "months");
    assert(toString(PeriodUnit.years) == "years");

    assert(toStrings([PeriodUnit.days, PeriodUnit.weeks]) == ["days", "weeks"]);
    assert(toPeriodUnits(["days", "weeks"]) == [PeriodUnit.days, PeriodUnit.weeks]);
}

/// Status of a data subject's data lifecycle
enum DataLifecycleStatus {
    active,
    blocked,
    markedForDeletion,
    deleted,
    archived
}

DataLifecycleStatus toDataLifecycleStatus(string value) {
    mixin(EnumSwitch("DataLifecycleStatus", "active"));
}
DataLifecycleStatus[] toDataLifecycleStatuses(string[] names) {
    return names.map!toDataLifecycleStatus.array;
}
string toString(DataLifecycleStatus status) {
    return status.to!string;
}
string[] toStrings(DataLifecycleStatus[] statuses) {
    return statuses.map!toString.array;
}
/// 
unittest {
    mixin(ShowTest!("DataLifecycleStatus"));

    assert("active".toDataLifecycleStatus == DataLifecycleStatus.active);
    assert("blocked".toDataLifecycleStatus == DataLifecycleStatus.blocked);
    assert("markedForDeletion".toDataLifecycleStatus == DataLifecycleStatus.markedForDeletion);
    assert("deleted".toDataLifecycleStatus == DataLifecycleStatus.deleted);
    assert("archived".toDataLifecycleStatus == DataLifecycleStatus.archived);

    assert("".toDataLifecycleStatus == DataLifecycleStatus.active);
    assert("unknown".toDataLifecycleStatus == DataLifecycleStatus.active);

    assert(toString(DataLifecycleStatus.active) == "active");
    assert(toString(DataLifecycleStatus.blocked) == "blocked");
    assert(toString(DataLifecycleStatus.markedForDeletion) == "markedForDeletion");
    assert(toString(DataLifecycleStatus.deleted) == "deleted");
    assert(toString(DataLifecycleStatus.archived) == "archived");

    assert(toStrings([DataLifecycleStatus.active, DataLifecycleStatus.blocked]) == ["active", "blocked"]);
    assert(toDataLifecycleStatuses(["active", "blocked"]) == [DataLifecycleStatus.active, DataLifecycleStatus.blocked]);
}


/// Status of a deletion request
enum DeletionRequestStatus {
    pending,
    inProgress,
    completed,
    failed,
    cancelled
}
DeletionRequestStatus toDeletionRequestStatus(string value) {
    mixin(EnumSwitch("DeletionRequestStatus", "pending"));  
}
DeletionRequestStatus[] toDeletionRequestStatuses(string[] names) {
    return names.map!toDeletionRequestStatus.array;
}
string toString(DeletionRequestStatus status) {
    return status.to!string;
}
string[] toStrings(DeletionRequestStatus[] statuses) {
    return statuses.map!toString.array;
}
/// 
unittest {
    mixin(ShowTest!("DeletionRequestStatus"));

    assert("pending".toDeletionRequestStatus == DeletionRequestStatus.pending);
    assert("inProgress".toDeletionRequestStatus == DeletionRequestStatus.inProgress);
    assert("completed".toDeletionRequestStatus == DeletionRequestStatus.completed);
    assert("failed".toDeletionRequestStatus == DeletionRequestStatus.failed);
    assert("cancelled".toDeletionRequestStatus == DeletionRequestStatus.cancelled);

    assert("".toDeletionRequestStatus == DeletionRequestStatus.pending);
    assert("unknown".toDeletionRequestStatus == DeletionRequestStatus.pending);

    assert(toString(DeletionRequestStatus.pending) == "pending");
    assert(toString(DeletionRequestStatus.inProgress) == "inProgress");
    assert(toString(DeletionRequestStatus.completed) == "completed");
    assert(toString(DeletionRequestStatus.failed) == "failed");
    assert(toString(DeletionRequestStatus.cancelled) == "cancelled");

    assert(toStrings([DeletionRequestStatus.pending, DeletionRequestStatus.inProgress]) == ["pending", "inProgress"]);
    assert(toDeletionRequestStatuses(["pending", "inProgress"]) == [DeletionRequestStatus.pending, DeletionRequestStatus.inProgress]);
}

/// Type of deletion action
enum DeletionActionType {
    block,
    delete_,
    anonymize
}
DeletionActionType toDeletionActionType(string value) {
    mixin(EnumSwitch("DeletionActionType", "block"));
}
DeletionActionType[] toDeletionActionTypes(string[] names) {
    return names.map!toDeletionActionType.array;
}
string toString(DeletionActionType type) {
    return type.to!string;
}
string[] toStrings(DeletionActionType[] types) {
    return types.map!toString.array;
}
///
unittest {
    mixin(ShowTest!("DeletionActionType"));

    assert("block".toDeletionActionType == DeletionActionType.block);
    assert("delete".toDeletionActionType == DeletionActionType.delete_);
    assert("anonymize".toDeletionActionType == DeletionActionType.anonymize);

    assert("".toDeletionActionType == DeletionActionType.block);
    assert("unknown".toDeletionActionType == DeletionActionType.block);

    assert(DeletionActionType.block.toString == "block");
    assert(DeletionActionType.delete_.toString == "delete_");
    assert(DeletionActionType.anonymize.toString == "anonymize");

    assert([DeletionActionType.block, DeletionActionType.delete_].toStrings == ["block", "delete_"]);
    assert(["block", "delete"].toDeletionActionTypes == [DeletionActionType.block, DeletionActionType.delete_]);
}

/// Status of an archiving job
enum ArchivingJobStatus {
    scheduled,
    running,
    completed,
    failed,
    cancelled
}

ArchivingJobStatus toArchivingJobStatus(string value) {
    mixin(EnumSwitch("ArchivingJobStatus", "scheduled"));
}
ArchivingJobStatus[] toArchivingJobStatuses(string[] names) {
    return names.map!toArchivingJobStatus.array;
}
string toString(ArchivingJobStatus status) {
    return status.to!string;
}
string[] toStrings(ArchivingJobStatus[] statuses) {
    return statuses.map!toString.array;
}
/// 
unittest {
    mixin(ShowTest!("ArchivingJobStatus"));

    assert("scheduled".toArchivingJobStatus == ArchivingJobStatus.scheduled);
    assert("running".toArchivingJobStatus == ArchivingJobStatus.running);
    assert("completed".toArchivingJobStatus == ArchivingJobStatus.completed);
    assert("failed".toArchivingJobStatus == ArchivingJobStatus.failed);
    assert("cancelled".toArchivingJobStatus == ArchivingJobStatus.cancelled);

    assert("".toArchivingJobStatus == ArchivingJobStatus.scheduled);
    assert("unknown".toArchivingJobStatus == ArchivingJobStatus.scheduled);

    assert(toString(ArchivingJobStatus.scheduled) == "scheduled");
    assert(toString(ArchivingJobStatus.running) == "running");
    assert(toString(ArchivingJobStatus.completed) == "completed");
    assert(toString(ArchivingJobStatus.failed) == "failed");
    assert(toString(ArchivingJobStatus.cancelled) == "cancelled");

    assert(toStrings([ArchivingJobStatus.scheduled, ArchivingJobStatus.running]) == ["scheduled", "running"]);
    assert(toArchivingJobStatuses(["scheduled", "running"]) == [ArchivingJobStatus.scheduled, ArchivingJobStatus.running]);     
}

/// Type of archiving operation
enum ArchivingOperationType {
    archive,
    destruct,
    archiveAndDestruct
}
ArchivingOperationType toArchivingOperationType(string value) {
    mixin(EnumSwitch("ArchivingOperationType", "archive"));
}
ArchivingOperationType[] toArchivingOperationTypes(string[] names) {
    return names.map!toArchivingOperationType.array;
}
string toString(ArchivingOperationType type) {
    return type.to!string;
}
string[] toStrings(ArchivingOperationType[] types) {
    return types.map!toString.array;
}
/// 
unittest {
    mixin(ShowTest!("ArchivingOperationType"));

    assert("archive".toArchivingOperationType == ArchivingOperationType.archive);
    assert("destruct".toArchivingOperationType == ArchivingOperationType.destruct);
    assert("archiveAndDestruct".toArchivingOperationType == ArchivingOperationType.archiveAndDestruct);

    assert("".toArchivingOperationType == ArchivingOperationType.archive);
    assert("unknown".toArchivingOperationType == ArchivingOperationType.archive);

    assert(ArchivingOperationType.archive.toString == "archive");
    assert(ArchivingOperationType.destruct.toString == "destruct");
    assert(ArchivingOperationType.archiveAndDestruct.toString == "archiveAndDestruct");

    assert([ArchivingOperationType.archive, ArchivingOperationType.destruct].toStrings == ["archive", "destruct"]);
    assert(["archive", "destruct"].toArchivingOperationTypes == [ArchivingOperationType.archive, ArchivingOperationType.destruct]);
}

/// Scope of an application group
enum ApplicationGroupScope {
    global,
    regional,
    local
}

ApplicationGroupScope toApplicationGroupScope(string value) {
    mixin(EnumSwitch("ApplicationGroupScope", "global"));
}
ApplicationGroupScope[] toApplicationGroupScopes(string[] names) {
    return names.map!toApplicationGroupScope.array;
}
string toString(ApplicationGroupScope scope_) {
    return scope_.to!string;
}
string[] toStrings(ApplicationGroupScope[] scopes) {
    return scopes.map!toString.array;
}
/// 
unittest {
    mixin(ShowTest!("ApplicationGroupScope"));

    assert("global".toApplicationGroupScope == ApplicationGroupScope.global);
    assert("regional".toApplicationGroupScope == ApplicationGroupScope.regional);
    assert("local".toApplicationGroupScope == ApplicationGroupScope.local);

    assert("".toApplicationGroupScope == ApplicationGroupScope.global);
    assert("unknown".toApplicationGroupScope == ApplicationGroupScope.global);

    assert(ApplicationGroupScope.global.toString == "global");
    assert(ApplicationGroupScope.regional.toString == "regional");
    assert(ApplicationGroupScope.local.toString == "local");

    assert([ApplicationGroupScope.global, ApplicationGroupScope.regional].toStrings == ["global", "regional"]);
    assert(["global", "regional"].toApplicationGroupScopes == [ApplicationGroupScope.global, ApplicationGroupScope.regional]);
}

/// Purpose check result
enum PurposeCheckResult {
    withinResidence,
    withinRetention,
    endOfPurpose,
    endOfRetention,
    noRuleFound
}

PurposeCheckResult toPurposeCheckResult(string value) {
    mixin(EnumSwitch("PurposeCheckResult", "withinResidence"));
}
PurposeCheckResult[] toPurposeCheckResults(string[] names) {
    return names.map!toPurposeCheckResult.array;
}
string toString(PurposeCheckResult result) {
    return result.to!string;
}
string[] toStrings(PurposeCheckResult[] results) {
    return results.map!toString.array;
}
///
unittest {
    mixin(ShowTest!("PurposeCheckResult"));

    assert("withinResidence".toPurposeCheckResult == PurposeCheckResult.withinResidence);
    assert("withinRetention".toPurposeCheckResult == PurposeCheckResult.withinRetention);
    assert("endOfPurpose".toPurposeCheckResult == PurposeCheckResult.endOfPurpose);
    assert("endOfRetention".toPurposeCheckResult == PurposeCheckResult.endOfRetention);
    assert("noRuleFound".toPurposeCheckResult == PurposeCheckResult.noRuleFound);

    assert("".toPurposeCheckResult == PurposeCheckResult.withinResidence);
    assert("unknown".toPurposeCheckResult == PurposeCheckResult.withinResidence);

    assert(PurposeCheckResult.withinResidence.toString == "withinResidence");
    assert(PurposeCheckResult.withinRetention.toString == "withinRetention");
    assert(PurposeCheckResult.endOfPurpose.toString == "endOfPurpose");
    assert(PurposeCheckResult.endOfRetention.toString == "endOfRetention");
    assert(PurposeCheckResult.noRuleFound.toString == "noRuleFound");

    assert([PurposeCheckResult.withinResidence, PurposeCheckResult.withinRetention].toStrings == ["withinResidence", "withinRetention"]);
    assert(["withinResidence", "withinRetention"].toPurposeCheckResults == [PurposeCheckResult.withinResidence, PurposeCheckResult.withinRetention]);
}   
