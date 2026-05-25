module uim.platform.databricks.domain.entities.data_product;
import uim.platform.databricks;

mixin(ShowModule!());

@safe:

/// An SAP BDC data product consumed or published via Databricks.
struct DataProduct {
  mixin TenantEntity!(DataProductId);

  WorkspaceId       workspaceId;
  string            name;
  string            description;
  string            provider;          // SAP system identifier
  string            version_;
  DataProductStatus status;
  ShareMode         shareMode;
  string            targetCatalog;     // Unity Catalog target
  string            targetSchema;
  string            sourceSystemId;    // BDC formation source
  long              lastSyncAt;        // Unix epoch ms, last synchronisation
  string            tags;              // comma-separated
}
