/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_autoscaler.application.usecases.manage.bindings;

import uim.platform.application_autoscaler;

mixin(ShowModule!());

@safe:

class ManageAppBindingsUseCase {
  private AppBindingRepository repo;

  this(AppBindingRepository repo) {
    this.repo = repo;
  }

  CommandResult createBinding(CreateAppBindingRequest r) {
    import core.time : MonoTime;
    import std.conv : to;
    import std.random : uniform;

    auto id  = "bind-" ~ MonoTime.currTime.ticks.to!string ~ "-" ~ uniform(1000, 9999).to!string;
    auto now = MonoTime.currTime.ticks;

    AppBindingEntity binding;
    binding.id                = id;
    binding.tenantId          = r.tenantId;
    binding.appGuid           = r.appGuid;
    binding.appName           = r.appName;
    binding.serviceInstanceId = r.serviceInstanceId;
    binding.policyId          = "";
    binding.currentInstances  = 1;
    binding.boundAt           = now;
    binding.updatedAt         = now;

    repo.save(binding);
    return CommandResult(true, id, "");
  }

  CommandResult updateBinding(UpdateAppBindingRequest r) {
    if (!repo.existsById(r.id))
      return CommandResult(false, "", "Binding not found");

    import core.time : MonoTime;
    auto existing = repo.findById(r.id);
    existing.currentInstances = r.currentInstances;
    existing.updatedAt        = MonoTime.currTime.ticks;
    repo.update(existing);
    return CommandResult(true, r.id, "");
  }

  CommandResult deleteBinding(AppBindingId id) {
    if (!repo.existsById(id))
      return CommandResult(false, "", "Binding not found");
    repo.remove(id);
    return CommandResult(true, id, "");
  }

  CommandResult attachPolicy(AppBindingId bindingId, PolicyId policyId) {
    if (!repo.existsById(bindingId))
      return CommandResult(false, "", "Binding not found");

    import core.time : MonoTime;
    auto existing = repo.findById(bindingId);
    existing.policyId   = policyId;
    existing.updatedAt  = MonoTime.currTime.ticks;
    repo.update(existing);
    return CommandResult(true, bindingId, "");
  }

  AppBindingEntity getBinding(AppBindingId id) {
    return repo.findById(id);
  }

  AppBindingEntity[] listBindings(TenantId tenantId) {
    return repo.findByTenantId(tenantId);
  }
}
