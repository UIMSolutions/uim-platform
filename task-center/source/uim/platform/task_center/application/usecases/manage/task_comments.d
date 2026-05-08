/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.application.usecases.manage.manage.task_comments;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

class ManageTaskCommentsUseCase { // TODO: UIMUseCase {
    private TaskCommentRepository repo;

    this(TaskCommentRepository repo) {
        this.repo = repo;
    }

    TaskComment getTaskCommentById(TenantId tenantId, TaskCommentId id) {
        return repo.findById(tenantId, id);
    }

    TaskComment[] listTaskCommentsByTask(TenantId tenantId, TaskId taskId) {
        return repo.findByTask(tenantId, taskId);
    }

    CommandResult createTaskComment(CreateTaskCommentRequest req) {
        TaskComment c;
        c.id = req.id;
        c.tenantId = req.tenantId;
        c.taskId = req.taskId;
        c.author = req.author;
        c.content = req.content;
        repo.save(req.tenantId, c);
        return CommandResult(true, req.id.value, "");
    }

    CommandResult updateTaskComment(UpdateTaskCommentRequest req) {
        auto existing = repo.findById(req.tenantId, req.id);
        if (existing.isNull)
            return CommandResult(false, "", "Comment not found");
        if (req.content.length > 0) existing.content = req.content;
        repo.update(req.tenantId, existing);
        return CommandResult(true, req.id.value, "");
    }

    CommandResult deleteTaskComment(TenantId tenantId, TaskCommentId id) {
        auto comment = repo.findById(tenantId, id);
        if (comment.isNull)
            return CommandResult(false, "", "Comment not found");

        repo.remove(comment);
        return CommandResult(true, comment.id.value, "");
    }
}
