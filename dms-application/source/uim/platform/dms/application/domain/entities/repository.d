/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms.application.domain.entities.repository;

// import uim.platform.dms.application.domain.types;
import uim.platform.dms.application;

mixin(ShowModule!());

@safe:
class Repository {
  mixin TenantEntity!(RepositoryId);

  string name;
  string description;
  RepositoryStatus status = RepositoryStatus.active;
  long maxFileSize = 104_857_600; // 100 MB default
  string allowedFileTypes; // JSON array of extensions, e.g. '["pdf","docx"]'

  Json toJson() const {
    return entityToJson
      .set("name", name)
      .set("description", description)
      .set("status", status.to!string)
      .set("maxFileSize", maxFileSize)
      .set("allowedFileTypes", allowedFileTypes);
  }
}
