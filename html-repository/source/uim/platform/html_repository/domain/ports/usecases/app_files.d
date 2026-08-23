/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.domain.ports.usecases.app_files;

import uim.platform.html_repository;

mixin(ShowModule!());

@safe:

interface IManageAppFilesUseCase {

    UsecaseResult uploadFile(UploadAppFileRequest r);

    UsecaseResult updateFile(UpdateAppFileRequest r);

    AppFile getFile(TenantId tenantId, AppFileId id);

    AppFile getFile(TenantId tenantId, AppVersionId versionId, string filePath);

    AppFile[] listFiles(TenantId tenantId, AppVersionId versionId);

    UsecaseResult deleteFile(TenantId tenantId, AppFileId id);

    size_t countFiles(TenantId tenantId, AppVersionId versionId);

    long totalSizeByVersion(TenantId tenantId, AppVersionId versionId);

}
