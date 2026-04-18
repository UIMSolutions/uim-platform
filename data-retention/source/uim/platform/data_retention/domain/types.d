module uim.platform.data_retention.domain.types;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

struct BusinessPurposeId {
    string value;
    this(string value) { this.value = value; }
    mixin DomainId;
}

struct LegalGroundId {
    string value;
    this(string value) { this.value = value; }
    mixin DomainId;
}

struct RetentionRuleId {
    string value;
    this(string value) { this.value = value; }
    mixin DomainId;
}

struct ResidenceRuleId {
    string value;
    this(string value) { this.value = value; }
    mixin DomainId;
}

struct DataSubjectId {
    string value;
    this(string value) { this.value = value; }
    mixin DomainId;
}

struct DeletionRequestId {
    string value;
    this(string value) { this.value = value; }
    mixin DomainId;
}

struct ArchivingJobId {
    string value;
    this(string value) { this.value = value; }
    mixin DomainId;
}

struct ApplicationGroupId {
    string value;
    this(string value) { this.value = value; }
    mixin DomainId;
}

struct LegalEntityId {
    string value;
    this(string value) { this.value = value; }
    mixin DomainId;
}

struct DataSubjectRoleId {
    string value;
    this(string value) { this.value = value; }
    mixin DomainId;
}
