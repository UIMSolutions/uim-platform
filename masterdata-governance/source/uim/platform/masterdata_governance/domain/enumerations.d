module uim.platform.masterdata_governance.domain.enumerations;

// --- Enumerations ---

enum BPCategory {
    organization,
    person,
    group
}

enum BPStatus {
    active,
    inactive,
    blocked,
    markedForDeletion
}

enum BPRole {
    customer,
    supplier,
    employee,
    contactPerson,
    financialServices,
    businessUser
}

enum ValidationStatus {
    notValidated,
    valid,
    invalid,
    partiallyValid
}

enum ChangeRequestStatus {
    draft,
    submitted,
    inReview,
    approved,
    rejected,
    revisionRequested,
    withdrawn
}

enum ChangeRequestType {
    create,
    update,
    block,
    markForDeletion,
    unblock,
    merge,
    archive
}

enum RuleType {
    required,
    format,
    range,
    uniqueness,
    consistency,
    referentialIntegrity
}

enum RuleSeverity {
    error,
    warning,
    info
}

enum QualityStatus {
    excellent,
    good,
    fair,
    poor
}

enum ReplicationType {
    full,
    delta,
    selective
}

enum ReplicationStatus {
    pending,
    inProgress,
    completed,
    failed,
    cancelled,
    skipped
}

enum BPLegalForm {
    unknown,
    corporation,
    partnership,
    soleProprietorship,
    limitedLiability,
    publicLimited,
    cooperative,
    foundation,
    association
}

enum AddressType {
    permanent,
    billing,
    delivery,
    correspondence,
    primary
}
