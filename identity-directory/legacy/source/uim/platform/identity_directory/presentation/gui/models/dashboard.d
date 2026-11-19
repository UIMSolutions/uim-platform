/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_directory.presentation.gui.models.dashboard;

import std.conv : to;

import uim.platform.identity_directory;

mixin(ShowModule!());

@safe:

struct GuiMetricModel {
    string label;
    string value;
}

struct GuiActionModel {
    string label;
    string method;
    string path;
    string body;
}

struct GuiTableModel {
    string[] headers;
    string[][] rows;
}

struct GuiPageModel {
    string pageId;
    string title;
    string tenantId;
    string intro;
    string[] highlights;
    GuiMetricModel[] metrics;
    GuiActionModel[] actions;
    GuiTableModel table;
    string requestPath;
    string requestBody;
}

GuiPageModel buildDashboardModel(string tenantId, size_t apiClientCount, size_t auditCount,
    size_t userCount, size_t groupCount, size_t schemaCount, size_t passwordPolicyCount) {
    GuiPageModel model;
    model.pageId = "dashboard";
    model.title = "Management Dashboard";
    model.tenantId = tenantId.length > 0 ? tenantId : "default";
    model.intro = "Operate the six identity-directory areas from a single GTK MVC surface.";
    model.highlights = ["Desktop navigation for the full identity lifecycle",
        "Live counts from the application layer",
        "Entity-specific workspaces with request previews",
    ];
    model.metrics = [GuiMetricModel("API clients", apiClientCount.to!string),
        GuiMetricModel("Audit events", auditCount.to!string),
        GuiMetricModel("Users", userCount.to!string),
        GuiMetricModel("Groups", groupCount.to!string),
        GuiMetricModel("Schemas", schemaCount.to!string),
        GuiMetricModel("Password policies", passwordPolicyCount.to!string),
    ];
    model.actions = [GuiActionModel("Open API clients", "GET", "api-clients", ""),
        GuiActionModel("Open audit log", "GET", "audit", ""),
        GuiActionModel("Open users", "GET", "users", ""),
        GuiActionModel("Open groups", "GET", "groups", ""),
        GuiActionModel("Open schemas", "GET", "schemas", ""),
        GuiActionModel("Open password policies", "GET", "password-policies", ""),
    ];
    return model;
}

GuiPageModel buildApiClientsModel(string tenantId, ApiClient[] clients) {
    auto model = buildPageModel("api-clients", "API Clients", tenantId,
        "Create, inspect, and revoke technical clients used for service-to-service access.",
        [    "Technical credentials with scopes",
            "Revoke-first lifecycle control",
            "Audit-friendly client administration",
        ],
        ["Name", "Client ID", "Active", "Expires At", "Scopes"],
        GuiActionModel("Create client", "POST", "/api/v1/api-clients", q{
{
  "name": "analytics-client",
  "description": "Client for analytics jobs",
  "scopes": ["openid", "profile", "directory.read"],
  "expiresAt": 1893456000
}
}));
    foreach (client; clients) {
        model.table.rows ~= [    client.name,
            client.clientId,
            client.active ? "active" : "inactive",
            client.expiresAt > 0 ? client.expiresAt.to!string : "never",
            joinStrings(client.scopes, ", "),
        ];
    }
    model.requestPath = "/api/v1/api-clients";
    model.requestBody = model.actions[0].body;
    return model;
}

GuiPageModel buildAuditModel(string tenantId, AuditEvent[] events) {
    auto model = buildPageModel("audit", "Audit Log", tenantId,
        "Inspect audit activity by actor, target, or event type.",
        [    "Actor and target drilldowns",
            "Security and lifecycle history",
            "Tenant-scoped event stream",
        ],
        ["Type", "Actor", "Target", "Description", "Timestamp"],
        GuiActionModel("Filter by actor", "GET", "/api/v1/audit-logs/actor/{actorId}", ""));
    foreach (event; events) {
        model.table.rows ~= [    event.eventType.to!string,
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

GuiPageModel buildUsersModel(string tenantId, IDUser[] users) {
    auto model = buildPageModel("users", "Users", tenantId,
        "Manage SCIM users, search records, and review account status.",
        [    "SCIM profile data",
            "Password change workflow",
            "Search and deactivate controls",
        ],
        ["User Name", "Display Name", "Status", "Primary Email", "Groups"],
        GuiActionModel("Create user", "POST", "/scim/Users", q{
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
}));
    foreach (user; users) {
        model.table.rows ~= [    user.userName,
            user.getDisplayName(),
            user.isActive() ? "active" : "inactive",
            user.primaryEmail(),
            user.groupIds.length.to!string,
        ];
    }
    model.requestPath = "/scim/Users";
    model.requestBody = model.actions[0].body;
    return model;
}

GuiPageModel buildGroupsModel(string tenantId, IDGroup[] groups) {
    auto model = buildPageModel("groups", "Groups", tenantId,
        "Create groups and manage their membership graph.",
        [    "SCIM groups",
            "Membership add/remove flows",
            "Change history in audit log",
        ],
        ["Display Name", "Members", "Description", "Type"],
        GuiActionModel("Create group", "POST", "/scim/Groups", q{
{
  "displayName": "Platform Admins",
  "description": "Administrators for the platform",
  "members": []
}
}));
    foreach (group; groups) {
        model.table.rows ~= [    group.displayName,
            group.memberCount().to!string,
            group.description,
            group.groupType.to!string,
        ];
    }
    model.requestPath = "/scim/Groups";
    model.requestBody = model.actions[0].body;
    return model;
}

GuiPageModel buildSchemasModel(string tenantId, Schema[] schemas) {
    auto model = buildPageModel("schemas", "Schemas", tenantId,
        "Design and maintain custom SCIM schema extensions.",
        [    "Attribute metadata management",
            "Reusable custom schema definitions",
            "Attribute count visibility",
        ],
        ["Name", "Attribute Count", "Description"],
        GuiActionModel("Create schema", "POST", "/scim/Schemas", q{
{
  "name": "costCenterSchema",
  "description": "Custom attribute schema for cost centers",
  "attributes": [
    {"id": "costCenter", "name": "costCenter", "description": "Cost center code"}
  ]
}
}));
    foreach (schema; schemas) {
        model.table.rows ~= [    schema.name,
            schema.attributes.length.to!string,
            schema.description,
        ];
    }
    model.requestPath = "/scim/Schemas";
    model.requestBody = model.actions[0].body;
    return model;
}

GuiPageModel buildPasswordPoliciesModel(string tenantId, PasswordPolicy[] policies) {
    auto model = buildPageModel("password-policies", "Password Policies", tenantId,
        "Review and define the active password policy for a tenant.",
        [    "Strength and lockout controls",
            "Active policy visibility",
            "History and expiry settings",
        ],
        ["Name", "Active", "Min Length", "Expiry Days", "Special Char"],
        GuiActionModel("Create policy", "POST", "/api/v1/password-policies", q{
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
}));
    foreach (policy; policies) {
        model.table.rows ~= [    policy.name,
            policy.active ? "active" : "inactive",
            policy.minLength.to!string,
            policy.expiryDays.to!string,
            policy.requireSpecialChar ? "required" : "optional",
        ];
    }
    model.requestPath = "/api/v1/password-policies";
    model.requestBody = model.actions[0].body;
    return model;
}

string renderTextReport(GuiPageModel dashboard, GuiPageModel[] pages) {
    string text;
    text ~= renderPageText(dashboard);
    foreach (page; pages) {
        text ~= "\n\n" ~ renderPageText(page);
    }
    return text;
}

string renderPageText(GuiPageModel model) {
    string text;
    text ~= model.title ~ "\n";
    text ~= repeatChar('=', model.title.length) ~ "\n";
    text ~= "Tenant: " ~ model.tenantId ~ "\n";
    text ~= model.intro ~ "\n\n";

    if (model.highlights.length > 0) {
        text ~= "Highlights:\n";
        foreach (highlight; model.highlights) {
            text ~= "- " ~ highlight ~ "\n";
        }
        text ~= "\n";
    }

    if (model.metrics.length > 0) {
        text ~= "Metrics:\n";
        foreach (metric; model.metrics) {
            text ~= "- " ~ metric.label ~ ": " ~ metric.value ~ "\n";
        }
        text ~= "\n";
    }

    if (model.actions.length > 0) {
        text ~= "Actions:\n";
        foreach (action; model.actions) {
            text ~= "- " ~ action.method ~ " " ~ action.path ~ " :: " ~ action.label ~ "\n";
        }
        text ~= "\n";
    }

    if (model.table.headers.length > 0) {
        text ~= renderTableText(model.table);
    }

    if (model.requestPath.length > 0) {
        text ~= "Request Path: " ~ model.requestPath ~ "\n";
    }
    if (model.requestBody.length > 0) {
        text ~= "Request Body:\n" ~ model.requestBody ~ "\n";
    }

    return text;
}

private GuiPageModel buildPageModel(string pageId, string title, string tenantId,
    string intro, string[] highlights, string[] headers, GuiActionModel action) {
    GuiPageModel model;
    model.pageId = pageId;
    model.title = title;
    model.tenantId = tenantId.length > 0 ? tenantId : "default";
    model.intro = intro;
    model.highlights = highlights;
    model.table.headers = headers;
    model.actions = [action];
    model.requestPath = action.path;
    model.requestBody = action.body;
    return model;
}

private string joinStrings(string[] values, string separator) {
    string text;
    foreach (index, value; values) {
        if (index > 0)
            text ~= separator;
        text ~= value;
    }
    return text;
}

private string renderTableText(GuiTableModel table) {
    string text;
    text ~= "Table:\n";
    text ~= joinStrings(table.headers, " | ") ~ "\n";
    text ~= repeatChar('-', 40) ~ "\n";
    foreach (row; table.rows) {
        text ~= joinStrings(row, " | ") ~ "\n";
    }
    text ~= "\n";
    return text;
}

private string repeatChar(char character, size_t count) {
    string text;
    foreach (_; 0 .. count) {
        text ~= character;
    }
    return text;
}
