/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.job_scheduling.application.usecases.manage.run_logs;
// import uim.platform.job_scheduling.domain.types;
// import uim.platform.job_scheduling.domain.entities.run_log;
// import uim.platform.job_scheduling.domain.ports.repositories.run_logs;
// import uim.platform.job_scheduling.domain.services.run_tracker;
// import uim.platform.job_scheduling.application.dto;


// alias RunLog = uim.platform.job_scheduling.domain.entities.run_log.RunLog;
import uim.platform.job_scheduling;

mixin(ShowModule!());

@safe:
class ManageRunLogsUseCase { // TODO: UIMUseCase {
    private RunLogRepository repo;

    this(RunLogRepository repo) {
        this.repo = repo;
    }

    RunLog getById(TenantId tenantId, RunLogId id) {
        return repo.findById(tenantId, id);
    }

    RunLog[] listRunLogs(TenantId tenantId, ScheduleId scheduleId) {
        return repo.findBySchedule(tenantId, scheduleId);
    }

    RunLog[] listRunLogs(TenantId tenantId, JobId jobId) {
        return repo.findByJob(tenantId, jobId);
    }

    CommandResult createRunLog(TenantId tenantId, ScheduleId scheduleId, JobId jobId) {
        RunLog runlog;
        runlog.initEntity(tenantId);
        runlog.scheduleId = scheduleId;
        runlog.jobId = jobId;
        runlog.tenantId = precheck.tenantId;
        runlog.status = RunStatus.scheduled;
        runlog.scheduledAt = runlog.createdAt;

        repo.save(runlog);
        return CommandResult(true, runlog.id.value, "");
    }

    CommandResult updateStatus(UpdateRunLogRequest req) {
        auto runlog = repo.findById(req.tenantId, req.runLogId);
        if (runlog.isNull)
            return CommandResult(false, "", "Run log not found");

        auto targetStatus = req.status.to!RunStatus;
        if (!RunTracker.canTransition(runlog.status, targetStatus))
            return CommandResult(false, "", "Invalid status transition");

        runlog.status = targetStatus;
        if (req.statusMessage.length > 0)
            runlog.statusMessage = req.statusMessage;
        runlog.httpStatus = req.httpStatus;
        runlog.completedAt = req.completedAt;
        runlog.executionDurationMs = req.executionDurationMs;

        if (targetStatus == RunStatus.triggered) {
            import core.time : MonoTime;

            runlog.triggeredAt = currentTimestamp;
        }

        repo.update(runlog);
        return CommandResult(true, runlog.id.value, "");
    }
}
