/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Business rules of a bucket: encryption, quota, write protection.
module uim.platform.object_store.domain.services.bucket_rules;

import uim.platform.object_store;

mixin(ShowModule!());

@safe:

/// SSE-KMS and SSE-C need a key id; the other types must not carry one.
void validateEncryption(ref Bucket bucket) {
  bucket.encryptionKeyId = bucket.encryptionKeyId.strip;
  final switch (bucket.encryptionType) {
  case EncryptionType.sseKms:
    validate(bucket.encryptionKeyId.length > 0, "Encryption key ID is required for SSE-KMS");
    break;
  case EncryptionType.sseC:
    validate(bucket.encryptionKeyId.length > 0, "Encryption key ID is required for SSE-C");
    break;
  case EncryptionType.none, EncryptionType.sseS3:
    bucket.encryptionKeyId = "";
    break;
  }
}

/// The quota must not be negative nor below the current usage.
void validateQuota(const Bucket bucket) {
  validate(bucket.quotaBytes >= 0, "Quota must not be negative");
  validate(bucket.quotaBytes == 0 || bucket.quotaBytes >= bucket.usedBytes,
    "Quota of '%s' (%d bytes) is below the current usage (%d bytes)".format(bucket.name,
      bucket.quotaBytes, bucket.usedBytes));
}

/// Usage after a change of `deltaBytes` must stay within the quota.
void ensureQuota(const Bucket bucket, long deltaBytes) {
  if (bucket.quotaBytes == 0 || deltaBytes <= 0)
    return;
  validate(bucket.usedBytes + deltaBytes <= bucket.quotaBytes,
    "Quota of bucket '%s' exceeded: %d of %d bytes used, %d more requested".format(bucket.name,
      bucket.usedBytes, bucket.quotaBytes, deltaBytes));
}

/// Writes and deletes need an active bucket.
void ensureWritable(const Bucket bucket) {
  ensureState(bucket.status == BucketStatus.active, "Bucket '" ~ bucket.name ~ "' is suspended (read-only)");
}

/// Overwrites and deletes are refused while an object is under legal hold.
void ensureNotOnHold(const StorageObject obj) {
  ensureState(!obj.legalHold, "Object '" ~ obj.name ~ "' is under legal hold");
}

/// Archived objects must be restored before their content can be read.
void ensureReadable(const StorageObject obj) {
  ensureState(obj.status != ObjectStatus.archived, "Object '" ~ obj.name ~ "' is archived — restore it first");
  if (obj.status == ObjectStatus.deleted)
    throw new ObjectStoreNotFoundException("Object '" ~ obj.name ~ "' is deleted");
}

///
unittest {
  mixin(ShowTest!("bucket rules"));

  Bucket b;
  b.name = "data";
  b.encryptionType = EncryptionType.sseKms;
  bool rejected;
  try validateEncryption(b);
  catch (ObjectStoreValidationException) rejected = true;
  assert(rejected);
  b.encryptionType = EncryptionType.sseS3;
  b.encryptionKeyId = "k1";
  validateEncryption(b);
  assert(b.encryptionKeyId == "");

  b.quotaBytes = 100;
  b.usedBytes = 90;
  ensureQuota(b, 10);
  rejected = false;
  try ensureQuota(b, 11);
  catch (ObjectStoreValidationException) rejected = true;
  assert(rejected);
  b.quotaBytes = 50;
  rejected = false;
  try validateQuota(b);
  catch (ObjectStoreValidationException) rejected = true;
  assert(rejected);
}
