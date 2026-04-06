/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.network_asset_collaboration.application.usecases.manage.manage_documents;

import uim.platform.network_asset_collaboration;

mixin(ShowModule!());

@safe:

class ManageDocumentsUseCase : UIMUseCase {
    private DocumentRepository repo;

    this(DocumentRepository repo) {
        this.repo = repo;
    }

    Document* get_(DocumentId id) {
        return repo.findById(id);
    }

    Document[] list() {
        return repo.findAll();
    }

    Document[] listByTenant(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    Document[] listByEquipment(string equipmentId) {
        return repo.findByEquipment(equipmentId);
    }

    Document[] listByModel(string modelId) {
        return repo.findByModel(modelId);
    }

    Document[] listByType(DocumentType documentType) {
        return repo.findByType(documentType);
    }

    CommandResult create(DocumentDTO dto) {
        Document d;
        d.id = dto.id;
        d.tenantId = dto.tenantId;
        d.equipmentId = dto.equipmentId;
        d.modelId = dto.modelId;
        d.name = dto.name;
        d.description = dto.description;
        d.version_ = dto.version_;
        d.fileName = dto.fileName;
        d.fileSize = dto.fileSize;
        d.mimeType = dto.mimeType;
        d.language = dto.language;
        d.uploadedBy = dto.uploadedBy;
        d.createdBy = dto.createdBy;
        if (!AssetValidator.isValidDocument(d))
            return CommandResult(false, "", "Invalid document data");
        repo.save(d);
        return CommandResult(true, dto.id, "");
    }

    CommandResult update(DocumentDTO dto) {
        auto existing = repo.findById(dto.id);
        if (existing is null)
            return CommandResult(false, "", "Document not found");
        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.version_.length > 0) existing.version_ = dto.version_;
        if (dto.modifiedBy.length > 0) existing.modifiedBy = dto.modifiedBy;
        repo.update(*existing);
        return CommandResult(true, dto.id, "");
    }

    CommandResult remove(DocumentId id) {
        auto existing = repo.findById(id);
        if (existing is null)
            return CommandResult(false, "", "Document not found");
        repo.remove(id);
        return CommandResult(true, id, "");
    }
}
