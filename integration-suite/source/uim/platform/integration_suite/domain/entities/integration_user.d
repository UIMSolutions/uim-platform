module uim.platform.integration_suite.domain.entities.integration_user;
import uim.platform.integration_suite;
mixin(ShowModule!());
@safe:

/// A tenant user within the Integration Suite platform.
struct IntegrationUser {
  mixin TenantEntity!(IntegrationUserId);

  string               email;
  string               firstName;
  string               lastName;
  IntegrationUserRole  role;
  bool                 active;
  string               externalUserId;
  long               lastLoginAt;

  Json toJson() const {
    auto j = entityToJson();
    j["email"]          = Json(email);
    j["firstName"]      = Json(firstName);
    j["lastName"]       = Json(lastName);
    j["role"]           = Json(cast(string) role);
    j["active"]         = Json(active);
    j["externalUserId"] = Json(externalUserId);
    j["lastLoginAt"]    = Json(lastLoginAt);
    return j;
  }
}
