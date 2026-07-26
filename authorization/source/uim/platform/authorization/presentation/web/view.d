module uim.platform.authorization.presentation.web.view;

import std.conv : to;
import vibe.data.json : Json;
import uim.platform.authorization;

mixin(ShowModule!());

@safe:

class AuthorizationWebView {
  Json listResponse(string entityName, Json items) {
    auto payload = Json.emptyObject;
    payload["items"] = items;
    payload["totalCount"] = Json(cast(int) items.length);
    return successResponse(entityName ~ " list retrieved successfully", "Retrieved", 200, payload);
  }

  Json idResponse(string entityName, string id, int code = 200) {
    auto payload = Json.emptyObject;
    payload["id"] = Json(id);
    auto status = code == 201 ? "Created" : "Updated";
    return successResponse(entityName ~ " operation successful", status, code, payload);
  }

  Json singleResponse(string entityName, Json item) {
    return successResponse(entityName ~ " retrieved successfully", "Retrieved", 200, item);
  }

  string renderDashboard(string tenantId, size_t applications, size_t policies, size_t assignments) {
    return "<html><head><title>Authorization Management</title></head><body>" ~
      "<h1>Authorization Management Service</h1>" ~
      "<p>Tenant: " ~ tenantId ~ "</p>" ~
      "<ul>" ~
      "<li>Applications: " ~ applications.to!string ~ "</li>" ~
      "<li>Policies: " ~ policies.to!string ~ "</li>" ~
      "<li>Assignments: " ~ assignments.to!string ~ "</li>" ~
      "</ul>" ~
      "</body></html>";
  }
}
