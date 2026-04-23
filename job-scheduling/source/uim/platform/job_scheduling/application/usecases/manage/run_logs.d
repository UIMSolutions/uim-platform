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

// import uim.platform.service;
// import std.conv : to;

// alias RunLog = uim.platform.job_scheduling.domain.entities.run_log.RunLog;
import uim.platform.job_scheduling;

mixin(ShowModule!());

@safe:
class ManageRunLogsUseCase { // TODO: UIMUseCase {
    private RunLogRepository repo;

    this(RunLogRepository repo) {
        this.repo = repo;
    }

    RunLog getById(RunLogId id) {
        return repo.findById(id);
    }

    RunLog[] listBySchedule(TenantId tenantId, ScheduleId scheduleId, JobId jobId) {
        return repo.findBySchedule(tenantId, scheduleId, jobId);
    }

    RunLog[] listByJob(TenantId tenantId, JobId jobId) {
        return repo.findByJob(tenantId, jobId);
    }

    CommandResult createRunLog(TenantId tenantId, ScheduleId scheduleId, JobId jobId) {
        import std.uuid : randomUUID;

        auto id = randomUUID();

        RunLog r;
        r.id = id;
        r.scheduleId = scheduleId;
        r.jobId = jobId;
        r.tenantId = tenantId;
        r.status = RunStatus.scheduled;

        import core.time : MonoTime;

        auto now = MonoTime.currTime.ticks;
        r.scheduledAt = now;
        r.createdAt = now;

        repo.save(r);
        return CommandResult(true, r.id, "");
    }

    CommandResult updateStatus(UpdateRunLogRequest req) {
        if (!repo.existsById(req.runLogId))
            return CommandResult(false, "", "Run log not found");

        auto existing = repo.findById(req.runLogId);
        auto targetStatus = req.status.to!RunStatus;
        if (!RunTracker.canTransition(existing.status, targetStatus))
            return CommandResult(false, "", "Invalid status transition");

        existing.status = targetStatus;
        if (req.statusMessage.length > 0)
            existing.statusMessage = req.statusMessage;
        existing.httpStatus = req.httpStatus;
        existing.completedAt = req.completedAt;
        existing.executionDurationMs = req.executionDurationMs;

        if (targetStatus == RunStatus.triggered) {
            import core.time : MonoTime;

            existing.triggeredAt = MonoTime.currTime.ticks;
        }

        repo.update(existing);
        return CommandResult(true, existing.id, "");
    }

}
