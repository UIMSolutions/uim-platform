/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.application.usecases.manage.command_inputs;

import uim.platform.automation_pilot;

mixin(ShowModule!());

@safe:

class ManageCommandInputsUseCase { // TODO: UIMUseCase {
    private CommandInputRepository repo;

    this(CommandInputRepository repo) {
        this.repo = repo;
    }

    CommandInput getCommandInput(TenantId tenantId, CommandInputId id) {
        return repo.findById(tenantId, id);
    }

    CommandInput[] listCommandInputs(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    CommandResult createCommandInput(CommandInputDTO dto) {
        auto ci = CommandInput(dto.tenantId, dto.inputId.isNull ? CommandInputId(createId) : dto.inputId, dto.createdBy);
        ci.name = dto.name;
        ci.description = dto.description;
        ci.keys = dto.keys;
        ci.values = dto.values;
        ci.version_ = dto.version_;
        ci.commandId = dto.commandId;
        if (!AutomationValidator.isValidCommandInput(ci))
            return CommandResult(false, "", "Invalid command input data");

        repo.save(ci);
        return CommandResult(true, ci.id.value, "");
    }

    CommandResult updateCommandInput(CommandInputDTO dto) {
        auto existing = repo.findById(dto.tenantId, dto.inputId);
        if (existing.isNull)
            return CommandResult(false, "", "Command input not found");

        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.keys.length > 0) existing.keys = dto.keys;
        if (dto.values.length > 0) existing.values = dto.values;
        if (!dto.updatedBy.isNull) existing.updatedBy = dto.updatedBy;

        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteCommandInput(TenantId tenantId, CommandInputId id) {
        auto entity = repo.findById(tenantId, id);
        if (entity.isNull)
            return CommandResult(false, "", "Command input not found");
            
        repo.remove(entity);
        return CommandResult(true, entity.id.value, "");
    }
}

///
unittest {
//    auto repo = new CommandInputRepository();
//    auto usecase = new ManageCommandInputsUseCase(repo);
//    auto tenantId = TenantId("test-tenant");
//
//    // Test create
//    CommandInputDTO createDto;
//    createDto.tenantId = tenantId;
//    createDto.commandInputId = CommandInputId("commandInput-1");
//    createDto.name = "Test CommandInput";
//    auto createResult = usecase.createCommandInput(createDto);
//    assert(createResult.success, createResult.message);
//
//    // Test list
//    auto items = usecase.listCommandInputs(tenantId);
//    assert(items.length == 1);
//
//    // Test get
//    auto item = usecase.getCommandInput(tenantId, CommandInputId("commandInput-1"));
//    assert(!item.isNull);
//
//    // Test update
//    CommandInputDTO updateDto;
//    updateDto.tenantId = tenantId;
//    updateDto.commandInputId = CommandInputId("commandInput-1");
//    updateDto.name = "Updated CommandInput";
//    auto updateResult = usecase.updateCommandInput(updateDto);
//    assert(updateResult.success, updateResult.message);
//
//    // Test delete
//    auto deleteResult = usecase.deleteCommandInput(tenantId, CommandInputId("commandInput-1"));
//    assert(deleteResult.success, deleteResult.message);
//    assert(usecase.listCommandInputs(tenantId).length == 0);

}
