module uim.platform.object_store.domain.entities.service_binding;

import uim.platform.object_store.domain.types;

class ServiceBinding
{
  ServiceBindingId id;
  TenantId tenantId;
  string name;
  BucketId bucketId;
  string accessKeyId;
  string secretAccessKeyHash; // stored hashed, never returned in plain text
  BindingPermission permission = BindingPermission.readOnly;
  BindingStatus status = BindingStatus.active;
  long expiresAt; // 0 = no expiry
  UserId createdBy;
  long createdAt;
}
