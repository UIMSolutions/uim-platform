module domain.services.encryption_policy;

import domain.entities.bucket;
import domain.types;

/// Domain service: validates encryption configuration.
struct EncryptionValidationResult
{
    bool valid;
    string error;
}

struct EncryptionPolicy
{
    static EncryptionValidationResult validate(ref const Bucket bucket)
    {
        if (bucket.encryptionType == EncryptionType.sse_kms || bucket.encryptionType == EncryptionType.sse_c)
        {
            if (bucket.encryptionKeyId.length == 0)
                return EncryptionValidationResult(false,
                    "Encryption key ID is required for " ~ (
                        bucket.encryptionType == EncryptionType.sse_kms ? "SSE-KMS" : "SSE-C"
                    ));
        }
        return EncryptionValidationResult(true, "");
    }
}
