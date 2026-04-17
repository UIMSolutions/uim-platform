/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.application.usecases.manage.clients;

import uim.platform.document_ai.domain.types;
import uim.platform.document_ai.domain.entities.client;
import uim.platform.document_ai.domain.ports.repositories.clients;
import uim.platform.document_ai.application.dto;

import std.uuid : randomUUID;
import std.conv : to;

class ManageClientsUseCase : UIMUseCase {
  private ClientRepository repo;

  this(ClientRepository repo) {
    this.repo = repo;
  }

  CommandResult create(CreateClientRequest r) {
    if (r.tenantId.isEmpty)
      return CommandResult(false, "", "Tenant ID is required");

    Client c;
    c.id = r.clientId.length > 0 ? r.clientId : randomUUID().to!string;
    c.tenantId = r.tenantId;
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

    import core.time : MonoTime;
    auto now = MonoTime.currTime.ticks;
    c.createdAt = now;
    c.modifiedAt = now;

    repo.save(c);
    return CommandResult(true, c.id, "");
  }

  CommandResult patch(PatchClientRequest r) {
    if (r.clientId.isEmpty)
      return CommandResult(false, "", "Client ID is required");

    auto existing = repo.findById(r.clientId);
    if (existing.id.isEmpty)
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

    import core.time : MonoTime;
    existing.modifiedAt = MonoTime.currTime.ticks;

    repo.update(existing);
    return CommandResult(true, existing.id, "");
  }

  Client get_(ClientId id) {
    return repo.findById(id);
  }

  Client[] listByTenant(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  CommandResult remove(ClientId id) {
    auto existing = repo.findById(id);
    if (existing.id.isEmpty)
      return CommandResult(false, "", "Client not found");

    repo.remove(id);
    return CommandResult(true, id.toString, "");
  }

  size_t countByTenant(TenantId tenantId) {
    return repo.countByTenant(tenantId);
  }
}
