/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.domain.ports.repositories.app_files;

// import uim.platform.html_repository.domain.entities.app_file;
// import uim.platform.html_repository.domain.types;
import uim.platform.html_repository;

mixin(ShowModule!());

@safe:
interface AppFileRepository : ITenantRepository!(AppFile, AppFileId) {
  
  bool existsByPath(AppVersionId versionId, string filePath);
  AppFile findByPath(AppVersionId versionId, string filePath);
  void removeByPath(AppVersionId versionId, string filePath);

  size_t countByVersion(AppVersionId versionId);
  AppFile[] findByVersion(AppVersionId versionId);
  void removeByVersion(AppVersionId versionId);

  size_t countByCategory(AppVersionId versionId, FileCategory category);
  AppFile[] findByCategory(AppVersionId versionId, FileCategory category);
  void removeByCategory(AppVersionId versionId, FileCategory category);
  
  long totalSizeByVersion(AppVersionId versionId);
}
