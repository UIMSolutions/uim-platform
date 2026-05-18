/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.buildcode.application.usecases.manage.service_bindings;

import uim.platform.buildcode;
import std.conv : to;

mixin(ShowModule!());

@safe:

class ManageServiceBindingsUseCase {
  private ServiceBindingRepository  _repo;

  this(ServiceBindingRepository repo) { _repo = repo; }

  CommandResult create(string tenantId, CreateServiceBindingRequest req) {
    ServiceBinding sb;
    sb.initEntity(tenantId);
    sb.projectId    = ProjectId(req.projectId);
    sb.serviceName  = req.serviceName;
    sb.servicePlan  = req.servicePlan;
    sb.bindingLabel = req.bindingLabel;
    sb.instanceId   = req.instanceId;
    sb.status       = BindingStatus.active;

    _repo.save(sb);
    return CommandResult(true, sb.id.value, "");
  }

  ServiceBinding getById(string tenantId, string id) {
    return _repo.findById(tenantId, ServiceBindingId(id));
  }

  ServiceBinding[] list(string tenantId) {
    return _repo.findByTenant(tenantId);
  }

  ServiceBinding[] listByProject(string tenantId, string projectId) {
    return _repo.findByProject(tenantId, projectId);
  }

  CommandResult remove(string tenantId, string id) {
    auto sb = _repo.findById(tenantId, ServiceBindingId(id));
    if (sb.isNull) return CommandResult(false, "", "Service binding not found");
    _repo.remove(tenantId, ServiceBindingId(id));
    return CommandResult(true, id, "");
  }
}
