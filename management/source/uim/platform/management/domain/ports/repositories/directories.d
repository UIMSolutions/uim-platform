/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.domain.ports.repositories.directories;

// import uim.platform.management.domain.entities.directory;
// import uim.platform.management.domain.types;
import uim.platform.management;

mixin(ShowModule!());

@safe:
/// Port: outgoing — directory persistence.
interface DirectoryRepository {
  bool existsById(DirectoryId id);
  Directory findById(DirectoryId id);
  
  Directory[] findByGlobalAccount(GlobalAccountId globalAccountId);
  Directory[] findByParent(DirectoryId parentDirectoryId);
  Directory[] findByStatus(GlobalAccountId globalAccountId, DirectoryStatus status);

  void save(Directory dir);
  void update(Directory dir);
  void remove(DirectoryId id);
}
