/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.directory.application.usecases.manage.schemas;
// import uim.platform.identity.directory.domain.entities.schema;
// import uim.platform.identity.directory.domain.entities.audit_event;

// import uim.platform.identity.directory.domain.ports.repositories.schemas;
// import uim.platform.identity.directory.domain.ports.repositories.audits;
// import uim.platform.identity.directory.application.dto;


import uim.platform.identity.directory;

// mixin(ShowModule!());

@safe:
/// Application use case: custom schema management.
class ManageSchemasUseCase { // TODO: UIMUseCase {
  private SchemaRepository schemaRepo;
  private AuditRepository auditRepo;

  this(SchemaRepository schemaRepo, AuditRepository auditRepo) {
    this.schemaRepo = schemaRepo;
    this.auditRepo = auditRepo;
  }

  /// Create a new custom schema.
  SchemaResponse createSchema(CreateSchemaRequest req) {
    if (schemaRepo.existsByName(req.tenantId, req.name))
      return SchemaResponse("", "Schema with this name already exists");

    auto now = currentTimestamp();
    auto schemaUrn = "urn:sap:cloud:scim:schemas:extension:custom:2.0:" ~ req.name;
    auto schema = Schema(schemaUrn, req.tenantId, req.name, req.description,
        req.attributes, now, now,);
    schemaRepo.save(schema);

    auditRepo.save(AuditEvent(randomUUID().toString(), req.tenantId, AuditEventType.schemaCreated,
        "system", "System", schemaUrn, "Schema",
        "Schema created: " ~ req.name, "", "", null, now,));

    return SchemaResponse(schemaUrn, "");
  }

  /// Get schema by ID.
  Schema getSchema(SchemaId id) {
    return schemaRepo.findById(tenantId, id);
  }

  /// List schemas for a tenant.
  Schema[] listSchemas(TenantId tenantId, size_t offset = 0, size_t limit = 100) {
    return schemaRepo.findByTenant(tenantId, offset, limit);
  }

  /// Update a schema.
  CommandResult updateSchema(UpdateSchemaRequest req) {
    auto schema = schemaRepo.findById(req.schemaId);
    if (schema.isNull)
      return CommandResult(false, "", "Schema not found");

    if (req.name.length > 0)
      schema.name = req.name;
    if (req.description.length > 0)
      schema.description = req.description;
    if (req.attributes.length > 0)
      schema.attributes = req.attributes;

    schema.updatedAt = currentTimestamp();
    schemaRepo.update(schema);

    auditRepo.save(AuditEvent(randomUUID().toString(), schema.tenantId,
        AuditEventType.schemaUpdated, "system", "System", req.schemaId,
        "Schema", "Schema updated", "", "", null, Clock.currStdTime(),));

    return CommandResult(true, schema.id.value, "");
  }

  /// Delete a schema.
  CommandResult deleteSchema(SchemaId id) {
    auto schema = schemaRepo.findById(tenantId, id);
    if (schema.isNull)
      return CommandResult(false, "", "Schema not found");

    schemaRepo.remove(schema);

    auditRepo.save(AuditEvent(randomUUID().toString(), schema.tenantId,
        AuditEventType.schemaDeleted, "system", "System", schema.id, "Schema",
        "Schema deleted: " ~ schema.name, "", "", null, Clock.currStdTime(),));

    return CommandResult(true, schema.id.value, "");
  }
}
