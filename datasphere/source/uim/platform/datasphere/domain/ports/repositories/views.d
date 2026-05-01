/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.domain.ports.repositories.views;

// import uim.platform.datasphere.domain.types;
// import uim.platform.datasphere.domain.entities.view_;
import uim.platform.datasphere;

mixin(ShowModule!()); 

@safe:
interface ViewRepository {
  View findById(SpaceId spaceId, ViewId id);
  View[] findBySpace(SpaceId spaceId);
  View[] findBySemantic(SpaceId spaceId, ViewSemantic semantic);
  View[] findExposed(SpaceId spaceId);
  void save(View v);
  void update(View v);
  void remove(SpaceId spaceId, ViewId id);
  size_t countBySpace(SpaceId spaceId);
}
