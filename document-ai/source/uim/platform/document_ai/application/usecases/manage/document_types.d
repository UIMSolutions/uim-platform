/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.application.usecases.manage.document_types;

import uim.platform.document_ai.domain.types;
import uim.platform.document_ai.domain.entities.document_type;
import uim.platform.document_ai.domain.ports.repositories.document_types;
import uim.platform.document_ai.application.dto;

import std.uuid : randomUUID;
import std.conv : to;

class ManageDocumentTypesUseCase { // TODO: UIMUseCase {
  private DocumentTypeRepository repo;

  this(DocumentTypeRepository repo) {
    this.repo = repo;
  }

  CommandResult create(CreateDocumentTypeRequest r) {
    if (r.name.length == 0)
      return CommandResult(false, "", "Document type name is required");
    if (r.clientId.isEmpty)
      return CommandResult(false, "", "Client ID is required");

    DocumentType dt;
    dt.id = randomUUID();
    dt.tenantId = r.tenantId;
    dt.clientId = r.clientId;
    dt.name = r.name;
    dt.description = r.description;
    dt.defaultSchemaId = r.defaultSchemaId;
    dt.supportedFileTypes = r.supportedFileTypes;

    dt.category = parseCategory(r.category);

    import core.time : MonoTime;
    auto now = MonoTime.currTime.ticks;
    dt.createdAt = now;
    dt.updatedAt = now;

    repo.save(dt);
    return CommandResult(true, dt.id, "");
  }

  CommandResult update(UpdateDocumentTypeRequest r) {
    if (r.documentTypeId.isEmpty)
      return CommandResult(false, "", "Document type ID is required");

    auto existing = repo.findById(r.documentTypeId, r.clientId);
    if (existing.isNull)
      return CommandResult(false, "", "Document type not found");

    if (r.name.length > 0) existing.name = r.name;
    if (r.description.length > 0) existing.description = r.description;
    if (r.defaultSchemaId.length > 0) existing.defaultSchemaId = r.defaultSchemaId;
    if (r.category.length > 0) existing.category = parseCategory(r.category);

    import core.time : MonoTime;
    existing.updatedAt = MonoTime.currTime.ticks;

    repo.update(existing);
    return CommandResult(true, existing.id, "");
  }

  DocumentType getById(DocumentTypeId id, ClientId clientId) {
    return repo.findById(id, clientId);
  }

  DocumentType[] list(ClientId clientId) {
    return repo.findByClient(clientId);
  }

  DocumentType[] listByCategory(DocumentCategory category, ClientId clientId) {
    return repo.findByCategory(category, clientId);
  }

  CommandResult remove(DocumentTypeId id, ClientId clientId) {
    auto existing = repo.findById(id, clientId);
    if (existing.isNull)
      return CommandResult(false, "", "Document type not found");

    repo.remove(id, clientId);
    return CommandResult(true, id.toString, "");
  }

  size_t count(ClientId clientId) {
    return repo.countByClient(clientId);
  }
}

private DocumentCategory parseCategory(string c) {
  switch (c) {
    case "invoice": return DocumentCategory.invoice;
    case "purchase_order": return DocumentCategory.purchase_order;
    case "payment_advice": return DocumentCategory.payment_advice;
    case "delivery_note": return DocumentCategory.delivery_note;
    case "credit_memo": return DocumentCategory.credit_memo;
    case "bank_statement": return DocumentCategory.bank_statement;
    case "receipt": return DocumentCategory.receipt;
    case "contract": return DocumentCategory.contract;
    case "customs_declaration": return DocumentCategory.customs_declaration;
    case "bill_of_lading": return DocumentCategory.bill_of_lading;
    case "letter_of_credit": return DocumentCategory.letter_of_credit;
    case "custom": return DocumentCategory.custom;
    default: return DocumentCategory.general;
  }
}
