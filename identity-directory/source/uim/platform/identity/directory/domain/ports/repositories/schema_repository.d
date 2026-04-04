/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.directory.domain.ports.repositories.schemas;

import uim.platform.identity.directory.domain.entities.schema;
import uim.platform.identity.directory.domain.types;

/// Port: outgoing — custom schema persistence.
interface SchemaRepository
{
  Schema findById(SchemaId id);
  Schema findByName(TenantId tenantId, string name);
  Schema[] findByTenant(TenantId tenantId, uint offset = 0, uint limit = 100);
  void save(Schema schema);
  void update(Schema schema);
  void remove(SchemaId id);
}
