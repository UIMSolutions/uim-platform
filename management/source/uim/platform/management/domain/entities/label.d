module uim.platform.management.domain.entities.label;

// import uim.platform.management.domain.types;
import uim.platform.management;

mixin(ShowModule!());

@safe:
/// A label is a key-value tag attached to a BTP resource for
/// organizing and categorizing global accounts, directories, subaccounts, etc.
struct Label {
    LabelId id;
    LabeledResourceType resourceType;
    string resourceId; // ID of the labeled resource
    string key; // label key, e.g. "costCenter", "project"
    string[] values; // one or more values for this key
    string createdBy;
    long createdAt;
    long modifiedAt;
}
