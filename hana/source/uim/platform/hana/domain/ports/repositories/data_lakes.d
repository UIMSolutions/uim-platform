/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana.domain.ports.repositories.data_lakes;

import uim.platform.hana.domain.types;
import uim.platform.hana.domain.entities.data_lake;

interface DataLakeRepository {
  DataLake findById(DataLakeId id);
  DataLake[] findByTenant(TenantId tenantId);
  DataLake[] findByInstance(InstanceId instanceId);
  void save(DataLake d);
  void update(DataLake d);
  void remove(DataLakeId id);
  long countByTenant(TenantId tenantId);
}
