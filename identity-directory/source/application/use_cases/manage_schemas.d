module application.use_cases.manage_schemas;

import domain.entities.schema;
import domain.entities.audit_event;
import domain.types;
import domain.ports.schema_repository;
import domain.ports.audit_repository;
import application.dto;

import std.uuid;
import std.datetime.systime : Clock;

/// Application use case: custom schema management.
class ManageSchemasUseCase
{
    private SchemaRepository schemaRepo;
    private AuditRepository auditRepo;

    this(SchemaRepository schemaRepo, AuditRepository auditRepo)
    {
        this.schemaRepo = schemaRepo;
        this.auditRepo = auditRepo;
    }

    /// Create a new custom schema.
    SchemaResponse createSchema(CreateSchemaRequest req)
    {
        auto existing = schemaRepo.findByName(req.tenantId, req.name);
        if (existing != Schema.init)
            return SchemaResponse("", "Schema with this name already exists");

        auto now = Clock.currStdTime();
        auto schemaUrn = "urn:sap:cloud:scim:schemas:extension:custom:2.0:" ~ req.name;
        auto schema = Schema(
            schemaUrn,
            req.tenantId,
            req.name,
            req.description,
            req.attributes,
            now,
            now,
        );
        schemaRepo.save(schema);

        auditRepo.save(AuditEvent(
            randomUUID().toString(),
            req.tenantId,
            AuditEventType.schemaCreated,
            "system", "System",
            schemaUrn, "Schema",
            "Schema created: " ~ req.name,
            "", "", null,
            now,
        ));

        return SchemaResponse(schemaUrn, "");
    }

    /// Get schema by ID.
    Schema getSchema(SchemaId id)
    {
        return schemaRepo.findById(id);
    }

    /// List schemas for a tenant.
    Schema[] listSchemas(TenantId tenantId, uint offset = 0, uint limit = 100)
    {
        return schemaRepo.findByTenant(tenantId, offset, limit);
    }

    /// Update a schema.
    string updateSchema(UpdateSchemaRequest req)
    {
        auto schema = schemaRepo.findById(req.schemaId);
        if (schema == Schema.init)
            return "Schema not found";

        if (req.name.length > 0)
            schema.name = req.name;
        if (req.description.length > 0)
            schema.description = req.description;
        if (req.attributes.length > 0)
            schema.attributes = req.attributes;

        schema.updatedAt = Clock.currStdTime();
        schemaRepo.update(schema);

        auditRepo.save(AuditEvent(
            randomUUID().toString(),
            schema.tenantId,
            AuditEventType.schemaUpdated,
            "system", "System",
            req.schemaId, "Schema",
            "Schema updated",
            "", "", null,
            Clock.currStdTime(),
        ));

        return "";
    }

    /// Delete a schema.
    string deleteSchema(SchemaId id)
    {
        auto schema = schemaRepo.findById(id);
        if (schema == Schema.init)
            return "Schema not found";

        schemaRepo.remove(id);

        auditRepo.save(AuditEvent(
            randomUUID().toString(),
            schema.tenantId,
            AuditEventType.schemaDeleted,
            "system", "System",
            id, "Schema",
            "Schema deleted: " ~ schema.name,
            "", "", null,
            Clock.currStdTime(),
        ));

        return "";
    }
}
