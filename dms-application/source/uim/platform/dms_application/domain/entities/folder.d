module domain.entities.folder;

import domain.types;

class Folder
{
  FolderId id;
  TenantId tenantId;
  RepositoryId repositoryId;
  FolderId parentFolderId; // empty for root folders
  string name;
  string description;
  string path; // e.g. "/root/subfolder/child"
  UserId createdBy;
  long createdAt;
  long updatedAt;
}
