/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana.infrastructure.persistence.memory.schemas;

// import uim.platform.hana.domain.types;
// import uim.platform.hana.domain.entities.schema;
// import uim.platform.hana.domain.ports.repositories.schemas;

// import std.algorithm : filter;
// import std.array : array;
import uim.platform.hana;

mixin(ShowModule!());

@safe:
class MemorySchemaRepository : SchemaRepository {
  private Schema[] store;

  Schema findById(SchemaId id) {
    foreach (ref s; store) {
      if (s.id == id)
        return s;
    }
    return Schema.init;
  }

  Schema[] findByTenant(TenantId tenantId) {
    return store.filter!(s => s.tenantId == tenantId).array;
  }

  Schema[] findByInstance(InstanceId instanceId) {
    return store.filter!(s => s.instanceId == instanceId).array;
  }

  void save(Schema s) {
    store ~= s;
  }

  void update(Schema s) {
    foreach (ref existing; store) {
      if (existing.id == s.id) {
        existing = s;
        return;
      }
    }
  }

  void remove(SchemaId id) {
    store = store.filter!(s => s.id != id).array;
  }

  long countByTenant(TenantId tenantId) {
    return cast(long) store.filter!(s => s.tenantId == tenantId).array.length;
  }
}
