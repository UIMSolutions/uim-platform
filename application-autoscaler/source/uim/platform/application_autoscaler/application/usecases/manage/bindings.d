/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_autoscaler.application.usecases.manage.bindings;

import uim.platform.application_autoscaler;

// mixin(ShowModule!());

@safe:

class ManageAppBindingsUseCase {
  private AppBindingRepository repo;

  this(AppBindingRepository repo) {
    this.repo = repo;
  }

  CommandResult createBinding(CreateAppBindingRequest r) {
    
    
    import std.random : uniform;

    auto id  = "bind-" ~ currentTimestamp.to!string ~ "-" ~ uniform(1000, 9999).to!string;

    AppBinding binding;
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
    auto existing = repo.findById(r.tenamtId, r.bindingId);
    if (existing.isNull)
      return CommandResult(false, "", "Binding not found");

    
    existing.currentInstances = r.currentInstances;
    existing.updatedAt        = currentTimestamp;

    repo.update(existing);
    return CommandResult(true, existing.id.value, "");
  }

  CommandResult deleteBinding(TenantId tenantId, AppBindingId id) {
    auto existing = repo.findById(tenantId, id);
    if (existing.isNull)
      return CommandResult(false, "", "Binding not found");

    repo.remove(existing);
    return CommandResult(true, existing.id.value, "");
  }

  CommandResult attachPolicy(TenantId tenantId, AppBindingId bindingId, ScalingPolicyId policyId) {
    auto existing = repo.findById(tenantId, bindingId);
    if (existing.isNull)
      return CommandResult(false, "", "Binding not found");

    
    existing.policyId   = policyId;
    existing.updatedAt  = currentTimestamp;

    repo.update(existing);
    return CommandResult(true, existing.id.value, "");
  }

  AppBinding getBinding(TenantId tenantId, AppBindingId id) {
    return repo.findById(tenantId, id);
  }

  AppBinding[] listBindings(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }
}
