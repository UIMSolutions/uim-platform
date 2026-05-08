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

import uim.platform.hana;

mixin(ShowModule!());

@safe:
class ManageDataLakesUseCase { // TODO: UIMUseCase {
  private DataLakeRepository repo;

  this(DataLakeRepository repo) {
    this.repo = repo;
  }

  CommandResult createDataLake(CreateDataLakeRequest r) {
    if (r.isNull || r.name.length == 0)
      return CommandResult(false, "", "Data lake ID and name are required");

    if (repo.existsById(r.id))
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
    d.updatedAt = now;

    repo.save(d);
    return CommandResult(true, d.id.value, "");
  }

  DataLake getDataLake(DataLakeId id) {
    return repo.findById(tenantId, id);
  }

  DataLake[] listDataLakes(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  CommandResult updateDataLake(UpdateDataLakeRequest r) {
    if (!repo.existsById(r.id))
      return CommandResult(false, "", "Data lake not found");

    auto existing = repo.findById(r.id);
    existing.name = r.name;
    existing.description = r.description;
    existing.computeNodes = r.computeNodes;

    import core.time : MonoTime;
    existing.updatedAt = MonoTime.currTime.ticks;

    repo.update(existing);
    return CommandResult(true, existing.id.value, "");
  }

  CommandResult deleteDataLake(DataLakeId id) {
    auto lake = repo.findById(tenantId, id);
    if (lake.isNull)
      return CommandResult(false, "", "Data lake not found");

    repo.remove(lake);
    return CommandResult(true, lake.id.value, "");
  }

  size_t countDataLakes(TenantId tenantId) {
    return repo.countByTenant(tenantId);
  }
}
