/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.print.application.usecases.manage.print_tasks;

import uim.platform.print;

// mixin(ShowModule!());

@safe:

class ManagePrintTasksUseCase {
    private PrintTaskRepository repo;

    this(PrintTaskRepository repo) {
        this.repo = repo;
    }

    PrintTask getPrintTask(TenantId tenantId, PrintTaskId id) {
        return repo.findById(tenantId, id);
    }

    PrintTask[] listPrintTasks(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    PrintTask[] listByQueue(TenantId tenantId, PrintQueueId queueId) {
        return repo.findByQueue(tenantId, queueId);
    }

    PrintTask[] listPendingByQueue(TenantId tenantId, PrintQueueId queueId) {
        return repo.findPendingByQueue(tenantId, queueId);
    }

    CommandResult createPrintTask(PrintTaskDTO dto) {
        PrintTask task;
        task.initEntity(dto.tenantId, dto.createdBy);
        task.id = dto.taskId;
        task.queueId = PrintQueueId(dto.queueId);
        task.documentId = PrintDocumentId(dto.documentId);
        task.applicationId = dto.applicationId;
        task.senderApplication = dto.senderApplication;
        task.copies = dto.copies >= 1 ? dto.copies : 1;
        task.paperFormat = dto.paperFormat;
        task.colorPrint = dto.colorPrint;
        task.duplexPrint = dto.duplexPrint;
        task.tray = dto.tray;
        task.status = PrintTaskStatus.pending;

        if (!PrintValidator.isValidPrintTask(task))
            return CommandResult(false, "", "Invalid print task: queueId and documentId are required");

        repo.save(task);
        return CommandResult(true, task.id.value, "");
    }

    CommandResult updatePrintTask(TenantId tenantId, PrintTaskId id, string status, string errorMessage) {
        auto existing = repo.findById(tenantId, id);
        if (existing.isNull)
            return CommandResult(false, "", "Print task not found");

        if (status.length > 0) {
            
            try { existing.status = status.to!PrintTaskStatus; } catch (Exception) {}
        }
        if (errorMessage.length > 0) existing.errorMessage = errorMessage;

        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deletePrintTask(TenantId tenantId, PrintTaskId id) {
        auto entity = repo.findById(tenantId, id);
        if (entity.isNull)
            return CommandResult(false, "", "Print task not found");
        repo.remove(entity);
        return CommandResult(true, id.value, "");
    }
}
