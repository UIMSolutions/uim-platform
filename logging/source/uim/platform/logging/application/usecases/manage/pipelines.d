/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.application.usecases.manage.pipelines;
// import uim.platform.logging.domain.entities.pipeline;
// import uim.platform.logging.domain.ports.repositories.pipelines;



import std.conv : ConvException, to;
import std.string : toLower;
import uim.platform.logging;

mixin(ShowModule!());

@safe:
class ManagePipelinesUseCase { // TODO: UIMUseCase {
  private PipelineRepository repo;

  private bool tryParseSourceType(string raw, out PipelineSourceType sourceType) {
    auto normalized = raw.toLower;
    if (normalized == "app" || normalized == "application")
      normalized = "custom";
    if (normalized == "cf")
      normalized = "cloudFoundry";
    if (normalized == "cloudfoundry" || normalized == "cloud_foundry")
      normalized = "cloudFoundry";
    if (normalized == "k8s")
      normalized = "kubernetes";

    try {
      sourceType = normalized.to!PipelineSourceType;
      return true;
    } catch (ConvException) {
      return false;
    }
  }

  private bool tryParseFormat(string raw, out PipelineFormat format) {
    auto normalized = raw.toLower;
    if (normalized == "text")
      normalized = "plaintext";

    try {
      format = normalized.to!PipelineFormat;
      return true;
    } catch (ConvException) {
      return false;
    }
  }

  private bool tryParseProcessorType(string raw, out ProcessorType processorType) {
    try {
      processorType = raw.toLower.to!ProcessorType;
      return true;
    } catch (ConvException) {
      return false;
    }
  }

  this(PipelineRepository repo) {
    this.repo = repo;
  }

  CommandResult createPipeline(CreatePipelineRequest req) {
    if (req.name.length == 0)
      return CommandResult(false, "", "Pipeline name is required");

    PipelineSourceType sourceType;
    if (!tryParseSourceType(req.sourceType, sourceType))
      return CommandResult(false, "", "Invalid pipeline source type: " ~ req.sourceType);

    PipelineFormat format;
    if (!tryParseFormat(req.format, format))
      return CommandResult(false, "", "Invalid pipeline format: " ~ req.format);

    Pipeline p;
    p.initEntity(req.tenantId, req.createdBy);
    p.name = req.name;
    p.description = req.description;
    p.sourceType = sourceType;
    p.format = format;
    p.targetStreamId = req.targetStreamId;
    p.isActive = true;

    foreach (index, proc; req.processors) {
      ProcessorType processorType;
      if (!tryParseProcessorType(proc.type, processorType))
        return CommandResult(false, "", "Invalid processor type at index " ~ index.to!string ~ ": " ~ proc.type);

      PipelineProcessor pp;
      pp.type = processorType;
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
    if (req.format.length > 0) {
      PipelineFormat format;
      if (!tryParseFormat(req.format, format))
        return CommandResult(false, "", "Invalid pipeline format: " ~ req.format);
      p.format = format;
    }
    if (req.targetStreamId.value.length > 0)
      p.targetStreamId = req.targetStreamId;
    p.isActive = req.isActive;
    p.updatedAt = clockSeconds();

    if (req.processors.length > 0) {
      p.processors = [];
      foreach (index, proc; req.processors) {
        ProcessorType processorType;
        if (!tryParseProcessorType(proc.type, processorType))
          return CommandResult(false, "", "Invalid processor type at index " ~ index.to!string ~ ": " ~ proc.type);

        PipelineProcessor pp;
        pp.type = processorType;
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
