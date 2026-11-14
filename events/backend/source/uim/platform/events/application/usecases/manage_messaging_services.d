/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.application.usecases.manage_messaging_services;

import uim.platform.events;

mixin(ShowModule!());

@safe:

class ManageMessagingServicesUseCase : IManageMessagingServices {
  protected IMessagingServiceRepository services;
  protected IMessageClientRepository clients;
  protected IQueueRepository queues;
  protected IEventChannelRepository channels;

  this(IMessagingServiceRepository services, IMessageClientRepository clients, IQueueRepository queues,
    IEventChannelRepository channels) {
    this.services = services;
    this.clients = clients;
    this.queues = queues;
    this.channels = channels;
  }

  MessagingService[] listMessagingServices(TenantId tenantId) {
    return services.findAll(tenantId);
  }

  MessagingService getMessagingService(TenantId tenantId, MessagingServiceId id) {
    return services.findById(tenantId, id).required("Messaging service '" ~ id.value ~ "'");
  }

  MessagingService createMessagingService(CreateMessagingServiceRequest r) {
    MessagingService s;
    stampCreated!(MessagingService, MessagingServiceId)(s, r.tenantId, r.actor, r.id);
    if (services.existsById(r.tenantId, s.id))
      throw EventsException.conflict("Messaging service '" ~ s.id.value ~ "' already exists");
    s.name = r.name.strip;
    s.description = r.description;
    s.namespace = r.namespace.strip.strip("/");
    s.plan = parseDomainEnumOr!MessagingServicePlan(r.plan, MessagingServicePlan.standard, "plan");
    s.region = r.region;
    s.maxConnections = r.maxConnections;
    s.maxQueues = r.maxQueues;
    s.maxQueueDepth = r.maxQueueDepth;
    s.maxMessageSize = r.maxMessageSize;
    s.tokenEndpoint = r.tokenEndpoint;
    s.messagingEndpoint = r.messagingEndpoint;
    s.validate();
    ensureUnique(s);
    services.save(s);
    return s;
  }

  MessagingService updateMessagingService(UpdateMessagingServiceRequest r) {
    auto s = getMessagingService(r.tenantId, r.id);
    r.name.applyTo(s.name);
    r.description.applyTo(s.description);
    applyEnum(r.status, s.status, "status");
    applyEnum(r.plan, s.plan, "plan");
    r.region.applyTo(s.region);
    r.maxConnections.applyTo(s.maxConnections);
    r.maxQueues.applyTo(s.maxQueues);
    r.maxQueueDepth.applyTo(s.maxQueueDepth);
    r.maxMessageSize.applyTo(s.maxMessageSize);
    r.tokenEndpoint.applyTo(s.tokenEndpoint);
    r.messagingEndpoint.applyTo(s.messagingEndpoint);
    s.validate();
    ensureUnique(s);
    auto used = queues.findByService(s.tenantId, s.id).length;
    if (used > quotaOf(s).maxQueues)
      throw EventsException.quotaExceeded("The service already has " ~ countOf(used, "queue") ~ ", more than the new limit");
    stampUpdated(s, r.actor);
    services.save(s);
    return s;
  }

  void deleteMessagingService(TenantId tenantId, MessagingServiceId id) {
    auto s = getMessagingService(tenantId, id);
    string[] dependents;
    if (auto n = clients.findByService(tenantId, id).length)
      dependents ~= countOf(n, "client");
    if (auto n = queues.findByService(tenantId, id).length)
      dependents ~= countOf(n, "queue");
    if (auto n = channels.findByService(tenantId, id).length)
      dependents ~= countOf(n, "channel");
    if (dependents.length)
      throw EventsException.ruleViolation("Messaging service '" ~ s.name ~ "' still has " ~ dependents.join(", "));
    services.removeById(tenantId, id);
  }

  protected void ensureUnique(const MessagingService s) {
    auto other = services.findByName(s.tenantId, s.name);
    if (!other.isNull && other.id != s.id)
      throw EventsException.conflict("A messaging service named '" ~ s.name ~ "' already exists");
    other = services.findByNamespace(s.tenantId, s.namespace);
    if (!other.isNull && other.id != s.id)
      throw EventsException.conflict("Namespace '" ~ s.namespace ~ "' is already used by '" ~ other.name ~ "'");
  }
}
