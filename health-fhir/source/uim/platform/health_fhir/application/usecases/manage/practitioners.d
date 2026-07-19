/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.health_fhir.application.usecases.manage.practitioners;
import uim.platform.health_fhir;
mixin(ShowModule!());

@safe:

class ManagePractitionersUseCase {
  private PractitionerRepository repo;

  this(PractitionerRepository repo) {
    this.repo = repo;
  }

  CommandResult createPractitioner(CreatePractitionerRequest r) {
    auto err = FhirValidator.validatePractitioner(r.practitionerId.value);
    if (err.length > 0) return CommandResult(false, "", err);

    if (!repo.findById(r.tenantId, r.practitionerId).isNull)
      return CommandResult(false, "", "Practitioner already exists");

    auto p = Practitioner(r.tenantId);
    p.id             = r.practitionerId;
    p.name_          = r.name_;
    p.gender_        = r.gender_;
    p.birthDate_     = r.birthDate_;
    p.address_       = r.address_;
    p.active_        = r.active_;
    p.telecom_       = r.telecom_;
    p.qualification_ = r.qualification_;

    repo.save(p);
    return CommandResult(true, p.id.value, "");
  }

  CommandResult updatePractitioner(UpdatePractitionerRequest r) {
    auto existing = repo.findById(r.tenantId, r.practitionerId);
    if (existing.isNull)
      return CommandResult(false, "", "Practitioner not found");

    auto p = Practitioner(r.tenantId); //, r.createdBy);
    p.id             = r.practitionerId;
    p.name_          = r.name_;
    p.gender_        = r.gender_;
    p.birthDate_     = r.birthDate_;
    p.address_       = r.address_;
    p.active_        = r.active_;
    p.telecom_       = r.telecom_;
    p.qualification_ = r.qualification_;
    p.createdAt      = existing.createdAt;

    repo.update(p);
    return CommandResult(true, p.id.value, "");
  }

  Practitioner getPractitioner(TenantId tenantId, PractitionerId id) {
    return repo.findById(tenantId, id);
  }

  Practitioner[] listPractitioners(TenantId tenantId) {
    return repo.findByTenantAll(tenantId);
  }

  CommandResult deletePractitioner(TenantId tenantId, PractitionerId id) {
    auto entity = repo.findById(tenantId, id);
    if (entity.isNull)
      return CommandResult(false, "", "Practitioner not found");
    repo.remove(entity);
    return CommandResult(true, entity.id.value, "");
  }

  size_t countPractitioners(TenantId tenantId) {
    return repo.countByTenant(tenantId);
  }
}
