/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Dependency injection container — wires repositories, use cases, and controllers.
module uim.platform.identity.infrastructure.container;

import uim.platform.identity;

@safe:

struct Container {
    ManageUsersUseCase manageUsersUseCase;
    ManageGroupsUseCase manageGroupsUseCase;
    ManageApplicationsUseCase manageApplicationsUseCase;
    ManageIdentityProvidersUseCase manageIdentityProvidersUseCase;
    ManageProvisioningJobsUseCase manageProvisioningJobsUseCase;

    UserController userController;
    GroupController groupController;
    ApplicationController applicationController;
    IdentityProviderController identityProviderController;
    ProvisioningJobController provisioningJobController;

    IdentityWebController identityWebController;
    IdentityCliController identityCliController;
}

Container buildContainer(SrvConfig config) @trusted {
    Container c;
    UserRepository userRepo;
    GroupRepository groupRepo;
    ApplicationRepository appRepo;
    IdentityProviderRepository idpRepo;
    ProvisioningJobRepository jobRepo;

    final switch (config.backend) {
        case PersistenceBackend.memory:
            userRepo = new MemoryUserRepository();
            groupRepo = new MemoryGroupRepository();
            appRepo = new MemoryApplicationRepository();
            idpRepo = new MemoryIdentityProviderRepository();
            jobRepo = new MemoryProvisioningJobRepository();
            break;
        case PersistenceBackend.file_:
            import std.file : mkdirRecurse;
            mkdirRecurse(config.dataDir);
            userRepo = new FileUserRepository(config.dataDir);
            groupRepo = new FileGroupRepository(config.dataDir);
            appRepo = new FileApplicationRepository(config.dataDir);
            idpRepo = new FileIdentityProviderRepository(config.dataDir);
            jobRepo = new FileProvisioningJobRepository(config.dataDir);
            break;
        case PersistenceBackend.mongodb:
            import vibe.db.mongo.mongo : connectMongoDB;
            auto mongoClient = connectMongoDB(config.mongoUri);
            auto db = mongoClient.getDatabase(config.mongoDb);
            userRepo = new MongoUserRepository(db["users"]);
            groupRepo = new MongoGroupRepository(db["groups"]);
            appRepo = new MongoApplicationRepository(db["applications"]);
            idpRepo = new MongoIdentityProviderRepository(db["identity_providers"]);
            jobRepo = new MongoProvisioningJobRepository(db["provisioning_jobs"]);
            break;
    }

    c.manageUsersUseCase = new ManageUsersUseCase(userRepo);
    c.manageGroupsUseCase = new ManageGroupsUseCase(groupRepo);
    c.manageApplicationsUseCase = new ManageApplicationsUseCase(appRepo);
    c.manageIdentityProvidersUseCase = new ManageIdentityProvidersUseCase(idpRepo);
    c.manageProvisioningJobsUseCase = new ManageProvisioningJobsUseCase(jobRepo);

    c.userController = new UserController(c.manageUsersUseCase);
    c.groupController = new GroupController(c.manageGroupsUseCase);
    c.applicationController = new ApplicationController(c.manageApplicationsUseCase);
    c.identityProviderController = new IdentityProviderController(c.manageIdentityProvidersUseCase);
    c.provisioningJobController = new ProvisioningJobController(c.manageProvisioningJobsUseCase);

    c.identityWebController = new IdentityWebController(
        c.manageUsersUseCase, c.manageGroupsUseCase, c.manageApplicationsUseCase);
    c.identityCliController = new IdentityCliController(
        c.manageUsersUseCase, c.manageGroupsUseCase, c.manageApplicationsUseCase, c.manageProvisioningJobsUseCase);

    return c;
}
