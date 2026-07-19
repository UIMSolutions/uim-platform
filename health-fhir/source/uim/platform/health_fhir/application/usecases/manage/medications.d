/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.health_fhir.application.usecases.manage.medications;
import uim.platform.health_fhir;
mixin(ShowModule!());

@safe:

class ManageMedicationsUseCase {
  private MedicationRepository repo;

  this(MedicationRepository repo) {
    this.repo = repo;
  }

  CommandResult createMedication(CreateMedicationRequest r) {
    auto err = FhirValidator.validateMedication(r.medicationId.value);
    if (err.length > 0) return CommandResult(false, "", err);

    if (!repo.findById(r.tenantId, r.medicationId).isNull)
      return CommandResult(false, "", "Medication already exists");

    auto m = Medication(r.tenantId);
    m.id           = r.medicationId;
    m.code_        = r.code_;
    m.status_      = r.status_;
    m.manufacturer_ = r.manufacturer_;
    m.form_        = r.form_;
    m.amount_      = r.amount_;
    m.ingredient_  = r.ingredient_;

    repo.save(m);
    return CommandResult(true, m.id.value, "");
  }

  CommandResult updateMedication(UpdateMedicationRequest r) {
    auto existing = repo.findById(r.tenantId, r.medicationId);
    if (existing.isNull)
      return CommandResult(false, "", "Medication not found");

    auto m = Medication(r.tenantId);
    m.id           = r.medicationId;
    m.code_        = r.code_;
    m.status_      = r.status_;
    m.manufacturer_ = r.manufacturer_;
    m.form_        = r.form_;
    m.amount_      = r.amount_;
    m.ingredient_  = r.ingredient_;
    m.createdAt    = existing.createdAt;

    repo.update(m);
    return CommandResult(true, m.id.value, "");
  }

  Medication getMedication(TenantId tenantId, MedicationId id) {
    return repo.findById(tenantId, id);
  }

  Medication[] listMedications(TenantId tenantId) {
    return repo.findByTenantAll(tenantId);
  }

  CommandResult deleteMedication(TenantId tenantId, MedicationId id) {
    auto entity = repo.findById(tenantId, id);
    if (entity.isNull)
      return CommandResult(false, "", "Medication not found");
    repo.remove(entity);
    return CommandResult(true, entity.id.value, "");
  }
}
