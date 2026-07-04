module uim.platform.task_center.application.dtos.taskattachment;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:
struct CreateTaskAttachmentRequest {
    TenantId tenantId; // This is needed to identify the tenant to which the task attachment belongs, which is important for multi-tenancy support and ensuring that the attachment is created in the correct context.  
    TaskAttachmentId attachmentId; // This is needed to ensure idempotency of the request. The client can generate a UUID and pass it here. If a task attachment with the same ID already exists, the service can return the existing attachment instead of creating a new one.
    TaskId taskId; // This is needed to link the attachment to the task to which it belongs, which is important for tracking and processing the attachment correctly.

    string fileName; // The name of the attached file. This is a required field, as it provides a reference to the file being attached and is often used in attachment lists and notifications.
    string fileSize; // The size of the attached file. This is a required field, as it provides information about the file being attached and can be used for validation and display purposes.
    string mimeType; // The MIME type of the attached file. This is a required field, as it provides information about the type of file being attached and can be used for validation and display purposes.
    UserId uploadedBy; // The user who is uploading the attachment. This is important for auditing purposes, as it allows the system to track who uploaded the attachment.
    string[string] customAttributes; // Custom attributes for the attachment. This is an optional field, but it can be used to store additional information about the attachment that may be relevant for processing or
}

struct UpdateTaskAttachmentRequest {
    TenantId tenantId; // This is needed to identify the tenant to which the task attachment belongs, which is important for multi-tenancy support and ensuring that the attachment is updated in the correct context.  
    TaskAttachmentId attachmentId; // This is needed to identify which attachment to update. The client must pass the ID of the attachment to be updated.
    string fileName; // The new name of the attached file. This field is optional; if the client does not want to update the file name, it can be left empty or null.
    string fileSize; // The new size of the attached file. This field is optional; if the client does not want to update the file size, it can be left empty or null.
    string mimeType; // The new MIME type of the attached file. This field is optional; if the client does not want to update the MIME type, it can be left empty or null.
    UserId updatedBy; // The user who is performing the update operation. This is important for auditing purposes, as it allows the system to track who made changes to the attachment.
    string[string] customAttributes; // The new custom attributes for the attachment. This field is optional; if the client does not want to update the custom attributes, it can be left empty or null.
}
