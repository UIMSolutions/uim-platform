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

/// Type of legal ground for data processing
enum LegalGroundType {
    consent,
    contract,
    legalObligation,
    vitalInterest,
    publicInterest,
    legitimateInterest
}

/// Period unit for retention and residence durations
enum PeriodUnit {
    days,
    weeks,
    months,
    years
}

/// Status of a data subject's data lifecycle
enum DataLifecycleStatus {
    active,
    blocked,
    markedForDeletion,
    deleted,
    archived
}

/// Status of a deletion request
enum DeletionRequestStatus {
    pending,
    inProgress,
    completed,
    failed,
    cancelled
}

/// Type of deletion action
enum DeletionActionType {
    block,
    delete_,
    anonymize
}

/// Status of an archiving job
enum ArchivingJobStatus {
    scheduled,
    running,
    completed,
    failed,
    cancelled
}

/// Type of archiving operation
enum ArchivingOperationType {
    archive,
    destruct,
    archiveAndDestruct
}

/// Scope of an application group
enum ApplicationGroupScope {
    global,
    regional,
    local
}

/// Purpose check result
enum PurposeCheckResult {
    withinResidence,
    withinRetention,
    endOfPurpose,
    endOfRetention,
    noRuleFound
}
