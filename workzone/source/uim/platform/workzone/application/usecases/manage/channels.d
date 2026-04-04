/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.application.usecases.manage.channels;

// import std.uuid;
// import std.datetime.systime : Clock;

import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.channel;
import uim.platform.workzone.domain.ports.repositories.channels;
import uim.platform.workzone.application.dto;

class ManageChannelsUseCase
{
  private ChannelRepository repo;

  this(ChannelRepository repo)
  {
    this.repo = repo;
  }

  CommandResult createChannel(CreateChannelRequest req)
  {
    if (req.name.length == 0)
      return CommandResult("", "Channel name is required");

    auto now = Clock.currStdTime();
    auto ch = Channel();
    ch.id = randomUUID().toString();
    ch.workspaceId = req.workspaceId;
    ch.tenantId = req.tenantId;
    ch.name = req.name;
    ch.description = req.description;
    ch.channelType = req.channelType;
    ch.config = req.config;
    ch.createdAt = now;
    ch.updatedAt = now;

    repo.save(ch);
    return CommandResult(ch.id, "");
  }

  Channel* getChannel(ChannelId id, TenantId tenantId)
  {
    return repo.findById(id, tenantId);
  }

  Channel[] listByWorkspace(WorkspaceId workspaceId, TenantId tenantId)
  {
    return repo.findByWorkspace(workspaceId, tenantId);
  }

  CommandResult updateChannel(UpdateChannelRequest req)
  {
    auto ch = repo.findById(req.id, req.tenantId);
    if (ch is null)
      return CommandResult("", "Channel not found");

    if (req.name.length > 0)
      ch.name = req.name;
    if (req.description.length > 0)
      ch.description = req.description;
    ch.active = req.active;
    ch.config = req.config;
    ch.updatedAt = Clock.currStdTime();

    repo.update(*ch);
    return CommandResult(ch.id, "");
  }

  void deleteChannel(ChannelId id, TenantId tenantId)
  {
    repo.remove(id, tenantId);
  }
}
