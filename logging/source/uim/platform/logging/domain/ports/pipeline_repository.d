/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.domain.ports.repositories.pipelines;

import uim.platform.logging.domain.entities.pipeline;
import uim.platform.logging.domain.types;

interface PipelineRepository {
  Pipeline findById(PipelineId id);
  Pipeline[] findByTenant(TenantId tenantId);
  Pipeline[] findActive(TenantId tenantId);
  Pipeline[] findBySource(TenantId tenantId, PipelineSourceType sourceType);
  void save(Pipeline p);
  void update(Pipeline p);
  void remove(PipelineId id);
}
