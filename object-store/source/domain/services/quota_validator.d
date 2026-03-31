module domain.services.quota_validator;

import domain.entities.bucket;

/// Domain service: validates storage quota constraints.
struct QuotaValidationResult
{
    bool valid;
    string error;
}

struct QuotaValidator
{
    static QuotaValidationResult validate(ref const Bucket bucket, long additionalBytes)
    {
        if (bucket.quotaBytes == 0)
            return QuotaValidationResult(true, "");

        if (bucket.usedBytes + additionalBytes > bucket.quotaBytes)
            return QuotaValidationResult(false, "Bucket quota exceeded");

        return QuotaValidationResult(true, "");
    }
}
