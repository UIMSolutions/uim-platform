/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.directory.infrastructure.persistence.memory.schema;

// import uim.platform.identity.directory.domain.entities.schema;
// import uim.platform.identity.directory.domain.types;
// import uim.platform.identity.directory.domain.ports.repositories.schemas;
import uim.platform.identity.directory;

mixin(ShowModule!());

@safe:
/// In-memory adapter for custom schema persistence.
class MemorySchemaRepository : TenantRepository!(Schema, SchemaId), SchemaRepository {

  bool existsByName(TenantId tenantId, string name) {
    return findAll().any!(s => s.tenantId == tenantId && s.name == name);
  }
  Schema findByName(TenantId tenantId, string name) {
    foreach (s; findAll()) {
      if (s.tenantId == tenantId && s.name == name)
        return s;
    }
    return Schema.init;
  }

}
