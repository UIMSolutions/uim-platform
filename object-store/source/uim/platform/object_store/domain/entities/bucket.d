/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.object_store.domain.entities.bucket;

// import uim.platform.object_store.domain.types;
import uim.platform.object_store;

mixin(ShowModule!());

@safe:
struct Bucket {
  mixin TenantEntity!(BucketId);

  string name;
  string region;
  StorageClass storageClass = StorageClass.standard;
  bool versioningEnabled = false;
  EncryptionType encryptionType = EncryptionType.none;
  string encryptionKeyId;
  BucketStatus status = BucketStatus.active;
  long quotaBytes = 0; // 0 = unlimited
  long usedBytes = 0;
  long objectCount = 0;

  Json toJson() const {
    auto j = entityToJson
      .set("name", name)
      .set("region", region)
      .set("storageClass", storageClass.toString())
      .set("versioningEnabled", versioningEnabled)
      .set("encryptionType", encryptionType.toString())
      .set("encryptionKeyId", encryptionKeyId)
      .set("status", status.toString())
      .set("quotaBytes", quotaBytes)
      .set("usedBytes", usedBytes)
      .set("objectCount", objectCount);

    return j;
  }
}
