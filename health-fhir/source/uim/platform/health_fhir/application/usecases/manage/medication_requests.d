/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.health_fhir.application.usecases.manage.medication_requests;
import uim.platform.health_fhir;

// mixin(ShowModule!());

@safe:

class ManageMedicationRequestsUseCase {
  private MedicationRequestRepository repo;

  this(MedicationRequestRepository repo) {
    this.repo = repo;
  }

  CommandResult createMedicationRequest(CreateMedicationOrderRequest r) {
    auto err = FhirValidator.validateMedicationRequest(r.medicationRequestId.value);
    if (err.length > 0) return CommandResult(false, "", err);

    if (!repo.findById(r.tenantId, r.medicationRequestId).isNull)
      return CommandResult(false, "", "MedicationRequest already exists");

    MedicationRequest mr;
    mr.initEntity(r.tenantId);
    mr.id                   = r.medicationRequestId;
    mr.status_              = r.status_;
    mr.intent_              = r.intent_;
    mr.medicationReference_ = r.medicationReference_;
    mr.subject_             = r.subject_;
    mr.encounter_           = r.encounter_;
    mr.authoredOn_          = r.authoredOn_;
    mr.requester_           = r.requester_;
    mr.recorder_            = r.recorder_;
    mr.reasonCode_          = r.reasonCode_;
    mr.reasonReference_     = r.reasonReference_;
    mr.note_                = r.note_;
    mr.dosageInstructionText_ = r.dosageInstructionText_;

    repo.save(mr);
    return CommandResult(true, mr.id.value, "");
  }

  CommandResult updateMedicationRequest(UpdateMedicationOrderRequest r) {
    auto existing = repo.findById(r.tenantId, r.medicationRequestId);
    if (existing.isNull)
      return CommandResult(false, "", "MedicationRequest not found");

    MedicationRequest mr;
    mr.initEntity(r.tenantId);
    mr.id                   = r.medicationRequestId;
    mr.status_              = r.status_;
    mr.intent_              = r.intent_;
    mr.medicationReference_ = r.medicationReference_;
    mr.subject_             = r.subject_;
    mr.encounter_           = r.encounter_;
    mr.authoredOn_          = r.authoredOn_;
    mr.requester_           = r.requester_;
    mr.recorder_            = r.recorder_;
    mr.reasonCode_          = r.reasonCode_;
    mr.reasonReference_     = r.reasonReference_;
    mr.note_                = r.note_;
    mr.dosageInstructionText_ = r.dosageInstructionText_;
    mr.createdAt            = existing.createdAt;

    repo.update(mr);
    return CommandResult(true, mr.id.value, "");
  }

  MedicationRequest getMedicationRequest(TenantId tenantId, MedicationRequestId id) {
    return repo.findById(tenantId, id);
  }

  MedicationRequest[] listMedicationRequests(TenantId tenantId) {
    return repo.findByTenantAll(tenantId);
  }

  MedicationRequest[] listByPatient(TenantId tenantId, string patientRef) {
    return repo.findByPatient(tenantId, patientRef);
  }

  CommandResult deleteMedicationRequest(TenantId tenantId, MedicationRequestId id) {
    auto entity = repo.findById(tenantId, id);
    if (entity.isNull)
      return CommandResult(false, "", "MedicationRequest not found");
    repo.remove(entity);
    return CommandResult(true, entity.id.value, "");
  }
}
