/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.infrastructure.persistence.repositories.app_files;
// import uim.platform.html_repository.domain.ports.repositories.app_files;
// import uim.platform.html_repository.domain.entities.app_file;
// import uim.platform.html_repository.domain.types;
import uim.platform.html_repository;

mixin(ShowModule!());

@safe:
class AppFileRepository : TenantRepository!(AppFile, AppFileId), IAppFileRepository {

  bool existsByPath(TenantId tenantId, AppVersionId versionId, string filePath) {
    return findByTenant(tenantId).any!(e => e.versionId == versionId && e.filePath == filePath);
  }

  AppFile findByPath(TenantId tenantId, AppVersionId versionId, string filePath) {
    foreach (e; findByTenant(tenantId)) {
      if (e.versionId == versionId && e.filePath == filePath) return e;
    }

    return AppFile.init;
  }

  void removeByPath(TenantId tenantId, AppVersionId versionId, string filePath) {
    AppFile file = findByPath(tenantId, versionId, filePath);
    if (file.id != AppFileId.init) {
      remove(file);
    }
  }

  size_t countByVersion(TenantId tenantId, AppVersionId versionId) {
    return findByVersion(tenantId, versionId).length;
  }

  AppFile[] filterByVersion(AppFile[] files, AppVersionId versionId) {
    return files.filter!(f => f.versionId == versionId).array;
  }

  AppFile[] findByVersion(TenantId tenantId, AppVersionId versionId) {
    return filterByVersion(findByTenant(tenantId), versionId);
  }

  void removeByVersion(TenantId tenantId, AppVersionId versionId) {
    findByVersion(tenantId, versionId).each!(e => remove(e));
  }

  size_t countByCategory(TenantId tenantId, AppVersionId versionId, FileCategory category) {
    return findByCategory(tenantId, versionId, category).length;
  }
  AppFile[] filterByCategory(AppFile[] files, AppVersionId versionId, FileCategory category) {
    return files.filter!(f => f.versionId == versionId && f.category == category).array;
  }
  
  AppFile[] findByCategory(TenantId tenantId, AppVersionId versionId, FileCategory category) {
    return filterByCategory(findByTenant(tenantId), versionId, category);
  }

  void removeByCategory(TenantId tenantId, AppVersionId versionId, FileCategory category) {
    findByCategory(tenantId, versionId, category).each!(e => remove(e));
  }

  long totalSizeByVersion(TenantId tenantId, AppVersionId versionId) {
    return findByTenant(tenantId).filter!(e => e.versionId == versionId).map!(e => e.sizeBytes).sum;
  }

}
