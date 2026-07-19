/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms_integration.domain.types;

import uim.platform.dms_integration;
mixin(ShowModule!());

@safe:

struct RepositoryId {
    mixin(IdTemplate);
}

struct DocumentId {
    mixin(IdTemplate);
}

struct FolderId {
    mixin(IdTemplate);
}

struct DocumentVersionId {
    mixin(IdTemplate);
}

struct PermissionId {
    mixin(IdTemplate);
}
