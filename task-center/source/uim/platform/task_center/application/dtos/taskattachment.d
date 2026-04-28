module uim.platform.task_center.application.dtos.taskattachment;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:
struct CreateTaskAttachmentRequest {
    TenantId tenantId;
    string id;
    string taskId;
    string fileName;
    string fileSize;
    string mimeType;
    string uploadedBy;
}