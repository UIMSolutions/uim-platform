/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere_composer.application.usecases.manage.data_products;

import uim.platform.datasphere_composer;
import std.conv : to;

mixin(ShowModule!());

@safe:
class ManageDataProductsUseCase {
  protected IDataProductRepository repo;

  this(IDataProductRepository repo) {
    this.repo = repo;
  }

  UsecaseResult create(CreateDataProductRequest r) {
    DataProduct p;
    p.createEntity(r.tenantId);
    if (!r.productId.isNull)
      p.id = r.productId;
    p.tenantId = r.tenantId;
    p.providerId = r.providerId;
    p.name = r.name;
    p.description = r.description;
    p.schemaVersion = r.schemaVersion;
    p.namespace = r.namespace;
    p.enabled = r.enabled;
    p.status = DataProductStatus.pending;
    p.metadata = r.metadata;

    auto err = ComposerValidator.validateDataProduct(p);
    if (err !is null)
      return UsecaseResult(false, p.id.value, err);

    repo.save(p);
    return UsecaseResult(true, p.id.value, null);
  }

  DataProduct[] list(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  DataProduct[] listProducts(TenantId tenantId) {
    return list(tenantId);
  }

  DataProduct[] listByProvider(TenantId tenantId, string providerId) {
    return repo.findByProvider(tenantId, DataProviderId(providerId));
  }

  DataProduct[] listProducts(TenantId tenantId, string providerId) {
    return listByProvider(tenantId, providerId);
  }

  DataProduct getById(TenantId tenantId, DataProductId id) {
    return repo.findById(tenantId, id);
  }

  DataProduct getById(TenantId tenantId, string id) {
    return getById(tenantId, DataProductId(id));
  }

  DataProduct getProduct(TenantId tenantId, DataProductId id) {
    return getById(tenantId, id);
  }

  UsecaseResult update(UpdateDataProductRequest r) {
    auto p = repo.findById(r.tenantId, r.productId);
    if (p.isNull)
      return UsecaseResult(false, r.productId.value, "Data product not found");

    if (r.name.length > 0)
      p.name = r.name;
    if (r.description.length > 0)
      p.description = r.description;
    p.enabled = r.enabled;
    if (r.status.length > 0) {
      try {
        p.status = r.status.to!DataProductStatus;
      } catch (Exception) {
        return UsecaseResult(false, r.productId.value, "Invalid data product status");
      }
    }

    repo.update(p);
    return UsecaseResult(true, p.id.value, null);
  }

  UsecaseResult remove(TenantId tenantId, DataProductId id) {
    auto p = repo.findById(tenantId, id);
    if (p.isNull)
      return UsecaseResult(false, id.value, "Data product not found");
      
    repo.remove(p);
    return UsecaseResult(true, id.value, null);
  }
}
