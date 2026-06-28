/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.health_fhir.application.usecases.manage.organizations;
import uim.platform.health_fhir;

// mixin(ShowModule!());

@safe:

class ManageOrganizationsUseCase {
  private OrganizationRepository repo;

  this(OrganizationRepository repo) {
    this.repo = repo;
  }

  CommandResult createOrganization(CreateOrganizationRequest r) {
    auto err = FhirValidator.validateOrganization(r.organizationId.value, r.name_);
    if (err.length > 0) return CommandResult(false, "", err);

    if (!repo.find(r.tenantId, r.organizationId).isNull)
      return CommandResult(false, "", "Organization already exists");

    Organization o;
    o.initEntity(r.tenantId);
    o.id       = r.organizationId;
    o.active_  = r.active_;
    o.type_    = r.type_;
    o.name_    = r.name_;
    o.alias_   = r.alias_;
    o.telecom_ = r.telecom_;
    o.address_ = r.address_;
    o.partOf_  = r.partOf_;

    repo.save(o);
    return CommandResult(true, o.id.value, "");
  }

  CommandResult updateOrganization(UpdateOrganizationRequest r) {
    auto existing = repo.find(r.tenantId, r.organizationId);
    if (existing.isNull)
      return CommandResult(false, "", "Organization not found");

    Organization o;
    o.initEntity(r.tenantId);
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
    return CommandResult(true, o.id.value, "");
  }

  Organization getOrganization(TenantId tenantId, OrganizationId id) {
    return repo.find(tenantId, id);
  }

  Organization[] listOrganizations(TenantId tenantId) {
    return repo.findByTenantAll(tenantId);
  }

  CommandResult deleteOrganization(TenantId tenantId, OrganizationId id) {
    auto entity = repo.find(tenantId, id);
    if (entity.isNull)
      return CommandResult(false, "", "Organization not found");
    repo.remove(entity);
    return CommandResult(true, entity.id.value, "");
  }
}
