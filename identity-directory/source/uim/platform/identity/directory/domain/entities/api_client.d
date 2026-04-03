module uim.platform.identity.directory.domain.entities.api_client;

import uim.platform.identity.directory.domain.types;

/// API client / technical user for service-to-service access.
struct ApiClient
{
  ApiClientId id;
  TenantId tenantId;
  string name;
  string description;
  string clientId;
  string clientSecret;
  string[] scopes;
  bool active = true;
  long createdAt;
  long expiresAt; // 0 = no expiry
  long lastUsedAt;

  bool isExpired(long now) const
  {
    return expiresAt > 0 && now > expiresAt;
  }
}
