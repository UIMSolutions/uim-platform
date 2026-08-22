/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.application.usecases.manage.app_files;

import uim.platform.html_repository;

mixin(ShowModule!());

@safe:

class ManageAppFilesUseCase {
    private IAppFileRepository repo;

    this(IAppFileRepository repo) {
        this.repo = repo;
    }

    UsecaseResult uploadFile(UploadAppFileRequest r) {
        if (!DeploymentValidator.validateFilePath(r.filePath))
            return UsecaseResult(false, "", "Invalid file path");

        auto file = AppFile(r.tenantId);
        file.versionId = r.versionId;
        file.filePath = r.filePath;
        file.contentType = r.contentType;
        file.encoding = r.encoding;
        file.sizeBytes = r.sizeBytes;
        file.etag = ContentDeliveryService.generateEtag(r.content);
        file.category = categorizeFile(r.filePath);
        file.content = r.content;

        repo.save(file);
        return UsecaseResult(true, file.id.value, "");
    }

    UsecaseResult updateFile(UpdateAppFileRequest r) {
        auto file = repo.findById(r.tenantId, r.fileId);
        if (file.isNull)
            return UsecaseResult(false, "", "File not found");

        if (r.content.length > 0) {
            file.content = r.content;
            file.sizeBytes = r.sizeBytes;
            file.etag = ContentDeliveryService.generateEtag(r.content);
        }
        if (r.contentType.length > 0)
            file.contentType = r.contentType;
        if (r.encoding.length > 0)
            file.encoding = r.encoding;
        file.updatedAt = currentTimestamp();

        repo.update(file);
        return UsecaseResult(true, file.id.value, "");
    }

    AppFile getFile(TenantId tenantId, AppFileId id) {
        return repo.findById(tenantId, id);
    }

    AppFile getFile(TenantId tenantId, AppVersionId versionId, string filePath) {
        return repo.findByPath(tenantId, versionId, filePath);
    }

    AppFile[] listFiles(TenantId tenantId, AppVersionId versionId) {
        return repo.findByVersion(tenantId, versionId);
    }

    UsecaseResult deleteFile(TenantId tenantId, AppFileId id) {
        auto file = repo.findById(tenantId, id);
        if (file.isNull)
            return UsecaseResult(false, "", "File not found");

        repo.remove(file);
        return UsecaseResult(true, file.id.value, "");
    }

    size_t countFiles(TenantId tenantId, AppVersionId versionId) {
        return repo.countByVersion(tenantId, versionId);
    }

    long totalSizeByVersion(TenantId tenantId, AppVersionId versionId) {
        return repo.totalSizeByVersion(tenantId, versionId);
    }

    private static FileCategory categorizeFile(string filePath) {
        import std.algorithm : endsWith;

        if (filePath.endsWith(".html") || filePath.endsWith(".htm"))
            return FileCategory.html;
        if (filePath.endsWith(".js"))
            return FileCategory.javascript;
        if (filePath.endsWith(".css"))
            return FileCategory.css;
        if (filePath.endsWith(".png") ||
            filePath.endsWith(".jpg") ||
            filePath.endsWith(".gif") ||
            filePath.endsWith(".svg"))
            return FileCategory.image;
        if (filePath.endsWith(".json"))
            return FileCategory.json;

        return FileCategory.other;
    }

}
