module uim.platform.authorization.domain.entities.policy;

import vibe.data.json : Json;
import uim.platform.authorization;

mixin(ShowModule!());

@safe:

struct PolicyCondition {
  string attribute;
  string op;
  string value;

  Json toJson() const {
    auto j = Json.emptyObject;
    j["attribute"] = Json(attribute);
    j["op"] = Json(op);
    j["value"] = Json(value);
    return j;
  }
}

struct AuthorizationPolicy {
  string id;
  string tenantId;
  string applicationId;
  string name;
  string description;
  string resource;
  string action;
  PolicyCondition[] conditions;
  bool isBasePolicy;
  long createdAt;
  long updatedAt;

  Json toJson() const {
    auto conds = Json.emptyArray;
    foreach (c; conditions) {
      conds ~= c.toJson();
    }

    auto j = Json.emptyObject;
    j["id"] = Json(id);
    j["tenantId"] = Json(tenantId);
    j["applicationId"] = Json(applicationId);
    j["name"] = Json(name);
    j["description"] = Json(description);
    j["resource"] = Json(resource);
    j["action"] = Json(action);
    j["conditions"] = conds;
    j["isBasePolicy"] = Json(isBasePolicy);
    j["createdAt"] = Json(createdAt);
    j["updatedAt"] = Json(updatedAt);
    return j;
  }
}
