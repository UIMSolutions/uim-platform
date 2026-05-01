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
interface DataFlowRepository {
  DataFlow findById(SpaceId spaceId, DataFlowId id);
  DataFlow[] findBySpace(SpaceId spaceId);
  DataFlow[] findByStatus(SpaceId spaceId, FlowStatus status);
  void save(DataFlow df);
  void update(DataFlow df);
  void remove(SpaceId spaceId, DataFlowId id);
  size_t countBySpace(SpaceId spaceId);
}
