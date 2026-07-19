module uim.platform.task_center.application.dtos.taskcomment;

import uim.platform.task_center;
mixin(ShowModule!());

@safe:
struct CreateTaskCommentRequest {
    TenantId tenantId; // This is needed to identify the tenant to which the task comment belongs, which is important for multi-tenancy support and ensuring that the comment is created in the correct context.
    TaskCommentId commentId; // This is needed to ensure idempotency of the request. The client can generate a UUID and pass it here. If a task comment with the same ID already exists, the service can return the existing comment instead of creating a new one.
    TaskId taskId; // This is needed to link the comment to the task on which it is being made, which is important for tracking and processing the comment correctly.
    UserId author; // This is needed to identify the user who is making the comment, which is important for auditing and accountability purposes.
    string content; // The content of the comment. This is a required field, as it contains the actual comment being made and is essential for the purpose of the comment.
    UserId createdBy; // The user who is creating the comment. This is important for auditing purposes, as it allows the system to track who created the comment.
    string[string] customAttributes; // Custom attributes for the comment. This is an optional field, but it can be used to store additional information about the comment that may be relevant for processing or

}

struct UpdateTaskCommentRequest {
    TenantId tenantId; // This is needed to identify the tenant to which the task comment belongs, which is important for multi-tenancy support and ensuring that the comment is updated in the correct context.
    TaskCommentId commentId; // This is needed to identify which comment to update. The client must pass the ID of the comment to be updated.
    string content; // The new content of the comment. This field is optional; if the client does not want to update the content, it can be left empty or null.
    UserId updatedBy; // The user who is performing the update operation. This is important for auditing purposes, as it allows the system to track who made changes to the comment.
    string[string] customAttributes; // The new custom attributes for the comment. This field is optional; if the client does not want to update the custom attributes, it can be left empty or null.
}
