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

// import std.conv : to;
import uim.platform.logging;

mixin(ShowModule!());

@safe:
class ManagePipelinesUseCase : UIMUseCase {
  private PipelineRepository repo;

  this(PipelineRepository repo) {
    this.repo = repo;
  }

  CommandResult create(CreatePipelineRequest req) {
    import std.uuid : randomUUID;

    if (req.name.length == 0)
      return CommandResult(false, "", "Pipeline name is required");

    Pipeline p;
    p.id = randomUUID();
    p.tenantId = req.tenantId;
    p.name = req.name;
    p.description = req.description;
    p.sourceType = toLogSourceType(req.sourceType);
    p.format = parseFormat(req.format);
    p.targetStreamId = req.targetStreamId;
    p.isActive = true;
    p.createdBy = req.createdBy;
    p.createdAt = clockSeconds();

    foreach (proc; req.processors) {
      PipelineProcessor pp;
      pp.type = parseProcessorType(proc.type);
      pp.name = proc.name;
      pp.config = proc.config;
      pp.order_ = proc.order_;
      p.processors ~= pp;
    }

    repo.save(p);
    return CommandResult(true, p.id.value, "");
  }

  CommandResult update(string id, UpdatePipelineRequest req) {
    return update(PipelineId(id), req);
  }

  CommandResult update(PipelineId id, UpdatePipelineRequest req) {
    auto p = repo.findById(id);
    if (p.id.isEmpty)
      return CommandResult(false, "", "Pipeline not found");

    if (req.description.length > 0)
      p.description = req.description;
    if (req.format.length > 0)
      p.format = parseFormat(req.format);
    if (req.targetStreamId.value.length > 0)
      p.targetStreamId = req.targetStreamId;
    p.isActive = req.isActive;
    p.updatedAt = clockSeconds();

    if (req.processors.length > 0) {
      p.processors = [];
      foreach (proc; req.processors) {
        PipelineProcessor pp;
        pp.type = parseProcessorType(proc.type);
        pp.name = proc.name;
        pp.config = proc.config;
        pp.order_ = proc.order_;
        p.processors ~= pp;
      }
    }

    repo.update(p);
    return CommandResult(true, id.value, "");
  }

  bool hasById(string id) {
    return hasById(PipelineId(id));
  }

  bool hasById(PipelineId id) {
    return repo.existsById(id);
  }

  Pipeline getById(string id) {
    return getById(PipelineId(id));
  }

  Pipeline getById(PipelineId id) {
    return repo.findById(id);
  }

  Pipeline[] list(string tenantId) {
    return list(TenantId(tenantId));
  }

  Pipeline[] list(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  Pipeline[] listActive(string tenantId) {
    return listActive(TenantId(tenantId));
  }

  Pipeline[] listActive(TenantId tenantId) {
    return repo.findActive(tenantId);
  }

  CommandResult remove(string id) {
    return remove(PipelineId(id));
  }

  CommandResult remove(PipelineId id) {
    repo.remove(id);
    return CommandResult(true, id.value, "");
  }

  private static PipelineSourceType toLogSourceType(string s) {
    switch (s) {
    case "cloudFoundry":
      return PipelineSourceType.cloudFoundry;
    case "kyma":
      return PipelineSourceType.kyma;
    case "kubernetes":
      return PipelineSourceType.kubernetes;
    case "otel":
      return PipelineSourceType.otel;
    default:
      return PipelineSourceType.custom;
    }
  }

  private static PipelineFormat parseFormat(string s) {
    switch (s) {
    case "json":
      return PipelineFormat.json;
    case "otel":
      return PipelineFormat.otel;
    case "syslog":
      return PipelineFormat.syslog;
    case "plaintext":
      return PipelineFormat.plaintext;
    default:
      return PipelineFormat.json;
    }
  }

  private static ProcessorType parseProcessorType(string s) {
    switch (s) {
    case "filter":
      return ProcessorType.filter;
    case "transform":
      return ProcessorType.transform;
    case "enrich":
      return ProcessorType.enrich;
    case "sample":
      return ProcessorType.sample;
    case "redact":
      return ProcessorType.redact;
    default:
      return ProcessorType.filter;
    }
  }


}
