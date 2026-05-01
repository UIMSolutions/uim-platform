/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.application.usecases.process_documents;

import uim.platform.document_ai.domain.types;
import uim.platform.document_ai.domain.entities.document;
import uim.platform.document_ai.domain.entities.extraction_result;
import uim.platform.document_ai.domain.ports.repositories.documents;
import uim.platform.document_ai.domain.ports.repositories.extraction_results;
import uim.platform.document_ai.domain.services.document_validator;
import uim.platform.document_ai.application.dto;

import std.uuid : randomUUID;
import std.conv : to;

class ProcessDocumentsUseCase { // TODO: UIMUseCase {
  private DocumentRepository docRepo;
  private ExtractionResultRepository resultRepo;

  this(DocumentRepository docRepo, ExtractionResultRepository resultRepo) {
    this.docRepo = docRepo;
    this.resultRepo = resultRepo;
  }

  CommandResult upload(UploadDocumentRequest r) {
    if (r.fileName.length == 0)
      return CommandResult(false, "", "File name is required");
    if (r.clientId.isEmpty)
      return CommandResult(false, "", "Client ID is required");

    auto validation = validateFileType(r.fileName);
    if (!validation.valid)
      return CommandResult(false, "", validation.error);

    Document doc;
    doc.id = randomUUID();
    doc.tenantId = r.tenantId;
    doc.clientId = r.clientId;
    doc.fileName = r.fileName;
    doc.fileType = detectFileType(r.fileName);
    doc.mimeType = r.mimeType;
    doc.fileSize = r.fileSize;
    doc.schemaId = r.schemaId;
    doc.templateId = r.templateId;
    doc.documentTypeId = r.documentTypeId;
    doc.language = r.language.length > 0 ? r.language : "en";
    doc.status = DocumentStatus.pending;
    doc.extractionMethod = ExtractionMethod.ml_model;

    // Parse labels
    DocumentLabel[] labels;
    foreach (pair; r.labels) {
      if (pair.length >= 2) {
        DocumentLabel lbl;
        lbl.key = pair[0];
        lbl.value = pair[1];
        labels ~= lbl;
      }
    }
    doc.labels = labels;

    import core.time : MonoTime;
    auto now = MonoTime.currTime.ticks;
    doc.uploadedAt = now;
    doc.createdAt = now;
    doc.updatedAt = now;

    docRepo.save(doc);

    // Simulate extraction processing
    processExtraction(doc);

    return CommandResult(true, doc.id, "");
  }

  CommandResult confirm(ConfirmDocumentRequest r) {
    if (r.documentId.isEmpty)
      return CommandResult(false, "", "Document ID is required");

    auto doc = docRepo.findById(r.documentId, r.clientId);
    if (doc.isNull)
      return CommandResult(false, "", "Document not found");
    if (doc.status != DocumentStatus.completed)
      return CommandResult(false, "", "Document must be in completed status to confirm");

    doc.status = DocumentStatus.confirmed;

    import core.time : MonoTime;
    doc.updatedAt = MonoTime.currTime.ticks;

    docRepo.update(doc);
    return CommandResult(true, doc.id, "");
  }

  Document getById(DocumentId id, ClientId clientId) {
    return docRepo.findById(id, clientId);
  }

  Document[] list(ClientId clientId) {
    return docRepo.findByClient(clientId);
  }

  Document[] listByStatus(DocumentStatus status, ClientId clientId) {
    return docRepo.findByStatus(status, clientId);
  }

  Document[] listByDocumentType(DocumentTypeId typeId, ClientId clientId) {
    return docRepo.findByDocumentType(typeId, clientId);
  }

  CommandResult remove(DocumentId id, ClientId clientId) {
    auto existing = docRepo.findById(id, clientId);
    if (existing.isNull)
      return CommandResult(false, "", "Document not found");

    docRepo.remove(id, clientId);
    return CommandResult(true, id.toString, "");
  }

  ExtractionResult getExtractionResult(DocumentId docId, ClientId clientId) {
    return resultRepo.findByDocument(docId, clientId);
  }

  size_t count(ClientId clientId) {
    return docRepo.countByClient(clientId);
  }

  private void processExtraction(Document doc) {
    import core.time : MonoTime;

    ExtractionResult result;
    result.id = randomUUID();
    result.tenantId = doc.tenantId;
    result.clientId = doc.clientId;
    result.documentId = doc.id;
    result.schemaId = doc.schemaId;
    result.method = doc.extractionMethod;
    result.overallConfidence = 0.85;
    result.extractedFieldCount = 0;
    result.totalPages = doc.pageCount > 0 ? doc.pageCount : 1;

    auto now = MonoTime.currTime.ticks;
    result.processedAt = now;
    result.createdAt = now;

    resultRepo.save(result);

    // Update document status
    doc.status = DocumentStatus.completed;
    doc.processedAt = now;
    doc.updatedAt = now;
    docRepo.update(doc);
  }
}
