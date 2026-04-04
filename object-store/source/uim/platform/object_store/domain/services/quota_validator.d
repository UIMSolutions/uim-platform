/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.object_store.domain.services.quota_validator;

import uim.platform.object_store.domain.entities.bucket;

/// Domain service: validates storage quota constraints.
struct QuotaValidationResult {
  bool valid;
  string error;
}

struct QuotaValidator {
  static QuotaValidationResult validate(const Bucket bucket, long additionalBytes) {
    if (bucket.quotaBytes == 0)
      return QuotaValidationResult(true, "");

    if (bucket.usedBytes + additionalBytes > bucket.quotaBytes)
      return QuotaValidationResult(false, "Bucket quota exceeded");

    return QuotaValidationResult(true, "");
  }
}
