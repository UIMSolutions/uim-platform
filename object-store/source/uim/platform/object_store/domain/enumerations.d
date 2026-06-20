module uim.platform.object_store.domain.enumerations;
import uim.platform.object_store;

mixin(ShowModule!());

@safe:

enum StorageClass {
  standard,
  archive,
  nearline,
  coldline,
}

StorageClass toStorageClass(string value) {
  mixin(toEnumSwitch("StorageClass", "StorageClass.standard"));
}

string toString(StorageClass value) {
  return value.to!string();
}
///
unittest {
  mixin(ShowTest!("StorageClass"));

  assert("standard".toStorageClass == StorageClass.standard);
  assert("archive".toStorageClass == StorageClass.archive);
  assert("nearline".toStorageClass == StorageClass.nearline);
  assert("coldline".toStorageClass == StorageClass.coldline);

  assert(StorageClass.standard.toString == "standard");
  assert(StorageClass.archive.toString == "archive");
  assert(StorageClass.nearline.toString == "nearline");
  assert(StorageClass.coldline.toString == "coldline");
}

enum BucketStatus {
  active,
  suspended,
  deleted,
}

BucketStatus toBucketStatus(string value) {
  mixin(toEnumSwitch("BucketStatus", "BucketStatus.active"));
}

string toString(BucketStatus value) {
  return value.to!string();
}
///
unittest {
  mixin(ShowTest!("BucketStatus"));

  assert("active".toBucketStatus == BucketStatus.active);
  assert("suspended".toBucketStatus == BucketStatus.suspended);
  assert("deleted".toBucketStatus == BucketStatus.deleted);
  assert("unknown".toBucketStatus == BucketStatus.active); // default

  assert(BucketStatus.active.toString == "active");
  assert(BucketStatus.suspended.toString == "suspended");
  assert(BucketStatus.deleted.toString == "deleted");
}

enum ObjectStatus {
  active,
  archived,
  deleted,
}

ObjectStatus toObjectStatus(string value) {
  mixin(toEnumSwitch("ObjectStatus", "ObjectStatus.active"));
}

string toString(ObjectStatus value) {
  return value.to!string();
}
///
unittest {
  mixin(ShowTest!("ObjectStatus"));

  assert("active".toObjectStatus == ObjectStatus.active);
  assert("archived".toObjectStatus == ObjectStatus.archived);
  assert("deleted".toObjectStatus == ObjectStatus.deleted);
  assert("unknown".toObjectStatus == ObjectStatus.active); // default

  assert(ObjectStatus.active.toString == "active");
  assert(ObjectStatus.archived.toString == "archived");
  assert(ObjectStatus.deleted.toString == "deleted");
}

enum EncryptionType {
  none,
  sse_s3,
  sse_kms,
  sse_c,
}

EncryptionType toEncryptionType(string value) {
  mixin(toEnumSwitch("EncryptionType", "EncryptionType.none"));
}

string toString(EncryptionType value) {
  return value.to!string();
}
/// 
unittest {
  mixin(ShowTest!("EncryptionType"));

  assert("none".toEncryptionType == EncryptionType.none);
  assert("sse_s3".toEncryptionType == EncryptionType.sse_s3);
  assert("sse_kms".toEncryptionType == EncryptionType.sse_kms);
  assert("sse_c".toEncryptionType == EncryptionType.sse_c);
  assert("unknown".toEncryptionType == EncryptionType.none); // default

  assert(EncryptionType.none.toString == "none");
  assert(EncryptionType.sse_s3.toString == "sse_s3");
  assert(EncryptionType.sse_kms.toString == "sse_kms");
  assert(EncryptionType.sse_c.toString == "sse_c");
}

enum PolicyEffect {
  allow,
  deny,
}

PolicyEffect toPolicyEffect(string value) {
  mixin(toEnumSwitch("PolicyEffect", "PolicyEffect.allow"));
}

string toString(PolicyEffect value) {
  return value.to!string();
}
/// 
unittest {
  mixin(ShowTest!("PolicyEffect"));

  assert("allow".toPolicyEffect == PolicyEffect.allow);
  assert("deny".toPolicyEffect == PolicyEffect.deny);
  assert("unknown".toPolicyEffect == PolicyEffect.allow); // default

  assert(PolicyEffect.allow.toString == "allow");
  assert(PolicyEffect.deny.toString == "deny");
}

enum BindingPermission {
  readOnly,
  readWrite,
  admin,
}

BindingPermission toBindingPermission(string value) {
  mixin(toEnumSwitch("BindingPermission", "BindingPermission.readOnly"));
}

string toString(BindingPermission value) {
  return value.to!string();
}
/// 
unittest {
  mixin(ShowTest!("BindingPermission"));

  assert("readOnly".toBindingPermission == BindingPermission.readOnly);
  assert("readWrite".toBindingPermission == BindingPermission.readWrite);
  assert("admin".toBindingPermission == BindingPermission.admin);
  assert("unknown".toBindingPermission == BindingPermission.readOnly); // default

  assert(BindingPermission.readOnly.toString == "readOnly");
  assert(BindingPermission.readWrite.toString == "readWrite");
  assert(BindingPermission.admin.toString == "admin");
}

enum BindingStatus {
  active,
  revoked,
  expired,
}

BindingStatus toBindingStatus(string value) {
  mixin(toEnumSwitch("BindingStatus", "BindingStatus.active"));
}

string toString(BindingStatus value) {
  return value.to!string();
}
/// 
unittest {
  mixin(ShowTest!("BindingStatus"));

  assert("active".toBindingStatus == BindingStatus.active);
  assert("revoked".toBindingStatus == BindingStatus.revoked);
  assert("expired".toBindingStatus == BindingStatus.expired);
  assert("unknown".toBindingStatus == BindingStatus.active); // default

  assert(BindingStatus.active.toString == "active");
  assert(BindingStatus.revoked.toString == "revoked");
  assert(BindingStatus.expired.toString == "expired");
}

enum RuleStatus {
  enabled,
  disabled,
}

RuleStatus toRuleStatus(string value) {
  mixin(toEnumSwitch("RuleStatus", "RuleStatus.disabled"));
}

string toString(RuleStatus value) {
  return value.to!string();
}
/// 
unittest {
  mixin(ShowTest!("RuleStatus"));
  
  assert("enabled".toRuleStatus == RuleStatus.enabled);
  assert("disabled".toRuleStatus == RuleStatus.disabled);
  assert("unknown".toRuleStatus == RuleStatus.disabled); // default

  assert(RuleStatus.enabled.toString == "enabled");
  assert(RuleStatus.disabled.toString == "disabled");
}
