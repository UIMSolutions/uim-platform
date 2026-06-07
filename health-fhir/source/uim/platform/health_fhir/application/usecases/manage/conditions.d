/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.health_fhir.application.usecases.manage.conditions;
import uim.platform.health_fhir;

// mixin(ShowModule!());

@safe:

class ManageConditionsUseCase {
  private ConditionRepository repo;

  this(ConditionRepository repo) {
    this.repo = repo;
  }

  CommandResult createCondition(CreateConditionRequest r) {
    auto err = FhirValidator.validateCondition(r.conditionId.value);
    if (err.length > 0) return CommandResult(false, "", err);

    if (!repo.findById(r.tenantId, r.conditionId).isNull)
      return CommandResult(false, "", "Condition already exists");

    Condition c;
    c.initEntity(r.tenantId);
    c.id                   = r.conditionId;
    c.clinicalStatus_      = r.clinicalStatus_;
    c.verificationStatus_  = r.verificationStatus_;
    c.category_            = r.category_;
    c.severity_            = r.severity_;
    c.code_                = r.code_;
    c.subject_             = r.subject_;
    c.encounter_           = r.encounter_;
    c.onsetDateTime_       = r.onsetDateTime_;
    c.abatementDateTime_   = r.abatementDateTime_;
    c.recordedDate_        = r.recordedDate_;
    c.recorder_            = r.recorder_;
    c.note_                = r.note_;

    repo.save(c);
    return CommandResult(true, c.id.value, "");
  }

  CommandResult updateCondition(UpdateConditionRequest r) {
    auto existing = repo.findById(r.tenantId, r.conditionId);
    if (existing.isNull)
      return CommandResult(false, "", "Condition not found");

    Condition c;
    c.initEntity(r.tenantId);
    c.id                   = r.conditionId;
    c.clinicalStatus_      = r.clinicalStatus_;
    c.verificationStatus_  = r.verificationStatus_;
    c.category_            = r.category_;
    c.severity_            = r.severity_;
    c.code_                = r.code_;
    c.subject_             = r.subject_;
    c.encounter_           = r.encounter_;
    c.onsetDateTime_       = r.onsetDateTime_;
    c.abatementDateTime_   = r.abatementDateTime_;
    c.recordedDate_        = r.recordedDate_;
    c.recorder_            = r.recorder_;
    c.note_                = r.note_;
    c.createdAt            = existing.createdAt;

    repo.update(c);
    return CommandResult(true, c.id.value, "");
  }

  Condition getCondition(TenantId tenantId, ConditionId id) {
    return repo.findById(tenantId, id);
  }

  Condition[] listConditions(TenantId tenantId) {
    return repo.findByTenantAll(tenantId);
  }

  Condition[] listByPatient(TenantId tenantId, string patientRef) {
    return repo.findByPatient(tenantId, patientRef);
  }

  CommandResult deleteCondition(TenantId tenantId, ConditionId id) {
    auto entity = repo.findById(tenantId, id);
    if (entity.isNull)
      return CommandResult(false, "", "Condition not found");
    repo.remove(entity);
    return CommandResult(true, entity.id.value, "");
  }
}
