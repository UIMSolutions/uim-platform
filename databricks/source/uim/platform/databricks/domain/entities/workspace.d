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
  long            createdAt;       // Unix epoch ms
}
