module uim.platform.identity.directory.domain.ports.schema_repository;

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
