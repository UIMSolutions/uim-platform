/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.infrastructure.container;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

struct Container {
    // Repositories (driven adapters)
    MemoryDataSubjectRepository subjectRepo;
    MemoryDataSubjectRequestRepository requestRepo;
    MemoryPersonalDataRecordRepository recordRepo;
    MemoryRegisteredApplicationRepository appRepo;
    MemoryProcessingPurposeRepository purposeRepo;
    MemoryConsentRecordRepository consentRepo;
    MemoryRetentionRuleRepository retentionRepo;
    MemoryDataProcessingLogRepository logRepo;

    // Use cases (application layer)
    ManageDataSubjectsUseCase manageSubjects;
    ManageDataSubjectRequestsUseCase manageRequests;
    ManagePersonalDataRecordsUseCase manageRecords;
    ManageRegisteredApplicationsUseCase manageApplications;
    ManageProcessingPurposesUseCase managePurposes;
    ManageConsentRecordsUseCase manageConsents;
    ManageRetentionRulesUseCase manageRetention;
    ManageDataProcessingLogsUseCase manageLogs;

    // Controllers (driving adapters)
    DataSubjectController subjectController;
    DataSubjectRequestController requestController;
    PersonalDataRecordController recordController;
    RegisteredApplicationController applicationController;
    ProcessingPurposeController purposeController;
    ConsentRecordController consentController;
    RetentionRuleController retentionController;
    DataProcessingLogController logController;
    HealthController healthController;
}

Container buildContainer(SrvConfig config) {
    Container c;

    // Infrastructure adapters
    c.subjectRepo = new MemoryDataSubjectRepository();
    c.requestRepo = new MemoryDataSubjectRequestRepository();
    c.recordRepo = new MemoryPersonalDataRecordRepository();
    c.appRepo = new MemoryRegisteredApplicationRepository();
    c.purposeRepo = new MemoryProcessingPurposeRepository();
    c.consentRepo = new MemoryConsentRecordRepository();
    c.retentionRepo = new MemoryRetentionRuleRepository();
    c.logRepo = new MemoryDataProcessingLogRepository();

    // Application use cases
    c.manageSubjects = new ManageDataSubjectsUseCase(c.subjectRepo);
    c.manageRequests = new ManageDataSubjectRequestsUseCase(c.requestRepo);
    c.manageRecords = new ManagePersonalDataRecordsUseCase(c.recordRepo);
    c.manageApplications = new ManageRegisteredApplicationsUseCase(c.appRepo);
    c.managePurposes = new ManageProcessingPurposesUseCase(c.purposeRepo);
    c.manageConsents = new ManageConsentRecordsUseCase(c.consentRepo);
    c.manageRetention = new ManageRetentionRulesUseCase(c.retentionRepo);
    c.manageLogs = new ManageDataProcessingLogsUseCase(c.logRepo);

    // Presentation controllers
    c.subjectController = new DataSubjectController(c.manageSubjects);
    c.requestController = new DataSubjectRequestController(c.manageRequests);
    c.recordController = new PersonalDataRecordController(c.manageRecords);
    c.applicationController = new RegisteredApplicationController(c.manageApplications);
    c.purposeController = new ProcessingPurposeController(c.managePurposes);
    c.consentController = new ConsentRecordController(c.manageConsents);
    c.retentionController = new RetentionRuleController(c.manageRetention);
    c.logController = new DataProcessingLogController(c.manageLogs);
    c.healthController = new HealthController("personal-data", "1.0.0");

    return c;
}
