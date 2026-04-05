/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana.domain.ports.repositories.database_users;

// import uim.platform.hana.domain.types;
// import uim.platform.hana.domain.entities.database_user;
import uim.platform.hana;

mixin(ShowModule!());

@safe:
interface DatabaseUserRepository {
  DatabaseUser findById(DatabaseUserId id);
  DatabaseUser[] findByTenant(TenantId tenantId);
  DatabaseUser[] findByInstance(InstanceId instanceId);
  void save(DatabaseUser u);
  void update(DatabaseUser u);
  void remove(DatabaseUserId id);
  long countByTenant(TenantId tenantId);
}
