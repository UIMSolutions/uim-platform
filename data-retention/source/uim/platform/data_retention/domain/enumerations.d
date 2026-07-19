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
enum BusinessPurposeStatus {
    inactive,
    active,
    deprecated_
}

BusinessPurposeStatus toBusinessPurposeStatus(string name) {
    const map = [
        "inactive": BusinessPurposeStatus.inactive,
        "active": BusinessPurposeStatus.active,
        "deprecated": BusinessPurposeStatus.deprecated_
    ];
    return map.get(name.toLower(), BusinessPurposeStatus.inactive);
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

LegalGroundType toLegalGroundType(string name) {
    const map = [
        "consent": LegalGroundType.consent,
        "contract": LegalGroundType.contract,
        "legalObligation": LegalGroundType.legalObligation,
        "vitalInterest": LegalGroundType.vitalInterest,
        "publicInterest": LegalGroundType.publicInterest,
        "legitimateInterest": LegalGroundType.legitimateInterest
    ];
    return map.get(name.toLower(), LegalGroundType.consent);
}

/// Period unit for retention and residence durations
enum PeriodUnit {
    days,
    weeks,
    months,
    years
}

PeriodUnit toPeriodUnit(string name) {
    const map = [
        "days": PeriodUnit.days,
        "weeks": PeriodUnit.weeks,
        "months": PeriodUnit.months,
        "years": PeriodUnit.years
    ];
    return map.get(name.toLower(), PeriodUnit.days);
}

/// Status of a data subject's data lifecycle
enum DataLifecycleStatus {
    active,
    blocked,
    markedForDeletion,
    deleted,
    archived
}

DataLifecycleStatus toDataLifecycleStatus(string name) {
    const map = [
        "active": DataLifecycleStatus.active,
        "blocked": DataLifecycleStatus.blocked,
        "markedForDeletion": DataLifecycleStatus.markedForDeletion,
        "deleted": DataLifecycleStatus.deleted,
        "archived": DataLifecycleStatus.archived
    ];
    return map.get(name.toLower(), DataLifecycleStatus.active);
}

/// Status of a deletion request
enum DeletionRequestStatus {
    pending,
    inProgress,
    completed,
    failed,
    cancelled
}
DeletionRequestStatus toDeletionRequestStatus(string name) {
    const map = [
        "pending": DeletionRequestStatus.pending,
        "inProgress": DeletionRequestStatus.inProgress,
        "completed": DeletionRequestStatus.completed,
        "failed": DeletionRequestStatus.failed,
        "cancelled": DeletionRequestStatus.cancelled
    ];
    return map.get(name.toLower(), DeletionRequestStatus.pending);
}

/// Type of deletion action
enum DeletionActionType {
    block,
    delete_,
    anonymize
}
DeletionActionType toDeletionActionType(string name) {
    const map = [
        "block": DeletionActionType.block,
        "delete": DeletionActionType.delete_,
        "anonymize": DeletionActionType.anonymize
    ];
    return map.get(name.toLower(), DeletionActionType.block);
}

/// Status of an archiving job
enum ArchivingJobStatus {
    scheduled,
    running,
    completed,
    failed,
    cancelled
}

ArchivingJobStatus toArchivingJobStatus(string name) {
    const map = [
        "scheduled": ArchivingJobStatus.scheduled,
        "running": ArchivingJobStatus.running,
        "completed": ArchivingJobStatus.completed,
        "failed": ArchivingJobStatus.failed,
        "cancelled": ArchivingJobStatus.cancelled
    ];
    return map.get(name.toLower(), ArchivingJobStatus.scheduled);
}

/// Type of archiving operation
enum ArchivingOperationType {
    archive,
    destruct,
    archiveAndDestruct
}
ArchivingOperationType toArchivingOperationType(string name) {
    const map = [
        "archive": ArchivingOperationType.archive,
        "destruct": ArchivingOperationType.destruct,
        "archiveAndDestruct": ArchivingOperationType.archiveAndDestruct
    ];
    return map.get(name.toLower(), ArchivingOperationType.archive);
}

/// Scope of an application group
enum ApplicationGroupScope {
    global,
    regional,
    local
}

ApplicationGroupScope toApplicationGroupScope(string name) {
    const map = [
        "global": ApplicationGroupScope.global,
        "regional": ApplicationGroupScope.regional,
        "local": ApplicationGroupScope.local
    ];
    return map.get(name.toLower(), ApplicationGroupScope.global);
}

/// Purpose check result
enum PurposeCheckResult {
    withinResidence,
    withinRetention,
    endOfPurpose,
    endOfRetention,
    noRuleFound
}

PurposeCheckResult toPurposeCheckResult(string name) {
    const map = [
        "withinResidence": PurposeCheckResult.withinResidence,
        "withinRetention": PurposeCheckResult.withinRetention,
        "endOfPurpose": PurposeCheckResult.endOfPurpose,
        "endOfRetention": PurposeCheckResult.endOfRetention,
        "noRuleFound": PurposeCheckResult.noRuleFound
    ];
    return map.get(name.toLower(), PurposeCheckResult.noRuleFound);
}
