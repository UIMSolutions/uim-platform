module uim.platform.databricks.domain.ports.repositories.data_products;
import uim.platform.databricks;

mixin(ShowModule!());

@safe:

interface DataProductRepository : TenantRepository!(DataProduct, DataProductId) {
  DataProduct[] findByWorkspace(TenantId tenantId, WorkspaceId workspaceId);
  DataProduct[] findByStatus(TenantId tenantId, DataProductStatus status);
  DataProduct[] findByProvider(TenantId tenantId, string provider);
  DataProduct[] findByShareMode(TenantId tenantId, ShareMode shareMode);
}
