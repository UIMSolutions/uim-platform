/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Application bindings.
///
/// Rules: the application GUID is unique per tenant and cannot change; an
/// attached policy must exist; the instance count is set on create only
/// (afterwards the scaling engine or a manual scaling changes it, both
/// recorded in the history). Deleting a binding removes its metric samples
/// and its scaling history.
module uim.platform.application_autoscaler.application.usecases.bindings;

import uim.platform.application_autoscaler;

mixin(ShowModule!());

@safe:

class ManageBindingsUseCase : ResourceInteractor!(AppBinding, AppBindingId, BindingInput), IManageBindings {
  this(AasRepositories repos, IClock clock, IAasEventPublisher events, IAasUnitOfWork unitOfWork, AasPolicy policy) {
    super(repos, clock, events, unitOfWork, policy);
  }

  protected override IAasRepository!(AppBinding, AppBindingId) store() {
    return repos.bindings;
  }

  protected override string what() {
    return "Binding";
  }

  protected override string eventPrefix() {
    return "binding";
  }

  protected override string[] immutableAttributes() {
    return ["appGuid", "currentInstances"];
  }

  protected override BindingInput toInput(const AppBinding e) {
    BindingInput i;
    i.name = e.name;
    i.appGuid = e.appGuid;
    i.serviceInstanceId = e.serviceInstanceId;
    i.description = e.description;
    i.policyId = e.policyId.value;
    i.currentInstances = e.currentInstances;
    return i;
  }

  protected override void fromInput(TenantId t, ref AppBinding e, BindingInput i, bool creating) {
    e.name = i.name.strip;
    e.appGuid = i.appGuid.strip;
    if (creating)
      foreach (other; repos.bindings.findByReference(t, "appGuid", e.appGuid))
        throw AasException.conflict("Application '" ~ e.appGuid ~ "' is already bound ('" ~ other.id.value ~ "')");
    e.serviceInstanceId = i.serviceInstanceId.strip;
    e.description = i.description.strip;
    e.policyId = ScalingPolicyId(optionalReference!ScalingPolicyId(repos.policies, t, i.policyId, "Policy"));
    if (creating)
      e.currentInstances = i.currentInstances;
  }

  protected override void beforeRemove(TenantId t, const AppBinding e, UserId actor) {
    repos.metrics.removeByReference(t, "bindingId", e.id.value);
    repos.events.removeByReference(t, "bindingId", e.id.value);
  }

  AppBinding attachPolicy(TenantId t, AppBindingId id, ScalingPolicyId policyId, UserId actor) {
    auto b = get(t, id);
    auto p = policyOf(t, policyId);
    b.policyId = p.id;
    return changed(b, actor, "binding.policyAttached", Json(["policy": Json(p.id.value)]));
  }

  AppBinding detachPolicy(TenantId t, AppBindingId id, UserId actor) {
    auto b = get(t, id);
    if (!b.hasPolicy)
      throw AasException.ruleViolation("Binding '" ~ b.name ~ "' has no policy");
    auto old = b.policyId.value;
    b.policyId = ScalingPolicyId.init;
    return changed(b, actor, "binding.policyDetached", Json(["policy": Json(old)]));
  }

  AppBinding suspend(TenantId t, AppBindingId id, UserId actor) {
    auto b = get(t, id);
    if (b.status == BindingStatus.suspended)
      throw AasException.ruleViolation("Autoscaling of '" ~ b.name ~ "' is already suspended");
    b.status = BindingStatus.suspended;
    return changed(b, actor, "binding.suspended");
  }

  AppBinding resume(TenantId t, AppBindingId id, UserId actor) {
    auto b = get(t, id);
    if (b.status == BindingStatus.active)
      throw AasException.ruleViolation("Autoscaling of '" ~ b.name ~ "' is not suspended");
    b.status = BindingStatus.active;
    return changed(b, actor, "binding.resumed");
  }

  protected AppBinding changed(AppBinding b, UserId actor, string event, Json data = Json.emptyObject) {
    b.validate();
    stampUpdated(b, actor, now);
    repos.bindings.save(b);
    emit(event, b.tenantId, b.id.value, data);
    return b;
  }
}
