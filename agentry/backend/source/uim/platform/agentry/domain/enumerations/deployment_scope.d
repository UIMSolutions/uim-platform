/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.domain.enumerations.deployment_scope;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

/// Target scope of a deployment
enum DeploymentScope {
    // Used for deployments that are targeted to individual devices, which may indicate that the deployment is intended for specific devices based on criteria like device ID, user assignment, or other attributes
    device,
    // Used for deployments that are targeted to groups of devices, which may indicate that the deployment is intended for a collection of devices that share certain characteristics or are organized into logical groups for management purposes
    group,
    // Used for deployments that are targeted to an entire tenant, which may indicate that the deployment is intended for all devices and users within a specific tenant or organizational unit, and may require broader coordination and communication to ensure successful deployment across the entire scope
    tenant
}

DeploymentScope toDeploymentScope(string value) {
    mixin(EnumSwitch("DeploymentScope", "tenant"));
}

DeploymentScope[] toDeploymentScopes(string[] values) {
    return values.map!(toDeploymentScope).array;
}
string toString(DeploymentScope value) {
    return value.to!string; // This will return the enum member name as a string, e.g. "device", "group", etc
}
string[] toString(DeploymentScope[] values) {
    return values.map!toString.array;
}
///
unittest {
    assert("device".toDeploymentScope == DeploymentScope.device);
    assert("GROUP".toDeploymentScope == DeploymentScope.group);
    assert("Tenant".toDeploymentScope == DeploymentScope.tenant);

    assert("unknown".toDeploymentScope == DeploymentScope.tenant);
    assert("".toDeploymentScope == DeploymentScope.tenant);

    assert(DeploymentScope.device.toString == "device");
    assert(DeploymentScope.group.toString == "group");
    assert(DeploymentScope.tenant.toString == "tenant");
    assert(["device", "group", "tenant", "unknown"].toDeploymentScopes ==
            [        DeploymentScope.device, DeploymentScope.group,
                DeploymentScope.tenant, DeploymentScope.tenant
            ]);
    assert([DeploymentScope.device, DeploymentScope.group, DeploymentScope.tenant
    ].toString ==
        ["device", "group", "tenant"]);
}
