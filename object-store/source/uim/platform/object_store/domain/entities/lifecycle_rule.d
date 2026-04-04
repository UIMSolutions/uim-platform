/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.object_store.domain.entities.lifecycle_rule;

import uim.platform.object_store.domain.types;

class LifecycleRule {
  LifecycleRuleId id;
  TenantId tenantId;
  BucketId bucketId;
  string name;
  string prefix; // key prefix filter, e.g. "logs/"
  RuleStatus status = RuleStatus.enabled;
  int expirationDays; // days after creation to delete (0 = disabled)
  int transitionDays; // days after creation to transition (0 = disabled)
  StorageClass transitionStorageClass = StorageClass.nearline;
  int abortIncompleteUploadDays; // days to abort incomplete multipart uploads
  UserId createdBy;
  long createdAt;
  long updatedAt;
}
