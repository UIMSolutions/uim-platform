/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.domain.ports.resource_group_repository;

import uim.platform.ai_launchpad.domain.types;
import uim.platform.ai_launchpad.domain.entities.resource_group : ResourceGroup;

interface IResourceGroupRepository {
  void save(ResourceGroup rg);
  ResourceGroup findById(ResourceGroupId id, ConnectionId connectionId);
  ResourceGroup[] findByConnection(ConnectionId connectionId);
  ResourceGroup[] findAll();
  void remove(ResourceGroupId id, ConnectionId connectionId);
}
