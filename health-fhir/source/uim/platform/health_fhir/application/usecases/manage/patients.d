/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.health_fhir.application.usecases.manage.patients;
import uim.platform.health_fhir;
mixin(ShowModule!());

@safe:

class ManagePatientsUseCase {
  private PatientRepository repo;

  this(PatientRepository repo) {
    this.repo = repo;
  }

  CommandResult createPatient(CreatePatientRequest r) {
    auto err = FhirValidator.validatePatient(
      r.patientId.value,
      r.name_.length > 0 ? r.name_[0].family_ : ""
    );
    if (err.length > 0) return CommandResult(false, "", err);

    if (!repo.findById(r.tenantId, r.patientId).isNull)
      return CommandResult(false, "", "Patient already exists");

    auto p = Patient(r.tenantId);
    p.id         = r.patientId;
    p.name_      = r.name_;
    p.birthDate_ = r.birthDate_;
    p.gender_    = r.gender_;
    p.address_   = r.address_;
    p.active_    = r.active_;
    p.telecom_   = r.telecom_;

    repo.save(p);
    return CommandResult(true, p.id.value, "");
  }

  CommandResult updatePatient(UpdatePatientRequest r) {
    auto existing = repo.findById(r.tenantId, r.patientId);
    if (existing.isNull)
      return CommandResult(false, "", "Patient not found");

    auto p = Patient(r.tenantId);
    p.id         = r.patientId;
    p.name_      = r.name_;
    p.birthDate_ = r.birthDate_;
    p.gender_    = r.gender_;
    p.address_   = r.address_;
    p.active_    = r.active_;
    p.telecom_   = r.telecom_;
    p.createdAt  = existing.createdAt;

    repo.update(p);
    return CommandResult(true, p.id.value, "");
  }

  Patient getPatient(TenantId tenantId, PatientId id) {
    return repo.findById(tenantId, id);
  }

  Patient[] listPatients(TenantId tenantId) {
    return repo.findByTenantAll(tenantId);
  }

  Patient[] searchByName(TenantId tenantId, string namePart) {
    return repo.searchByName(tenantId, namePart);
  }

  CommandResult deletePatient(TenantId tenantId, PatientId id) {
    auto entity = repo.findById(tenantId, id);
    if (entity.isNull)
      return CommandResult(false, "", "Patient not found");
    repo.remove(entity);
    return CommandResult(true, entity.id.value, "");
  }

  size_t countPatients(TenantId tenantId) {
    return repo.countByTenant(tenantId);
  }
}
