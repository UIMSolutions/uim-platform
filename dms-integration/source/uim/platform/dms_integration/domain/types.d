/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms_integration.domain.types;

import uim.platform.dms_integration;

// mixin(ShowModule!());

@safe:

struct RepositoryId {
    string value;
    this(string value) { this.value = value; }
    mixin DomainId;
}

struct DocumentId {
    string value;
    this(string value) { this.value = value; }
    mixin DomainId;
}

struct FolderId {
    string value;
    this(string value) { this.value = value; }
    mixin DomainId;
}

struct DocumentVersionId {
    string value;
    this(string value) { this.value = value; }
    mixin DomainId;
}

struct PermissionId {
    string value;
    this(string value) { this.value = value; }
    mixin DomainId;
}
