module domain.entities.cors_rule;

import domain.types;

class CorsRule
{
  CorsRuleId id;
  TenantId tenantId;
  BucketId bucketId;
  string allowedOrigins; // JSON array, e.g. '["https://example.com"]'
  string allowedMethods; // JSON array, e.g. '["GET","PUT","POST"]'
  string allowedHeaders; // JSON array, e.g. '["Content-Type","Authorization"]'
  string exposedHeaders; // JSON array, e.g. '["ETag"]'
  int maxAgeSeconds = 3600;
  long createdAt;
  long updatedAt;
}
