module uim.platform.integration_suite.domain.entities.integration_package;
import uim.platform.integration_suite;
// mixin(ShowModule!());
@safe:

/// A container that groups related integration artifacts (flows, mappings).
struct IntegrationPackage {
  mixin TenantEntity!(IntegrationPackageId);

  string         name;
  string         version_;
  string         description;
  string         vendor;
  ArtifactStatus status;
  string         category;
  string[]       tags;
  string[string] metadata;

  Json toJson() const {
    auto j = entityToJson();
    j["name"]        = Json(name);
    j["version"]     = Json(version_);
    j["description"] = Json(description);
    j["vendor"]      = Json(vendor);
    j["status"]      = Json(cast(string) status);
    j["category"]    = Json(category);
    j["tags"]        = jsonStrArray(tags);
    j["metadata"]    = jsonKeyValuePairs(metadata);
    return j;
  }
}
