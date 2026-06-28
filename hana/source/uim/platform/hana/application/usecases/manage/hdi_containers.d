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

// mixin(ShowModule!());

@safe:
class ManageHDIContainersUseCase { // TODO: UIMUseCase {
  private HDIContainerRepository repo;

  this(HDIContainerRepository repo) {
    this.repo = repo;
  }

  CommandResult createHDIContainer(CreateHDIContainerRequest r) {
    if (r.isNull || r.name.length == 0)
      return CommandResult(false, "", "HDI Container ID and name are required");

    if (repo.existsById(r.id))
      return CommandResult(false, "", "HDI Container already exists");

    HDIContainer c;
    c.initEntity(r.tenantId);
    c.id = r.id;
    c.instanceId = r.instanceId;
    c.name = r.name;
    c.description = r.description;
    c.status = HDIContainerStatus.creating;
    c.appUser = r.appUser;
    c.grantedSchemas = r.grantedSchemas;

    repo.save(c);
    return CommandResult(true, c.id.value, "");
  }

  HDIContainer getHDIContainer(HDIContainerId id) {
    return repo.find(tenantId, id);
  }

  HDIContainer[] listHDIContainers(TenantId tenantId) {
    return repo.find(tenantId);
  }

  CommandResult updateHDIContainer(UpdateHDIContainerRequest r) {
    auto existing = repo.findById(r.id);
    if (existing.isNull)
      return CommandResult(false, "", "HDI Container not found");

    existing.name = r.name;
    existing.description = r.description;
    existing.grantedSchemas = r.grantedSchemas;

    
    existing.updatedAt = currentTimestamp;

    repo.update(existing);
    return CommandResult(true, existing.id.value, "");
  }

  CommandResult deleteHDIContainer(HDIContainerId id) {
    auto entity = repo.find(tenantId, id);
    if (entity.isNull)
      return CommandResult(false, "", "HDI Container not found");

    repo.remove(entity);
    return CommandResult(true, entity.id.value, "");
  }

  size_t countHDIContainers(TenantId tenantId) {
    return repo.count(tenantId);
  }
}
