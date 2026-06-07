/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere_composer.application.usecases.manage.data_products;

import uim.platform.datasphere_composer;

// mixin(ShowModule!());

@safe:
class ManageDataProductsUseCase {
  private DataProductRepository repo;

  this(DataProductRepository repo) { this.repo = repo; }

  CommandResult create(CreateDataProductRequest r) {
    DataProduct p;
    p.id = DataProductId(r.id.length > 0 ? r.id : currentTimestamp());
    p.tenantId = TenantId(r.tenantId);
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
    return CommandResult(true, p.id.value, null);
  }

  DataProduct[] list(TenantId tenantId) {
    return repo.findByTenant(TenantId(tenantId));
  }

  DataProduct[] listByProvider(TenantId tenantId, string providerId) {
    return repo.findByProvider(TenantId(tenantId), DataProviderId(providerId));
  }

  DataProduct getById(TenantId tenantId, string id) {
    return repo.findById(TenantId(tenantId), DataProductId(id));
  }

  CommandResult update(UpdateDataProductRequest r) {
    auto p = repo.findById(TenantId(r.tenantId), DataProductId(r.id));
    if (p.isNull) return CommandResult(false, r.id, "Data product not found");

    if (r.name.length > 0)        p.name = r.name;
    if (r.description.length > 0) p.description = r.description;
    p.enabled = r.enabled;
    if (r.status.length > 0) {
      
      try { p.status = r.status.to!DataProductStatus; } catch (Exception) {}
    }

    repo.update(p);
    return CommandResult(true, p.id.value, null);
  }

  CommandResult remove(TenantId tenantId, string id) {
    auto p = repo.findById(TenantId(tenantId), DataProductId(id));
    if (p.isNull) return CommandResult(false, id, "Data product not found");
    repo.remove(TenantId(tenantId), DataProductId(id));
    return CommandResult(true, id, null);
  }
}
