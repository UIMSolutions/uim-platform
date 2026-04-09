/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.domain.ports.repositories.views;

import uim.platform.datasphere.domain.types;
import uim.platform.datasphere.domain.entities.view_;

interface ViewRepository {
  View findById(ViewId id, SpaceId spaceId);
  View[] findBySpace(SpaceId spaceId);
  View[] findBySemantic(ViewSemantic semantic, SpaceId spaceId);
  View[] findExposed(SpaceId spaceId);
  void save(View v);
  void update(View v);
  void remove(ViewId id, SpaceId spaceId);
  size_t countBySpace(SpaceId spaceId);
}
