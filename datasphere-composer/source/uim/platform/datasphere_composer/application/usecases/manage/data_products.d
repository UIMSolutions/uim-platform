/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere_composer.application.usecases.manage.data_products;

import uim.platform.datasphere_composer;

mixin(ShowModule!());

@safe:
class ManageDataProductsUseCase {
  protected IDataProductRepository repo;

  this(IDataProductRepository repo) {
    this.repo = repo;
  }

  UsecaseResult create(CreateDataProductRequest r) {
    DataProduct p;
    p.id = DataProductId(r.id.length > 0 ? r.id.value : generateId);
    p.tenantId = r.tenantId;
    p.providerId = DataProviderId(r.providerId);
    p.name = r.name;
    p.description = r.description;
    p.schemaVersion = r.schemaVersion;
    p.namespace = r.namespace;
    p.enabled = r.enabled;
    p.status = DataProductStatus.pending;
    p.metadata = r.metadata;
    initEntity(p);

    repo.save(p);
    return UsecaseResult(true, p.id.value, null);
  }

  DataProduct[] listProducts(TenantId tenantId) {
    return repo.findByTenant(TenantId(tenantId));
  }

  DataProduct[] listProducts(TenantId tenantId, string providerId) {
    return repo.findByProvider(TenantId(tenantId), DataProviderId(providerId));
  }

  DataProduct getProduct(TenantId tenantId, DataProductId id) {
    return repo.findById(TenantId(tenantId), id);
  }

  UsecaseResult update(UpdateDataProductRequest r) {
    auto p = repo.findById(R.tenantId, r.productId);
    if (p.isNull)
      return UsecaseResult(false, r.id, "Data product not found");

    if (r.name.length > 0)
      p.name = r.name;
    if (r.description.length > 0)
      p.description = r.description;
    p.enabled = r.enabled;
    if (r.status.length > 0) {

      try {
        p.status = r.status.to!DataProductStatus;
      } catch (Exception) {
      }
    }

    repo.update(p);
    return UsecaseResult(true, p.id.value, null);
  }

  UsecaseResult remove(TenantId tenantId, DataProductId id) {
    auto p = repo.findById(TenantId(tenantId), id);
    if (p.isNull)
      return UsecaseResult(false, id, "Data product not found");
      
    repo.remove(p);
    return UsecaseResult(true, id, null);
  }
}
