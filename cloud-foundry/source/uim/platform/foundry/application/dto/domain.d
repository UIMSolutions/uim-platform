module uim.platform.foundry.application.dto.domain;
 import uim.platform.foundry;
mixin(ShowModule!());

@safe:

struct CreateDomainRequest {
  OrgId ownerOrgId;
  TenantId tenantId;
  CfDomainId domainId;

  string name;
  string scope_;
  bool isInternal;
  UserId createdBy;
}
