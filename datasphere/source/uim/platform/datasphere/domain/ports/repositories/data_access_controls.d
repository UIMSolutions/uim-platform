/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.domain.ports.repositories.data_access_controls;

// import uim.platform.datasphere.domain.types;
// import uim.platform.datasphere.domain.entities.data_access_control;
import uim.platform.datasphere;

mixin(ShowModule!()); 

@safe:
interface DataAccessControlRepository {
  DataAccessControl findById(DataAccessControlId id, SpaceId spaceId);
  DataAccessControl[] findBySpace(SpaceId spaceId);
  DataAccessControl[] findByView(ViewId viewId, SpaceId spaceId);
  void save(DataAccessControl dac);
  void update(DataAccessControl dac);
  void remove(DataAccessControlId id, SpaceId spaceId);
  size_t countBySpace(SpaceId spaceId);
}
