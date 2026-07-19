module uim.platform.data_retention.domain.types;
import uim.platform.data_retention;
mixin(ShowModule!());

@safe:

struct BusinessPurposeId {
    mixin(IdTemplate);
}

struct LegalGroundId {
    mixin(IdTemplate);
}

struct RetentionRuleId {
    mixin(IdTemplate);
}

struct ResidenceRuleId {
    mixin(IdTemplate);
}

struct DataSubjectId {
    mixin(IdTemplate);
}

struct DeletionRequestId {
    mixin(IdTemplate);
}

struct ArchivingJobId {
    mixin(IdTemplate);
}

struct ApplicationGroupId {
    mixin(IdTemplate);
}

struct LegalEntityId {
    mixin(IdTemplate);
}

struct DataSubjectRoleId {
    mixin(IdTemplate);
}
