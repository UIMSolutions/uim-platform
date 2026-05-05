/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana.domain.ports.repositories.data_lakes;

// import uim.platform.hana.domain.types;
// import uim.platform.hana.domain.entities.data_lake;
import uim.platform.hana;

mixin(ShowModule!());

@safe:
interface DataLakeRepository : ITenantRepository!(DataLake, DataLakeId) {

  size_t countByInstance(DatabaseInstanceId instanceId);
  DataLake[] findByInstance(DatabaseInstanceId instanceId);
  void removeByInstance(DatabaseInstanceId instanceId);

}
