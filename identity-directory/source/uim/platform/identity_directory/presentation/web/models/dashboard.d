/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_directory.presentation.web.models.dashboard;

import std.array : join;
import std.conv : to;

import uim.platform.identity_directory;

mixin(ShowModule!());

@safe:

struct WebActionModel {
  string label;
  string method;
  string path;
  string body;
}

struct WebMetricModel {
  string label;
  string value;
}

struct WebTableModel {
  string[] headers;
  string[][] rows;
}

struct WebPageModel {
  string serviceName;
  string title;
  string tenantId;
  string intro;
  string[] highlights;
  WebMetricModel[] metrics;
  WebActionModel[] actions;
  WebTableModel table;
  string requestPath;
  string requestBody;
}

WebPageModel buildDashboardModel(string tenantId, size_t apiClientCount, size_t auditCount,
    size_t userCount, size_t groupCount, size_t schemaCount, size_t passwordPolicyCount) {
  WebPageModel model;
  model.serviceName = "Identity Directory";
  model.title = "Management Dashboard";
  model.tenantId = tenantId.length > 0 ? tenantId : "default";
  model.intro = "Operate the six identity-directory areas from a single HTML MVC surface.";
  model.highlights = [
    "Browser-friendly control panels",
    "Live counts from application use cases",
    "Request templates for the API endpoints",
  ];
  model.metrics = [
    WebMetricModel("API clients", apiClientCount.to!string),
    WebMetricModel("Audit events", auditCount.to!string),
    WebMetricModel("Users", userCount.to!string),
    WebMetricModel("Groups", groupCount.to!string),
    WebMetricModel("Schemas", schemaCount.to!string),
    WebMetricModel("Password policies", passwordPolicyCount.to!string),
  ];
  model.actions = [
    WebActionModel("Open API clients", "GET", "/web/identity-directory/api-clients?tenantId=" ~
        model.tenantId, ""),
    WebActionModel("Open audits", "GET", "/web/identity-directory/audit?tenantId=" ~
        model.tenantId, ""),
    WebActionModel("Open users", "GET", "/web/identity-directory/users?tenantId=" ~
        model.tenantId, ""),
    WebActionModel("Open groups", "GET", "/web/identity-directory/groups?tenantId=" ~
        model.tenantId, ""),
    WebActionModel("Open schemas", "GET", "/web/identity-directory/schemas?tenantId=" ~
        model.tenantId, ""),
    WebActionModel("Open password policies", "GET", "/web/identity-directory/password-policies?tenantId=" ~
        model.tenantId, ""),
  ];
  return model;
}

WebPageModel buildApiClientsModel(string tenantId, ApiClient[] clients) {
  WebPageModel model;
  model.serviceName = "Identity Directory";
  model.title = "API Clients";
  model.tenantId = tenantId.length > 0 ? tenantId : "default";
  model.intro = "Create, inspect, and revoke technical clients used for service-to-service access.";
  model.highlights = [
    "Technical credentials with scopes",
    "Simple revoke-first lifecycle",
    "Audit trail on create and revoke",
  ];
  model.metrics = [WebMetricModel("Clients", clients.length.to!string)];
  model.actions = [
    WebActionModel("Create client", "POST", "/api/v1/api-clients", q{
{
  "name": "analytics-client",
  "description": "Client for analytics jobs",
  "scopes": ["openid", "profile", "directory.read"],
  "expiresAt": 1893456000
}
}),
    WebActionModel("Revoke client", "DELETE", "/api/v1/api-clients/{id}", ""),
  ];
  model.table.headers = ["Name", "Client ID", "Active", "Expires At", "Scopes"];
  foreach (client; clients) {
    model.table.rows ~= [
      client.name,
      client.clientId,
      client.active ? "active" : "inactive",
      client.expiresAt > 0 ? client.expiresAt.to!string : "never",
      client.scopes.join(", "),
    ];
  }
  model.requestPath = "/api/v1/api-clients";
  model.requestBody = q{
{
  "name": "analytics-client",
  "description": "Client for analytics jobs",
  "scopes": ["openid", "profile", "directory.read"],
  "expiresAt": 1893456000
}
};
  return model;
}

WebPageModel buildAuditModel(string tenantId, AuditEvent[] events) {
  WebPageModel model;
  model.serviceName = "Identity Directory";
  model.title = "Audit Log";
  model.tenantId = tenantId.length > 0 ? tenantId : "default";
  model.intro = "Inspect audit activity by actor, target, or event type.";
  model.highlights = [
    "Actor and target drilldowns",
    "Security and lifecycle history",
    "Tenant-scoped event stream",
  ];
  model.metrics = [WebMetricModel("Events", events.length.to!string)];
  model.actions = [
    WebActionModel("Filter by actor", "GET", "/api/v1/audit-logs/actor/{actorId}", ""),
    WebActionModel("Filter by target", "GET", "/api/v1/audit-logs/target/{targetId}", ""),
  ];
  model.table.headers = ["Type", "Actor", "Target", "Description", "Timestamp"];
  foreach (event; events) {
    model.table.rows ~= [
      event.eventType.to!string,
      event.actorId,
      event.targetType ~ ": " ~ event.targetId,
      event.description,
      event.timestamp.to!string,
    ];
  }
  model.requestPath = "/api/v1/audit-logs";
  model.requestBody = "";
  return model;
}

WebPageModel buildUsersModel(string tenantId, IDUser[] users) {
  WebPageModel model;
  model.serviceName = "Identity Directory";
  model.title = "Users";
  model.tenantId = tenantId.length > 0 ? tenantId : "default";
  model.intro = "Manage SCIM users, search records, and update credentials.";
  model.highlights = [
    "SCIM profile data",
    "Password change workflow",
    "Search and deactivate controls",
  ];
  model.metrics = [WebMetricModel("Users", users.length.to!string)];
  model.actions = [
    WebActionModel("Create user", "POST", "/scim/Users", q{
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
    WebActionModel("Change password", "POST", "/scim/Users/change-password", q{
{
  "currentPassword": "ChangeMe123!",
  "newPassword": "ChangeMe456!"
}
}),
  ];
  model.table.headers = ["User Name", "Display Name", "Status", "Primary Email", "Groups"];
  foreach (user; users) {
    model.table.rows ~= [
      user.userName,
      user.getDisplayName(),
      user.isActive() ? "active" : "inactive",
      user.primaryEmail(),
      user.groupIds.length.to!string,
    ];
  }
  model.requestPath = "/scim/Users";
  model.requestBody = q{
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
};
  return model;
}

WebPageModel buildGroupsModel(string tenantId, IDGroup[] groups) {
  WebPageModel model;
  model.serviceName = "Identity Directory";
  model.title = "Groups";
  model.tenantId = tenantId.length > 0 ? tenantId : "default";
  model.intro = "Create groups and manage their membership graph.";
  model.highlights = [
    "SCIM groups",
    "Membership add/remove flows",
    "Change history in audit log",
  ];
  model.metrics = [WebMetricModel("Groups", groups.length.to!string)];
  model.actions = [
    WebActionModel("Create group", "POST", "/scim/Groups", q{
{
  "displayName": "Platform Admins",
  "description": "Administrators for the platform",
  "members": []
}
}),
    WebActionModel("Add member", "POST", "/scim/Groups/members", q{
{
  "groupId": "group-id",
  "memberId": "user-id",
  "memberType": "User",
  "display": "Jane Doe"
}
}),
  ];
  model.table.headers = ["Display Name", "Members", "Description", "Type"];
  foreach (group; groups) {
    model.table.rows ~= [
      group.displayName,
      group.memberCount().to!string,
      group.description,
      group.groupType.to!string,
    ];
  }
  model.requestPath = "/scim/Groups";
  model.requestBody = q{
{
  "displayName": "Platform Admins",
  "description": "Administrators for the platform",
  "members": []
}
};
  return model;
}

WebPageModel buildSchemasModel(string tenantId, Schema[] schemas) {
  WebPageModel model;
  model.serviceName = "Identity Directory";
  model.title = "Schemas";
  model.tenantId = tenantId.length > 0 ? tenantId : "default";
  model.intro = "Design and maintain custom SCIM schema extensions.";
  model.highlights = [
    "Attribute metadata management",
    "Reusable custom schema definitions",
    "Attribute count visibility",
  ];
  model.metrics = [WebMetricModel("Schemas", schemas.length.to!string)];
  model.actions = [
    WebActionModel("Create schema", "POST", "/scim/Schemas", q{
{
  "name": "costCenterSchema",
  "description": "Custom attribute schema for cost centers",
  "attributes": [
    {"id": "costCenter", "name": "costCenter", "description": "Cost center code"}
  ]
}
}),
  ];
  model.table.headers = ["Name", "Attribute Count", "Description"];
  foreach (schema; schemas) {
    model.table.rows ~= [
      schema.name,
      schema.attributes.length.to!string,
      schema.description,
    ];
  }
  model.requestPath = "/scim/Schemas";
  model.requestBody = q{
{
  "name": "costCenterSchema",
  "description": "Custom attribute schema for cost centers",
  "attributes": [
    {"id": "costCenter", "name": "costCenter", "description": "Cost center code"}
  ]
}
};
  return model;
}

WebPageModel buildPasswordPoliciesModel(string tenantId, PasswordPolicy[] policies) {
  WebPageModel model;
  model.serviceName = "Identity Directory";
  model.title = "Password Policies";
  model.tenantId = tenantId.length > 0 ? tenantId : "default";
  model.intro = "Review and define the active password policy for a tenant.";
  model.highlights = [
    "Strength and lockout controls",
    "Active policy visibility",
    "History and expiry settings",
  ];
  model.metrics = [WebMetricModel("Policies", policies.length.to!string)];
  model.actions = [
    WebActionModel("Create policy", "POST", "/api/v1/password-policies", q{
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
  ];
  model.table.headers = ["Name", "Active", "Min Length", "Expiry Days", "Special Char"];
  foreach (policy; policies) {
    model.table.rows ~= [
      policy.name,
      policy.active ? "active" : "inactive",
      policy.minLength.to!string,
      policy.expiryDays.to!string,
      policy.requireSpecialChar ? "required" : "optional",
    ];
  }
  model.requestPath = "/api/v1/password-policies";
  model.requestBody = q{
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
};
  return model;
}