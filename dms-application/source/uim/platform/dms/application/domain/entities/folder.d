/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms.application.domain.entities.folder;

// import uim.platform.dms.application.domain.types;
import uim.platform.dms.application;

mixin(ShowModule!());

@safe:
class Folder {
  mixin TenantEntity!(FolderId);

  RepositoryId repositoryId;
  FolderId parentFolderId; // empty for root folders
  string name;
  string description;
  string path; // e.g. "/root/subfolder/child"
  
  Json  toJson() const {
    auto j = entityToJson
      .set("repositoryId", repositoryId.value)
      .set("parentFolderId", parentFolderId.value)
      .set("name", name)
      .set("description", description)
      .set("path", path);

    return j;
  }
}
