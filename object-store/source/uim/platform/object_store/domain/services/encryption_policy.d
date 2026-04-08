/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.object_store.domain.services.encryption_policy;

import uim.platform.object_store.domain.entities.bucket;
import uim.platform.object_store.domain.types;

/// Domain service: validates encryption configuration.
struct EncryptionValidationResult {
  bool valid;
  string error;
}

struct EncryptionPolicy {
  static EncryptionValidationResult validate(const Bucket bucket) {
    if (bucket.encryptionType == EncryptionType.sse_kms
      || bucket.encryptionType == EncryptionType.sse_c) {
      if (bucket.encryptionKeyid.isEmpty)
        return EncryptionValidationResult(false, "Encryption key ID is required for " ~ (
            bucket.encryptionType == EncryptionType.sse_kms ? "SSE-KMS" : "SSE-C"));
    }
    return EncryptionValidationResult(true, "");
  }
}
