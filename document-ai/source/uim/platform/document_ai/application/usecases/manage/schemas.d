/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.application.usecases.manage.schemas;

import uim.platform.document_ai.domain.types;
import uim.platform.document_ai.domain.entities.schema;
import uim.platform.document_ai.domain.ports.repositories.schemas;
import uim.platform.document_ai.application.dto;

import std.uuid : randomUUID;
import std.conv : to;

class ManageSchemasUseCase { // TODO: UIMUseCase {
  private SchemaRepository repo;

  this(SchemaRepository repo) {
    this.repo = repo;
  }

  CommandResult create(CreateSchemaRequest r) {
    if (r.name.length == 0)
      return CommandResult(false, "", "Schema name is required");
    if (r.clientId.isEmpty)
      return CommandResult(false, "", "Client ID is required");

    Schema s;
    s.id = randomUUID();
    s.tenantId = r.tenantId;
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
        f.type = parseFieldType(pair[2]);
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
        f.type = parseFieldType(pair[2]);
        f.required = pair.length >= 4 && pair[3] == "true";
        lFields ~= f;
      }
    }
    s.lineItemFields = lFields;

    import core.time : MonoTime;
    auto now = MonoTime.currTime.ticks;
    s.createdAt = now;
    s.updatedAt = now;

    repo.save(s);
    return CommandResult(true, s.id.value, "");
  }

  CommandResult update(UpdateSchemaRequest r) {
    if (r.schemaId.isEmpty)
      return CommandResult(false, "", "Schema ID is required");

    auto existing = repo.findById(r.schemaId, r.clientId);
    if (existing.isNull)
      return CommandResult(false, "", "Schema not found");

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

    import core.time : MonoTime;
    existing.updatedAt = MonoTime.currTime.ticks;

    repo.update(existing);
    return CommandResult(true, existing.id.value, "");
  }

  Schema getById(SchemaId id, ClientId clientId) {
    return repo.findById(id, clientId);
  }

  Schema[] list(ClientId clientId) {
    return repo.findByClient(clientId);
  }

  Schema[] listByDocumentType(DocumentTypeId typeId, ClientId clientId) {
    return repo.findByDocumentType(typeId, clientId);
  }

  CommandResult remove(SchemaId id, ClientId clientId) {
    auto existing = repo.findById(id, clientId);
    if (existing.isNull)
      return CommandResult(false, "", "Schema not found");

    repo.remove(id, clientId);
    return CommandResult(true, id.value, "");
  }

  size_t count(ClientId clientId) {
    return repo.countByClient(clientId);
  }
}

private FieldValueType parseFieldType(string t) {
  switch (t) {
    case "string": return FieldValueType.string_;
    case "number": return FieldValueType.number_;
    case "date": return FieldValueType.date_;
    case "boolean": return FieldValueType.boolean_;
    case "currency": return FieldValueType.currency;
    case "address": return FieldValueType.address;
    case "line_items": return FieldValueType.line_items;
    default: return FieldValueType.string_;
  }
}
