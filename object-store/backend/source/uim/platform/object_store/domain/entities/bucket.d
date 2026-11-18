/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.object_store.domain.entities.bucket;

import uim.platform.object_store;

mixin(ShowModule!());

@safe:

/// A bucket: a named container of objects on one IaaS provider and region.
/// Name, provider and region are fixed after creation.
struct Bucket {
  mixin TenantEntity!BucketId;

  string name; /// unique per tenant, S3 naming rules (see domain.services.naming)
  string description;
  IaasProvider provider = IaasProvider.aws;
  string region; /// Region.id of the provider
  StorageClass storageClass = StorageClass.standard; /// default class of new objects
  bool versioningEnabled; /// keep every version; deletes write delete markers
  EncryptionType encryptionType = EncryptionType.sseS3;
  string encryptionKeyId; /// sseKms / sseC
  bool publicAccessBlocked = true; /// ignore "*" allow policies for anonymous callers
  long quotaBytes; /// 0 = unlimited
  BucketStatus status = BucketStatus.active;
  MetadataEntry[] labels;

  // Usage (maintained by the object operations)
  long usedBytes; /// all stored versions
  int objectCount; /// active + archived objects
  int versionCount; /// stored versions (without delete markers)
}
