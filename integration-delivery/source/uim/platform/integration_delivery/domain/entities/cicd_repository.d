/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration_delivery.domain.entities.cicd_repository;

import uim.platform.integration_delivery;

mixin(ShowModule!());

@safe:

struct CicdRepository {
    mixin TenantEntity!(CicdRepositoryId);

    string name;
    string description;
    RepositoryType repositoryType = RepositoryType.github;
    string url;
    CredentialId credentialId;
    string defaultBranch;
    string webhookUrl;
    bool webhookEnabled;
    RepositoryStatus status = RepositoryStatus.active;
    long lastSyncAt;

    Json toJson() const {
        return entityToJson
            .set("name", name)
            .set("description", description)
            .set("repositoryType", repositoryType.to!string)
            .set("url", url)
            .set("credentialId", credentialId.value)
            .set("defaultBranch", defaultBranch)
            .set("webhookUrl", webhookUrl)
            .set("webhookEnabled", webhookEnabled)
            .set("status", status.to!string)
            .set("lastSyncAt", lastSyncAt);
    }
}
