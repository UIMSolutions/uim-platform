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

    auto id  = "bind-" ~ currentTimestamp.to!string ~ "-" ~ uniform(1000, 9999).to!string;

    AppBindingEntity binding;
    binding.initEntity(r.tenantId);
    binding.id                = id;
    binding.appGuid           = r.appGuid;
    binding.appName           = r.appName;
    binding.serviceInstanceId = r.serviceInstanceId;
    binding.policyId          = "";
    binding.currentInstances  = 1;
    binding.boundAt           = binding.createdAt;

    repo.save(binding);
    return CommandResult(true, binding.id.value, "");
  }

  CommandResult updateBinding(UpdateAppBindingRequest r) {
    if (!repo.existsById(r.id))
      return CommandResult(false, "", "Binding not found");

    import core.time : MonoTime;
    auto existing = repo.findById(r.id);
    existing.currentInstances = r.currentInstances;
    existing.updatedAt        = currentTimestamp;
    repo.update(existing);
    return CommandResult(true, existing.id.value, "");
  }

  CommandResult deleteBinding(TenantId tenantId, AppBindingId id) {
    if (!repo.existsById(id))
      return CommandResult(false, "", "Binding not found");
    auto existing = repo.findById(id);

    repo.remove(existing);
    return CommandResult(true, existing.id.value, "");
  }

  CommandResult attachPolicy(TenantId tenantId, AppBindingId bindingId, PolicyId policyId) {
    if (!repo.existsById(bindingId))
      return CommandResult(false, "", "Binding not found");

    import core.time : MonoTime;
    auto existing = repo.findById(bindingId);
    existing.policyId   = policyId;
    existing.updatedAt  = currentTimestamp;

    repo.update(existing);
    return CommandResult(true, existing.id.value, "");
  }

  AppBindingEntity getBinding(TenantId tenantId, AppBindingId id) {
    return repo.findById(id);
  }

  AppBindingEntity[] listBindings(TenantId tenantId) {
    return repo.findByTenantId(tenantId);
  }
}
