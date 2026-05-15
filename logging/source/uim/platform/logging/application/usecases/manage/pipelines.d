/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.application.usecases.manage.pipelines;
// import uim.platform.logging.domain.entities.pipeline;
// import uim.platform.logging.domain.ports.repositories.pipelines;
// import uim.platform.logging.domain.types;
// import uim.platform.logging.application.dto;

import uim.platform.logging;

mixin(ShowModule!());

@safe:
class ManagePipelinesUseCase { // TODO: UIMUseCase {
  private PipelineRepository repo;

  this(PipelineRepository repo) {
    this.repo = repo;
  }

  CommandResult createPipeline(CreatePipelineRequest req) {
    import std.uuid : randomUUID;

    if (req.name.length == 0)
      return CommandResult(false, "", "Pipeline name is required");

    Pipeline p;
    p.initEntity(req.tenantId, req.createdBy);
    p.name = req.name;
    p.description = req.description;
    p.sourceType = req.sourceType.to!PipelineSourceType;
    p.format = req.format.to!PipelineFormat;
    p.targetStreamId = req.targetStreamId;
    p.isActive = true;

    foreach (proc; req.processors) {
      PipelineProcessor pp;
      pp.type = proc.type.to!ProcessorType;
      pp.name = proc.name;
      pp.config = proc.config;
      pp.order_ = proc.order_;
      p.processors ~= pp;
    }

    repo.save(p);
    return CommandResult(true, p.id.value, "");
  }

  CommandResult updatePipeline(UpdatePipelineRequest req) {
    auto p = repo.findById(req.tenantId, req.pipelineId);
    if (p.isNull)
      return CommandResult(false, "", "Pipeline not found");

    if (req.description.length > 0)
      p.description = req.description;
    if (req.format.length > 0)
      p.format = req.format.to!PipelineFormat;
    if (req.targetStreamId.value.length > 0)
      p.targetStreamId = req.targetStreamId;
    p.isActive = req.isActive;
    p.updatedAt = clockSeconds();

    if (req.processors.length > 0) {
      p.processors = [];
      foreach (proc; req.processors) {
        PipelineProcessor pp;
        pp.type = proc.type.to!ProcessorType;
        pp.name = proc.name;
        pp.config = proc.config;
        pp.order_ = proc.order_;
        p.processors ~= pp;
      }
    }

    repo.update(p);
    return CommandResult(true, p.id.value, "");
  }

  bool hasPipeline(TenantId tenantId, PipelineId id) {
    return repo.existsById(tenantId, id);
  }

  Pipeline getPipeline(TenantId tenantId, PipelineId id) {
    return repo.findById(tenantId, id);
  }

  Pipeline[] listPipelines(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  Pipeline[] listActivePipelines(TenantId tenantId) {
    return repo.findActive(tenantId);
  }

  CommandResult deletePipeline(TenantId tenantId, PipelineId id) {
    auto p = repo.findById(tenantId, id);
    if (p.isNull)
      return CommandResult(false, "", "Pipeline not found");

    repo.remove(p);
    return CommandResult(true, p.id.value, "");
  }

}
