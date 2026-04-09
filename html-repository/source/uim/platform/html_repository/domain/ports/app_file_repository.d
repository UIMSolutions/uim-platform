/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.domain.ports.repositories.app_files;

import uim.platform.html_repository.domain.entities.app_file;
import uim.platform.html_repository.domain.types;

interface AppFileRepository {
  AppFile findById(AppFileId id);
  AppFile findByPath(AppVersionId versionId, string filePath);
  AppFile[] findByVersion(AppVersionId versionId);
  AppFile[] findByCategory(AppVersionId versionId, FileCategory category);
  AppFile[] findByTenant(TenantId tenantId);
  void save(AppFile file);
  void update(AppFile file);
  void remove(AppFileId id);
  void removeByVersion(AppVersionId versionId);
  size_t countByVersion(AppVersionId versionId);
  long totalSizeByVersion(AppVersionId versionId);
  size_t countByTenant(TenantId tenantId);
}
