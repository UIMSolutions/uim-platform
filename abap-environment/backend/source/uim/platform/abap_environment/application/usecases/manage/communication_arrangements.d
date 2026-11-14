/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.application.usecases.manage.communication_arrangements;

import uim.platform.abap_environment;

mixin(ShowModule!());

@safe:

/// Interactor: communication arrangements. One arrangement per scenario and
/// communication system.
class ManageCommunicationArrangementsUseCase
  : ResourceUseCase!(CommunicationArrangement, CommunicationArrangementId,
    CreateCommunicationArrangementRequest, UpdateCommunicationArrangementRequest),
  IManageCommunicationArrangementsUseCase {

  this(AbapRepositories repos, IAbapEventPublisher publisher) {
    super(repos, repos.communicationArrangements, publisher, "Communication arrangement", "abap.communication-arrangement");
  }

  override protected CommunicationArrangement build(CreateCommunicationArrangementRequest r) {
    auto system = requireActiveSystem(r.tenantId, r.parentId, "configure communication");
    auto a = CommunicationArrangement(r.tenantId);
    a.systemInstanceId = system.id;
    a.systemName = system.name;
    assignMatching(a, r.spec);
    a.scenarioId = CommunicationScenarioId(a.scenarioId.value.strip.toUpper);
    check(a);
    return a;
  }

  override protected void apply(ref CommunicationArrangement a, CommunicationArrangementSpec spec) {
    assignMatching(a, spec, ["name", "scenarioId"]);
    check(a);
  }

  protected void check(const ref CommunicationArrangement a) {
    validateArrangement(a);
    ensureUnique(repos.communicationArrangements.findByName(a.tenantId, a.systemInstanceId, a.name), a,
      "system '" ~ a.systemName ~ "'");
    foreach (other; repos.communicationArrangements.findBySystem(a.tenantId, a.systemInstanceId))
      ensureState(other.id == a.id || other.scenarioId != a.scenarioId || other.communicationSystem != a.communicationSystem,
        "Scenario " ~ a.scenarioId.value ~ " is already arranged with '" ~ a.communicationSystem ~ "' ('" ~ other.name ~ "')");
  }

  UsecaseResult activate(TenantId tenantId, CommunicationArrangementId id, UserId actor) {
    return transition(tenantId, id, actor, "activated", (ref CommunicationArrangement a) {
      ensureState(a.status != ArrangementStatus.active, "Communication arrangement '" ~ a.name ~ "' is already active");
      validateCredentials(a);
      a.status = ArrangementStatus.active;
    });
  }

  UsecaseResult deactivate(TenantId tenantId, CommunicationArrangementId id, UserId actor) {
    return transition(tenantId, id, actor, "deactivated", (ref CommunicationArrangement a) {
      ensureState(a.status == ArrangementStatus.active, "Communication arrangement '" ~ a.name ~ "' is not active");
      a.status = ArrangementStatus.inactive;
    });
  }
}
