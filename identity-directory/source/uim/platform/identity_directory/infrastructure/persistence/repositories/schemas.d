/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_directory.infrastructure.persistence.repositories.schemas;
// import uim.platform.identity_directory.domain.entities.schema;

// import uim.platform.identity_directory.domain.ports.repositories.schemas;
import uim.platform.identity_directory;

mixin(ShowModule!());

@safe:
/// In-memory adapter for custom schema persistence.
class SchemaRepository : TenantRepository!(Schema, SchemaId), ISchemaRepository {

  bool existsByName(TenantId tenantId, string name) {
    return findByTenant(tenantId).any!(s => s.name == name);
  }

  Schema findByName(TenantId tenantId, string name) {
    foreach (s; findByTenant(tenantId)) {
      if (s.name == name)
        return s;
    }
    return Schema.init;
  }

  void removeByName(TenantId tenantId, string name) {
    remove(findByName(tenantId, name));
  }

}

///
unittest {
  mixin(ShowTest!("SchemaRepository"));

  void testExistsByName() {
    auto repo = new SchemaRepository();
    auto tenantId = TenantId("test-tenant");
    
    auto schema = Schema(tenantId, SchemaId("schema1"));
    schema.name = "Test Schema";
    repo.save(schema);

    assert(repo.existsByName(tenantId, "Test Schema") == true);
  }

  void testFindByName() {
    auto repo = new SchemaRepository();
    auto tenantId = TenantId("test-tenant");
    auto schema = Schema(tenantId, SchemaId("schema1"));
    schema.name = "Test Schema";
    repo.save(schema);

    assert(repo.findByName(tenantId, "Test Schema") == schema);
  }
  void testRemoveByName() {
    auto repo = new SchemaRepository();
    auto tenantId = TenantId("test-tenant");

    auto schema = Schema(tenantId, SchemaId("schema1"));
    schema.name = "Test Schema";
    repo.save(schema);

    repo.removeByName(tenantId, "Test Schema");
    assert(repo.existsByName(tenantId, "Test Schema") == false);
  }
}
