module uim.platform.authorization.domain.entities.application;

import vibe.data.json : Json;
import uim.platform.authorization;

mixin(ShowModule!());

@safe:

struct ManagedApplication {
  string id;
  string tenantId;
  string name;
  string organizationId;
  string description;
  long createdAt;
  long updatedAt;

  Json toJson() const {
    auto j = Json.emptyObject;
    j["id"] = Json(id);
    j["tenantId"] = Json(tenantId);
    j["name"] = Json(name);
    j["organizationId"] = Json(organizationId);
    j["description"] = Json(description);
    j["createdAt"] = Json(createdAt);
    j["updatedAt"] = Json(updatedAt);
    return j;
  }
}

struct ApplicationApi {
  string id;
  string tenantId;
  string applicationId;
  string name;
  string endpoint;
  string[] operations;
  long createdAt;
  long updatedAt;

  Json toJson() const {
    auto ops = Json.emptyArray;
    foreach (op; operations) {
      ops ~= Json(op);
    }

    auto j = Json.emptyObject;
    j["id"] = Json(id);
    j["tenantId"] = Json(tenantId);
    j["applicationId"] = Json(applicationId);
    j["name"] = Json(name);
    j["endpoint"] = Json(endpoint);
    j["operations"] = ops;
    j["createdAt"] = Json(createdAt);
    j["updatedAt"] = Json(updatedAt);
    return j;
  }
}
