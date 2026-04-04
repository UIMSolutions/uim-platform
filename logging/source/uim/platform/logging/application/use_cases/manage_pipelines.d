/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.application.usecases.manage.pipelines;

import uim.platform.logging.domain.entities.pipeline;
import uim.platform.logging.domain.ports.pipeline_repository;
import uim.platform.logging.domain.types;
import uim.platform.logging.application.dto;

import std.conv : to;

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
    p.id = randomUUID().to!string;
    p.tenantId = req.tenantId;
    p.name = req.name;
    p.description = req.description;
    p.sourceType = parseSourceType(req.sourceType);
    p.format = parseFormat(req.format);
    p.targetStreamId = req.targetStreamId;
    p.isActive = true;
    p.createdBy = req.createdBy;
    p.createdAt = clockSeconds();

    foreach (ref proc; req.processors) {
      PipelineProcessor pp;
      pp.type = parseProcessorType(proc.type);
      pp.name = proc.name;
      pp.config = proc.config;
      pp.order_ = proc.order_;
      p.processors ~= pp;
    }

    repo.save(p);
    return CommandResult(true, p.id, "");
  }

  CommandResult update(PipelineId id, UpdatePipelineRequest req) {
    auto p = repo.findById(id);
    if (p.id.length == 0)
      return CommandResult(false, "", "Pipeline not found");

    if (req.description.length > 0)
      p.description = req.description;
    if (req.format.length > 0)
      p.format = parseFormat(req.format);
    if (req.targetStreamId.length > 0)
      p.targetStreamId = req.targetStreamId;
    p.isActive = req.isActive;
    p.updatedAt = clockSeconds();

    if (req.processors.length > 0) {
      p.processors = [];
      foreach (ref proc; req.processors) {
        PipelineProcessor pp;
        pp.type = parseProcessorType(proc.type);
        pp.name = proc.name;
        pp.config = proc.config;
        pp.order_ = proc.order_;
        p.processors ~= pp;
      }
    }

    repo.update(p);
    return CommandResult(true, id, "");
  }

  Pipeline get_(PipelineId id) {
    return repo.findById(id);
  }

  Pipeline[] list(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  Pipeline[] listActive(TenantId tenantId) {
    return repo.findActive(tenantId);
  }

  CommandResult remove(PipelineId id) {
    repo.remove(id);
    return CommandResult(true, id, "");
  }

  private static PipelineSourceType parseSourceType(string s) {
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

  private static long clockSeconds() {
    import core.time : MonoTime;

    return MonoTime.currTime.ticks / MonoTime.ticksPerSecond;
  }
}
