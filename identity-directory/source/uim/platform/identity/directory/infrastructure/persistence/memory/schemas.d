/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.directory.infrastructure.persistence.memory.schema_repo;

import uim.platform.identity.directory.domain.entities.schema;
import uim.platform.identity.directory.domain.types;
import uim.platform.identity.directory.domain.ports.repositories.schemas;

/// In-memory adapter for custom schema persistence.
class MemorySchemaRepository : SchemaRepository
{
  private Schema[SchemaId] store;

  Schema findById(SchemaId id)
  {
    if (auto p = id in store)
      return *p;
    return Schema.init;
  }

  Schema findByName(TenantId tenantId, string name)
  {
    foreach (s; store.byValue())
    {
      if (s.tenantId == tenantId && s.name == name)
        return s;
    }
    return Schema.init;
  }

  Schema[] findByTenant(TenantId tenantId, uint offset = 0, uint limit = 100)
  {
    Schema[] result;
    uint idx;
    foreach (s; store.byValue())
    {
      if (s.tenantId == tenantId)
      {
        if (idx >= offset && result.length < limit)
          result ~= s;
        idx++;
      }
    }
    return result;
  }

  void save(Schema schema)
  {
    store[schema.id] = schema;
  }

  void update(Schema schema)
  {
    store[schema.id] = schema;
  }

  void remove(SchemaId id)
  {
    store.remove(id);
  }
}
