/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana.application.usecases.manage.data_lakes;

// import uim.platform.hana.domain.types;
// import uim.platform.hana.domain.entities.data_lake;
// import uim.platform.hana.domain.ports.repositories.data_lakes;
// import uim.platform.hana.application.dto;

// import uim.platform.service;
// import std.conv : to;
import uim.platform.hana;

mixin(ShowModule!());

@safe:
class ManageDataLakesUseCase : UIMUseCase {
  private DataLakeRepository repo;

  this(DataLakeRepository repo) {
    this.repo = repo;
  }

  CommandResult create(CreateDataLakeRequest r) {
    if (r.id.isEmpty || r.name.length == 0)
      return CommandResult(false, "", "Data lake ID and name are required");

    auto existing = repo.findById(r.id);
    if (existing.id.length > 0)
      return CommandResult(false, "", "Data lake already exists");

    DataLake d;
    d.id = r.id;
    d.tenantId = r.tenantId;
    d.instanceId = r.instanceId;
    d.name = r.name;
    d.description = r.description;
    d.status = DataLakeStatus.creating;
    d.computeNodes = r.computeNodes;

    import core.time : MonoTime;
    auto now = MonoTime.currTime.ticks;
    d.createdAt = now;
    d.modifiedAt = now;

    repo.save(d);
    return CommandResult(true, d.id, "");
  }

  DataLake get_(DataLakeId id) {
    return repo.findById(id);
  }

  DataLake[] list(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  CommandResult update(UpdateDataLakeRequest r) {
    auto existing = repo.findById(r.id);
    if (existing.id.isEmpty)
      return CommandResult(false, "", "Data lake not found");

    existing.name = r.name;
    existing.description = r.description;
    existing.computeNodes = r.computeNodes;

    import core.time : MonoTime;
    existing.modifiedAt = MonoTime.currTime.ticks;

    repo.update(existing);
    return CommandResult(true, existing.id, "");
  }

  CommandResult remove(DataLakeId id) {
    auto existing = repo.findById(id);
    if (existing.id.isEmpty)
      return CommandResult(false, "", "Data lake not found");

    repo.remove(id);
    return CommandResult(true, id.toString, "");
  }

  long count(TenantId tenantId) {
    return repo.countByTenant(tenantId);
  }
}
