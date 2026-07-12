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
  active, // User is active and can authenticate
  inactive, // User is inactive and cannot authenticate
  locked, // User is locked due to too many failed login attempts
  staged, // User is staged for activation but not yet active
  provisioning, // User is currently being provisioned and not yet active
  pending // User is pending activation (e.g. awaiting email verification)
}
UserStatus toUserStatus(string s) {
  const map = [
    "active": UserStatus.active,
    "inactive": UserStatus.inactive,
    "locked": UserStatus.locked,
    "staged": UserStatus.staged
  ];
  return map.get(s.toLower, UserStatus.inactive);
}

/// SCIM 2.0 group type.
enum GroupType {
  standard, // Standard group with direct members
  dynamic, // Dynamic group with membership based on rules
  nested // Nested group that can contain other groups as members
}
GroupType toGroupType(string s) {
  const map = [
    "standard": GroupType.standard,
    "dynamic": GroupType.dynamic,
    "nested": GroupType.nested
  ];
  return map.get(s.toLower, GroupType.standard);
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
AttributeType toAttributeType(string s) {
  const map = [
    "string": AttributeType.stringType,
    "integer": AttributeType.integerType,
    "boolean": AttributeType.booleanType,
    "dateTime": AttributeType.dateTimeType,
    "reference": AttributeType.referenceType,
    "complex": AttributeType.complexType,
    "binary": AttributeType.binaryType
  ];
  return map.get(s.toLower, AttributeType.stringType);
}

/// Attribute mutability (SCIM 2.0).
enum Mutability {
  readWrite, // Attribute can be read and updated by clients
  readOnly, // Attribute can be read but not updated by clients
  writeOnly, // Attribute can be updated but not read by clients (e.g. password)
  immutable_, // Attribute is immutable and cannot be updated after creation (e.g. id)
}
Mutability toMutability(string s) {
  const map = [
    "readWrite": Mutability.readWrite,
    "readOnly": Mutability.readOnly,
    "writeOnly": Mutability.writeOnly,
    "immutable": Mutability.immutable_
  ];
  return map.get(s.toLower, Mutability.readWrite);
}

/// Attribute returned behavior (SCIM 2.0).
enum Returned {
  always, // Attribute is always returned in responses
  never, // Attribute is never returned in responses
  default_, // Attribute is returned by default but can be excluded with ?excludedAttributes
  request, // Attribute is returned only if explicitly requested via ?attributes
}
Returned toReturned(string s) {
  const map = [
    "always": Returned.always,
    "never": Returned.never,
    "default": Returned.default_,
    "request": Returned.request
  ];
  return map.get(s.toLower, Returned.default_);
}

/// Attribute uniqueness (SCIM 2.0).
enum Uniqueness {
  none, // Attribute values do not need to be unique
  server, // Attribute values must be unique within the server (e.g. username)
  global, // Attribute values must be globally unique across all servers (e.g. email)
}
Uniqueness toUniqueness(string s) {
  const map = [
    "none": Uniqueness.none,
    "server": Uniqueness.server,
    "global": Uniqueness.global
  ];
  return map.get(s.toLower, Uniqueness.none);
}

/// Password policy strength level.
enum PasswordStrength {
  weak, // Password is not strong enough
  standard, // Password meets standard complexity requirements
  strong, // Password meets strong complexity requirements
  enterprise, // Password meets enterprise-grade complexity requirements
}
PasswordStrength toPasswordStrength(string s) {
  const map = [
    "weak": PasswordStrength.weak,
    "standard": PasswordStrength.standard,
    "strong": PasswordStrength.strong,
    "enterprise": PasswordStrength.enterprise
  ];
  return map.get(s.toLower, PasswordStrength.standard);
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
AuditEventType toAuditEventType(string s) {
  const map = [
    "usercreated": AuditEventType.userCreated,
    "userupdated": AuditEventType.userUpdated,
    "userdeleted": AuditEventType.userDeleted,
    "useractivated": AuditEventType.userActivated,
    "userdeactivated": AuditEventType.userDeactivated,
    "userlocked": AuditEventType.userLocked,
    "userunlocked": AuditEventType.userUnlocked,
    "passwordchanged": AuditEventType.passwordChanged,
    "passwordreset": AuditEventType.passwordReset,
    "groupcreated": AuditEventType.groupCreated,
    "groupupdated": AuditEventType.groupUpdated,
    "groupdeleted": AuditEventType.groupDeleted,
    "memberadded": AuditEventType.memberAdded,
    "memberremoved": AuditEventType.memberRemoved,
    "schemacreated": AuditEventType.schemaCreated,
    "schemaupdated": AuditEventType.schemaUpdated,
    "schemadeleted": AuditEventType.schemaDeleted,
    "apiclientcreated": AuditEventType.apiClientCreated,
    "apiclientrevoked": AuditEventType.apiClientRevoked,
    "loginsuccess": AuditEventType.loginSuccess,
    "loginfailure": AuditEventType.loginFailure
  ];
  return map.get(s.toLower, AuditEventType.loginFailure);
}
/// Sort order.
enum SortOrder {
  ascending, // Sort in ascending order (A-Z, 0-9)
  descending, // Sort in descending order (Z-A, 9-0)
}
SortOrder toSortOrder(string s) {
  const map = [
    "ascending": SortOrder.ascending, 
    "descending": SortOrder.descending
  ];
  return map.get(s.toLower, SortOrder.ascending);
}
