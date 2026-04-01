module domain.types;

// --- ID type aliases ---
alias RepositoryId = string;
alias FolderId = string;
alias DocumentId = string;
alias DocumentVersionId = string;
alias ShareId = string;
alias PermissionId = string;
alias FavoriteId = string;
alias TenantId = string;
alias UserId = string;

// --- Enumerations ---

enum RepositoryStatus
{
  active,
  inactive,
  archived,
}

enum DocumentStatus
{
  draft,
  active,
  locked,
  archived,
  deleted,
}

enum VersionStatus
{
  current,
  superseded,
  archived,
}

enum PermissionLevel
{
  read,
  write,
  admin,
  owner,
}

enum ShareType
{
  internal,
  external,
  public_,
}

enum ShareStatus
{
  active,
  expired,
  revoked,
}

enum ResourceType
{
  document,
  folder,
  repository,
}

enum ContentCategory
{
  file,
  link,
  reference,
}
