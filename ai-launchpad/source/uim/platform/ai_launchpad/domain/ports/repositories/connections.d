/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.domain.ports.repositories.connections;

import uim.platform.ai_launchpad.domain.types;
import uim.platform.ai_launchpad.domain.entities.connection : Connection;

interface IConnectionRepository {
  bool existsById(ConnectionId id);
  Connection findById(ConnectionId id);
  
  Connection[] findByWorkspace(WorkspaceId workspaceId);
  Connection[] findAll();

  void save(Connection c);
  void remove(ConnectionId id);
}
