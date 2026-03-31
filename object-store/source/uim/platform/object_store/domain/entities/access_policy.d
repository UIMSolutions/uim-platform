module uim.platform.object_store.domain.entities.access_policy;

import domain.types;

class AccessPolicy
{
  AccessPolicyId id;
  TenantId tenantId;
  BucketId bucketId;
  string name;
  PolicyEffect effect = PolicyEffect.allow;
  string principal; // user/group/service identifier, "*" for all
  string actions;   // JSON array, e.g. '["GetObject","PutObject"]'
  string resources; // JSON array of key patterns, e.g. '["images/*"]'
  UserId createdBy;
  long createdAt;
  long updatedAt;
}
