module uim.platform.xyz.domain.ports.schema_repository;

import domain.entities.schema;
import domain.types;

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
