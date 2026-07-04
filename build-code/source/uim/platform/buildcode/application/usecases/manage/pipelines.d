/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.buildcode.application.usecases.manage.pipelines;

import uim.platform.buildcode;


mixin(ShowModule!());

@safe:

class ManagePipelinesUseCase {
  private PipelineRepository  _repo;
  private QuotaService        _quota;

  this(PipelineRepository repo) {
    _repo  = repo;
    _quota = QuotaService();
  }

  CommandResult create(TenantId tenantId, CreatePipelineRequest req) {
    auto existing = _repo.findByProject(tenantId, req.projectId);
    auto qerr = _quota.checkPipelineQuota(existing.length);
    if (qerr !is null) return CommandResult(false, "", qerr);

    PipelineStage stage = PipelineStage.full;
    static foreach (member; __traits(allMembers, PipelineStage)) {
      if (req.stage == mixin("PipelineStage." ~ member ~ ".to!string"))
        stage = mixin("PipelineStage." ~ member);
    }

    Pipeline p;
    p.initEntity(tenantId);
    p.projectId      = ProjectId(req.projectId);
    p.name           = req.name;
    p.description    = req.description;
    p.stage          = stage;
    p.repositoryUrl  = req.repositoryUrl;
    p.branch         = req.branch.length > 0 ? req.branch : "main";
    p.configFilePath = req.configFilePath;
    p.isActive       = true;
    p.triggerType    = req.triggerType.length > 0 ? req.triggerType : "manual";
    p.schedule       = req.schedule;

    _repo.save(p);
    return CommandResult(true, p.id.value, "");
  }

  Pipeline getById(TenantId tenantId, string id) {
    return _repo.findById(tenantId, PipelineId(id));
  }

  Pipeline[] list(TenantId tenantId) {
    return _repo.findByTenant(tenantId);
  }

  Pipeline[] listByProject(TenantId tenantId, string projectId) {
    return _repo.findByProject(tenantId, projectId);
  }

  CommandResult update(TenantId tenantId, string id, UpdatePipelineRequest req) {
    auto p = _repo.findById(tenantId, PipelineId(id));
    if (p.isNull) return CommandResult(false, "", "Pipeline not found");
    if (req.description.length > 0)    p.description    = req.description;
    if (req.branch.length > 0)         p.branch         = req.branch;
    if (req.configFilePath.length > 0) p.configFilePath = req.configFilePath;
    if (req.triggerType.length > 0)    p.triggerType    = req.triggerType;
    if (req.schedule.length > 0)       p.schedule       = req.schedule;
    p.isActive = req.isActive;
    _repo.update(p);
    return CommandResult(true, id, "");
  }

  CommandResult remove(TenantId tenantId, string id) {
    auto p = _repo.findById(tenantId, PipelineId(id));
    if (p.isNull) return CommandResult(false, "", "Pipeline not found");
    _repo.remove(tenantId, PipelineId(id));
    return CommandResult(true, id, "");
  }
}
