/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_directory.domain.enumerations;

import uim.platform.identity_directory;

mixin(ShowModule!());

@safe:

/// SCIM 2.0 user status.
enum UserStatus {
  active, // IDUser is active and can authenticate
  inactive, // IDUser is inactive and cannot authenticate
  locked, // IDUser is locked due to too many failed login attempts
  staged, // IDUser is staged for activation but not yet active
  provisioning, // IDUser is currently being provisioned and not yet active
  pending // IDUser is pending activation (e.g. awaiting email verification)
}
UserStatus toUserStatus(string value) {
  mixin(EnumSwitch("UserStatus", "active"));
}
UserStatus[] toUserStatus(string[] arr) {
  return arr.map!(s => toUserStatus(s)).array;
}
string toString(UserStatus status) {
  return status.to!string;
}
string[] toString(UserStatus[] statuses) {
  return statuses.map!(s => toString(s)).array;
}
///
unittest {
  mixin(ShowTest!("UserStatus"));

  assert(toUserStatus("active") == UserStatus.active);
  assert(toUserStatus("inactive") == UserStatus.inactive);
  assert(toUserStatus("locked") == UserStatus.locked);
  assert(toUserStatus("staged") == UserStatus.staged);
  assert(toUserStatus("provisioning") == UserStatus.provisioning);
  assert(toUserStatus("pending") == UserStatus.pending);

  assert(toString(UserStatus.active) == "active");
  assert(toString(UserStatus.inactive) == "inactive");
  assert(toString(UserStatus.locked) == "locked");
  assert(toString(UserStatus.staged) == "staged");
  assert(toString(UserStatus.provisioning) == "provisioning");
  assert(toString(UserStatus.pending) == "pending");

  assert([UserStatus.active, UserStatus.inactive, UserStatus.locked, UserStatus.staged, UserStatus.provisioning, UserStatus.pending].map!(s => toString(s)).array == ["active", "inactive", "locked", "staged", "provisioning", "pending"]);
  assert(["active", "inactive", "locked", "staged", "provisioning", "pending"].map!(s => toUserStatus(s)).array == [UserStatus.active, UserStatus.inactive, UserStatus.locked, UserStatus.staged, UserStatus.provisioning, UserStatus.pending]);
}

/// SCIM 2.0 group type.
enum GroupType {
  standard, // Standard group with direct members
  dynamic, // Dynamic group with membership based on rules
  nested // Nested group that can contain other groups as members
}
GroupType toGroupType(string value) {
  mixin(EnumSwitch("GroupType", "standard"));
}
GroupType[] toGroupType(string[] arr) {
  return arr.map!(s => toGroupType(s)).array;
}
string toString(GroupType type) {
  return type.to!string;
}
string[] toString(GroupType[] types) {
  return types.map!(s => toString(s)).array;
}
///
unittest {
  mixin(ShowTest!("GroupType"));

  assert(toGroupType("standard") == GroupType.standard);
  assert(toGroupType("dynamic") == GroupType.dynamic);
  assert(toGroupType("nested") == GroupType.nested);

  assert(toString(GroupType.standard) == "standard");
  assert(toString(GroupType.dynamic) == "dynamic");
  assert(toString(GroupType.nested) == "nested");

  assert([GroupType.standard, GroupType.dynamic, GroupType.nested].map!(s => toString(s)).array == ["standard", "dynamic", "nested"]);
  assert(["standard", "dynamic", "nested"].map!(s => toGroupType(s)).array == [GroupType.standard, GroupType.dynamic, GroupType.nested]);
}

/// Attribute data types for custom schemas.
enum AttributeType {
  stringType, // String data type
  integerType, // Integer data type
  booleanType, // Boolean data type
  dateTimeType, // DateTime data type
  referenceType, // Reference to another resource
  complexType, // Complex type with sub-attributes
  binaryType, // Binary data type
}
AttributeType toAttributeType(string value) {
  mixin(EnumSwitch("AttributeType", "stringType"));
}
AttributeType[] toAttributeType(string[] arr) {
  return arr.map!(s => toAttributeType(s)).array;
}
string toString(AttributeType type) {
  return type.to!string;
}
string[] toString(AttributeType[] types) {
  return types.map!(s => toString(s)).array;
}
/// 
unittest {
  mixin(ShowTest!("AttributeType"));

  assert("stringType".toAttributeType == AttributeType.stringType);
  assert("integerType".toAttributeType == AttributeType.integerType);
  assert("booleanType".toAttributeType == AttributeType.booleanType);
  assert("dateTimeType".toAttributeType == AttributeType.dateTimeType);
  assert("referenceType".toAttributeType == AttributeType.referenceType);
  assert("complexType".toAttributeType == AttributeType.complexType);
  assert("binaryType".toAttributeType == AttributeType.binaryType);

  assert(AttributeType.stringType.toString == "stringType");
  assert(AttributeType.integerType.toString == "integerType");
  assert(AttributeType.booleanType.toString == "booleanType");
  assert(AttributeType.dateTimeType.toString == "dateTimeType");
  assert(AttributeType.referenceType.toString == "referenceType");
  assert(AttributeType.complexType.toString == "complexType");
  assert(AttributeType.binaryType.toString == "binaryType");

  assert([AttributeType.stringType, AttributeType.integerType, AttributeType.booleanType, AttributeType.dateTimeType, AttributeType.referenceType, AttributeType.complexType, AttributeType.binaryType].map!(s => toString(s)).array == ["stringType", "integerType", "booleanType", "dateTimeType", "referenceType", "complexType", "binaryType"]);
  assert(["stringType", "integerType", "booleanType", "dateTimeType", "referenceType", "complexType", "binaryType"].map!(s => toAttributeType(s)).array == [AttributeType.stringType, AttributeType.integerType, AttributeType.booleanType, AttributeType.dateTimeType, AttributeType.referenceType, AttributeType.complexType, AttributeType.binaryType]);
}

/// Attribute mutability (SCIM 2.0).
enum Mutability : string {
  readWrite = "readWrite", // Attribute can be read and updated by clients
  readOnly = "readOnly", // Attribute can be read but not updated by clients
  writeOnly = "writeOnly", // Attribute can be updated but not read by clients (e.g. password)
  immutable_ = "immutable", // Attribute is immutable and cannot be updated after creation (e.g. id)
}
Mutability toMutability(string s) {
  switch (s.toLower) {
    case "readwrite": return Mutability.readWrite;
    case "readonly": return Mutability.readOnly;
    case "writeonly": return Mutability.writeOnly;
    case "immutable": return Mutability.immutable_;
    default: return Mutability.readWrite; // default to readWrite if unknown
  }
}
Mutability[] toMutability(string[] arr) {
  return arr.map!(s => toMutability(s)).array;
}
string toString(Mutability mut) {
  return mut.to!string;
}
string[] toString(Mutability[] muts) {
  return muts.map!(s => toString(s)).array;
}
///
unittest {
  mixin(ShowTest!("Mutability"));

  assert(toMutability("readWrite") == Mutability.readWrite);
  assert(toMutability("readOnly") == Mutability.readOnly);
  assert(toMutability("writeOnly") == Mutability.writeOnly);
  assert(toMutability("immutable") == Mutability.immutable_);

  assert(toString(Mutability.readWrite) == "readWrite");
  assert(toString(Mutability.readOnly) == "readOnly");
  assert(toString(Mutability.writeOnly) == "writeOnly");
  assert(toString(Mutability.immutable_) == "immutable");

  assert([Mutability.readWrite, Mutability.readOnly, Mutability.writeOnly, Mutability.immutable_].map!(s => toString(s)).array == ["readWrite", "readOnly", "writeOnly", "immutable"]);
  assert(["readWrite", "readOnly", "writeOnly", "immutable"].map!(s => toMutability(s)).array == [Mutability.readWrite, Mutability.readOnly, Mutability.writeOnly, Mutability.immutable_]);
}

/// Attribute returned behavior (SCIM 2.0).
enum Returned : string {
  always = "always", // Attribute is always returned in responses
  never = "never", // Attribute is never returned in responses
  default_ = "default", // Attribute is returned by default but can be excluded with ?excludedAttributes
  request = "request", // Attribute is returned only if explicitly requested via ?attributes
}
Returned toReturned(string s) {
  switch (s.toLower) {
    case "always": return Returned.always;
    case "never": return Returned.never;
    case "default": return Returned.default_;
    case "request": return Returned.request;
    default: return Returned.default_; // default to default if unknown
  }
}
Returned[] toReturned(string[] arr) {
  return arr.map!(s => toReturned(s)).array;
}
string toString(Returned ret) {
  return ret.to!string;
}
string[] toString(Returned[] rets) {
  return rets.map!(s => toString(s)).array;
} 
///
unittest {
  mixin(ShowTest!("Returned"));

  assert(toReturned("always") == Returned.always);
  assert(toReturned("never") == Returned.never);
  assert(toReturned("default") == Returned.default_);
  assert(toReturned("request") == Returned.request);

  assert(toString(Returned.always) == "always");
  assert(toString(Returned.never) == "never");
  assert(toString(Returned.default_) == "default");
  assert(toString(Returned.request) == "request");

  assert([Returned.always, Returned.never, Returned.default_, Returned.request].map!(s => toString(s)).array == ["always", "never", "default", "request"]);
  assert(["always", "never", "default", "request"].map!(s => toReturned(s)).array == [Returned.always, Returned.never, Returned.default_, Returned.request]);
}

/// Attribute uniqueness (SCIM 2.0).
enum Uniqueness {
  none, // Attribute values do not need to be unique
  server, // Attribute values must be unique within the server (e.g. username)
  global, // Attribute values must be globally unique across all servers (e.g. email)
}
Uniqueness toUniqueness(string value) {
  mixin(EnumSwitch("Uniqueness", "none"));
}
Uniqueness[] toUniqueness(string[] arr) {
  return arr.map!(s => toUniqueness(s)).array;
}
string toString(Uniqueness uniq) {
  return uniq.to!string;
}
string[] toString(Uniqueness[] uniqs) {
  return uniqs.map!(s => toString(s)).array;
}
///
unittest {
  mixin(ShowTest!("Uniqueness"));

  assert(toUniqueness("none") == Uniqueness.none);
  assert(toUniqueness("server") == Uniqueness.server);
  assert(toUniqueness("global") == Uniqueness.global);

  assert(toString(Uniqueness.none) == "none");
  assert(toString(Uniqueness.server) == "server");
  assert(toString(Uniqueness.global) == "global");

  assert([Uniqueness.none, Uniqueness.server, Uniqueness.global].map!(s => toString(s)).array == ["none", "server", "global"]);
  assert(["none", "server", "global"].map!(s => toUniqueness(s)).array == [Uniqueness.none, Uniqueness.server, Uniqueness.global]);
}

/// Password policy strength level.
enum PasswordStrength {
  weak, // Password is not strong enough
  standard, // Password meets standard complexity requirements
  strong, // Password meets strong complexity requirements
  enterprise, // Password meets enterprise-grade complexity requirements
}
PasswordStrength toPasswordStrength(string value) {
  mixin(EnumSwitch("PasswordStrength", "standard"));
}
PasswordStrength[] toPasswordStrength(string[] arr) {
  return arr.map!(s => toPasswordStrength(s)).array;
}
string toString(PasswordStrength strength) {
  return strength.to!string;
}
string[] toString(PasswordStrength[] strengths) {
  return strengths.map!(s => toString(s)).array;
}
///
unittest {
  mixin(ShowTest!("PasswordStrength"));

  assert(toPasswordStrength("weak") == PasswordStrength.weak);
  assert(toPasswordStrength("standard") == PasswordStrength.standard);
  assert(toPasswordStrength("strong") == PasswordStrength.strong);
  assert(toPasswordStrength("enterprise") == PasswordStrength.enterprise);  

  assert(toString(PasswordStrength.weak) == "weak");
  assert(toString(PasswordStrength.standard) == "standard");
  assert(toString(PasswordStrength.strong) == "strong");
  assert(toString(PasswordStrength.enterprise) == "enterprise");

  assert([PasswordStrength.weak, PasswordStrength.standard, PasswordStrength.strong, PasswordStrength.enterprise].map!(s => toString(s)).array == ["weak", "standard", "strong", "enterprise"]);
  assert(["weak", "standard", "strong", "enterprise"].map!(s => toPasswordStrength(s)).array == [PasswordStrength.weak, PasswordStrength.standard, PasswordStrength.strong, PasswordStrength.enterprise]);
}

/// Audit event type.
enum AuditEventType {
  userCreated, // A user account was created
  userUpdated, // A user account was updated
  userDeleted, // A user account was deleted
  userActivated, // A user account was activated
  userDeactivated, // A user account was deactivated
  userLocked, // A user account was locked due to too many failed login attempts
  userUnlocked, // A user account was unlocked by an administrator
  passwordChanged, // A user changed their password
  passwordReset, //  A user's password was reset
  groupCreated, // A group was created
  groupUpdated, // A group was updated
  groupDeleted, // A group was deleted
  memberAdded, // A member was added to a group
  memberRemoved, // A member was removed from a group
  schemaCreated, // A schema was created
  schemaUpdated, // A schema was updated
  schemaDeleted, // A schema was deleted
  apiClientCreated, // An API client was created
  apiClientRevoked, // An API client was revoked
  loginSuccess, // A user successfully logged in
  loginFailure, // A user failed to log in due to invalid credentials
}
AuditEventType toAuditEventType(string value) {
  mixin(EnumSwitch("AuditEventType", "loginSuccess"));
}
AuditEventType[] toAuditEventType(string[] arr) {
  return arr.map!(s => toAuditEventType(s)).array;
}
string toString(AuditEventType eventType) {
  return eventType.to!string;
}
string[] toString(AuditEventType[] eventTypes) {
  return eventTypes.map!(s => toString(s)).array;
}
///
unittest {
  mixin(ShowTest!("AuditEventType"));

  assert("userCreated".toAuditEventType == AuditEventType.userCreated);
  assert("userUpdated".toAuditEventType == AuditEventType.userUpdated);
  assert("userDeleted".toAuditEventType == AuditEventType.userDeleted);
  assert("userActivated".toAuditEventType == AuditEventType.userActivated);
  assert("userDeactivated".toAuditEventType == AuditEventType.userDeactivated);
  assert("userLocked".toAuditEventType == AuditEventType.userLocked);
  assert("userUnlocked".toAuditEventType == AuditEventType.userUnlocked);
  assert("passwordChanged".toAuditEventType == AuditEventType.passwordChanged);
  assert("passwordReset".toAuditEventType == AuditEventType.passwordReset);
  assert("groupCreated".toAuditEventType == AuditEventType.groupCreated);
  assert("groupUpdated".toAuditEventType == AuditEventType.groupUpdated);
  assert("groupDeleted".toAuditEventType == AuditEventType.groupDeleted);
  assert("memberAdded".toAuditEventType == AuditEventType.memberAdded);
  assert("memberRemoved".toAuditEventType == AuditEventType.memberRemoved);
  assert("schemaCreated".toAuditEventType == AuditEventType.schemaCreated);
  assert("schemaUpdated".toAuditEventType == AuditEventType.schemaUpdated);
  assert("schemaDeleted".toAuditEventType == AuditEventType.schemaDeleted);
  assert("apiClientCreated".toAuditEventType == AuditEventType.apiClientCreated);    
  assert("apiClientRevoked".toAuditEventType == AuditEventType.apiClientRevoked);
  assert("loginSuccess".toAuditEventType == AuditEventType.loginSuccess);
  assert("loginFailure".toAuditEventType == AuditEventType.loginFailure);

  assert(AuditEventType.userCreated.toString == "userCreated");
  assert(AuditEventType.userUpdated.toString == "userUpdated");
  assert(AuditEventType.userDeleted.toString == "userDeleted");
  assert(AuditEventType.userActivated.toString == "userActivated");
  assert(AuditEventType.userDeactivated.toString == "userDeactivated");
  assert(AuditEventType.userLocked.toString == "userLocked");
  assert(AuditEventType.userUnlocked.toString == "userUnlocked");    
  assert(AuditEventType.passwordChanged.toString == "passwordChanged");
  assert(AuditEventType.passwordReset.toString == "passwordReset");
  assert(AuditEventType.groupCreated.toString == "groupCreated");
  assert(AuditEventType.groupUpdated.toString == "groupUpdated");
  assert(AuditEventType.groupDeleted.toString == "groupDeleted");
  assert(AuditEventType.memberAdded.toString == "memberAdded");
  assert(AuditEventType.memberRemoved.toString == "memberRemoved");
  assert(AuditEventType.schemaCreated.toString == "schemaCreated");
  assert(AuditEventType.schemaUpdated.toString == "schemaUpdated");
  assert(AuditEventType.schemaDeleted.toString == "schemaDeleted");
  assert(AuditEventType.apiClientCreated.toString == "apiClientCreated");
  assert(AuditEventType.apiClientRevoked.toString == "apiClientRevoked");
  assert(AuditEventType.loginSuccess.toString == "loginSuccess");
  assert(AuditEventType.loginFailure.toString == "loginFailure");
  assert([AuditEventType.userCreated, AuditEventType.userUpdated, AuditEventType.userDeleted, AuditEventType.userActivated, AuditEventType.userDeactivated, AuditEventType.userLocked, AuditEventType.userUnlocked, AuditEventType.passwordChanged, AuditEventType.passwordReset, AuditEventType.groupCreated, AuditEventType.groupUpdated, AuditEventType.groupDeleted, AuditEventType.memberAdded, AuditEventType.memberRemoved, AuditEventType.schemaCreated, AuditEventType.schemaUpdated, AuditEventType.schemaDeleted, AuditEventType.apiClientCreated, AuditEventType.apiClientRevoked, AuditEventType.loginSuccess, AuditEventType.loginFailure].map!(s => toString(s)).array == ["userCreated", "userUpdated", "userDeleted", "userActivated", "userDeactivated", "userLocked", "userUnlocked", "passwordChanged", "passwordReset", "groupCreated", "groupUpdated", "groupDeleted", "memberAdded", "memberRemoved", "schemaCreated", "schemaUpdated", "schemaDeleted", "apiClientCreated", "apiClientRevoked", "loginSuccess", "loginFailure"]);
  assert(["userCreated", "userUpdated", "userDeleted", "userActivated", "userDeactivated", "userLocked", "userUnlocked", "passwordChanged", "passwordReset", "groupCreated", "groupUpdated", "groupDeleted", "memberAdded", "memberRemoved", "schemaCreated", "schemaUpdated", "schemaDeleted", "apiClientCreated", "apiClientRevoked", "loginSuccess", "loginFailure"].map!(s => toAuditEventType(s)).array == [AuditEventType.userCreated, AuditEventType.userUpdated, AuditEventType.userDeleted, AuditEventType.userActivated, AuditEventType.userDeactivated, AuditEventType.userLocked, AuditEventType.userUnlocked, AuditEventType.passwordChanged, AuditEventType.passwordReset, AuditEventType.groupCreated, AuditEventType.groupUpdated, AuditEventType.groupDeleted, AuditEventType.memberAdded, AuditEventType.memberRemoved, AuditEventType.schemaCreated, AuditEventType.schemaUpdated, AuditEventType.schemaDeleted, AuditEventType.apiClientCreated, AuditEventType.apiClientRevoked, AuditEventType.loginSuccess, AuditEventType.loginFailure]); 
}

/// Sort order.
enum SortOrder {
  ascending, // Sort in ascending order (A-Z, 0-9)
  descending, // Sort in descending order (Z-A, 9-0)
}
SortOrder toSortOrder(string value) {
  mixin(EnumSwitch("SortOrder", "ascending"));
}
SortOrder[] toSortOrder(string[] arr) {
  return arr.map!(s => toSortOrder(s)).array;
}
string toString(SortOrder order) {
  return order.to!string;
}
string[] toString(SortOrder[] orders) {
  return orders.map!(s => toString(s)).array;
}
///
unittest {
  mixin(ShowTest!("SortOrder"));

  assert(toSortOrder("ascending") == SortOrder.ascending);
  assert(toSortOrder("descending") == SortOrder.descending);

  assert(toString(SortOrder.ascending) == "ascending");
  assert(toString(SortOrder.descending) == "descending");

  assert([SortOrder.ascending, SortOrder.descending].map!(s => toString(s)).array == ["ascending", "descending"]);
  assert(["ascending", "descending"].map!(s => toSortOrder(s)).array == [SortOrder.ascending, SortOrder.descending]);
}
