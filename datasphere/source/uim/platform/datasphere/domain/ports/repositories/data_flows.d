/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.domain.ports.repositories.data_flows;
// import uim.platform.datasphere.domain.types;
// import uim.platform.datasphere.domain.entities.data_flow;
import uim.platform.datasphere;

mixin(ShowModule!()); 

@safe:
interface DataFlowRepository : ITenantRepository!(DataFlow, DataFlowId) {

  bool existsById(TenantId tenantId, SpaceId spaceId, DataFlowId id);
  DataFlow findById(TenantId tenantId, SpaceId spaceId, DataFlowId id);
  void removeById(TenantId tenantId, SpaceId spaceId, DataFlowId id);

  size_t countBySpace(TenantId tenantId, SpaceId spaceId);
  DataFlow[] findBySpace(TenantId tenantId, SpaceId spaceId);
  void removeBySpace(TenantId tenantId, SpaceId spaceId);

  size_t countByStatus(TenantId tenantId, SpaceId spaceId, FlowStatus status);
  DataFlow[] findByStatus(TenantId tenantId, SpaceId spaceId, FlowStatus status);
  void removeByStatus(TenantId tenantId, SpaceId spaceId, FlowStatus status);
  
}
