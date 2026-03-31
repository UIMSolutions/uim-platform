module domain.entities.lifecycle_rule;

import domain.types;

class LifecycleRule
{
  LifecycleRuleId id;
  TenantId tenantId;
  BucketId bucketId;
  string name;
  string prefix; // key prefix filter, e.g. "logs/"
  RuleStatus status = RuleStatus.enabled;
  int expirationDays;          // days after creation to delete (0 = disabled)
  int transitionDays;          // days after creation to transition (0 = disabled)
  StorageClass transitionStorageClass = StorageClass.nearline;
  int abortIncompleteUploadDays; // days to abort incomplete multipart uploads
  UserId createdBy;
  long createdAt;
  long updatedAt;
}
