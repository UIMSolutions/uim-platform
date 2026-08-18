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

import uim.platform.hana;

mixin(ShowModule!());

@safe:
class ManageDataLakesUseCase {
  protected IDataLakeRepository repo;

  this(IDataLakeRepository repo) {
    this.repo = repo;
  }

  UsecaseResult createDataLake(CreateDataLakeRequest r) {
    if (r.isNull || r.name.isEmpty)
      return UsecaseResult(false, "", "Data lake ID and name are required");

    auto datalake = repo.findById(r.tenantId, r.id);
    if (!datalake.isNull)
      return UsecaseResult(false, "", "Data lake already exists");

    auto d = DataLake(r.tenantId, r.createdBy);
    d.id = r.datalakeId;
    d.instanceId = r.instanceId;
    d.name = r.name;
    d.description = r.description;
    d.status = DataLakeStatus.creating;
    d.computeNodes = r.computeNodes;

    repo.save(d);
    return UsecaseResult(true, d.id.value, "");
  }

  DataLake getDataLake(DataLakeId id) {
    return repo.findById(tenantId, id);
  }

  DataLake[] listDataLakes(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  UsecaseResult updateDataLake(UpdateDataLakeRequest r) {
    auto existing = repo.findById(r.id);
    if (existing.isNull)
      return UsecaseResult(false, "", "Data lake not found");

    existing.name = r.name;
    existing.description = r.description;
    existing.computeNodes = r.computeNodes;

    
    existing.updatedAt = currentTimestamp;

    repo.update(existing);
    return UsecaseResult(true, existing.id.value, "");
  }

  UsecaseResult deleteDataLake(DataLakeId id) {
    auto lake = repo.findById(tenantId, id);
    if (lake.isNull)
      return UsecaseResult(false, "", "Data lake not found");

    repo.remove(lake);
    return UsecaseResult(true, lake.id.value, "");
  }

  size_t countDataLakes(TenantId tenantId) {
    return repo.countByTenant(tenantId);
  }
}
