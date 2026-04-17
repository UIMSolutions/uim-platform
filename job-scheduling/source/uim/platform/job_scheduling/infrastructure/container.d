/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.job_scheduling.infrastructure.container;

// import uim.platform.job_scheduling.infrastructure.config;

// // Repositories
// import uim.platform.job_scheduling.infrastructure.persistence.memory.job;
// import uim.platform.job_scheduling.infrastructure.persistence.memory.schedule;
// import uim.platform.job_scheduling.infrastructure.persistence.memory.run_log;
// import uim.platform.job_scheduling.infrastructure.persistence.memory.configuration;

// // Use Cases
// import uim.platform.job_scheduling.application.usecases.manage.jobs;
// import uim.platform.job_scheduling.application.usecases.manage.schedules;
// import uim.platform.job_scheduling.application.usecases.manage.run_logs;
// import uim.platform.job_scheduling.application.usecases.manage.configurations;

// // Controllers
// import uim.platform.job_scheduling.presentation.http.controllers.job;
// import uim.platform.job_scheduling.presentation.http.controllers.schedule;
// import uim.platform.job_scheduling.presentation.http.controllers.run_log;
// import uim.platform.job_scheduling.presentation.http.controllers.configuration;
// import uim.platform.job_scheduling.presentation.http.controllers.health;
import uim.platform.job_scheduling;

mixin(ShowModule!());

@safe:
struct Container {
    // Repositories (driven adapters)
    MemoryJobRepository jobRepo;
    MemoryScheduleRepository scheduleRepo;
    MemoryRunLogRepository runLogRepo;
    MemoryConfigurationRepository configRepo;

    // Use cases (application layer)
    ManageJobsUseCase manageJobs;
    ManageSchedulesUseCase manageSchedules;
    ManageRunLogsUseCase manageRunLogs;
    ManageConfigurationsUseCase manageConfigurations;

    // Controllers (driving adapters)
    JobController jobController;
    ScheduleController scheduleController;
    RunLogController runLogController;
    ConfigurationController configurationController;
    HealthController healthController;
}

Container buildContainer(AppConfig config) {
    Container container;

    // Infrastructure adapters
    container.jobRepo = new MemoryJobRepository();
    container.scheduleRepo = new MemoryScheduleRepository();
    container.runLogRepo = new MemoryRunLogRepository();
    container.configRepo = new MemoryConfigurationRepository();

    // Application use cases
    container.manageJobs = new ManageJobsUseCase(container.jobRepo);
    container.manageSchedules = new ManageSchedulesUseCase(container.scheduleRepo);
    container.manageRunLogs = new ManageRunLogsUseCase(container.runLogRepo);
    container.manageConfigurations = new ManageConfigurationsUseCase(container.configRepo);

    // Presentation controllers
    container.jobController = new JobController(container.manageJobs, container.manageSchedules);
    container.scheduleController = new ScheduleController(container.manageSchedules);
    container.runLogController = new RunLogController(container.manageRunLogs);
    container.configurationController = new ConfigurationController(container.manageConfigurations);
    container.healthController = new HealthController("job-scheduling");

    return container;
}
