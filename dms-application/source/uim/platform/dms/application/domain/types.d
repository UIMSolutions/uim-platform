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
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct FolderId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct DocumentId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct DocumentVersionId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct ShareId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct PermissionId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}
struct FavoriteId  {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

