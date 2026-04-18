/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.domain.ports.repositories.pipelines;

// import uim.platform.logging.domain.entities.pipeline;
// import uim.platform.logging.domain.types;
import uim.platform.logging;

mixin(ShowModule!());

@safe:
interface PipelineRepository : ITenantRepository!(Pipeline, PipelineId) {
  bool existsById(PipelineId id);
  Pipeline findById(PipelineId id);

  Pipeline[] findAll(TenantId tenantId);
  Pipeline[] findActive(TenantId tenantId);
  Pipeline[] findBySource(TenantId tenantId, PipelineSourceType sourceType);

  void save(Pipeline a);
  void save(TenantId tenantId, Pipeline a);

  void update(Pipeline a);
  void update(TenantId tenantId, Pipeline a);
}
