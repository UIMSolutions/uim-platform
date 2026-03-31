module uim.platform.object_store.domain.types;


// --- ID type aliases ---
alias BucketId = string;
alias ObjectId = string;
alias ObjectVersionId = string;
alias AccessPolicyId = string;
alias LifecycleRuleId = string;
alias CorsRuleId = string;
alias ServiceBindingId = string;
alias TenantId = string;
alias UserId = string;

// --- Enumerations ---

enum StorageClass
{
  standard,
  nearline,
  coldline,
  archive,
}

enum BucketStatus
{
  active,
  suspended,
  deleted,
}

enum ObjectStatus
{
  active,
  archived,
  deleted,
}

enum EncryptionType
{
  none,
  sse_s3,
  sse_kms,
  sse_c,
}

enum PolicyEffect
{
  allow,
  deny,
}

enum BindingPermission
{
  readOnly,
  readWrite,
  admin,
}

enum BindingStatus
{
  active,
  revoked,
  expired,
}

enum RuleStatus
{
  enabled,
  disabled,
}
