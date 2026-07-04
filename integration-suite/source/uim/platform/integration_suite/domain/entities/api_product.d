module uim.platform.integration_suite.domain.entities.api_product;
import uim.platform.integration_suite;
mixin(ShowModule!());
@safe:

/// An API product bundles one or more API proxies for developer portal consumption.
struct ApiProduct {
  mixin TenantEntity!(ApiProductId);

  string         name;
  string         description;
  ApiProxyStatus status;
  string[]       apiProxyIds;
  string[]       scopes;
  string[]       environments;
  bool           isPublic;
  string[string] metadata;

  Json toJson() const {
    auto j = entityToJson();
    j["name"]        = Json(name);
    j["description"] = Json(description);
    j["status"]      = Json(cast(string) status);
    j["apiProxyIds"] = jsonStrArray(apiProxyIds);
    j["scopes"]      = jsonStrArray(scopes);
    j["environments"]= jsonStrArray(environments);
    j["isPublic"]    = Json(isPublic);
    j["metadata"]    = jsonKeyValuePairs(metadata);
    return j;
  }
}
