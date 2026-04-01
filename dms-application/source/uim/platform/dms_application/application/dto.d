module application.dto;

import uim.platform.dms_application.domain.types;

// --- Repository DTOs ---

struct CreateRepositoryRequest
{
  TenantId tenantId;
  string name;
  string description;
  long maxFileSize;
  string allowedFileTypes;
  UserId createdBy;
}

struct UpdateRepositoryRequest
{
  RepositoryId id;
  TenantId tenantId;
  string name;
  string description;
  long maxFileSize;
  string allowedFileTypes;
}

// --- Folder DTOs ---

struct CreateFolderRequest
{
  TenantId tenantId;
  RepositoryId repositoryId;
  FolderId parentFolderId;
  string name;
  string description;
  UserId createdBy;
}

struct UpdateFolderRequest
{
  FolderId id;
  TenantId tenantId;
  string name;
  string description;
}

struct MoveFolderRequest
{
  FolderId id;
  TenantId tenantId;
  FolderId newParentFolderId;
}

// --- Document DTOs ---

struct CreateDocumentRequest
{
  TenantId tenantId;
  RepositoryId repositoryId;
  FolderId folderId;
  string name;
  string description;
  ContentCategory contentCategory;
  string mimeType;
  long fileSize;
  string tags;
  string properties;
  UserId createdBy;
}

struct UpdateDocumentRequest
{
  DocumentId id;
  TenantId tenantId;
  string name;
  string description;
  string tags;
  string properties;
}

struct MoveDocumentRequest
{
  DocumentId id;
  TenantId tenantId;
  FolderId newFolderId;
}

// --- Version DTOs ---

struct CheckInRequest
{
  DocumentId documentId;
  TenantId tenantId;
  UserId userId;
  bool isMajor;
  string comment;
  string fileName;
  string mimeType;
  long fileSize;
  string checksum;
}

// --- Share DTOs ---

struct CreateShareRequest
{
  TenantId tenantId;
  DocumentId documentId;
  ShareType shareType;
  string sharedWith;
  PermissionLevel permissionLevel;
  long expiresAt;
  UserId createdBy;
}

// --- Permission DTOs ---

struct CreatePermissionRequest
{
  TenantId tenantId;
  string resourceId;
  ResourceType resourceType;
  UserId userId;
  PermissionLevel level;
  UserId createdBy;
}

struct UpdatePermissionRequest
{
  PermissionId id;
  TenantId tenantId;
  PermissionLevel level;
}

// --- Favorite DTOs ---

struct CreateFavoriteRequest
{
  TenantId tenantId;
  UserId userId;
  string resourceId;
  ResourceType resourceType;
}

// --- Generic result ---

struct CommandResult
{
  string id;
  string error;

  bool isSuccess() const
  {
    return error.length == 0;
  }
}
