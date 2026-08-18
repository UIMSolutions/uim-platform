/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.application.usecases.manage.commands;

import uim.platform.automation_pilot;

mixin(ShowModule!());

@safe:

class ManageCommandsUseCase {
    private ICommandRepository repo;

    this(ICommandRepository repo) {
        this.repo = repo;
    }

    Command getCommand(TenantId tenantId, CommandId id) {
        return repo.findById(tenantId, id);
    }

    Command[] listCommands(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    Command[] listCommands(TenantId tenantId, CatalogId catalogId) {
        return repo.findByCatalog(tenantId, catalogId);
    }

    UsecaseResult createCommand(CommandDTO dto) {
        auto cmd = Command(dto.tenantId, dto.commandId.isNull ? CommandId(createId) : dto.commandId, dto.createdBy);
        cmd.catalogId = dto.catalogId;
        cmd.name = dto.name;
        cmd.description = dto.description;
        cmd.version_ = dto.version_;
        cmd.inputSchema = dto.inputSchema;
        cmd.outputSchema = dto.outputSchema;
        cmd.steps = dto.steps;
        cmd.timeout = dto.timeout;
        cmd.retryCount = dto.retryCount;
        cmd.tags = dto.tags;
        if (!AutomationValidator.isValidCommand(cmd))
            return UsecaseResult(false, "", "Invalid command data");

        repo.save(cmd);
        return UsecaseResult(true, cmd.id.value, "");
    }

    UsecaseResult updateCommand(CommandDTO dto) {
        auto existing = repo.findById(dto.tenantId, dto.commandId);
        if (existing.isNull)
            return UsecaseResult(false, "", "Command not found");
            
        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.inputSchema.length > 0) existing.inputSchema = dto.inputSchema;
        if (dto.outputSchema.length > 0) existing.outputSchema = dto.outputSchema;
        if (dto.steps.length > 0) existing.steps = dto.steps;
        if (dto.timeout.length > 0) existing.timeout = dto.timeout;
        if (!dto.updatedBy.isNull) existing.updatedBy = dto.updatedBy;
        repo.update(existing);
        return UsecaseResult(true, existing.id.value, "");
    }

    UsecaseResult deleteCommand(TenantId tenantId, CommandId id) {
        auto entity = repo.findById(tenantId, id);
        if (entity.isNull)
            return UsecaseResult(false, "", "Command not found");
            
        repo.remove(entity);
        return UsecaseResult(true, entity.id.value, "");
    }
}

///
unittest {
//    auto repo = new CommandRepository();
//    auto usecase = new ManageCommandsUseCase(repo);
//    auto tenantId = TenantId("test-tenant");
//
//    // Test create
//    CommandDTO createDto;
//    createDto.tenantId = tenantId;
//    createDto.commandId = CommandId("command-1");
//    createDto.name = "Test Command";
//    auto createResult = usecase.createCommand(createDto);
//    assert(createResult.success, createResult.message);
//
//    // Test list
//    auto items = usecase.listCommands(tenantId);
//    assert(items.length == 1);
//
//    // Test get
//    auto item = usecase.getCommand(tenantId, CommandId("command-1"));
//    assert(!item.isNull);
//
//    // Test update
//    CommandDTO updateDto;
//    updateDto.tenantId = tenantId;
//    updateDto.commandId = CommandId("command-1");
//    updateDto.name = "Updated Command";
//    auto updateResult = usecase.updateCommand(updateDto);
//    assert(updateResult.success, updateResult.message);
//
//    // Test delete
//    auto deleteResult = usecase.deleteCommand(tenantId, CommandId("command-1"));
//    assert(deleteResult.success, deleteResult.message);
//    assert(usecase.listCommands(tenantId).length == 0);

}
