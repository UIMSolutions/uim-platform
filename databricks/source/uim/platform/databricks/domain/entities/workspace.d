module uim.platform.databricks.domain.entities.workspace;
import uim.platform.databricks;

mixin(ShowModule!());

@safe:

/// A Databricks workspace — the top-level deployment unit.
struct Workspace {
  mixin TenantEntity!(WorkspaceId);

  string          name;
  string          region;
  WorkspaceTier   tier;
  WorkspaceStatus status;
  string          url;
  string          cloudProvider;   // aws, azure, gcp
  string          storageRoot;
  string          credentialId;

    Json toJson() const { 
        auto j = entityToJson()
        .set("name", name)
        .set("region", region)
        .set("tier", tier)
        .set("status", status)
        .set("url", url)
        .set("cloudProvider", cloudProvider)
        .set("storageRoot", storageRoot)
        .set("credentialId", credentialId);

    return j;
  }
}
