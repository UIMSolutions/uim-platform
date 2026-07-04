/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.master_data_integration.application.usecases.manage.client;

// import uim.platform.master_data_integration.domain.entities.client;
// import uim.platform.master_data_integration.domain.ports.repositories.clients;


import uim.platform.master_data_integration;

mixin(ShowModule!());

@safe:
/// Application service for connected client system management.
class ManageClientsUseCase { // TODO: UIMUseCase {
  private ClientRepository repo;

  this(ClientRepository repo) {
    this.repo = repo;
  }

  CommandResult createClient(CreateClientRequest req) {
    if (req.name.length == 0)
      return CommandResult(false, "", "Client name is required");

    auto client = Client(req.tenantId); //, UserId("test-user"));
    client.name = req.name;
    client.description = req.description;
    client.clientType = toClientType(req.clientType);
    client.status = ClientStatus.disconnected;
    client.systemUrl = req.systemUrl;
    client.destinationName = req.destinationName;
    client.communicationArrangement = req.communicationArrangement;
    client.supportedCategories = toMasterDataCategories(req.supportedCategories);
    client.supportsInitialLoad = req.supportsInitialLoad;
    client.supportsDeltaReplication = req.supportsDeltaReplication;
    client.supportsKeyMapping = req.supportsKeyMapping;
    client.authType = req.authType;
    client.clientIdRef = req.clientIdRef;
    client.certificateRef = req.certificateRef;

    repo.save(client);
    return CommandResult(true, client.id.value, "");
  }

  CommandResult updateClient(UpdateClientRequest req) {
    auto client = repo.findById(req.tenantId, req.clientId);
    if (client.isNull)
      return CommandResult(false, "", "Client not found");

    if (req.name.length > 0)
      client.name = req.name;
    if (req.description.length > 0)
      client.description = req.description;
    if (req.status.length > 0)
      client.status = toClientStatus(req.status);
    if (req.systemUrl.length > 0)
      client.systemUrl = req.systemUrl;
    if (req.destinationName.length > 0)
      client.destinationName = req.destinationName;
    if (req.communicationArrangement.length > 0)
      client.communicationArrangement = req.communicationArrangement;
    if (req.supportedCategories.length > 0)
      client.supportedCategories = toMasterDataCategories(req.supportedCategories);
    if (req.authType.length > 0)
      client.authType = req.authType;
    if (req.clientIdRef.length > 0)
      client.clientIdRef = req.clientIdRef;
    if (req.certificateRef.length > 0)
      client.certificateRef = req.certificateRef;
    client.updatedAt = clockSeconds();

    repo.update(client);
    return CommandResult(true, client.id.value, "");
  }

  CommandResult connectClient(TenantId tenantId, ClientId id) {
    auto client = repo.findById(tenantId, id);
    if (client.isNull)
      return CommandResult(false, "", "Client not found");

    client.status = ClientStatus.connected;
    // TODO:
    // client.lastSyncAt = currentTimestamp;
    // client.updatedAt = client.lastSyncAt;
    repo.update(client);
    return CommandResult(true, client.id.value, "");
  }

  CommandResult disconnectClient(TenantId tenantId, ClientId id) {
    auto client = repo.findById(tenantId, id);
    if (client.isNull)
      return CommandResult(false, "", "Client not found");

    client.status = ClientStatus.disconnected;
    client.updatedAt = clockSeconds();

    repo.update(client);
    return CommandResult(true, client.id.value, "");
  }

  Client getClient(TenantId tenantId, ClientId id) {
    return repo.findById(tenantId, id);
  }

  Client[] listClients(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  Client[] listClientsByStatus(TenantId tenantId, string status) {
    return repo.findByStatus(tenantId, toClientStatus(status));
  }

  Client[] listClientsByType(TenantId tenantId, string type) {
    return repo.findByType(tenantId, toClientType(type));
  }

  CommandResult deleteClient(TenantId tenantId, ClientId id) {
    auto client = repo.findById(tenantId, id);
    if (client.isNull)
      return CommandResult(false, "", "Client not found");

    repo.remove(client);
    return CommandResult(true, client.id.value, "");
  }

}


