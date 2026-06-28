module uim.platform.databricks.infrastructure.persistence.memory.data_products;
import uim.platform.databricks;

// mixin(ShowModule!());

@safe:

class MemoryDataProductRepository : TenantRepository!(DataProduct, DataProductId), DataProductRepository {
  DataProduct[] findByWorkspace(TenantId tenantId, WorkspaceId workspaceId) {
    import std.algorithm : filter;
    import std.array : array;
    return find(tenantId).filter!(dp => dp.workspaceId == workspaceId).array;
  }

  DataProduct[] findByStatus(TenantId tenantId, DataProductStatus status) {
    import std.algorithm : filter;
    import std.array : array;
    return find(tenantId).filter!(dp => dp.status == status).array;
  }

  DataProduct[] findByProvider(TenantId tenantId, string provider) {
    import std.algorithm : filter;
    import std.array : array;
    return find(tenantId).filter!(dp => dp.provider == provider).array;
  }

  DataProduct[] findByShareMode(TenantId tenantId, ShareMode shareMode) {
    import std.algorithm : filter;
    import std.array : array;
    return find(tenantId).filter!(dp => dp.shareMode == shareMode).array;
  }
}
