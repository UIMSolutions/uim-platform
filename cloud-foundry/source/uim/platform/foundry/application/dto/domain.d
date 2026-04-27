module uim.platform.foundry.application.dto.domain;
 import uim.platform.foundry;

mixin(ShowModule!());

@safe:

struct CreateDomainRequest {
  OrgId ownerOrgId;
  TenantId tenantId;
  string name;
  DomainScope scope_;
  bool isInternal;
  string createdBy;
}
