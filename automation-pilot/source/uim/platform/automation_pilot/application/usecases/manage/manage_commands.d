/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.application.usecases.manage.manage_commands;

import uim.platform.automation_pilot;

mixin(ShowModule!());

@safe:

class ManageCommandsUseCase : UIMUseCase {
    private CommandRepository repo;

    this(CommandRepository repo) {
        this.repo = repo;
    }

    Command getById(CommandId id) {
        return repo.findById(id);
    }

    Command[] list() {
        return repo.findAll();
    }

    Command[] listByTenant(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    Command[] listByCatalog(CatalogId catalogId) {
        return repo.findByCatalog(catalogId);
    }

    CommandResult create(CommandDTO dto) {
        Command cmd;
        cmd.id = CommandId(dto.id);
        cmd.tenantId = dto.tenantId;
        cmd.catalogId = CatalogId(dto.catalogId);
        cmd.name = dto.name;
        cmd.description = dto.description;
        cmd.version_ = dto.version_;
        cmd.inputSchema = dto.inputSchema;
        cmd.outputSchema = dto.outputSchema;
        cmd.steps = dto.steps;
        cmd.timeout = dto.timeout;
        cmd.retryCount = dto.retryCount;
        cmd.tags = dto.tags;
        cmd.createdBy = dto.createdBy;
        if (!AutomationValidator.isValidCommand(cmd))
            return CommandResult(false, "", "Invalid command data");
        repo.save(cmd);
        return CommandResult(true, dto.id, "");
    }

    CommandResult update(CommandDTO dto) {
        if (!repo.existsById(CommandId(dto.id)))
            return CommandResult(false, "", "Command not found");
        auto existing = repo.findById(CommandId(dto.id));
        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.inputSchema.length > 0) existing.inputSchema = dto.inputSchema;
        if (dto.outputSchema.length > 0) existing.outputSchema = dto.outputSchema;
        if (dto.steps.length > 0) existing.steps = dto.steps;
        if (dto.timeout.length > 0) existing.timeout = dto.timeout;
        if (dto.modifiedBy.length > 0) existing.modifiedBy = dto.modifiedBy;
        repo.update(existing);
        return CommandResult(true, dto.id, "");
    }

    CommandResult remove(CommandId id) {
        if (!repo.existsById(id))
            return CommandResult(false, "", "Command not found");
        repo.remove(id);
        return CommandResult(true, id.value, "");
    }
}
