/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.domain.enumerations.deployment_status;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

/// Deployment lifecycle status
enum DeploymentStatus {
    // Used for deployments that are currently pending and have not yet started, which may indicate that they are waiting for a scheduled time or for certain conditions to be met before they can begin
    pending,
    // Used for deployments that are currently in progress, which may indicate that they are actively being deployed to target devices or groups, and may require monitoring and management during the deployment process
    deploying,
    // Used for deployments that have been successfully deployed to target devices or groups, which may indicate that the deployment was successful and the new app version or configuration is now active on the target devices
    deployed,
    // Used for deployments that have encountered an error during the deployment process, which may indicate that the deployment was unsuccessful and may require troubleshooting or retrying the deployment
    failed,
    // Used for deployments that have been rolled back to a previous version or configuration, which may indicate that the deployment was unsuccessful or caused issues on the target devices, and the system has reverted to a known good state to mitigate any problems
    rolledBack
}

DeploymentStatus toDeploymentStatus(string value) {
    mixin(EnumSwitch("DeploymentStatus", "pending"));
}

DeploymentStatus[] toDeploymentStatuses(string[] values) {
    return values.map!(toDeploymentStatus).array;
}
string toString(DeploymentStatus value) {
    return value.to!string; // This will return the enum member name as a string, e.g. "pending", "deploying", etc
}
string[] toString(DeploymentStatus[] values) {
    return values.map!toString.array;
}
///
unittest {
    assert("pending".toDeploymentStatus == DeploymentStatus.pending);
    assert("DEPLOYING".toDeploymentStatus == DeploymentStatus.deploying);
    assert("Deployed".toDeploymentStatus == DeploymentStatus.deployed);
    assert("failed".toDeploymentStatus == DeploymentStatus.failed);
    assert("rolledBack".toDeploymentStatus == DeploymentStatus.rolledBack);

    assert("unknown".toDeploymentStatus == DeploymentStatus.pending);
    assert("".toDeploymentStatus == DeploymentStatus.pending);

    assert(DeploymentStatus.pending.toString == "pending");
    assert(DeploymentStatus.deploying.toString == "deploying");
    assert(DeploymentStatus.deployed.toString == "deployed");
    assert(DeploymentStatus.failed.toString == "failed");
    assert(DeploymentStatus.rolledBack.toString == "rolledBack");

    assert(["pending", "deploying", "deployed", "failed", "rolledBack", "unknown"
    ].toDeploymentStatuses ==
        [    DeploymentStatus.pending, DeploymentStatus.deploying,
            DeploymentStatus.deployed, DeploymentStatus.failed,
            DeploymentStatus.rolledBack, DeploymentStatus.pending
        ]);
    assert([DeploymentStatus.pending, DeploymentStatus.deploying,
        DeploymentStatus.deployed, DeploymentStatus.failed,
        DeploymentStatus.rolledBack
    ].toString ==
        ["pending", "deploying", "deployed", "failed", "rolledBack"]);
}
