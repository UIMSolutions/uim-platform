/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.application.usecases.manage_message_clients;

import uim.platform.events;

mixin(ShowModule!());

@safe:

class ManageMessageClientsUseCase : IManageMessageClients {
  protected IMessageClientRepository clients;
  protected IMessagingServiceRepository services;
  protected IMessageBindingRepository bindings;

  this(IMessageClientRepository clients, IMessagingServiceRepository services, IMessageBindingRepository bindings) {
    this.clients = clients;
    this.services = services;
    this.bindings = bindings;
  }

  MessageClient[] listMessageClients(TenantId tenantId) {
    return clients.findAll(tenantId);
  }

  MessageClient getMessageClient(TenantId tenantId, MessageClientId id) {
    return clients.findById(tenantId, id).required("Message client '" ~ id.value ~ "'");
  }

  MessageClient createMessageClient(CreateMessageClientRequest r) {
    auto service = services.findById(r.tenantId, MessagingServiceId(r.serviceId))
      .required("Messaging service '" ~ r.serviceId ~ "'");
    MessageClient c;
    stampCreated!(MessageClient, MessageClientId)(c, r.tenantId, r.actor, r.id);
    if (clients.existsById(r.tenantId, c.id))
      throw EventsException.conflict("Message client '" ~ c.id.value ~ "' already exists");
    c.serviceId = service.id;
    c.name = r.name.strip;
    c.description = r.description;
    c.protocol = parseDomainEnumOr!MessageClientProtocol(r.protocol, MessageClientProtocol.httprest, "protocol");
    c.clientId = r.clientId.length > 0 ? r.clientId : "sb-" ~ c.id.value;
    c.clientSecret = r.clientSecret.length > 0 ? r.clientSecret : newResourceId();
    c.tokenUrl = r.tokenUrl.length > 0 ? r.tokenUrl : service.tokenEndpoint;
    c.permittedNamespace = r.permittedNamespace.length > 0 ? r.permittedNamespace.strip("/") : service.namespace;
    c.validate();
    checkNamespace(c, service);
    ensureUniqueName(c);
    auto quota = quotaOf(service).maxConnections;
    if (clients.findByService(r.tenantId, service.id).length >= quota)
      throw EventsException.quotaExceeded("Messaging service '" ~ service.name ~ "' allows " ~ countOf(quota, "client"));
    clients.save(c);
    return c;
  }

  MessageClient updateMessageClient(UpdateMessageClientRequest r) {
    auto c = getMessageClient(r.tenantId, r.id);
    r.name.applyTo(c.name);
    r.description.applyTo(c.description);
    applyEnum(r.status, c.status, "status");
    applyEnum(r.protocol, c.protocol, "protocol");
    r.clientSecret.applyTo(c.clientSecret);
    r.tokenUrl.applyTo(c.tokenUrl);
    if (r.permittedNamespace.isSet)
      c.permittedNamespace = r.permittedNamespace.value.strip("/");
    c.validate();
    checkNamespace(c, services.findById(c.tenantId, c.serviceId).required("Messaging service"));
    ensureUniqueName(c);
    stampUpdated(c, r.actor);
    clients.save(c);
    return c;
  }

  void deleteMessageClient(TenantId tenantId, MessageClientId id) {
    getMessageClient(tenantId, id);
    foreach (b; bindings.findByClient(tenantId, id))
      bindings.removeById(tenantId, b.id);
    clients.removeById(tenantId, id);
  }

  protected static void checkNamespace(const MessageClient c, const MessagingService s) {
    if (c.permittedNamespace != s.namespace && !isInNamespace(c.permittedNamespace, s.namespace))
      throw EventsException.invalid("permittedNamespace must be '" ~ s.namespace ~ "' or lie below it");
  }

  protected void ensureUniqueName(const MessageClient c) {
    auto other = clients.findByName(c.tenantId, c.serviceId, c.name);
    if (!other.isNull && other.id != c.id)
      throw EventsException.conflict("A client named '" ~ c.name ~ "' already exists for this service");
  }
}
