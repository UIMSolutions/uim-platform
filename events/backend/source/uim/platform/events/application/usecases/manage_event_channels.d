/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.application.usecases.manage_event_channels;

import uim.platform.events;

mixin(ShowModule!());

@safe:

class ManageEventChannelsUseCase : IManageEventChannels {
  protected IEventChannelRepository channels;
  protected IMessagingServiceRepository services;
  protected IMessageBindingRepository bindings;

  this(IEventChannelRepository channels, IMessagingServiceRepository services, IMessageBindingRepository bindings) {
    this.channels = channels;
    this.services = services;
    this.bindings = bindings;
  }

  EventChannel[] listEventChannels(TenantId tenantId) {
    return channels.findAll(tenantId);
  }

  EventChannel getEventChannel(TenantId tenantId, EventChannelId id) {
    return channels.findById(tenantId, id).required("Event channel '" ~ id.value ~ "'");
  }

  EventChannel createEventChannel(CreateEventChannelRequest r) {
    auto service = services.findById(r.tenantId, MessagingServiceId(r.serviceId))
      .required("Messaging service '" ~ r.serviceId ~ "'");
    EventChannel c;
    stampCreated!(EventChannel, EventChannelId)(c, r.tenantId, r.actor, r.id);
    if (channels.existsById(r.tenantId, c.id))
      throw EventsException.conflict("Event channel '" ~ c.id.value ~ "' already exists");
    c.serviceId = service.id;
    c.name = r.name.strip;
    c.description = r.description;
    c.channelType = parseDomainEnumOr!EventChannelType(r.channelType, EventChannelType.topic, "channelType");
    c.topicName = r.topicName.strip.strip("/");
    c.asyncapiDefinition = r.asyncapiDefinition;
    c.retentionHours = r.retentionHours;
    c.partitions = r.partitions > 0 ? r.partitions : 1;
    c.validate();
    if (!isInNamespace(c.topicName, service.namespace))
      throw EventsException.invalid("Topic '" ~ c.topicName ~ "' is outside namespace '" ~ service.namespace ~ "'");
    auto other = channels.findByTopic(r.tenantId, service.id, c.topicName);
    if (!other.isNull)
      throw EventsException.conflict("Topic '" ~ c.topicName ~ "' already has channel '" ~ other.name ~ "'");
    channels.save(c);
    return c;
  }

  EventChannel updateEventChannel(UpdateEventChannelRequest r) {
    auto c = getEventChannel(r.tenantId, r.id);
    r.name.applyTo(c.name);
    r.description.applyTo(c.description);
    applyEnum(r.status, c.status, "status");
    applyEnum(r.channelType, c.channelType, "channelType");
    r.asyncapiDefinition.applyTo(c.asyncapiDefinition);
    r.retentionHours.applyTo(c.retentionHours);
    r.partitions.applyTo(c.partitions);
    c.validate();
    stampUpdated(c, r.actor);
    channels.save(c);
    return c;
  }

  void deleteEventChannel(TenantId tenantId, EventChannelId id) {
    getEventChannel(tenantId, id);
    foreach (b; bindings.findByChannel(tenantId, id))
      bindings.removeById(tenantId, b.id);
    channels.removeById(tenantId, id);
  }
}
