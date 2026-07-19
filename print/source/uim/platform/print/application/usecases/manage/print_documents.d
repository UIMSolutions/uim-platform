/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.print.application.usecases.manage.print_documents;

import uim.platform.print;
mixin(ShowModule!());

@safe:

class ManagePrintDocumentsUseCase {
    private PrintDocumentRepository repo;

    this(PrintDocumentRepository repo) {
        this.repo = repo;
    }

    PrintDocument getPrintDocument(TenantId tenantId, PrintDocumentId id) {
        return repo.findById(tenantId, id);
    }

    PrintDocument[] listPrintDocuments(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    CommandResult createPrintDocument(PrintDocumentDTO dto) {
        auto  doc = PrintDocument(dto.tenantId, dto.documentId, dto.createdBy);
        doc.fileName = dto.fileName;
        doc.mimeType = dto.mimeType;
        doc.sizeBytes = dto.sizeBytes;
        doc.storageUri = dto.storageUri;
        doc.checksum = dto.checksum;
        doc.description = dto.description;
        doc.expiresAt = dto.expiresAt;
        if (dto.format.length > 0) {
            
            try { doc.format = dto.format.to!DocumentFormat; } catch (Exception) {}
        }

        if (!PrintValidator.isValidPrintDocument(doc))
            return CommandResult(false, "", "Invalid document: fileName and mimeType are required");

        repo.save(doc);
        return CommandResult(true, doc.id.value, "");
    }

    CommandResult deletePrintDocument(TenantId tenantId, PrintDocumentId id) {
        auto entity = repo.findById(tenantId, id);
        if (entity.isNull)
            return CommandResult(false, "", "Document not found");
        repo.remove(entity);
        return CommandResult(true, id.value, "");
    }
}
