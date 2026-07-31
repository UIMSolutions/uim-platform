/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.application.usecases.manage.scheduled_executions;

import uim.platform.automation_pilot;

mixin(ShowModule!());

@safe:

class ManageScheduledExecutionsUseCase { // TODO: UIMUseCase {
    private ScheduledExecutionRepository repo;

    this(ScheduledExecutionRepository repo) {
        this.repo = repo;
    }

    ScheduledExecution getScheduledExecution(TenantId tenantId, ScheduledExecutionId id) {
        return repo.findById(tenantId, id);
    }

    ScheduledExecution[] listScheduledExecutions(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    ScheduledExecution[] listScheduledExecutions(TenantId tenantId, CommandId commandId) {
        return repo.findByCommand(tenantId, commandId);
    }

    CommandResult createScheduledExecution(ScheduledExecutionDTO dto) {
        auto se = ScheduledExecution(dto.tenantId, dto.executionId.isNull ? ScheduledExecutionId(createId) : dto.executionId, dto.createdBy);
        se.commandId = dto.commandId;
        se.cronExpression = dto.cronExpression;
        se.scheduledAt = dto.scheduledAt;
        se.inputValues = dto.inputValues;
        se.description = dto.description;
        se.maxRetries = dto.maxRetries;
        se.retryDelay = dto.retryDelay;
        if (!AutomationValidator.isValidScheduledExecution(se))
            return CommandResult(false, "", "Invalid scheduled execution data");
            
        repo.save(se);
        return CommandResult(true, se.id.value, "");
    }

    CommandResult updateScheduledExecution(ScheduledExecutionDTO dto) {
        auto existing = repo.findById(dto.tenantId, dto.executionId);
        if (existing.isNull)
            return CommandResult(false, "", "Scheduled execution not found");

        if (dto.cronExpression.length > 0) existing.cronExpression = dto.cronExpression;
        if (dto.scheduledAt > 0) existing.scheduledAt = dto.scheduledAt;
        if (dto.description.length > 0) existing.description = dto.description;
        if (!dto.updatedBy.isNull) existing.updatedBy = dto.updatedBy;
        
        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteScheduledExecution(TenantId tenantId, ScheduledExecutionId id) {
        auto entity = repo.findById(tenantId, id);
        if (entity.isNull)
            return CommandResult(false, "", "Scheduled execution not found");
            
        repo.remove(entity);
        return CommandResult(true, entity.id.value, "");
    }
}

///
unittest {
//     auto repo = new ScheduledExecutionRepository();
//     auto usecase = new ManageScheduledExecutionsUseCase(repo);
//     auto tenantId = TenantId("test-tenant");
// 
//     // Test create
//     ScheduledExecutionDTO createDto;
//     createDto.tenantId = tenantId;
//     createDto.scheduledExecutionId = ScheduledExecutionId("scheduledExecution-1");
//     createDto.name = "Test ScheduledExecution";
//     auto createResult = usecase.createScheduledExecution(createDto);
//     assert(createResult.success, createResult.message);
// 
//     // Test list
//     auto items = usecase.listScheduledExecutions(tenantId);
//     assert(items.length == 1);
// 
//     // Test get
//     auto item = usecase.getScheduledExecution(tenantId, ScheduledExecutionId("scheduledExecution-1"));
//     assert(!item.isNull);
// 
//     // Test update
//     ScheduledExecutionDTO updateDto;
//     updateDto.tenantId = tenantId;
//     updateDto.scheduledExecutionId = ScheduledExecutionId("scheduledExecution-1");
//     updateDto.name = "Updated ScheduledExecution";
//     auto updateResult = usecase.updateScheduledExecution(updateDto);
//     assert(updateResult.success, updateResult.message);
// 
//     // Test delete
//     auto deleteResult = usecase.deleteScheduledExecution(tenantId, ScheduledExecutionId("scheduledExecution-1"));
//     assert(deleteResult.success, deleteResult.message);
//     assert(usecase.listScheduledExecutions(tenantId).length == 0);

}
