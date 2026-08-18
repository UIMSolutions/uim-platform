/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.health_fhir.application.usecases.manage.organizations;
import uim.platform.health_fhir;

mixin(ShowModule!());

@safe:

class ManageOrganizationsUseCase {
  protected IOrganizationRepository repo;

  this(IOrganizationRepository repo) {
    this.repo = repo;
  }

  UsecaseResult createOrganization(CreateOrganizationRequest r) {
    auto err = FhirValidator.validateOrganization(r.organizationId.value, r.name_);
    if (err.length > 0) return UsecaseResult(false, "", err);

    if (!repo.findById(r.tenantId, r.organizationId).isNull)
      return UsecaseResult(false, "", "Organization already exists");

    auto o = Organization(r.tenantId);
    o.id       = r.organizationId;
    o.active_  = r.active_;
    o.type_    = r.type_;
    o.name_    = r.name_;
    o.alias_   = r.alias_;
    o.telecom_ = r.telecom_;
    o.address_ = r.address_;
    o.partOf_  = r.partOf_;

    repo.save(o);
    return UsecaseResult(true, o.id.value, "");
  }

  UsecaseResult updateOrganization(UpdateOrganizationRequest r) {
    auto existing = repo.findById(r.tenantId, r.organizationId);
    if (existing.isNull)
      return UsecaseResult(false, "", "Organization not found");

    auto o  = Organization(r.tenantId);
    o.id        = r.organizationId;
    o.active_   = r.active_;
    o.type_     = r.type_;
    o.name_     = r.name_;
    o.alias_    = r.alias_;
    o.telecom_  = r.telecom_;
    o.address_  = r.address_;
    o.partOf_   = r.partOf_;
    o.createdAt = existing.createdAt;

    repo.update(o);
    return UsecaseResult(true, o.id.value, "");
  }

  Organization getOrganization(TenantId tenantId, OrganizationId id) {
    return repo.findById(tenantId, id);
  }

  Organization[] listOrganizations(TenantId tenantId) {
    return repo.findByTenantAll(tenantId);
  }

  UsecaseResult deleteOrganization(TenantId tenantId, OrganizationId id) {
    auto entity = repo.findById(tenantId, id);
    if (entity.isNull)
      return UsecaseResult(false, "", "Organization not found");
    repo.remove(entity);
    return UsecaseResult(true, entity.id.value, "");
  }
}
