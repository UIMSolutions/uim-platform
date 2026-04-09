/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.master_data_integration.application.usecases.manage.clients;

import uim.platform.master_data_integration.application.dto;
import uim.platform.master_data_integration.domain.entities.client;
import uim.platform.master_data_integration.domain.ports.repositories.clients;
import uim.platform.master_data_integration.domain.types;

/// Application service for connected client system management.
class ManageClientsUseCase : UIMUseCase {
  private ClientRepository repo;

  this(ClientRepository repo) {
    this.repo = repo;
  }

  CommandResult create(CreateClientRequest req) {
    if (req.name.length == 0)
      return CommandResult(false, "", "Client name is required");

    // import std.uuid : randomUUID;
    auto id = randomUUID().toString();

    Client client;
    client.id = randomUUID();
    client.tenantId = req.tenantId;
    client.name = req.name;
    client.description = req.description;
    client.clientType = parseClientType(req.clientType);
    client.status = ClientStatus.disconnected;
    client.systemUrl = req.systemUrl;
    client.destinationName = req.destinationName;
    client.communicationArrangement = req.communicationArrangement;
    client.supportedCategories = parseCategories(req.supportedCategories);
    client.supportsInitialLoad = req.supportsInitialLoad;
    client.supportsDeltaReplication = req.supportsDeltaReplication;
    client.supportsKeyMapping = req.supportsKeyMapping;
    client.authType = req.authType;
    client.clientIdRef = req.clientIdRef;
    client.certificateRef = req.certificateRef;
    client.createdBy = req.createdBy;
    client.createdAt = clockSeconds();
    client.modifiedAt = client.createdAt;

    repo.save(client);
    return CommandResult(true, id.toString, "");
  }

  CommandResult updateClient(ClientId id, UpdateClientRequest req) {
    auto client = repo.findById(id);
    if (client.id.isEmpty)
      return CommandResult(false, "", "Client not found");

    if (req.name.length > 0)
      client.name = req.name;
    if (req.description.length > 0)
      client.description = req.description;
    if (req.status.length > 0)
      client.status = parseClientStatus(req.status);
    if (req.systemUrl.length > 0)
      client.systemUrl = req.systemUrl;
    if (req.destinationName.length > 0)
      client.destinationName = req.destinationName;
    if (req.communicationArrangement.length > 0)
      client.communicationArrangement = req.communicationArrangement;
    if (req.supportedCategories.length > 0)
      client.supportedCategories = parseCategories(req.supportedCategories);
    if (req.authType.length > 0)
      client.authType = req.authType;
    if (req.clientIdRef.length > 0)
      client.clientIdRef = req.clientIdRef;
    if (req.certificateRef.length > 0)
      client.certificateRef = req.certificateRef;
    client.modifiedAt = clockSeconds();

    repo.update(client);
    return CommandResult(true, id.toString, "");
  }

  CommandResult connect(ClientId id) {
    auto client = repo.findById(id);
    if (client.id.isEmpty)
      return CommandResult(false, "", "Client not found");
    client.status = ClientStatus.connected;
    client.lastSyncAt = clockSeconds();
    client.modifiedAt = client.lastSyncAt;
    repo.update(client);
    return CommandResult(true, id.toString, "");
  }

  CommandResult disconnect(ClientId id) {
    auto client = repo.findById(id);
    if (client.id.isEmpty)
      return CommandResult(false, "", "Client not found");
    client.status = ClientStatus.disconnected;
    client.modifiedAt = clockSeconds();
    repo.update(client);
    return CommandResult(true, id.toString, "");
  }

  Client getClient(ClientId id) {
    return repo.findById(id);
  }

  Client[] listByTenant(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  Client[] listByStatus(TenantId tenantId, string status) {
    return repo.findByStatus(tenantId, parseClientStatus(status));
  }

  Client[] listByType(TenantId tenantId, string type) {
    return repo.findByType(tenantId, parseClientType(type));
  }

  CommandResult deleteClient(ClientId id) {
    auto client = repo.findById(id);
    if (client.id.isEmpty)
      return CommandResult(false, "", "Client not found");
    repo.remove(id);
    return CommandResult(true, id.toString, "");
  }

  private ClientType parseClientType(string s) {
    switch (s) {
    case "sapS4Hana":
      return ClientType.sapS4Hana;
    case "sapSuccessFactors":
      return ClientType.sapSuccessFactors;
    case "sapAriba":
      return ClientType.sapAriba;
    case "sapFieldglass":
      return ClientType.sapFieldglass;
    case "sapConcur":
      return ClientType.sapConcur;
    case "sapBusinessByDesign":
      return ClientType.sapBusinessByDesign;
    case "thirdParty":
      return ClientType.thirdParty;
    case "custom":
      return ClientType.custom;
    default:
      return ClientType.sapS4Hana;
    }
  }

  private ClientStatus parseClientStatus(string s) {
    switch (s) {
    case "connected":
      return ClientStatus.connected;
    case "disconnected":
      return ClientStatus.disconnected;
    case "error":
      return ClientStatus.error;
    case "suspended":
      return ClientStatus.suspended;
    default:
      return ClientStatus.disconnected;
    }
  }

  private MasterDataCategory[] parseCategories(string[] cats) {
    MasterDataCategory[] result;
    foreach (s; cats) {
      switch (s) {
      case "businessPartner":
        result ~= MasterDataCategory.businessPartner;
        break;
      case "costCenter":
        result ~= MasterDataCategory.costCenter;
        break;
      case "profitCenter":
        result ~= MasterDataCategory.profitCenter;
        break;
      case "companyCode":
        result ~= MasterDataCategory.companyCode;
        break;
      case "workforcePerson":
        result ~= MasterDataCategory.workforcePerson;
        break;
      case "bankAccount":
        result ~= MasterDataCategory.bankAccount;
        break;
      case "plant":
        result ~= MasterDataCategory.plant;
        break;
      case "custom":
        result ~= MasterDataCategory.custom;
        break;
      default:
        break;
      }
    }
    return result;
  }
}


