module uim.platform.integration_suite.domain.entities.api_proxy;
import uim.platform.integration_suite;
// mixin(ShowModule!());
@safe:

/// An API proxy exposes a backend service as a managed API endpoint.
struct ApiProxy {
  mixin TenantEntity!(ApiProxyId);

  string         name;
  string         description;
  string         version_;
  ApiProxyStatus status;
  string         targetEndpoint;
  string         basePath;
  string[]       policies;
  string[]       tags;
  string[string] metadata;

  Json toJson() const {
    auto j = entityToJson();
    j["name"]           = Json(name);
    j["description"]    = Json(description);
    j["version"]        = Json(version_);
    j["status"]         = Json(cast(string) status);
    j["targetEndpoint"] = Json(targetEndpoint);
    j["basePath"]       = Json(basePath);
    j["policies"]       = jsonStrArray(policies);
    j["tags"]           = jsonStrArray(tags);
    j["metadata"]       = jsonKeyValuePairs(metadata);
    return j;
  }
}
