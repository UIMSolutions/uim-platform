/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.domain.ports.repositories.spaces;

import uim.platform.datasphere.domain.types;
import uim.platform.datasphere.domain.entities.space;

interface SpaceRepository {
  Space findById(SpaceId id);
  Space[] findByTenant(TenantId tenantId);
  void save(Space s);
  void update(Space s);
  void remove(SpaceId id);
  long countByTenant(TenantId tenantId);
}
