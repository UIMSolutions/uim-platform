module uim.platform.object_store.domain.enumerations;
import uim.platform.object_store;

mixin(ShowModule!());

@safe:
// --- Enumerations ---

enum StorageClass {
  archive,
  standard,
  nearline,
  coldline,
}
StorageClass toStorageClass(string s) {
  switch (s.toLower()) {
    case "archive": return StorageClass.archive;
    case "standard": return StorageClass.standard;
    case "nearline": return StorageClass.nearline;
    case "coldline": return StorageClass.coldline;
    default: return StorageClass.standard; // default
  }
}

enum BucketStatus {
  active,
  suspended,
  deleted,
}
BucketStatus toBucketStatus(string s) {
  switch (s.toLower()) {
    case "active": return BucketStatus.active;
    case "suspended": return BucketStatus.suspended;
    case "deleted": return BucketStatus.deleted;
    default: return BucketStatus.active; // default
  }
}

enum ObjectStatus {
  active,
  archived,
  deleted,
}
ObjectStatus toObjectStatus(string s) {
  switch (s.toLower()) {
    case "active": return ObjectStatus.active;
    case "archived": return ObjectStatus.archived;
    case "deleted": return ObjectStatus.deleted;
    default: return ObjectStatus.active; // default
  }
}

enum EncryptionType {
  none,
  sse_s3,
  sse_kms,
  sse_c,
}
EncryptionType toEncryptionType(string s) {
  switch (s.toLower()) {
    case "none": return EncryptionType.none;
    case "sse_s3": return EncryptionType.sse_s3;
    case "sse_kms": return EncryptionType.sse_kms;
    case "sse_c": return EncryptionType.sse_c;
    default: return EncryptionType.none; // default
  }
}

enum PolicyEffect {
  allow,
  deny,
}
PolicyEffect toPolicyEffect(string s) {
  switch (s.toLower()) {
    case "allow": return PolicyEffect.allow;
    case "deny": return PolicyEffect.deny;
    default: return PolicyEffect.deny; // default
  }
}

enum BindingPermission {
  readOnly,
  readWrite,
  admin,
}
BindingPermission toBindingPermission(string s) {
  switch (s.toLower()) {
    case "readonly": return BindingPermission.readOnly;
    case "readwrite": return BindingPermission.readWrite;
    case "admin": return BindingPermission.admin;
    default: return BindingPermission.readOnly; // default
  }
}

enum BindingStatus {
  active,
  revoked,
  expired,
}
BindingStatus toBindingStatus(string s) {
  switch (s.toLower()) {
    case "active": return BindingStatus.active;
    case "revoked": return BindingStatus.revoked;
    case "expired": return BindingStatus.expired;
    default: return BindingStatus.active; // default
  }
}

enum RuleStatus {
  enabled,
  disabled,
}

RuleStatus toRuleStatus(string s) {
  switch (s.toLower) {
    case "enabled": return RuleStatus.enabled;
    case "disabled": return RuleStatus.disabled;
    default: return RuleStatus.disabled; // default
  }
}