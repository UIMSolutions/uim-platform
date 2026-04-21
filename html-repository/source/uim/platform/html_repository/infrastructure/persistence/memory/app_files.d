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
class AppFileMemoryRepository : AppFileRepository {
  private AppFile[] store;

  bool existsById(AppFileId id) {
    foreach (e; store) {
      if (e.id == id) return true;
    }
    return false;
  }

  AppFile findById(AppFileId id) {
    foreach (e; store) {
      if (e.id == id) return e;
    }
    return AppFile.init;
  }

  AppFile findByPath(AppVersionId versionId, string filePath) {
    foreach (e; store) {
      if (e.versionId == versionId && e.filePath == filePath) return e;
    }
    return AppFile.init;
  }

  AppFile[] findByVersion(AppVersionId versionId) {
    AppFile[] result;
    foreach (e; store) {
      if (e.versionId == versionId) result ~= e;
    }
    return result;
  }

  AppFile[] findByCategory(AppVersionId versionId, FileCategory category) {
    AppFile[] result;
    foreach (e; store) {
      if (e.versionId == versionId && e.category == category) result ~= e;
    }
    return result;
  }

  AppFile[] findByTenant(TenantId tenantId) {
    AppFile[] result;
    foreach (e; store) {
      if (e.tenantId == tenantId) result ~= e;
    }
    return result;
  }

  void save(AppFile file) {
    store ~= file;
  }

  void update(AppFile file) {
    foreach (i, e; store) {
      if (e.id == file.id) {
        store[i] = file;
        return;
      }
    }
  }

  void remove(AppFileId id) {
    AppFile[] result;
    foreach (e; store) {
      if (e.id != id) result ~= e;
    }
    store = result;
  }

  void removeByVersion(AppVersionId versionId) {
    AppFile[] result;
    foreach (e; store) {
      if (e.versionId != versionId) result ~= e;
    }
    store = result;
  }

  size_t countByVersion(AppVersionId versionId) {
    size_t count = 0;
    foreach (e; store) {
      if (e.versionId == versionId) count++;
    }
    return count;
  }

  long totalSizeByVersion(AppVersionId versionId) {
    long total = 0;
    foreach (e; store) {
      if (e.versionId == versionId) total += e.sizeBytes;
    }
    return total;
  }

  size_t countByTenant(TenantId tenantId) {
    size_t count = 0;
    foreach (e; store) {
      if (e.tenantId == tenantId) count++;
    }
    return count;
  }
}
