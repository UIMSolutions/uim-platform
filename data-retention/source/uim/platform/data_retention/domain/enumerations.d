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

ArchivingJobStatus toArchivingJobStatus(string name) {
    switch (name) {
    case "scheduled":
        return ArchivingJobStatus.scheduled;
    case "running":
        return ArchivingJobStatus.running;
    case "completed":
        return ArchivingJobStatus.completed;
    case "failed":
        return ArchivingJobStatus.failed;
    case "cancelled":
        return ArchivingJobStatus.cancelled;
    default:
        return ArchivingJobStatus.scheduled;
    }
}

/// Type of archiving operation
enum ArchivingOperationType {
    archive,
    destruct,
    archiveAndDestruct
}

    ArchivingOperationType toArchivingOperationType(string name) {
        switch (name) {
        case "archive":
            return ArchivingOperationType.archive;
        case "destruct":
            return ArchivingOperationType.destruct;
        case "archiveAndDestruct":
            return ArchivingOperationType.archiveAndDestruct;
        default:
            return ArchivingOperationType.archive;
        }
    }

/// Scope of an application group
enum ApplicationGroupScope {
    global,
    regional,
    local
}

ApplicationGroupScope toApplicationGroupScope(string name) {
    switch (name) {
    case "global":
        return ApplicationGroupScope.global;
    case "regional":
        return ApplicationGroupScope.regional;
    case "local":
        return ApplicationGroupScope.local;
    default:
        return ApplicationGroupScope.global;
    }
}

/// Purpose check result
enum PurposeCheckResult {
    withinResidence,
    withinRetention,
    endOfPurpose,
    endOfRetention,
    noRuleFound
}
