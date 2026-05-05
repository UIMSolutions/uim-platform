/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana.domain.ports.repositories.instances;

// import uim.platform.hana.domain.types;
// import uim.platform.hana.domain.entities.instance;
import uim.platform.hana;

mixin(ShowModule!());

@safe:
interface InstanceRepository : ITenantRepository!(DatabaseInstance, DatabaseInstanceId) {

  size_t countByStatus(InstanceStatus status);
  DatabaseInstance[] findByStatus(InstanceStatus status);
  void removeByStatus(InstanceStatus status);

  size_t countByType(InstanceType type);
  DatabaseInstance[] findByType(InstanceType type);
  void removeByType(InstanceType type);

}
