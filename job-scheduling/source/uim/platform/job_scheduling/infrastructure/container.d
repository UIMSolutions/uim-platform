/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.job_scheduling.infrastructure.container;

import uim.platform.job_scheduling.infrastructure.config;

// Repositories
import uim.platform.job_scheduling.infrastructure.persistence.memory.job_repo;
import uim.platform.job_scheduling.infrastructure.persistence.memory.schedule_repo;
import uim.platform.job_scheduling.infrastructure.persistence.memory.run_log_repo;
import uim.platform.job_scheduling.infrastructure.persistence.memory.configuration_repo;

// Use Cases
import uim.platform.job_scheduling.application.usecases.manage.jobs;
import uim.platform.job_scheduling.application.usecases.manage.schedules;
import uim.platform.job_scheduling.application.usecases.manage.run_logs;
import uim.platform.job_scheduling.application.usecases.manage.configurations;

// Controllers
import uim.platform.job_scheduling.presentation.http.controllers.job;
import uim.platform.job_scheduling.presentation.http.controllers.schedule;
import uim.platform.job_scheduling.presentation.http.controllers.run_log;
import uim.platform.job_scheduling.presentation.http.controllers.configuration;
import uim.platform.job_scheduling.presentation.http.controllers.health;

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
    Container c;

    // Infrastructure adapters
    c.jobRepo = new MemoryJobRepository();
    c.scheduleRepo = new MemoryScheduleRepository();
    c.runLogRepo = new MemoryRunLogRepository();
    c.configRepo = new MemoryConfigurationRepository();

    // Application use cases
    c.manageJobs = new ManageJobsUseCase(c.jobRepo);
    c.manageSchedules = new ManageSchedulesUseCase(c.scheduleRepo);
    c.manageRunLogs = new ManageRunLogsUseCase(c.runLogRepo);
    c.manageConfigurations = new ManageConfigurationsUseCase(c.configRepo);

    // Presentation controllers
    c.jobController = new JobController(c.manageJobs, c.manageSchedules);
    c.scheduleController = new ScheduleController(c.manageSchedules);
    c.runLogController = new RunLogController(c.manageRunLogs);
    c.configurationController = new ConfigurationController(c.manageConfigurations);
    c.healthController = new HealthController();

    return c;
}
