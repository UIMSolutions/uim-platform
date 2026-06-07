module uim.platform.integration_suite.domain.entities.integration_flow;
import uim.platform.integration_suite;
// mixin(ShowModule!());
@safe:

/// An integration flow defines the message processing logic between systems.
struct IntegrationFlow {
  mixin TenantEntity!(IntegrationFlowId);

  IntegrationPackageId packageId;
  string               name;
  string               description;
  string               version_;
  ArtifactStatus       status;
  DeploymentStatus     deploymentStatus;
  FlowDirection        direction;
  AdapterType          senderAdapterType;
  AdapterType          receiverAdapterType;
  string               senderEndpoint;
  string               receiverEndpoint;
  string[]             steps;
  long               deployedAt;
  string               deployedBy;
  string[string]       metadata;

  Json toJson() const {
    auto j = entityToJson();
    j["packageId"]           = Json(packageId.value);
    j["name"]                = Json(name);
    j["description"]         = Json(description);
    j["version"]             = Json(version_);
    j["status"]              = Json(cast(string) status);
    j["deploymentStatus"]    = Json(cast(string) deploymentStatus);
    j["direction"]           = Json(cast(string) direction);
    j["senderAdapterType"]   = Json(cast(string) senderAdapterType);
    j["receiverAdapterType"] = Json(cast(string) receiverAdapterType);
    j["senderEndpoint"]      = Json(senderEndpoint);
    j["receiverEndpoint"]    = Json(receiverEndpoint);
    j["steps"]               = jsonStrArray(steps);
    j["deployedAt"]          = Json(deployedAt);
    j["deployedBy"]          = Json(deployedBy);
    j["metadata"]            = jsonKeyValuePairs(metadata);
    return j;
  }
}
