/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.databricks.application.usecases.manage_data_products;
import uim.platform.databricks;

// mixin(ShowModule!());

@safe:

class ManageDataProductsUseCase {
private:
  DataProductRepository _repo;

public:
  this(DataProductRepository repo) { _repo = repo; }

  UseCaseResult!DataProduct create(CreateDataProductRequest r) {
    auto dp = DataProduct();
    dp.id            = r.id;
    dp.tenantId      = r.tenantId;
    dp.workspaceId   = r.workspaceId;
    dp.name          = r.name;
    dp.description   = r.description;
    dp.provider      = r.provider;
    dp.version_      = r.version_;
    dp.status        = DataProductStatus.pending;
    dp.shareMode     = r.shareMode;
    dp.targetCatalog = r.targetCatalog;
    dp.targetSchema  = r.targetSchema;
    dp.sourceSystemId= r.sourceSystemId;
    dp.tags          = r.tags;
    import std.datetime : Clock;
    dp.lastSyncAt = Clock.currTime().toUnixTime() * 1000;
    _repo.save(dp);
    return UseCaseResult!DataProduct(true, "Data product registered", dp);
  }

  UseCaseResult!(DataProduct[]) list(TenantId tenantId) {
    return UseCaseResult!(DataProduct[])(true, "", _repo.find(tenantId));
  }

  UseCaseResult!DataProduct get(TenantId tenantId, DataProductId id) {
    auto dp = _repo.find(tenantId, id);
    if (dp.isNull)
      return UseCaseResult!DataProduct(false, "Data product not found", DataProduct.init);
    return UseCaseResult!DataProduct(true, "", dp);
  }

  UseCaseResult!DataProduct update(UpdateDataProductRequest r) {
    auto dp = _repo.find(r.tenantId, r.id);
    if (dp.isNull)
      return UseCaseResult!DataProduct(false, "Data product not found", DataProduct.init);
    if (r.description.length   > 0) dp.description   = r.description;
    if (r.version_.length      > 0) dp.version_       = r.version_;
    if (r.targetCatalog.length > 0) dp.targetCatalog  = r.targetCatalog;
    if (r.targetSchema.length  > 0) dp.targetSchema   = r.targetSchema;
    if (r.tags.length          > 0) dp.tags            = r.tags;
    dp.shareMode = r.shareMode;
    _repo.save(dp);
    return UseCaseResult!DataProduct(true, "Data product updated", dp);
  }

  UseCaseResult!bool remove(TenantId tenantId, DataProductId id) {
    auto dp = _repo.find(tenantId, id);
    if (dp.isNull)
      return UseCaseResult!bool(false, "Data product not found", false);
    dp.status = DataProductStatus.unavailable;
    _repo.save(dp);
    return UseCaseResult!bool(true, "Data product removed", true);
  }
}
