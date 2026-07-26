module uim.platform.authorization.domain.entities.authorization_decision;

import vibe.data.json : Json;
import uim.platform.authorization;

mixin(ShowModule!());

@safe:

struct AuthorizationDecision {
  string tenantId;
  string principalId;
  string applicationId;
  string resource;
  string action;
  bool allowed;
  string reason;
  string[] matchedPolicyIds;

  Json toJson() const {
    auto ids = Json.emptyArray;
    foreach (id; matchedPolicyIds) {
      ids ~= Json(id);
    }

    auto j = Json.emptyObject;
    j["tenantId"] = Json(tenantId);
    j["principalId"] = Json(principalId);
    j["applicationId"] = Json(applicationId);
    j["resource"] = Json(resource);
    j["action"] = Json(action);
    j["allowed"] = Json(allowed);
    j["reason"] = Json(reason);
    j["matchedPolicyIds"] = ids;
    return j;
  }
}
