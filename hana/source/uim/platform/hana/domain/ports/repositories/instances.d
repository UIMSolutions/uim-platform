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
interface InstanceRepository {
  DatabaseInstance findById(InstanceId id);
  DatabaseInstance[] findByTenant(TenantId tenantId);
  void save(DatabaseInstance i);
  void update(DatabaseInstance i);
  void remove(InstanceId id);
  long countByTenant(TenantId tenantId);
}
