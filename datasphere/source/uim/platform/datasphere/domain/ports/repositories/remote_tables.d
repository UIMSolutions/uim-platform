/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.domain.ports.repositories.remote_tables;

import uim.platform.datasphere.domain.types;
import uim.platform.datasphere.domain.entities.remote_table;

interface RemoteTableRepository {
  RemoteTable findById(RemoteTableId id, SpaceId spaceId);
  RemoteTable[] findBySpace(SpaceId spaceId);
  RemoteTable[] findByConnection(ConnectionId connId, SpaceId spaceId);
  void save(RemoteTable rt);
  void update(RemoteTable rt);
  void remove(RemoteTableId id, SpaceId spaceId);
  long countBySpace(SpaceId spaceId);
}
