/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana.application.usecases.manage.hdi_containers;
// import uim.platform.hana.domain.types;
// import uim.platform.hana.domain.entities.hdi_container;
// import uim.platform.hana.domain.ports.repositories.hdi_containers;
// import uim.platform.hana.application.dto;

import uim.platform.hana;

mixin(ShowModule!());

@safe:
class ManageHDIContainersUseCase {
  protected IHDIContainerRepository repo;

  this(IHDIContainerRepository repo) {
    this.repo = repo;
  }

  UsecaseResult createHDIContainer(CreateHDIContainerRequest r) {
    if (r.isNull || r.name.isEmpty)
      return UsecaseResult(false, "", "HDI Container ID and name are required");

    if (repo.existsById(r.id))
      return UsecaseResult(false, "", "HDI Container already exists");

    auto c = HDIContainer(r.tenantId, r.id, r.createdBy);
    c.instanceId = r.instanceId;
    c.name = r.name;
    c.description = r.description;
    c.status = HDIContainerStatus.creating;
    c.appUser = r.appUser;
    c.grantedSchemas = r.grantedSchemas;

    repo.save(c);
    return UsecaseResult(true, c.id.value, "");
  }

  HDIContainer getHDIContainer(HDIContainerId id) {
    return repo.findById(tenantId, id);
  }

  HDIContainer[] listHDIContainers(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  UsecaseResult updateHDIContainer(UpdateHDIContainerRequest r) {
    auto existing = repo.findById(r.id);
    if (existing.isNull)
      return UsecaseResult(false, "", "HDI Container not found");

    existing.name = r.name;
    existing.description = r.description;
    existing.grantedSchemas = r.grantedSchemas;

    
    existing.updatedAt = currentTimestamp;

    repo.update(existing);
    return UsecaseResult(true, existing.id.value, "");
  }

  UsecaseResult deleteHDIContainer(HDIContainerId id) {
    auto entity = repo.findById(tenantId, id);
    if (entity.isNull)
      return UsecaseResult(false, "", "HDI Container not found");

    repo.remove(entity);
    return UsecaseResult(true, entity.id.value, "");
  }

  size_t countHDIContainers(TenantId tenantId) {
    return repo.countByTenant(tenantId);
  }
}
