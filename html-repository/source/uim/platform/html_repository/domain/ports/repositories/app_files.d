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
  bool existsById(AppFileId id);
  AppFile findById(AppFileId id);
  
  bool existsByPath(AppVersionId versionId, string filePath);
  AppFile findByPath(AppVersionId versionId, string filePath);

  size_t countByVersion(AppVersionId versionId);
  AppFile[] findByVersion(AppVersionId versionId);

  size_t countByTenant(TenantId tenantId);
  AppFile[] findByTenant(TenantId tenantId);
  
  AppFile[] findByCategory(AppVersionId versionId, FileCategory category);
  
  void save(AppFile file);
  void update(AppFile file);
  void remove(AppFileId id);
  void removeByVersion(AppVersionId versionId);
  long totalSizeByVersion(AppVersionId versionId);
}
