/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.directory.domain.types;

/// Unique identifier type aliases for type safety.


struct GroupId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}



struct SchemaId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct AttributeId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct ApiClientId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

/// SCIM 2.0 user status.
enum UserStatus {
  active,
  inactive,
  locked,
  staged,
}

/// SCIM 2.0 group type.
enum GroupType {
  standard,
  dynamic,
}

/// Attribute data types for custom schemas.
enum AttributeType {
  stringType,
  integerType,
  booleanType,
  dateTimeType,
  referenceType,
  complexType,
  binaryType,
}

/// Attribute mutability (SCIM 2.0).
enum Mutability {
  readWrite,
  readOnly,
  writeOnly,
  immutable_,
}

/// Attribute returned behavior (SCIM 2.0).
enum Returned {
  always,
  never,
  default_,
  request,
}

/// Attribute uniqueness (SCIM 2.0).
enum Uniqueness {
  none,
  server,
  global,
}

/// Password policy strength level.
enum PasswordStrength {
  weak,
  standard,
  strong,
  enterprise,
}

/// Audit event type.
enum AuditEventType {
  userCreated,
  userUpdated,
  userDeleted,
  userActivated,
  userDeactivated,
  userLocked,
  userUnlocked,
  passwordChanged,
  passwordReset,
  groupCreated,
  groupUpdated,
  groupDeleted,
  memberAdded,
  memberRemoved,
  schemaCreated,
  schemaUpdated,
  schemaDeleted,
  apiClientCreated,
  apiClientRevoked,
  loginSuccess,
  loginFailure,
}

/// Sort order.
enum SortOrder {
  ascending,
  descending,
}
