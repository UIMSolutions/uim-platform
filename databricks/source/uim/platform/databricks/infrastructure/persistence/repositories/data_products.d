/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.databricks.infrastructure.persistence.repositories.data_products;
import uim.platform.databricks;

mixin(ShowModule!());

@safe:

class MemoryDataProductRepository : TenantRepository!(DataProduct, DataProductId), DataProductRepository {
  DataProduct[] findByWorkspace(TenantId tenantId, WorkspaceId workspaceId) {
    import std.algorithm : filter;
    import std.array : array;
    return findByTenant(tenantId).filter!(dp => dp.workspaceId == workspaceId).array;
  }

  DataProduct[] findByStatus(TenantId tenantId, DataProductStatus status) {
    import std.algorithm : filter;
    import std.array : array;
    return findByTenant(tenantId).filter!(dp => dp.status == status).array;
  }

  DataProduct[] findByProvider(TenantId tenantId, string provider) {
    import std.algorithm : filter;
    import std.array : array;
    return findByTenant(tenantId).filter!(dp => dp.provider == provider).array;
  }

  DataProduct[] findByShareMode(TenantId tenantId, ShareMode shareMode) {
    import std.algorithm : filter;
    import std.array : array;
    return findByTenant(tenantId).filter!(dp => dp.shareMode == shareMode).array;
  }
}
