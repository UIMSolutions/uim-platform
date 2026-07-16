/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_directory.application.dto;

// import uim.platform.identity_directory.domain.types;
// import uim.platform.identity_directory.domain.entities.user : UserName, Email,
//   PhoneNumber, Address, ExtendedAttribute;
// import uim.platform.identity_directory.domain.entities.group : GroupMember;
// import uim.platform.identity_directory.domain.entities.schema : SchemaAttribute;
import uim.platform.identity_directory;

mixin(ShowModule!());

@safe:
/// --- IDUser DTOs ---

struct CreateUserRequest {
  TenantId tenantId;
  UserId userId;

  string externalId;
  string userName;
  UserName name;
  string displayName;
  string userType;
  string preferredLanguage;
  string locale;
  string timezone;
  string password;
  Email[] emails;
  PhoneNumber[] phoneNumbers;
  Address[] addresses;
  ExtendedAttribute[] extendedAttributes;
  string[] schemas;
}

struct UpdateUserRequest {
  TenantId tenantId;

  UserId userId;
  UserName name;
  string displayName;
  string userType;
  string preferredLanguage;
  string locale;
  string timezone;
  bool active;
  Email[] emails;
  PhoneNumber[] phoneNumbers;
  Address[] addresses;
  ExtendedAttribute[] extendedAttributes;
}

struct UserResponse {
  UserId userId;
  string error;

  bool hasError() const {
    return error.length > 0;
  }
}
/// --- IDGroup DTOs ---

struct CreateGroupRequest {
  TenantId tenantId;
  string externalId;
  string displayName;
  string description;
  GroupMember[] members;
}

struct UpdateGroupRequest {
  TenantId tenantId;
  GroupId groupId;
  string displayName;
  string description;
}

struct AddMemberRequest {
  TenantId tenantId;
  GroupId groupId;
  string memberId;
  string memberType; // "User" or "Group"
  string display;
}

struct RemoveMemberRequest {
  TenantId tenantId;
  GroupId groupId;
  string memberId;
}

struct GroupResponse {
  string id;
  string error;

  bool hasError() const {
    return error.length > 0;
  }
}
/// --- Schema DTOs ---

struct CreateSchemaRequest {
  TenantId tenantId;
  SchemaId schemaId;

  string name;
  string description;
  SchemaAttribute[] attributes;
}

struct UpdateSchemaRequest {
  TenantId tenantId;
  SchemaId schemaId;
  string name;
  string description;
  SchemaAttribute[] attributes;
}

struct SchemaResponse {
  SchemaId schemaId;
  string error;

  bool hasError() const {
    return error.length > 0;
  }
}
/// --- Password Policy DTOs ---
struct CreatePasswordPolicyRequest {
  TenantId tenantId;
  PasswordPolicyId policyId;

  string name;
  string description;
  size_t minLength;
  size_t maxLength;
  bool requireUppercase;
  bool requireLowercase;
  bool requireDigit;
  bool requireSpecialChar;
  size_t minUniqueChars;
  size_t maxRepeatedChars;
  size_t passwordHistoryCount;
  size_t maxFailedAttempts;
  size_t lockoutDurationMinutes;
  size_t expiryDays;
}

struct PasswordPolicyResponse {
  PasswordPolicyId policyId;
  string error;

  bool hasError() const {
    return error.length > 0;
  }
}
/// --- API Client DTOs ---
struct CreateApiClientRequest {
  TenantId tenantId;
  string name;
  string description;
  string[] scopes;
  long expiresAt; // 0 = no expiry
}

struct ApiClientResponse {
  string clientId;
  string clientSecret; // only returned on creation
  string error;

  bool hasError() const {
    return error.length > 0;
  }
}
/// --- SCIM List Response ---

struct ScimListResponse(T) {
  long totalResults;
  long startIndex;
  long itemsPerPage;
  T[] resources;
}
