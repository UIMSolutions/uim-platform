/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms.application.domain.entities.repository;

import uim.platform.dms.application.domain.types;

class Repository {
  RepositoryId id;
  TenantId tenantId;
  string name;
  string description;
  RepositoryStatus status = RepositoryStatus.active;
  long maxFileSize = 104_857_600; // 100 MB default
  string allowedFileTypes; // JSON array of extensions, e.g. '["pdf","docx"]'
  UserId createdBy;
  long createdAt;
  long updatedAt;
}
