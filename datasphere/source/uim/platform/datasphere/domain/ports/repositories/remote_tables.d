/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.domain.ports.repositories.remote_tables;

// import uim.platform.datasphere.domain.types;
// import uim.platform.datasphere.domain.entities.remote_table;
import uim.platform.datasphere;

mixin(ShowModule!()); 

@safe:
interface RemoteTableRepository {
  RemoteTable findById(SpaceId spaceId, RemoteTableId id);
  RemoteTable[] findBySpace(SpaceId spaceId);
  RemoteTable[] findByConnection(SpaceId spaceId, ConnectionId connId);
  void save(RemoteTable rt);
  void update(RemoteTable rt);
  void remove(SpaceId spaceId, RemoteTableId id);
  size_t countBySpace(SpaceId spaceId);
}
