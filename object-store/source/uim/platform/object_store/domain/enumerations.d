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
  mixin(EnumSwitch("StorageClass", "StorageClass.standard"));
}
StorageClass[] toStorageClass(string[] values) {
  return values.map!(v => v.toStorageClass).array;
}
string toString(StorageClass value) {
  return value.to!string();
}
string[] toString(StorageClass[] values) {
  return values.map!(v => v.toString).array;
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

  assert(["standard", "archive"].toStorageClass == [StorageClass.standard, StorageClass.archive]);
  assert([StorageClass.standard, StorageClass.archive].toString == ["standard", "archive"]);
}

enum BucketStatus {
  active,
  suspended,
  deleted,
}

BucketStatus toBucketStatus(string value) {
  mixin(EnumSwitch("BucketStatus", "BucketStatus.active"));
}
BucketStatus[] toBucketStatus(string[] values) {
  return values.map!(v => v.toBucketStatus).array;
}

string toString(BucketStatus value) {
  return value.to!string();
}
string[] toString(BucketStatus[] values) {
  return values.map!(v => v.toString).array;
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

assert(["active", "suspended"].toBucketStatus == [BucketStatus.active, BucketStatus.suspended]);
  assert([BucketStatus.active, BucketStatus.suspended].toString == ["active", "suspended"]);
}

enum ObjectStatus {
  active,
  archived,
  deleted,
}

ObjectStatus toObjectStatus(string value) {
  mixin(EnumSwitch("ObjectStatus", "ObjectStatus.active"));
}
ObjectStatus[] toObjectStatus(string[] values) {
  return values.map!(v => v.toObjectStatus).array;
} 
string toString(ObjectStatus value) {
  return value.to!string();
}
string[] toString(ObjectStatus[] values) {
  return values.map!(v => v.toString).array;
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

  assert(["active", "archived"].toObjectStatus == [ObjectStatus.active, ObjectStatus.archived]);
  assert([ObjectStatus.active, ObjectStatus.archived].toString == ["active", "archived"]);
}

enum EncryptionType {
  none,
  sse_s3,
  sse_kms,
  sse_c,
}

EncryptionType toEncryptionType(string value) {
  mixin(EnumSwitch("EncryptionType", "EncryptionType.none"));
}
EncryptionType[] toEncryptionType(string[] values) {
  return values.map!(v => v.toEncryptionType).array;
}

string toString(EncryptionType value) {
  return value.to!string();
}
string[] toString(EncryptionType[] values) {
  return values.map!(v => v.toString).array;
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

  assert(["none", "sse_kms"].toEncryptionType == [EncryptionType.none, EncryptionType.sse_kms]);
  assert([EncryptionType.none, EncryptionType.sse_kms].toString == ["none", "sse_kms"]);
}

enum PolicyEffect {
  allow,
  deny,
}

PolicyEffect toPolicyEffect(string value) {
  mixin(EnumSwitch("PolicyEffect", "PolicyEffect.allow"));
}
PolicyEffect[] toPolicyEffect(string[] values) {
  return values.map!(v => v.toPolicyEffect).array;
}

string toString(PolicyEffect value) {
  return value.to!string();
}
string[] toString(PolicyEffect[] values) {
  return values.map!(v => v.toString).array;
}
/// 
unittest {
  mixin(ShowTest!("PolicyEffect"));

  assert("allow".toPolicyEffect == PolicyEffect.allow);
  assert("deny".toPolicyEffect == PolicyEffect.deny);
  assert("unknown".toPolicyEffect == PolicyEffect.allow); // default

  assert(PolicyEffect.allow.toString == "allow");
  assert(PolicyEffect.deny.toString == "deny");

  assert(["allow", "deny"].toPolicyEffect == [PolicyEffect.allow, PolicyEffect.deny]);
  assert([PolicyEffect.allow, PolicyEffect.deny].toString == ["allow", "deny"]);
}

enum BindingPermission {
  readOnly,
  readWrite,
  admin,
}

BindingPermission toBindingPermission(string value) {
  mixin(EnumSwitch("BindingPermission", "BindingPermission.readOnly"));
}
BindingPermission[] toBindingPermission(string[] values) {
  return values.map!(v => v.toBindingPermission).array;
}

string toString(BindingPermission value) {
  return value.to!string();
}
string[] toString(BindingPermission[] values) {
  return values.map!(v => v.toString).array;
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

  assert(["readOnly", "admin"].toBindingPermission == [BindingPermission.readOnly, BindingPermission.admin]);
  assert([BindingPermission.readOnly, BindingPermission.admin].toString == ["readOnly", "admin"]);
}

enum BindingStatus {
  active,
  revoked,
  expired,
}

BindingStatus toBindingStatus(string value) {
  mixin(EnumSwitch("BindingStatus", "BindingStatus.active"));
}
BindingStatus[] toBindingStatus(string[] values) {
  return values.map!(v => v.toBindingStatus).array;
}

string toString(BindingStatus value) {
  return value.to!string();
}
string[] toString(BindingStatus[] values) {
  return values.map!(v => v.toString).array;
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

  assert(["active", "revoked"].toBindingStatus == [BindingStatus.active, BindingStatus.revoked]);
  assert([BindingStatus.active, BindingStatus.revoked].toString == ["active", "revoked"]);
}

enum RuleStatus {
  enabled,
  disabled,
}

RuleStatus toRuleStatus(string value) {
  mixin(EnumSwitch("RuleStatus", "RuleStatus.disabled"));
}
RuleStatus[] toRuleStatus(string[] values) {
  return values.map!(v => v.toRuleStatus).array;
}

string toString(RuleStatus value) {
  return value.to!string();
}
string[] toString(RuleStatus[] values) {
  return values.map!(v => v.toString).array;
}
/// 
unittest {
  mixin(ShowTest!("RuleStatus"));

  assert("enabled".toRuleStatus == RuleStatus.enabled);
  assert("disabled".toRuleStatus == RuleStatus.disabled);
  assert("unknown".toRuleStatus == RuleStatus.disabled); // default

  assert(RuleStatus.enabled.toString == "enabled");
  assert(RuleStatus.disabled.toString == "disabled");

  assert(["enabled", "disabled"].toRuleStatus == [RuleStatus.enabled, RuleStatus.disabled]);
  assert([RuleStatus.enabled, RuleStatus.disabled].toString == ["enabled", "disabled"]);
}
