/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.infrastructure.persistence.memory.app_files;

// import uim.platform.html_repository.domain.ports.repositories.app_files;
// import uim.platform.html_repository.domain.entities.app_file;
// import uim.platform.html_repository.domain.types;
import uim.platform.html_repository;

mixin(ShowModule!());

@safe:
class AppFileMemoryRepository : TenantRepository!(AppFile, AppFileId), AppFileRepository {

  bool existsByPath(AppVersionId versionId, string filePath) {
    foreach (e; findAll) {
      if (e.versionId == versionId && e.filePath == filePath) return true;
    }
    return false;
  }

  AppFile findByPath(AppVersionId versionId, string filePath) {
    foreach (e; findAll) {
      if (e.versionId == versionId && e.filePath == filePath) return e;
    }
    return AppFile.init;
  }


  size_t countByVersion(AppVersionId versionId) {
    size_t count = 0;
    foreach (e; findAll) {
      if (e.versionId == versionId) count++;
    }
    return count;
  }
  AppFile[] filterByVersion(AppFile[] files, AppVersionId versionId) {
    return files.filter!(f => f.versionId == versionId).array;
  }
  AppFile[] findByVersion(AppVersionId versionId) {
    AppFile[] result;
    foreach (e; findAll) {
      if (e.versionId == versionId) result ~= e;
    }
    return result;
  }
  void removeByVersion(AppVersionId versionId) {
    AppFile[] result;
    foreach (e; findAll) {
      if (e.versionId != versionId) result ~= e;
    }
    store = result;
  }

  size_t countByCategory(AppVersionId versionId, FileCategory category) {
    size_t count = 0;
    foreach (e; findAll) {
      if (e.versionId == versionId && e.category == category) count++;
    }
    return count;
  }
  AppFile[] filterByCategory(AppFile[] files, AppVersionId versionId, FileCategory category) {
    return files.filter!(f => f.versionId == versionId && f.category == category).array;
  }
  AppFile[] findByCategory(AppVersionId versionId, FileCategory category) {
    AppFile[] result;
    foreach (e; findAll) {
      if (e.versionId == versionId && e.category == category) result ~= e;
    }
    return result;
  }
  void removeByCategory(AppVersionId versionId, FileCategory category) {
    AppFile[] result;
    foreach (e; findAll) {
      if (e.versionId != versionId || e.category != category) result ~= e;
    }
    store = result;
  }

  long totalSizeByVersion(AppVersionId versionId) {
    long total = 0;
    foreach (e; findAll) {
      if (e.versionId == versionId) total += e.sizeBytes;
    }
    return total;
  }

}
