/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.directory.application.dto;

import uim.platform.identity.directory.domain.types;
import uim.platform.identity.directory.domain.entities.user : UserName, Email,
  PhoneNumber, Address, ExtendedAttribute;
import uim.platform.identity.directory.domain.entities.group : GroupMember;
import uim.platform.identity.directory.domain.entities.schema : SchemaAttribute;

/// --- User DTOs ---

struct CreateUserRequest {
  TenantId tenantId;
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
  string userId;
  string error;

  bool isSuccess() const
  {
    return error.length == 0;
  }
}

/// --- Group DTOs ---

struct CreateGroupRequest {
  TenantId tenantId;
  string externalId;
  string displayName;
  string description;
  GroupMember[] members;
}

struct UpdateGroupRequest {
  GroupId groupId;
  string displayName;
  string description;
}

struct AddMemberRequest {
  GroupId groupId;
  string memberId;
  string memberType; // "User" or "Group"
  string display;
}

struct RemoveMemberRequest {
  GroupId groupId;
  string memberId;
}

struct GroupResponse {
  string groupId;
  string error;

  bool isSuccess() const
  {
    return error.length == 0;
  }
}

/// --- Schema DTOs ---

struct CreateSchemaRequest {
  TenantId tenantId;
  string name;
  string description;
  SchemaAttribute[] attributes;
}

struct UpdateSchemaRequest {
  SchemaId schemaId;
  string name;
  string description;
  SchemaAttribute[] attributes;
}

struct SchemaResponse {
  string schemaId;
  string error;

  bool isSuccess() const
  {
    return error.length == 0;
  }
}

/// --- Password Policy DTOs ---

struct CreatePasswordPolicyRequest {
  TenantId tenantId;
  string name;
  string description;
  uint minLength;
  uint maxLength;
  bool requireUppercase;
  bool requireLowercase;
  bool requireDigit;
  bool requireSpecialChar;
  uint minUniqueChars;
  uint maxRepeatedChars;
  uint passwordHistoryCount;
  uint maxFailedAttempts;
  uint lockoutDurationMinutes;
  uint expiryDays;
}

struct PasswordPolicyResponse {
  string policyId;
  string error;

  bool isSuccess() const
  {
    return error.length == 0;
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

  bool isSuccess() const
  {
    return error.length == 0;
  }
}

/// --- SCIM List Response ---

struct ScimListResponse(T) {
  long totalResults;
  long startIndex;
  long itemsPerPage;
  T[] resources;
}
