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

// import uim.platform.service;
// import std.conv : to;
import uim.platform.hana;

mixin(ShowModule!());

@safe:
class ManageHDIContainersUseCase : UIMUseCase {
  private HDIContainerRepository repo;

  this(HDIContainerRepository repo) {
    this.repo = repo;
  }

  CommandResult create(CreateHDIContainerRequest r) {
    if (r.id.isEmpty || r.name.length == 0)
      return CommandResult(false, "", "HDI Container ID and name are required");

    if (repo.existsById(r.id))
      return CommandResult(false, "", "HDI Container already exists");

    HDIContainer c;
    c.id = r.id;
    c.tenantId = r.tenantId;
    c.instanceId = r.instanceId;
    c.name = r.name;
    c.description = r.description;
    c.status = HDIContainerStatus.creating;
    c.appUser = r.appUser;
    c.grantedSchemas = r.grantedSchemas;

    import core.time : MonoTime;
    auto now = MonoTime.currTime.ticks;
    c.createdAt = now;
    c.modifiedAt = now;

    repo.save(c);
    return CommandResult(true, c.id, "");
  }

  HDIContainer getById(HDIContainerId id) {
    return repo.findById(id);
  }

  HDIContainer[] list(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  CommandResult update(UpdateHDIContainerRequest r) {
    if (!repo.existsById(r.id))
      return CommandResult(false, "", "HDI Container not found");

    auto existing = repo.findById(r.id);
    existing.name = r.name;
    existing.description = r.description;
    existing.grantedSchemas = r.grantedSchemas;

    import core.time : MonoTime;
    existing.modifiedAt = MonoTime.currTime.ticks;

    repo.update(existing);
    return CommandResult(true, existing.id, "");
  }

  CommandResult remove(HDIContainerId id) {
    if (!repo.existsById(r.id))
      return CommandResult(false, "", "HDI Container not found");

    repo.remove(id);
    return CommandResult(true, id.toString, "");
  }

  size_t count(TenantId tenantId) {
    return repo.countByTenant(tenantId);
  }
}
