/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.application.usecases.process_documents;

// import uim.platform.document_ai.domain.entities.AiDocument;
// import uim.platform.document_ai.domain.entities.extraction_result;
// import uim.platform.document_ai.domain.ports.repositories.documents;
// import uim.platform.document_ai.domain.ports.repositories.extraction_results;
// import uim.platform.document_ai.domain.services.document_validator;
// import uim.platform.document_ai.application.dto;

import uim.platform.document_ai;

mixin(ShowModule!());

@safe:

class ProcessDocumentsUseCase {
  protected DocumentRepository docRepo;
  private ExtractionResultRepository resultRepo;

  this(DocumentRepository docRepo, ExtractionResultRepository resultRepo) {
    this.docRepo = docRepo;
    this.resultRepo = resultRepo;
  }

  UsecaseResult upload(UploadDocumentRequest r) {
    if (r.fileName.isEmpty)
      return UsecaseResult(false, "", "File name is required");
    if (r.clientId.isEmpty)
      return UsecaseResult(false, "", "Client ID is required");

    auto validation = validateFileType(r.fileName);
    if (!validation.valid)
      return UsecaseResult(false, "", validation.error);

    auto doc = AiDocument(r.tenantId);
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
    doc.uploadedAt = doc.createdAt;

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

    docRepo.save(doc);

    // Simulate extraction processing
    processExtraction(doc);

    return UsecaseResult(true, doc.id.value, "");
  }

  UsecaseResult confirm(ConfirmDocumentRequest r) {
    if (r.documentId.isEmpty)
      return UsecaseResult(false, "", "AiDocument ID is required");

    auto doc = docRepo.findById(r.tenantId, r.clientId, r.documentId);
    if (doc.isNull)
      return UsecaseResult(false, "", "AiDocument not found");
    if (doc.status != DocumentStatus.completed)
      return UsecaseResult(false, "", "AiDocument must be in completed status to confirm");

    doc.status = DocumentStatus.confirmed;

    
    doc.updatedAt = currentTimestamp;

    docRepo.update(doc);
    return UsecaseResult(true, doc.id.value, "");
  }

  AiDocument getById(TenantId tenantId, DocumentId id, ClientId clientId) {
    return docRepo.findById(tenantId, clientId, id);
  }

  AiDocument[] list(TenantId tenantId, ClientId clientId) {
    return docRepo.findByClient(tenantId, clientId);
  }

  AiDocument[] listByStatus(TenantId tenantId, ClientId clientId, DocumentStatus status) {
    return docRepo.findByStatus(tenantId, clientId, status);
  }

  AiDocument[] listByDocumentType(TenantId tenantId, ClientId clientId, DocumentTypeId typeId) {
    return docRepo.findByDocumentType(tenantId, clientId, typeId);
  }

  UsecaseResult deleteDocument(TenantId tenantId, ClientId clientId, DocumentId id) {
    auto entity = docRepo.findById(tenantId, clientId, id);
    if (entity.isNull)
      return UsecaseResult(false, "", "AiDocument not found");

    docRepo.remove(entity);
    return UsecaseResult(true, entity.id.value, "");
  }

  ExtractionResult getExtractionResult(TenantId tenantId, DocumentId docId, ClientId clientId) {
    return resultRepo.findByDocument(tenantId, clientId, docId);
  }

  size_t count(TenantId tenantId, ClientId clientId) {
    return docRepo.countByClient(tenantId, clientId);
  }

  private void processExtraction(AiDocument doc) {
    auto result = ExtractionResult(doc.tenantId);
    result.clientId = doc.clientId;
    result.documentId = doc.id;
    result.schemaId = doc.schemaId;
    result.method = doc.extractionMethod;
    result.overallConfidence = 0.85;
    result.extractedFieldCount = 0;
    result.totalPages = doc.pageCount > 0 ? doc.pageCount : 1;

    resultRepo.save(result);

    // Update AiDocument status
    doc.status = DocumentStatus.completed;
    doc.processedAt = currentTimestamp;
    doc.updatedAt = currentTimestamp;
    docRepo.update(doc);
  }
}
