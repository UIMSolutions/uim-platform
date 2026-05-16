/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana.application.usecases.manage.schemas;
// import uim.platform.hana.domain.types;
// import uim.platform.hana.domain.entities.schema;
// import uim.platform.hana.domain.ports.repositories.schemas;
// import uim.platform.hana.application.dto;



import uim.platform.hana;

mixin(ShowModule!());

@safe:
class ManageSchemasUseCase { // TODO: UIMUseCase {
  private SchemaRepository repo;

  this(SchemaRepository repo) {
    this.repo = repo;
  }

  CommandResult createSchema(CreateSchemaRequest r) {
    if (r.isNull || r.name.length == 0)
      return CommandResult(false, "", "Schema ID and name are required");

    auto existing = repo.findById(r.id);
    if (!existing.isNull)
      return CommandResult(false, "", "Schema already exists");

    Schema s;
    s.id = r.id;
    s.tenantId = r.tenantId;
    s.instanceId = r.instanceId;
    s.name = r.name;
    s.owner = r.owner;

    import core.time : MonoTime;
    auto now = currentTimestamp;
    s.createdAt = now;
    s.updatedAt = now;

    repo.save(s);
    return CommandResult(true, s.id.value, "");
  }

  Schema getSchemaById(TenantId tenantId, SchemaId id) {
    return repo.findById(tenantId, id);
  }

  Schema[] listSchemas(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  CommandResult updateSchema(UpdateSchemaRequest r) {
    auto schema = repo.findById(r.tenantId, r.id);
    if (schema.isNull)
      return CommandResult(false, "", "Schema not found");

    schema.owner = r.owner;

    import core.time : MonoTime;
    schema.updatedAt = currentTimestamp;

    repo.update(schema);
    return CommandResult(true, schema.id.value, "");
  }

  CommandResult deleteSchema(TenantId tenantId, SchemaId id) {
    auto schema = repo.findById(tenantId, id);
    if (schema.isNull)
      return CommandResult(false, "", "Schema not found");

    repo.remove(schema);
    return CommandResult(true, schema.id.value, "");
  }

  size_t countSchemas(TenantId tenantId) {
    return repo.countByTenant(tenantId);
  }
}
