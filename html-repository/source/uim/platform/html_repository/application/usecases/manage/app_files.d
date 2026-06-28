/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.application.usecases.manage.app_files;
// import uim.platform.html_repository.domain.ports.repositories.app_files;
// import uim.platform.html_repository.domain.entities.app_file;
// import uim.platform.html_repository.domain.services.content_delivery_service;
// import uim.platform.html_repository.domain.services.deployment_validator;
// import uim.platform.html_repository.domain.types;
// import uim.platform.html_repository.application.dto;

import uim.platform.html_repository;

// mixin(ShowModule!());

@safe:

class ManageAppFilesUseCase { // TODO: UIMUseCase {
    private AppFileRepository repo;

    this(AppFileRepository repo) {
        this.repo = repo;
    }

    CommandResult upload(UploadAppFileRequest r) {
        if (!DeploymentValidator.validateFilePath(r.filePath))
            return CommandResult(false, "", "Invalid file path");

        AppFile file;
        file.initEntity(r.tenantId, r.createdBy);

        file.appId = r.appId;
        file.versionId = r.versionId;
        file.filePath = r.filePath;
        file.fileName = r.fileName;
        file.contentType = r.contentType;
        file.sizeBytes = r.sizeBytes;
        file.etag = ContentDeliveryService.generateEtag(r.content);
        file.category = categorizeFile(r.filePath);
        file.content = r.content;

        repo.save(file);
        return CommandResult(true, file.id.value, "");
    }

    CommandResult update(AppFileId id, UpdateAppFileRequest r) {
        auto file = repo.find(tenantId, id);
        if (file.isNull)
            return CommandResult(false, "", "File not found");

        if (r.content.length > 0) {
            file.content = r.content;
            file.sizeBytes = r.sizeBytes;
            file.etag = ContentDeliveryService.generateEtag(r.content);
        }
        if (r.contentType.length > 0)
            file.contentType = r.contentType;
        file.updatedAt = currentTimestamp();
        file.updatedBy = r.updatedBy;

        repo.update(file);
        return CommandResult(true, file.id.value, "");
    }

    AppFile getById(AppFileId id) {
        return repo.find(tenantId, id);
    }

    AppFile getByPath(AppVersionId versionId, string filePath) {
        return repo.findByPath(versionId, filePath);
    }

    AppFile[] listByVersion(AppVersionId versionId) {
        return repo.findByVersion(versionId);
    }

    CommandResult delete(AppFileId id) {
        auto file = repo.find(tenantId, id);
        if (file.isNull)
            return CommandResult(false, "", "File not found");

        repo.remove(file);
        return CommandResult(true, file.id.value, "");
    }

    size_t countByVersion(AppVersionId versionId) {
        return repo.countByVersion(versionId);
    }

    long totalSizeByVersion(AppVersionId versionId) {
        return repo.totalSizeByVersion(versionId);
    }

    private static FileCategory categorizeFile(string filePath) {
        import std.algorithm : endsWith;

        if (filePath.endsWith(".html") || filePath.endsWith(".htm"))
            return FileCategory.html;
        if (filePath.endsWith(".js"))
            return FileCategory.javascript;
        if (filePath.endsWith(".css"))
            return FileCategory.stylesheet;
        if (filePath.endsWith(".png") || filePath.endsWith(".jpg") || filePath.endsWith(".gif") || filePath.endsWith(
                ".svg"))
            return FileCategory.image;
        if (filePath.endsWith(".json"))
            return FileCategory.configuration;
        return FileCategory.other;
    }

}
