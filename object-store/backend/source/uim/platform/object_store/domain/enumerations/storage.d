/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.object_store.domain.enumerations.storage;

import uim.platform.object_store;

mixin(ShowModule!());

@safe:

/// The hyperscaler that hosts a bucket (SAP Object Store runs on AWS S3,
/// Azure Blob Storage, Google Cloud Storage and Alibaba OSS).
enum IaasProvider {
  aws,
  azure,
  gcp,
  alibaba,
}

/// Storage tier of an object, from hot to cold. The declaration order is the
/// temperature order used by lifecycle transitions (only "colder" moves).
enum StorageClass {
  standard, /// frequently accessed data
  infrequentAccess, /// accessed less than once a month
  nearline, /// accessed about once a quarter
  coldline, /// accessed about once a year
  archive, /// long-term retention; must be restored before it can be read
}

/// Temperature rank of a storage class (0 = hottest).
int temperature(StorageClass c) pure nothrow {
  return cast(int) c;
}

/// Lifecycle of a bucket.
enum BucketStatus {
  active, /// read and write
  suspended, /// read-only (writes and deletes are refused)
}

/// Lifecycle of an object.
enum ObjectStatus {
  active, /// readable
  archived, /// in the archive tier — restore before reading
  deleted, /// latest version is a delete marker (versioned buckets only)
}

/// Server side encryption of a bucket.
enum EncryptionType {
  none,
  sseS3, /// provider managed keys
  sseKms, /// customer managed key in a key management service (encryptionKeyId)
  sseC, /// customer provided key (encryptionKeyId references it)
}

/// How object content is passed in a JSON payload.
enum ContentEncoding {
  text, /// UTF-8 text
  base64, /// binary content, base64 encoded
}

///
unittest {
  assert(temperature(StorageClass.archive) > temperature(StorageClass.nearline));
  assert(parseEnum!EncryptionType("sse_kms", EncryptionType.none) == EncryptionType.sseKms);
  assert(enumText(StorageClass.infrequentAccess) == "infrequentAccess");
}
