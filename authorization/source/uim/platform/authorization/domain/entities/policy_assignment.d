module uim.platform.authorization.domain.entities.policy_assignment;

import vibe.data.json : Json;
import uim.platform.authorization;

mixin(ShowModule!());

@safe:

struct PolicyAssignment {
  string id;
  string tenantId;
  string policyId;
  string principalType;
  string principalId;
  long createdAt;

  Json toJson() const {
    auto j = Json.emptyObject;
    j["id"] = Json(id);
    j["tenantId"] = Json(tenantId);
    j["policyId"] = Json(policyId);
    j["principalType"] = Json(principalType);
    j["principalId"] = Json(principalId);
    j["createdAt"] = Json(createdAt);
    return j;
  }
}
