/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.health_fhir.application.usecases.manage.encounters;
import uim.platform.health_fhir;

// mixin(ShowModule!());

@safe:

class ManageEncountersUseCase {
  private EncounterRepository repo;

  this(EncounterRepository repo) {
    this.repo = repo;
  }

  CommandResult createEncounter(CreateEncounterRequest r) {
    auto err = FhirValidator.validateEncounter(r.encounterId.value);
    if (err.length > 0) return CommandResult(false, "", err);

    if (!repo.findById(r.tenantId, r.encounterId).isNull)
      return CommandResult(false, "", "Encounter already exists");

    Encounter e;
    e.initEntity(r.tenantId);
    e.id              = r.encounterId;
    e.status_         = r.status_;
    e.class_          = r.class_;
    e.type_           = r.type_;
    e.subject_        = r.subject_;
    e.participant_    = r.participant_;
    e.periodStart_    = r.periodStart_;
    e.periodEnd_      = r.periodEnd_;
    e.reasonReference_ = r.reasonReference_;
    e.reasonCode_     = r.reasonCode_;
    e.serviceProvider_ = r.serviceProvider_;

    repo.save(e);
    return CommandResult(true, e.id.value, "");
  }

  CommandResult updateEncounter(UpdateEncounterRequest r) {
    auto existing = repo.findById(r.tenantId, r.encounterId);
    if (existing.isNull)
      return CommandResult(false, "", "Encounter not found");

    Encounter e;
    e.initEntity(r.tenantId);
    e.id               = r.encounterId;
    e.status_          = r.status_;
    e.class_           = r.class_;
    e.type_            = r.type_;
    e.subject_         = r.subject_;
    e.participant_     = r.participant_;
    e.periodStart_     = r.periodStart_;
    e.periodEnd_       = r.periodEnd_;
    e.reasonReference_ = r.reasonReference_;
    e.reasonCode_      = r.reasonCode_;
    e.serviceProvider_ = r.serviceProvider_;
    e.createdAt        = existing.createdAt;

    repo.update(e);
    return CommandResult(true, e.id.value, "");
  }

  Encounter getEncounter(TenantId tenantId, EncounterId id) {
    return repo.findById(tenantId, id);
  }

  Encounter[] listEncounters(TenantId tenantId) {
    return repo.findByTenantAll(tenantId);
  }

  Encounter[] listByPatient(TenantId tenantId, string patientRef) {
    return repo.findByPatient(tenantId, patientRef);
  }

  CommandResult deleteEncounter(TenantId tenantId, EncounterId id) {
    auto entity = repo.findById(tenantId, id);
    if (entity.isNull)
      return CommandResult(false, "", "Encounter not found");
    repo.remove(entity);
    return CommandResult(true, entity.id.value, "");
  }
}
