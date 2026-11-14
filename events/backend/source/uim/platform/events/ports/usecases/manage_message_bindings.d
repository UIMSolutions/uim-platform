/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.ports.usecases.manage_message_bindings;

import uim.platform.events;

mixin(ShowModule!());

@safe:

interface IManageMessageBindings {
  MessageBinding[] listMessageBindings(TenantId tenantId);
  MessageBinding getMessageBinding(TenantId tenantId, MessageBindingId id);
  MessageBinding createMessageBinding(CreateMessageBindingRequest request);
  MessageBinding updateMessageBinding(UpdateMessageBindingRequest request);
  /// Revokes the access of the client.
  void deleteMessageBinding(TenantId tenantId, MessageBindingId id);
}
