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

// import uim.platform.service;
// import std.conv : to;
import uim.platform.hana;

mixin(ShowModule!());

@safe:
class ManageSchemasUseCase { // TODO: UIMUseCase {
  private SchemaRepository repo;

  this(SchemaRepository repo) {
    this.repo = repo;
  }

  CommandResult create(CreateSchemaRequest r) {
    if (r.id.isEmpty || r.name.length == 0)
      return CommandResult(false, "", "Schema ID and name are required");

    auto existing = repo.findById(r.id);
    if (existing.id.length > 0)
      return CommandResult(false, "", "Schema already exists");

    Schema s;
    s.id = r.id;
    s.tenantId = r.tenantId;
    s.instanceId = r.instanceId;
    s.name = r.name;
    s.owner = r.owner;

    import core.time : MonoTime;
    auto now = MonoTime.currTime.ticks;
    s.createdAt = now;
    s.updatedAt = now;

    repo.save(s);
    return CommandResult(true, s.id, "");
  }

  Schema getById(SchemaId id) {
    return repo.findById(id);
  }

  Schema[] list(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  CommandResult update(UpdateSchemaRequest r) {
    if (!repo.existsById(r.id))
      return CommandResult(false, "", "Schema not found");

    auto existing = repo.findById(r.id);
    existing.owner = r.owner;

    import core.time : MonoTime;
    existing.updatedAt = MonoTime.currTime.ticks;

    repo.update(existing);
    return CommandResult(true, existing.id, "");
  }

  CommandResult remove(SchemaId id) {
    if (!repo.existsById(id))
      return CommandResult(false, "", "Schema not found");

    repo.remove(id);
    return CommandResult(true, id.toString, "");
  }

  size_t count(TenantId tenantId) {
    return repo.countByTenant(tenantId);
  }
}
