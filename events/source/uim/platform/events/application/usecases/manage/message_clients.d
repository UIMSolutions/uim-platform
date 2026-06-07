/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.application.usecases.manage.message_clients;

import uim.platform.events;

// mixin(ShowModule!());

@safe:

class ManageMessageClientsUseCase {
    private MessageClientRepository repo;

    this(MessageClientRepository repo) { this.repo = repo; }

    MessageClient getClient(TenantId tenantId, MessageClientId id) {
        return repo.findById(tenantId, id);
    }

    MessageClient[] listClients(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    MessageClient[] listByService(TenantId tenantId, MessagingServiceId serviceId) {
        return repo.findByService(tenantId, serviceId);
    }

    CommandResult createClient(MessageClientDTO dto) {
        MessageClient c;
        c.id = dto.clientId;
        c.tenantId = dto.tenantId;
        c.serviceId = dto.serviceId;
        c.name = dto.name;
        c.description = dto.description;
        c.xsappname = dto.xsappname;
        c.namespace = dto.namespace;
        c.permittedNamespace = dto.permittedNamespace;
        c.createdBy = dto.createdBy;
        if (!EventsValidator.isValidMessageClient(c))
            return CommandResult(false, "", "Invalid message client data");
        repo.save(c);
        return CommandResult(true, c.id.value, "");
    }

    CommandResult updateClient(MessageClientDTO dto) {
        auto existing = repo.findById(dto.tenantId, dto.clientId);
        if (existing.isNull) return CommandResult(false, "", "Message client not found");
        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.namespace.length > 0) existing.namespace = dto.namespace;
        if (dto.permittedNamespace.length > 0) existing.permittedNamespace = dto.permittedNamespace;
        if (!dto.updatedBy.isNull) existing.updatedBy = dto.updatedBy;
        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteClient(TenantId tenantId, MessageClientId id) {
        auto c = repo.findById(tenantId, id);
        if (c.isNull) return CommandResult(false, "", "Message client not found");
        repo.remove(c);
        return CommandResult(true, c.id.value, "");
    }
}
