/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.application.usecases.manage.clients;
// import uim.platform.document_ai.domain.types;
// import uim.platform.document_ai.domain.entities.client;
// import uim.platform.document_ai.domain.ports.repositories.clients;
// import uim.platform.document_ai.application.dto;

import uim.platform.document_ai;

// mixin(ShowModule!());

@safe:
class ManageClientsUseCase { // TODO: UIMUseCase {
  private ClientRepository repo;

  this(ClientRepository repo) {
    this.repo = repo;
  }

  CommandResult createClient(CreateClientRequest r) {
    if (r.tenantId.isEmpty)
      return CommandResult(false, "", "Tenant ID is required");

    Client c;
    c.initEntity(r.tenantId);
    c.id = r.clientId.length > 0 ? r.clientId : randomUUID().to!string;
    c.name = r.name;
    c.description = r.description;
    c.documentQuota = r.documentQuota > 0 ? r.documentQuota : 1000;
    c.documentsProcessed = 0;
    c.dataFeedbackEnabled = false;

    ClientLabel[] labels;
    foreach (pair; r.labels) {
      if (pair.length >= 2) {
        ClientLabel lbl;
        lbl.key = pair[0];
        lbl.value = pair[1];
        labels ~= lbl;
      }
    }
    c.labels = labels;

    repo.save(c);
    return CommandResult(true, c.id.value, "");
  }

  CommandResult patchClient(PatchClientRequest r) {
    if (r.clientId.isEmpty)
      return CommandResult(false, "", "Client ID is required");

    auto existing = repo.findById(r.clientId);
    if (existing.isNull)
      return CommandResult(false, "", "Client not found");

    if (r.name.length > 0) existing.name = r.name;
    if (r.description.length > 0) existing.description = r.description;
    if (r.documentQuota > 0) existing.documentQuota = r.documentQuota;
    existing.dataFeedbackEnabled = r.dataFeedbackEnabled;

    if (r.labels.length > 0) {
      ClientLabel[] labels;
      foreach (pair; r.labels) {
        if (pair.length >= 2) {
          ClientLabel lbl;
          lbl.key = pair[0];
          lbl.value = pair[1];
          labels ~= lbl;
        }
      }
      existing.labels = labels;
    }

    
    existing.updatedAt = currentTimestamp;

    repo.update(existing);
    return CommandResult(true, existing.id.value, "");
  }

  Client getClient(TenantId tenantId, ClientId id) {
    return repo.findById(tenantId, id);
  }

  Client[] listClients(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }
  size_t countClients(TenantId tenantId) {
    return repo.countByTenant(tenantId);
  }
  CommandResult deleteClient(TenantId tenantId, ClientId id) {
    auto client = repo.findById(tenantId, id);
    if (client.isNull)
      return CommandResult(false, "", "Client not found");

    repo.remove(client);
    return CommandResult(true, client.id.value, "");
  }


}
