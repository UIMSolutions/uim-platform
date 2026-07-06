/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms.application.domain.types;
import uim.platform.dms.application;

mixin(ShowModule!());

@safe:
// --- ID type aliases ---
struct RepositoryId {
  mixin(IdTemplate);
}

struct FolderId {
  mixin(IdTemplate);
}

struct DocumentId {
  mixin(IdTemplate);
}

struct DocumentVersionId {
  mixin(IdTemplate);
}

struct ShareId {
  mixin(IdTemplate);
}

struct PermissionId {
  mixin(IdTemplate);
}
struct FavoriteId  {
  mixin(IdTemplate);
}

