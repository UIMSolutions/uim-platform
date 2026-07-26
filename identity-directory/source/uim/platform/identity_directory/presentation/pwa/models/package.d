/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_directory.presentation.pwa.models;

import uim.platform.identity_directory;

mixin(ShowModule!());

@safe:

struct PwaEndpoint {
  string method;
  string path;
  string summary;
  string body;
}

struct PwaDomain {
  string key;
  string title;
  string description;
  PwaEndpoint[] endpoints;
}

struct PwaPageModel {
  string serviceName;
  string tenantId;
  string intro;
  string[] useCases;
  PwaDomain[] domains;
}

PwaPageModel buildPwaPageModel(string tenantId) {
  PwaPageModel model;
  model.serviceName = "Identity Directory PWA";
  model.tenantId = tenantId.length > 0 ? tenantId : "default";
  model.intro = "A browser-first control surface for the six identity-directory management areas.";
  model.useCases = [
    "ManageApiClientsUseCase",
    "QueryAuditLogUseCase",
    "ManageUsersUseCase",
    "ManageGroupsUseCase",
    "ManageSchemasUseCase",
    "ManagePasswordPoliciesUseCase",
  ];
  model.domains = [
    PwaDomain(
      "api-client",
      "API Clients",
      "Provision and revoke technical clients used by automation and integrations.",
      [
        PwaEndpoint("GET", "/api/v1/api-clients", "List clients", ""),
        PwaEndpoint("POST", "/api/v1/api-clients", "Create client", q{
{
  "name": "analytics-client",
  "description": "Client for analytics jobs",
  "scopes": ["openid", "profile", "directory.read"],
  "expiresAt": 1893456000
}
}),
        PwaEndpoint("GET", "/api/v1/api-clients/{id}", "Read client", ""),
        PwaEndpoint("DELETE", "/api/v1/api-clients/{id}", "Revoke client", ""),
      ]
    ),
    PwaDomain(
      "audit",
      "Audit Log",
      "Inspect who changed what, when, and against which target.",
      [
        PwaEndpoint("GET", "/api/v1/audit-logs", "List audit events", ""),
        PwaEndpoint("GET", "/api/v1/audit-logs/actor/{actorId}", "Filter by actor", ""),
        PwaEndpoint("GET", "/api/v1/audit-logs/target/{targetId}", "Filter by target", ""),
      ]
    ),
    PwaDomain(
      "user",
      "Users",
      "Create, query, modify, search, deactivate, and change passwords for SCIM users.",
      [
        PwaEndpoint("POST", "/scim/Users", "Create user", q{
{
  "userName": "jane.doe",
  "displayName": "Jane Doe",
  "userType": "employee",
  "preferredLanguage": "en",
  "locale": "en-US",
  "timezone": "UTC",
  "password": "ChangeMe123!",
  "addresses": []
}
}),
        PwaEndpoint("GET", "/scim/Users", "List users", ""),
        PwaEndpoint("GET", "/scim/Users/{id}", "Read user", ""),
        PwaEndpoint("PUT", "/scim/Users/{id}", "Update user", q{
{
  "displayName": "Jane Doe",
  "userType": "employee",
  "preferredLanguage": "en",
  "locale": "en-US",
  "timezone": "UTC",
  "active": true,
  "emails": [],
  "phoneNumbers": [],
  "addresses": [],
  "extendedAttributes": []
}
}),
        PwaEndpoint("DELETE", "/scim/Users/{id}", "Delete user", ""),
        PwaEndpoint("POST", "/scim/Users/change-password", "Change password", q{
{
  "currentPassword": "ChangeMe123!",
  "newPassword": "ChangeMe456!"
}
}),
        PwaEndpoint("GET", "/scim/Users/search?filter=userName%20eq%20\"jane.doe\"", "Search users", ""),
      ]
    ),
    PwaDomain(
      "group",
      "Groups",
      "Manage SCIM groups and membership changes.",
      [
        PwaEndpoint("POST", "/scim/Groups", "Create group", q{
{
  "displayName": "Platform Admins",
  "description": "Administrators for the platform",
  "members": []
}
}),
        PwaEndpoint("GET", "/scim/Groups", "List groups", ""),
        PwaEndpoint("GET", "/scim/Groups/{id}", "Read group", ""),
        PwaEndpoint("PUT", "/scim/Groups/{id}", "Update group", q{
{
  "displayName": "Platform Admins",
  "description": "Administrators for the platform"
}
}),
        PwaEndpoint("DELETE", "/scim/Groups/{id}", "Delete group", ""),
        PwaEndpoint("POST", "/scim/Groups/members", "Add member", q{
{
  "groupId": "group-id",
  "memberId": "user-id",
  "memberType": "User",
  "display": "Jane Doe"
}
}),
        PwaEndpoint("DELETE", "/scim/Groups/members", "Remove member", q{
{
  "groupId": "group-id",
  "memberId": "user-id"
}
}),
      ]
    ),
    PwaDomain(
      "schema",
      "Schemas",
      "Manage custom schema definitions used by SCIM resources.",
      [
        PwaEndpoint("POST", "/scim/Schemas", "Create schema", q{
{
  "name": "costCenterSchema",
  "description": "Custom attribute schema for cost centers",
  "attributes": [
    {"id": "costCenter", "name": "costCenter", "description": "Cost center code"}
  ]
}
}),
        PwaEndpoint("GET", "/scim/Schemas", "List schemas", ""),
        PwaEndpoint("GET", "/scim/Schemas/{id}", "Read schema", ""),
        PwaEndpoint("PUT", "/scim/Schemas/{id}", "Update schema", q{
{
  "name": "costCenterSchema",
  "description": "Custom attribute schema for cost centers",
  "attributes": []
}
}),
        PwaEndpoint("DELETE", "/scim/Schemas/{id}", "Delete schema", ""),
      ]
    ),
    PwaDomain(
      "password-policy",
      "Password Policies",
      "Create and review the active policy that governs password strength.",
      [
        PwaEndpoint("POST", "/api/v1/password-policies", "Create policy", q{
{
  "name": "default-policy",
  "description": "Standard policy for employee identities",
  "minLength": 12,
  "maxLength": 128,
  "requireUppercase": true,
  "requireLowercase": true,
  "requireDigit": true,
  "requireSpecialChar": true,
  "minUniqueChars": 1,
  "maxRepeatedChars": 2,
  "passwordHistoryCount": 5,
  "maxFailedAttempts": 5,
  "lockoutDurationMinutes": 30,
  "expiryDays": 90
}
}),
        PwaEndpoint("GET", "/api/v1/password-policies", "List policies", ""),
        PwaEndpoint("GET", "/api/v1/password-policies/active", "Read active policy", ""),
        PwaEndpoint("GET", "/api/v1/password-policies/{id}", "Read policy by id", ""),
      ]
    ),
  ];

  return model;
}