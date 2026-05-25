module uim.platform.integration_suite.domain.entities.message_mapping;
import uim.platform.integration_suite;
mixin(ShowModule!());
@safe:

/// A message mapping defines data transformation between source and target formats.
struct MessageMapping {
  mixin TenantEntity!(MessageMappingId);

  IntegrationPackageId packageId;
  string               name;
  string               description;
  string               version_;
  MappingStatus        status;
  B2bStandard          sourceStandard;
  B2bStandard          targetStandard;
  string               sourceSchema;
  string               targetSchema;
  string               mappingExpression;
  string[string]       metadata;

  Json toJson() const {
    auto j = entityToJson();
    j["packageId"]         = Json(packageId.value);
    j["name"]              = Json(name);
    j["description"]       = Json(description);
    j["version"]           = Json(version_);
    j["status"]            = Json(cast(string) status);
    j["sourceStandard"]    = Json(cast(string) sourceStandard);
    j["targetStandard"]    = Json(cast(string) targetStandard);
    j["sourceSchema"]      = Json(sourceSchema);
    j["targetSchema"]      = Json(targetSchema);
    j["mappingExpression"] = Json(mappingExpression);
    j["metadata"]          = jsonKeyValuePairs(metadata);
    return j;
  }
}
