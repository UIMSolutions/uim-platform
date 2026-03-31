module domain.entities.object_version;

import domain.types;

class ObjectVersion
{
  ObjectVersionId id;
  TenantId tenantId;
  ObjectId objectId;
  string versionTag; // e.g. "v1", "v2", auto-incremented label
  long size;
  string etag;
  string contentType;
  bool isLatest;
  bool isDeleteMarker;
  UserId createdBy;
  long createdAt;
}
