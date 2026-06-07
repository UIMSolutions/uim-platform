/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.health_fhir.application.usecases.manage.observations;
import uim.platform.health_fhir;

// mixin(ShowModule!());

@safe:

class ManageObservationsUseCase {
  private ObservationRepository repo;

  this(ObservationRepository repo) {
    this.repo = repo;
  }

  CommandResult createObservation(CreateObservationRequest r) {
    auto err = FhirValidator.validateObservation(r.observationId.value, r.status_.to!string);
    if (err.length > 0) return CommandResult(false, "", err);

    if (!repo.findById(r.tenantId, r.observationId).isNull)
      return CommandResult(false, "", "Observation already exists");

    Observation o;
    o.initEntity(r.tenantId);
    o.id                  = r.observationId;
    o.status_             = r.status_;
    o.code_               = r.code_;
    o.subject_            = r.subject_;
    o.encounter_          = r.encounter_;
    o.effectiveDateTime_  = r.effectiveDateTime_;
    o.valueQuantity_      = r.valueQuantity_;
    o.valueString_        = r.valueString_;
    o.category_           = r.category_;
    o.performer_          = r.performer_;
    o.note_               = r.note_;

    repo.save(o);
    return CommandResult(true, o.id.value, "");
  }

  CommandResult updateObservation(UpdateObservationRequest r) {
    auto existing = repo.findById(r.tenantId, r.observationId);
    if (existing.isNull)
      return CommandResult(false, "", "Observation not found");

    Observation o;
    o.initEntity(r.tenantId);
    o.id                  = r.observationId;
    o.status_             = r.status_;
    o.code_               = r.code_;
    o.subject_            = r.subject_;
    o.encounter_          = r.encounter_;
    o.effectiveDateTime_  = r.effectiveDateTime_;
    o.valueQuantity_      = r.valueQuantity_;
    o.valueString_        = r.valueString_;
    o.category_           = r.category_;
    o.performer_          = r.performer_;
    o.note_               = r.note_;
    o.createdAt           = existing.createdAt;

    repo.update(o);
    return CommandResult(true, o.id.value, "");
  }

  Observation getObservation(TenantId tenantId, ObservationId id) {
    return repo.findById(tenantId, id);
  }

  Observation[] listObservations(TenantId tenantId) {
    return repo.findByTenantAll(tenantId);
  }

  Observation[] listByPatient(TenantId tenantId, string patientRef) {
    return repo.findByPatient(tenantId, patientRef);
  }

  CommandResult deleteObservation(TenantId tenantId, ObservationId id) {
    auto entity = repo.findById(tenantId, id);
    if (entity.isNull)
      return CommandResult(false, "", "Observation not found");
    repo.remove(entity);
    return CommandResult(true, entity.id.value, "");
  }
}
