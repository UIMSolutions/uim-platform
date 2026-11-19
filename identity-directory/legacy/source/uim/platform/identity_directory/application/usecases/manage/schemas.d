/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_directory.application.usecases.manage.schemas;

import uim.platform.identity_directory;

mixin(ShowModule!());

@safe:
/// Application use case: custom schema management.
class ManageSchemasUseCase {
  protected ISchemaRepository schemaRepo;
  private IAuditRepository auditRepo;

  this(ISchemaRepository schemaRepo, IAuditRepository auditRepo) {
    this.schemaRepo = schemaRepo;
    this.auditRepo = auditRepo;
  }

  /// Create a new custom schema.
  UsecaseResult createSchema(CreateSchemaRequest req) {
    if (schemaRepo.existsByName(req.tenantId, req.name))
      return UsecaseResult(false, "", "Schema with this name already exists", 409);

    auto schemaUrn = "urn:sap:cloud:scim:schemas:extension:custom:2.0:" ~ req.name;
    auto schema = Schema(req.tenantId);
    // schema.schemaUrn = schemaUrn;
    schema.name = req.name;
    schema.description = req.description;
    schema.attributes = req.attributes;
    schemaRepo.save(schema);

    auto event = AuditEvent(req.tenantId);
    event.id = AuditEventId(createId);
    event.eventType = AuditEventType.schemaCreated;
    event.actorId = "system";
    // event.actorName = "System";
    event.targetId = schema.id.value;
    event.targetType = "Schema";
    event.description = "Schema created: " ~ req.name;
    auditRepo.save(event);

    return UsecaseResult(true, schema.id.value, schemaUrn, 200);
  }

  /// Get schema by ID.
  Schema getSchema(TenantId tenantId, SchemaId id) {
    return schemaRepo.findById(tenantId, id);
  }

  /// List schemas for a tenant.
  Schema[] listSchemas(TenantId tenantId, size_t offset = 0, size_t limit = 100) {
    return schemaRepo.findByTenant(tenantId, offset, limit);
  }

  /// Update a schema.
  UsecaseResult updateSchema(UpdateSchemaRequest req) {
    auto schema = schemaRepo.findById(req.tenantId, req.schemaId);
    if (schema.isNull)
      return UsecaseResult(false, "", "Schema not found", 404);

    if (req.name.length > 0)
      schema.name = req.name;
    if (req.description.length > 0)
      schema.description = req.description;
    if (req.attributes.length > 0)
      schema.attributes = req.attributes;

    schema.updatedAt = currentTimestamp();
    schemaRepo.update(schema);

    auto event = AuditEvent(req.tenantId);
    event.id = AuditEventId(createId);
    event.eventType = AuditEventType.schemaUpdated;
    event.actorId = "system";
    // event.actorName = "System";
    event.targetId = schema.id.value;
    event.targetType = "Schema";
    event.description = "Schema updated: " ~ schema.name;
    auditRepo.save(event);

    return UsecaseResult(true, schema.id.value, "", 200);
  }

  /// Delete a schema.
  UsecaseResult deleteSchema(TenantId tenantId, SchemaId id) {
    auto schema = schemaRepo.findById(tenantId, id);
    if (schema.isNull)
      return UsecaseResult(false, "", "Schema not found", 404);

    schemaRepo.remove(schema);

    auto event = AuditEvent(tenantId);
    event.id = AuditEventId(createId);
    event.eventType = AuditEventType.schemaDeleted;
    event.actorId = "system";
    // event.actorName = "System";
    event.targetId = schema.id.value;
    event.targetType = "Schema";
    event.description = "Schema deleted: " ~ schema.name; 
    auditRepo.save(event);

    return UsecaseResult(true, schema.id.value, "", 200);
  }
}

///
unittest {
//     auto schemaRepository = new SchemaRepository();
//     auto auditRepository = new AuditRepository();
//     auto usecase = new ManageSchemasUseCase(schemaRepository, auditRepository);
//     auto tenantId = TenantId("test-tenant");

}
