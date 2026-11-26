/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// The landscape: formations and the registered systems.
///
/// Rules: a system that is used by subscriptions can neither leave its
/// formation nor lose the role (producer / consumer) the subscriptions
/// need; systems, formations and topics owned by a system are only deleted
/// when nothing references them any more.
module uim.platform.application_events.application.usecases.landscape;

import uim.platform.application_events;

mixin(ShowModule!());

@safe:

class ManageFormationsUseCase : ResourceInteractor!(Formation, FormationId, FormationInput), IManageFormations {
  this(AehRepositories repos, IClock clock, IAuditTrail audit, IAehUnitOfWork unitOfWork, AehPolicy policy) {
    super(repos, clock, audit, unitOfWork, policy);
  }

  protected override IAehRepository!(Formation, FormationId) store() {
    return repos.formations;
  }

  protected override string what() {
    return "Formation";
  }

  protected override string eventPrefix() {
    return "formation";
  }

  protected override FormationInput toInput(const Formation e) {
    return FormationInput(e.name, e.description, e.globalAccountId);
  }

  protected override void fromInput(TenantId t, ref Formation e, FormationInput i, bool creating) {
    e.name = i.name.strip;
    e.description = i.description.strip;
    e.globalAccountId = i.globalAccountId.strip;
  }

  protected override void beforeRemove(TenantId t, const Formation e, UserId actor) {
    requireUnused("Formation '" ~ e.name ~ "'", repos.systems.countByReference(t, "formationId", e.id.value), "systems");
  }

  Formation activate(TenantId t, FormationId id, UserId actor) {
    return setStatus(t, id, FormationStatus.active, actor);
  }

  Formation deactivate(TenantId t, FormationId id, UserId actor) {
    return setStatus(t, id, FormationStatus.inactive, actor);
  }

  protected Formation setStatus(TenantId t, FormationId id, FormationStatus status, UserId actor) {
    auto f = get(t, id);
    if (f.status == status)
      throw AehException.ruleViolation("Formation '" ~ f.name ~ "' is already " ~ cast(string) status);
    f.status = status;
    return changed(f, actor, "formation." ~ (status == FormationStatus.active ? "activated" : "deactivated"));
  }

  SystemRegistration assignSystem(TenantId t, FormationId id, SystemRegistrationId systemId, UserId actor) {
    auto f = get(t, id);
    auto s = systemOf(t, systemId);
    if (s.formationId == f.id)
      throw AehException.ruleViolation("System '" ~ s.name ~ "' already belongs to formation '" ~ f.name ~ "'");
    requireNoSubscriptions(t, s, "change its formation");
    s.formationId = f.id;
    return changed(s, actor, "system.assigned", Json(["formation": Json(f.id.value)]));
  }

  SystemRegistration unassignSystem(TenantId t, SystemRegistrationId systemId, UserId actor) {
    auto s = systemOf(t, systemId);
    if (s.formationId.isNull)
      throw AehException.ruleViolation("System '" ~ s.name ~ "' belongs to no formation");
    requireNoSubscriptions(t, s, "leave its formation");
    auto old = s.formationId.value;
    s.formationId = FormationId.init;
    return changed(s, actor, "system.unassigned", Json(["formation": Json(old)]));
  }

  protected void requireNoSubscriptions(TenantId t, const SystemRegistration s, string action) {
    auto n = repos.subscriptions.countByReference(t, "producerSystemId", s.id.value)
      + repos.subscriptions.countByReference(t, "consumerSystemId", s.id.value);
    if (n > 0)
      throw AehException.ruleViolation(format("System '%s' cannot %s while %d subscriptions use it", s.name, action, n));
  }
}

class ManageSystemsUseCase : ResourceInteractor!(SystemRegistration, SystemRegistrationId, SystemInput), IManageSystems {
  this(AehRepositories repos, IClock clock, IAuditTrail audit, IAehUnitOfWork unitOfWork, AehPolicy policy) {
    super(repos, clock, audit, unitOfWork, policy);
  }

  protected override IAehRepository!(SystemRegistration, SystemRegistrationId) store() {
    return repos.systems;
  }

  protected override string what() {
    return "System";
  }

  protected override string eventPrefix() {
    return "system";
  }

  protected override SystemInput toInput(const SystemRegistration e) {
    return SystemInput(e.name, e.description, cast(string) e.systemType, e.systemUrl, e.formationId.value);
  }

  protected override void fromInput(TenantId t, ref SystemRegistration e, SystemInput i, bool creating) {
    e.name = i.name.strip;
    e.description = i.description.strip;
    e.systemType = parseDomainEnumOr!SystemType(i.systemType, SystemType.both, "system type");
    e.systemUrl = i.systemUrl.strip;
    e.formationId = FormationId(optionalReference!FormationId(repos.formations, t, i.formationId, "Formation"));
  }

  protected override void beforeSave(TenantId t, ref SystemRegistration e, bool creating) {
    if (creating)
      return;
    auto before = repos.systems.findById(t, e.id);
    auto asProducer = repos.subscriptions.countByReference(t, "producerSystemId", e.id.value);
    auto asConsumer = repos.subscriptions.countByReference(t, "consumerSystemId", e.id.value);
    if (!e.produces && asProducer > 0)
      throw AehException.ruleViolation(format("System '%s' produces the events of %d subscriptions", e.name, asProducer));
    if (!e.consumes && (asConsumer > 0 || repos.channels.countByReference(t, "consumerSystemId", e.id.value) > 0))
      throw AehException.ruleViolation("System '" ~ e.name ~ "' consumes events (subscriptions or channels exist)");
    if (before.formationId != e.formationId && asProducer + asConsumer > 0)
      throw AehException.ruleViolation(format("System '%s' cannot change its formation while %d subscriptions use it",
          e.name, asProducer + asConsumer));
  }

  protected override void beforeRemove(TenantId t, const SystemRegistration e, UserId actor) {
    auto what = "System '" ~ e.name ~ "'";
    requireUnused(what, repos.subscriptions.countByReference(t, "producerSystemId", e.id.value)
        + repos.subscriptions.countByReference(t, "consumerSystemId", e.id.value), "subscriptions");
    requireUnused(what, repos.channels.countByReference(t, "consumerSystemId", e.id.value), "channels");
    requireUnused(what, repos.topics.countByReference(t, "ownerSystemId", e.id.value), "event types it owns");
  }

  SystemRegistration activate(TenantId t, SystemRegistrationId id, UserId actor) {
    return setStatus(t, id, SystemStatus.active, actor);
  }

  SystemRegistration deactivate(TenantId t, SystemRegistrationId id, UserId actor) {
    return setStatus(t, id, SystemStatus.inactive, actor);
  }

  protected SystemRegistration setStatus(TenantId t, SystemRegistrationId id, SystemStatus status, UserId actor) {
    auto s = get(t, id);
    if (s.status == status)
      throw AehException.ruleViolation("System '" ~ s.name ~ "' is already " ~ cast(string) status);
    s.status = status;
    return changed(s, actor, "system." ~ (status == SystemStatus.active ? "activated" : "deactivated"));
  }
}
