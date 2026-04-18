module uim.platform.abap_enviroment.domain.entities.execution_log;

import uim.platform.abap_enviroment;

mixin(ShowModule!());

@safe:

struct JobExecutionLog {
    string executionId;
    JobStatus status;
    long startedAt;
    long finishedAt;
    string message;
    int returnCode;

    Json toJson() {
        return Json.emptyObject
            .set("executionId", executionId)
            .set("status", status.to!string)
            .set("startedAt", startedAt)
            .set("finishedAt", finishedAt)
            .set("message", message)
            .set("returnCode", returnCode);
    }
}
