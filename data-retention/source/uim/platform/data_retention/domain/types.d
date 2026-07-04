module uim.platform.data_retention.domain.types;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

struct BusinessPurposeId {
    string value;
    this(string value) { this.value = value; }
    mixin IdTemplate;
}

struct LegalGroundId {
    string value;
    this(string value) { this.value = value; }
    mixin IdTemplate;
}

struct RetentionRuleId {
    string value;
    this(string value) { this.value = value; }
    mixin IdTemplate;
}

struct ResidenceRuleId {
    string value;
    this(string value) { this.value = value; }
    mixin IdTemplate;
}

struct DataSubjectId {
    string value;
    this(string value) { this.value = value; }
    mixin IdTemplate;
}

struct DeletionRequestId {
    string value;
    this(string value) { this.value = value; }
    mixin IdTemplate;
}

struct ArchivingJobId {
    string value;
    this(string value) { this.value = value; }
    mixin IdTemplate;
}

struct ApplicationGroupId {
    string value;
    this(string value) { this.value = value; }
    mixin IdTemplate;
}

struct LegalEntityId {
    string value;
    this(string value) { this.value = value; }
    mixin IdTemplate;
}

struct DataSubjectRoleId {
    string value;
    this(string value) { this.value = value; }
    mixin IdTemplate;
}
