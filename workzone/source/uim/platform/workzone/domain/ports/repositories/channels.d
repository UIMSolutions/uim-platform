/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.ports.repositories.channels;

import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.channel;

interface ChannelRepository {
  Channel[] findByWorkspace(WorkspaceId workspaceId, TenantId tenantId);
  Channel* findById(ChannelId id, TenantId tenantId);
  void save(Channel channel);
  void update(Channel channel);
  void remove(ChannelId id, TenantId tenantId);
}
