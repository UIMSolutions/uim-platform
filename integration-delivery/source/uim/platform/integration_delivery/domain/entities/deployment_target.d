/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration_delivery.domain.entities.deployment_target;

import uim.platform.integration_delivery;

mixin(ShowModule!());

@safe:

struct DeploymentTarget {
    mixin TenantEntity!(DeploymentTargetId);

    string name;
    string description;
    DeploymentTargetType targetType = DeploymentTargetType.cloudFoundry;
    string url;
    CredentialId credentialId;
    string organization;
    string spaceOrNamespace;
    string region;
    DeploymentTargetStatus status = DeploymentTargetStatus.active;
    long lastDeployedAt;

    Json toJson() const {
        return entityToJson
            .set("name", name)
            .set("description", description)
            .set("targetType", targetType.to!string)
            .set("url", url)
            .set("credentialId", credentialId.value)
            .set("organization", organization)
            .set("spaceOrNamespace", spaceOrNamespace)
            .set("region", region)
            .set("status", status.to!string)
            .set("lastDeployedAt", lastDeployedAt);
    }
}
