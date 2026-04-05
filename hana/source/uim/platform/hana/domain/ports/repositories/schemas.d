/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana.domain.ports.repositories.schemas;

// import uim.platform.hana.domain.types;
// import uim.platform.hana.domain.entities.schema;
import uim.platform.hana;

mixin(ShowModule!());

@safe:
interface SchemaRepository {
  Schema findById(SchemaId id);
  Schema[] findByTenant(TenantId tenantId);
  Schema[] findByInstance(InstanceId instanceId);
  void save(Schema s);
  void update(Schema s);
  void remove(SchemaId id);
  long countByTenant(TenantId tenantId);
}
