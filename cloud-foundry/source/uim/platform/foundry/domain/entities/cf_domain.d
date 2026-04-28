/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.domain.entities.cf_domain;

// import uim.platform.foundry.domain.types;
import uim.platform.foundry;

mixin(ShowModule!());

@safe:
/// A Cloud Foundry domain — a DNS namespace under which routes are created.
/// Can be shared (platform-wide), private (org-scoped), or internal.
struct CfDomain {
  mixin TenantEntity!CfDomainId;

  OrgId ownerOrgId; // empty for shared domains
  string name; // e.g. "apps.example.com"
  DomainScope scope_ = DomainScope.shared_;
  bool isInternal;

  Json toJson() const {
    return entityToJson()
      .set("ownerOrgId", ownerOrgId)
      .set("name", name)
      .set("scope", scope_.to!string)
      .set("isInternal", isInternal);
  }
}
