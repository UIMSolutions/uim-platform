/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.buildcode.application.usecases.manage.devspaces;

import uim.platform.buildcode;


mixin(ShowModule!());

@safe:

class ManageDevSpacesUseCase {
  private DevSpaceRepository  _repo;
  private QuotaService        _quota;

  this(DevSpaceRepository repo) {
    _repo  = repo;
    _quota = QuotaService();
  }

  CommandResult create(TenantId tenantId, CreateDevSpaceRequest req) {
    auto existing = _repo.findByProject(tenantId, req.projectId);
    auto qerr = _quota.checkDevSpaceQuota(existing.length);
    if (qerr !is null) return CommandResult(false, "", qerr);

    auto ds = DevSpace(tenantId); // , DevSpaceId(createId), req.createdBy);
    ds.projectId     = ProjectId(req.projectId);
    ds.name          = req.name;
    ds.displayName   = req.displayName;
    ds.status        = DevSpaceStatus.stopped;
    ds.technicalUser = req.technicalUser;
    ds.storageGiB    = req.storageGiB > 0 ? req.storageGiB : 4;
    ds.ramGiB        = req.ramGiB    > 0 ? req.ramGiB    : 4;

    _repo.save(ds);
    return CommandResult(true, ds.id.value, "");
  }

  DevSpace getById(TenantId tenantId, string id) {
    return _repo.findById(tenantId, DevSpaceId(id));
  }

  DevSpace[] listByProject(TenantId tenantId, string projectId) {
    return _repo.findByProject(tenantId, projectId);
  }

  DevSpace[] list(TenantId tenantId) {
    return _repo.findByTenant(tenantId);
  }

  CommandResult setStatus(TenantId tenantId, string id, string statusStr) {
    auto ds = _repo.findById(tenantId, DevSpaceId(id));
    if (ds.isNull) return CommandResult(false, "", "Dev space not found");
    DevSpaceStatus st = DevSpaceStatus.stopped;
    static foreach (member; __traits(allMembers, DevSpaceStatus)) {
      if (statusStr == mixin("DevSpaceStatus." ~ member ~ ".to!string"))
        st = mixin("DevSpaceStatus." ~ member);
    }
    ds.status = st;
    _repo.update(ds);
    return CommandResult(true, id, "");
  }

  CommandResult remove(TenantId tenantId, string id) {
    auto ds = _repo.findById(tenantId, DevSpaceId(id));
    if (ds.isNull) return CommandResult(false, "", "Dev space not found");
    _repo.remove(tenantId, DevSpaceId(id));
    return CommandResult(true, id, "");
  }
}
