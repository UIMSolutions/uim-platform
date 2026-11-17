/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.application.usecases.manage.channels;

import uim.platform.workzone;

mixin(ShowModule!());

@safe:

/// Interactor: workspace channels. External channels need an http(s) source.
class ManageChannelsUseCase
  : ResourceUseCase!(WorkspaceChannel, ChannelId, CreateChannelRequest, UpdateChannelRequest),
  IManageChannelsUseCase {

  this(WorkzoneRepositories repos, IWorkzoneEventPublisher publisher) {
    super(repos, repos.channels, publisher, "Channel", "workzone.channel");
  }

  override protected WorkspaceChannel build(CreateChannelRequest r) {
    auto ws = requireWorkspace(r.tenantId, r.parentId, "channels");
    auto c = WorkspaceChannel(r.tenantId);
    c.workspaceId = ws.id;
    c.workspaceName = ws.name;
    assignMatching(c, r.spec);
    check(c);
    return c;
  }

  override protected void apply(ref WorkspaceChannel c, ChannelSpec spec) {
    assignMatching(c, spec);
    check(c);
  }

  protected void check(ref WorkspaceChannel c) {
    c.name = c.name.strip;
    validateDisplayName("Channel name", c.name, 80);
    ensureUniqueInWorkspace(c, c.workspaceName);
    if (c.channelType == ChannelType.external)
      validate(isHttpUrl(c.sourceUrl), "External channel '" ~ c.name ~ "' needs an http(s) source URL");
    else
      validateOptionalUrl("Source URL", c.sourceUrl);
    validate(c.pollIntervalSec >= 60, "Poll interval must be at least 60 seconds");
    validate(c.maxItems > 0 && c.maxItems <= 200, "Max items must be between 1 and 200");
    c.allowedRoles = requireRoles(c.tenantId, c.allowedRoles);
  }

  UsecaseResult activate(TenantId tenantId, ChannelId id, UserId actor) {
    return transition(tenantId, id, actor, "activated", (ref WorkspaceChannel c) {
      ensureState(!c.active, "Channel '" ~ c.name ~ "' is already active");
      c.active = true;
    });
  }

  UsecaseResult deactivate(TenantId tenantId, ChannelId id, UserId actor) {
    return transition(tenantId, id, actor, "deactivated", (ref WorkspaceChannel c) {
      ensureState(c.active, "Channel '" ~ c.name ~ "' is already inactive");
      c.active = false;
    });
  }
}
