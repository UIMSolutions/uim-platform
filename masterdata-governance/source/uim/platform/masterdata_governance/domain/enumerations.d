module uim.platform.masterdata_governance.domain.enumerations;
// --- Enumerations ---
import uim.platform.masterdata_governance;

mixin(ShowModule!());

@safe:
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

RuleType toRuleType(string s) {
    switch (s.toLower) {
        case "required": return RuleType.required;
        case "format": return RuleType.format;
        case "range": return RuleType.range;
        case "uniqueness": return RuleType.uniqueness;
        case "consistency": return RuleType.consistency;
        case "referentialintegrity": return RuleType.referentialIntegrity;
        default: return RuleType.required; // default
    }
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
