/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms.application.domain.types;

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






// --- Enumerations ---

enum RepositoryStatus {
  active,
  inactive,
  archived,
}

enum DocumentStatus {
  draft,
  active,
  locked,
  archived,
  deleted,
}

enum VersionStatus {
  current,
  superseded,
  archived,
}

enum PermissionLevel {
  read,
  write,
  admin,
  owner,
}

PermissionLevel parsePermissionLevel(string s) {
  switch (s) {
  case "read":
    return PermissionLevel.read;
  case "write":
    return PermissionLevel.write;
  case "admin":
    return PermissionLevel.admin;
  case "owner":
    return PermissionLevel.owner;
  default:
    return PermissionLevel.read;
  }
}

enum ShareType {
  internal,
  external,
  public_,
}

ShareType parseShareType(string s) {
  switch (s) {
  case "internal":
    return ShareType.internal;
  case "external":
    return ShareType.external;
  case "public":
    return ShareType.public_;
  default:
    return ShareType.internal;
  }
}

enum ShareStatus {
  active,
  expired,
  revoked,
}

enum ResourceType {
  document,
  folder,
  repository,
}

ResourceType parseResourceType(string s) {
  switch (s) {
  case "document":
    return ResourceType.document;
  case "folder":
    return ResourceType.folder;
  case "repository":
    return ResourceType.repository;
  default:
    return ResourceType.document;
  }
}

enum ContentCategory {
  file,
  link,
  reference,
}

ContentCategory parseContentCategory(string s) {
  switch (s) {
  case "file":
    return ContentCategory.file;
  case "link":
    return ContentCategory.link;
  case "reference":
    return ContentCategory.reference;
  default:
    return ContentCategory.file;
  }
}