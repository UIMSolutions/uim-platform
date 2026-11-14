/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.application.usecases.manage_message_bindings;

import uim.platform.events;

mixin(ShowModule!());

@safe:

class ManageMessageBindingsUseCase : IManageMessageBindings {
  protected IMessageBindingRepository bindings;
  protected IMessageClientRepository clients;
  protected IQueueRepository queues;
  protected IEventChannelRepository channels;

  this(IMessageBindingRepository bindings, IMessageClientRepository clients, IQueueRepository queues,
    IEventChannelRepository channels) {
    this.bindings = bindings;
    this.clients = clients;
    this.queues = queues;
    this.channels = channels;
  }

  MessageBinding[] listMessageBindings(TenantId tenantId) {
    return bindings.findAll(tenantId);
  }

  MessageBinding getMessageBinding(TenantId tenantId, MessageBindingId id) {
    return bindings.findById(tenantId, id).required("Message binding '" ~ id.value ~ "'");
  }

  MessageBinding createMessageBinding(CreateMessageBindingRequest r) {
    auto client = clients.findById(r.tenantId, MessageClientId(r.clientId)).required("Message client '" ~ r.clientId ~ "'");
    MessageBinding b;
    stampCreated!(MessageBinding, MessageBindingId)(b, r.tenantId, r.actor, r.id);
    if (bindings.existsById(r.tenantId, b.id))
      throw EventsException.conflict("Message binding '" ~ b.id.value ~ "' already exists");
    b.clientId = client.id;
    b.serviceId = client.serviceId;
    b.queueId = QueueId(r.queueId.strip);
    b.channelId = EventChannelId(r.channelId.strip);
    b.description = r.description;
    b.permission = parseDomainEnumOr!MessageBindingPermission(r.permission, MessageBindingPermission.publishSubscribe,
      "permission");
    b.validate();

    string target;
    if (!b.queueId.isNull) {
      auto q = queues.findById(r.tenantId, b.queueId).required("Queue '" ~ b.queueId.value ~ "'");
      if (q.serviceId != client.serviceId)
        throw EventsException.invalid("Queue and client belong to different messaging services");
      target = q.name;
    } else {
      auto c = channels.findById(r.tenantId, b.channelId).required("Event channel '" ~ b.channelId.value ~ "'");
      if (c.serviceId != client.serviceId)
        throw EventsException.invalid("Event channel and client belong to different messaging services");
      target = c.name;
    }
    foreach (other; bindings.findByClient(r.tenantId, client.id))
      if (other.queueId == b.queueId && other.channelId == b.channelId)
        throw EventsException.conflict("Client '" ~ client.name ~ "' is already bound to '" ~ target ~ "'");
    b.name = r.name.strip.length > 0 ? r.name.strip : client.name ~ " → " ~ target;
    bindings.save(b);
    return b;
  }

  MessageBinding updateMessageBinding(UpdateMessageBindingRequest r) {
    auto b = getMessageBinding(r.tenantId, r.id);
    r.name.applyTo(b.name);
    r.description.applyTo(b.description);
    applyEnum(r.status, b.status, "status");
    applyEnum(r.permission, b.permission, "permission");
    b.validate();
    stampUpdated(b, r.actor);
    bindings.save(b);
    return b;
  }

  void deleteMessageBinding(TenantId tenantId, MessageBindingId id) {
    getMessageBinding(tenantId, id);
    bindings.removeById(tenantId, id);
  }
}
