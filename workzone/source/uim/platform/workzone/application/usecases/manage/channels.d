/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.application.usecases.manage.channels;


// import uim.platform.workzone.domain.types;
// import uim.platform.workzone.domain.entities.channel;
// import uim.platform.workzone.domain.ports.repositories.channels;
// import uim.platform.workzone.application.dto;
import uim.platform.workzone;

// mixin(ShowModule!());

@safe:
class ManageChannelsUseCase { // TODO: UIMUseCase {
  private ChannelRepository repo;

  this(ChannelRepository repo) {
    this.repo = repo;
  }

  CommandResult createChannel(CreateChannelRequest req) {
    if (req.name.length == 0)
      return CommandResult(false, "", "Channel name is required");

    Channel ch;
    ch.initEntity(req.tenantId);

    ch.workspaceId = req.workspaceId;
    ch.name = req.name;
    ch.description = req.description;
    ch.channelType = req.channelType;
    ch.config = req.config;

    repo.save(ch);
    return CommandResult(true, ch.id.value, "");
  }

  Channel getChannel(TenantId tenantId, ChannelId id) {
    return repo.find(tenantId, id);
  }

  Channel[] listByWorkspace(TenantId tenantId, WorkspaceId workspaceId) {
    return repo.findByWorkspace(tenantId, workspaceId);
  }

  CommandResult updateChannel(UpdateChannelRequest req) {
    auto ch = repo.findById(req.tenantId, req.id);
    if (ch.isNull)
      return CommandResult(false, "", "Channel not found");

    if (req.name.length > 0)
      ch.name = req.name;
    if (req.description.length > 0)
      ch.description = req.description;
    ch.active = req.active;
    ch.config = req.config;
    ch.updatedAt = currentTimestamp();

    repo.update(ch);
    return CommandResult(true, ch.id.value, "");
  }

  CommandResult deleteChannel(TenantId tenantId, ChannelId id) {
    auto entity = repo.find(tenantId, id);
    if (entity.isNull)
      return CommandResult(false, "", "Channel not found");

    repo.remove(entity);
    return CommandResult(true, entity.id.value, "");
  }
}
