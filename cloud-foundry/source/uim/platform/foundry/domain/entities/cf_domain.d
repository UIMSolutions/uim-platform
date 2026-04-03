module uim.platform.cloud_foundry.domain.entities.cf_domain;

import uim.platform.cloud_foundry.domain.types;

/// A Cloud Foundry domain — a DNS namespace under which routes are created.
/// Can be shared (platform-wide), private (org-scoped), or internal.
struct CfDomain
{
  DomainId id;
  OrgId ownerOrgId;                   // empty for shared domains
  TenantId tenantId;
  string name;                        // e.g. "apps.example.com"
  DomainScope scope_ = DomainScope.shared_;
  bool isInternal;
  string createdBy;
  long createdAt;
  long updatedAt;
}
