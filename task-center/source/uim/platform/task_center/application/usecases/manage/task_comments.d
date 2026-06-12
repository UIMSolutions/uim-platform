/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.application.usecases.manage.task_comments;

import uim.platform.task_center;

// mixin(ShowModule!());

@safe:

class ManageTaskCommentsUseCase { // TODO: UIMUseCase {
    private TaskCommentRepository repo;

    this(TaskCommentRepository repo) {
        this.repo = repo;
    }

    TaskComment getComment(TenantId tenantId, TaskCommentId id) {
        return repo.findById(tenantId, id);
    }

    TaskComment[] listComments(TenantId tenantId, TaskId byTaskId) {
        return repo.findByTask(tenantId, byTaskId);
    }

    CommandResult createComment(CreateTaskCommentRequest req) {
        TaskComment comment;
        comment.initEntity(req.tenantId);

        comment.id = req.commentId;
        comment.taskId = req.taskId;
        // TODO: comment.author = req.author;
        comment.content = req.content;

        repo.save(comment);
        return CommandResult(true, comment.id.value, "");
    }

    CommandResult updateComment(UpdateTaskCommentRequest req) {
        auto existing = repo.findById(req.tenantId, req.commentId);
        if (existing.isNull)
            return CommandResult(false, "", "Comment not found");
        if (req.content.length > 0) existing.content = req.content;
 
        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteComment(TenantId tenantId, TaskCommentId id) {
        auto comment = repo.findById(tenantId, id);
        if (comment.isNull)
            return CommandResult(false, "", "Comment not found");

        repo.remove(comment);
        return CommandResult(true, comment.id.value, "");
    }
}
