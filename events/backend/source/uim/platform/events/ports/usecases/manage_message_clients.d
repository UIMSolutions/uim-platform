/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.ports.usecases.manage_message_clients;

import uim.platform.events;

mixin(ShowModule!());

@safe:

interface IManageMessageClients {
  MessageClient[] listMessageClients(TenantId tenantId);
  MessageClient getMessageClient(TenantId tenantId, MessageClientId id);
  MessageClient createMessageClient(CreateMessageClientRequest request);
  MessageClient updateMessageClient(UpdateMessageClientRequest request);
  /// Also removes the bindings of the client.
  void deleteMessageClient(TenantId tenantId, MessageClientId id);
}
