/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.application.usecases.manage.schemas;

// import uim.platform.document_ai.domain.entities.schema;
// import uim.platform.document_ai.domain.ports.repositories.schemas;
// import uim.platform.document_ai.application.dto;

import uim.platform.document_ai;

mixin(ShowModule!());

@safe:

class ManageSchemasUseCase {
  protected ISchemaRepository repo;

  this(ISchemaRepository repo) {
    this.repo = repo;
  }

  UsecaseResult createSchema(CreateSchemaRequest r) {
    if (r.name.isEmpty)
      return UsecaseResult(false, "", "Schema name is required");
      
    if (r.clientId.isEmpty)
      return UsecaseResult(false, "", "Client ID is required");

    auto s = Schema(r.tenantId);
    s.clientId = r.clientId;
    s.documentTypeId = r.documentTypeId;
    s.name = r.name;
    s.description = r.description;
    s.status = SchemaStatus.draft;
    s.supportedLanguages = r.supportedLanguages;

    // Parse header fields: [name, label, type, required]
    SchemaField[] hFields;
    foreach (pair; r.headerFields) {
      if (pair.length >= 3) {
        SchemaField f;
        f.name = pair[0];
        f.label = pair[1];
        f.type = toFieldValueType(pair[2]);
        f.required = pair.length >= 4 && pair[3] == "true";
        hFields ~= f;
      }
    }
    s.headerFields = hFields;

    // Parse line item fields
    LineItemField[] lFields;
    foreach (pair; r.lineItemFields) {
      if (pair.length >= 3) {
        LineItemField f;
        f.name = pair[0];
        f.label = pair[1];
        f.type = toFieldValueType(pair[2]);
        f.required = pair.length >= 4 && pair[3] == "true";
        lFields ~= f;
      }
    }
    s.lineItemFields = lFields;

    repo.save(s);
    return UsecaseResult(true, s.id.value, "");
  }

  UsecaseResult updateSchema(UpdateSchemaRequest r) {
    if (r.schemaId.isEmpty)
      return UsecaseResult(false, "", "Schema ID is required");

    auto existing = repo.findById(r.tenantId, r.clientId, r.schemaId);
    if (existing.isNull)
      return UsecaseResult(false, "", "Schema not found");

    if (r.name.length > 0) existing.name = r.name;
    if (r.description.length > 0) existing.description = r.description;

    if (r.status.length > 0) {
      switch (r.status) {
        case "active": existing.status = SchemaStatus.active; break;
        case "inactive": existing.status = SchemaStatus.inactive; break;
        case "draft": existing.status = SchemaStatus.draft; break;
        default: break;
      }
    }

    
    existing.updatedAt = currentTimestamp;

    repo.update(existing);
    return UsecaseResult(true, existing.id.value, "");
  }

  Schema getSchema(TenantId tenantId, ClientId clientId, SchemaId id) {
    return repo.findById(tenantId, clientId, id);
  }

  Schema[] listSchemas(TenantId tenantId, ClientId clientId) {
    return repo.findByClient(tenantId, clientId);
  }

  Schema[] listSchemas(TenantId tenantId, ClientId clientId, DocumentTypeId typeId) {
    return repo.findByDocumentType(tenantId, clientId, typeId);
  }

  UsecaseResult deleteSchema(TenantId tenantId, ClientId clientId, SchemaId id) {
    auto schema = repo.findById(tenantId, clientId, id);
    if (schema.isNull)
      return UsecaseResult(false, "", "Schema not found");

    repo.remove(schema);
    return UsecaseResult(true, schema.id.value, "");
  }

  size_t countSchemas(TenantId tenantId, ClientId clientId) {
    return repo.countByClient(tenantId, clientId);
  }
}

// private FieldValueType toFieldType(string t) {
//   switch (t) {
//     case "string": return FieldValueType.string_;
//     case "number": return FieldValueType.number_;
//     case "date": return FieldValueType.date_;
//     case "boolean": return FieldValueType.boolean_;
//     case "currency": return FieldValueType.currency;
//     case "address": return FieldValueType.address;
//     case "line_items": return FieldValueType.line_items;
//     default: return FieldValueType.string_;
//   }}
