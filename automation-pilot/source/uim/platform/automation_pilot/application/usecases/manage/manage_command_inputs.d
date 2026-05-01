/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.application.usecases.manage.manage_command_inputs;

import uim.platform.automation_pilot;

mixin(ShowModule!());

@safe:

class ManageCommandInputsUseCase { // TODO: UIMUseCase {
    private CommandInputRepository repo;

    this(CommandInputRepository repo) {
        this.repo = repo;
    }

    CommandInput getById(CommandInputId id) {
        return repo.findById(id);
    }

    CommandInput[] list() {
        return repo.findAll();
    }

    CommandInput[] listByTenant(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    CommandResult create(CommandInputDTO dto) {
        CommandInput ci;
        ci.id = CommandInputId(dto.id);
        ci.tenantId = dto.tenantId;
        ci.name = dto.name;
        ci.description = dto.description;
        ci.keys = dto.keys;
        ci.values = dto.values;
        ci.version_ = dto.version_;
        ci.commandId = dto.commandId;
        ci.createdBy = dto.createdBy;
        if (!AutomationValidator.isValidCommandInput(ci))
            return CommandResult(false, "", "Invalid command input data");
        repo.save(ci);
        return CommandResult(true, dto.id, "");
    }

    CommandResult update(CommandInputDTO dto) {
        if (!repo.existsById(CommandInputId(dto.id)))
            return CommandResult(false, "", "Command input not found");
        auto existing = repo.findById(CommandInputId(dto.id));
        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.keys.length > 0) existing.keys = dto.keys;
        if (dto.values.length > 0) existing.values = dto.values;
        if (dto.updatedBy.length > 0) existing.updatedBy = dto.updatedBy;
        repo.update(existing);
        return CommandResult(true, dto.id, "");
    }

    CommandResult remove(CommandInputId id) {
        if (!repo.existsById(id))
            return CommandResult(false, "", "Command input not found");
        repo.remove(id);
        return CommandResult(true, id.value, "");
    }
}
