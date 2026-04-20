module uim.platform.dms.application.domain.enumerations;

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



enum ShareType {
  internal,
  external,
  public_,
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

enum ContentCategory {
  file,
  link,
  reference,
}
