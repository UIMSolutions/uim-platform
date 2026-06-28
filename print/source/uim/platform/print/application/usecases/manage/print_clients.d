/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.print.application.usecases.manage.print_clients;

import uim.platform.print;

// mixin(ShowModule!());

@safe:

class ManagePrintClientsUseCase {
    private PrintClientRepository repo;

    this(PrintClientRepository repo) {
        this.repo = repo;
    }

    PrintClient getPrintClient(TenantId tenantId, PrintClientId id) {
        return repo.findById(tenantId, id);
    }

    PrintClient[] listPrintClients(TenantId tenantId) {
        return repo.find(tenantId);
    }

    CommandResult registerPrintClient(PrintClientDTO dto) {
        PrintClient client;
        client.initEntity(dto.tenantId, dto.createdBy);
        client.id = dto.clientId;
        client.name = dto.name;
        client.description = dto.description;
        client.version_ = dto.version_;
        client.hostName = dto.hostName;
        client.ipAddress = dto.ipAddress;
        client.osType = dto.osType;
        client.osVersion = dto.osVersion;
        client.status = PrintClientStatus.registered;

        import std.digest.sha : sha256Of;
        import std.digest : toHexString;
        
        client.authToken = sha256Of(client.id.value ~ client.hostName).toHexString.to!string;

        if (!PrintValidator.isValidPrintClient(client))
            return CommandResult(false, "", "Invalid print client: name and hostName are required");

        repo.save(client);
        return CommandResult(true, client.id.value, "");
    }

    CommandResult updatePrintClient(PrintClientDTO dto) {
        auto existing = repo.findById(dto.tenantId, dto.clientId);
        if (existing.isNull)
            return CommandResult(false, "", "Print client not found");

        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.version_.length > 0) existing.version_ = dto.version_;
        if (dto.ipAddress.length > 0) existing.ipAddress = dto.ipAddress;
        if (!dto.updatedBy.isNull) existing.updatedBy = dto.updatedBy;

        
        existing.lastSeenAt = MonoTime.currTime.ticks;

        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deletePrintClient(TenantId tenantId, PrintClientId id) {
        auto entity = repo.findById(tenantId, id);
        if (entity.isNull)
            return CommandResult(false, "", "Print client not found");
        repo.remove(entity);
        return CommandResult(true, id.value, "");
    }
}
