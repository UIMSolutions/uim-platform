/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.domain.enumerations;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

/// Mobile application target platform
enum AppPlatform {
    // Native iOS application, built using Swift or Objective-C and running on Apple devices
    ios,
    // Native Android application, built using Java or Kotlin and running on a wide range of devices from various manufacturers
    android,
    // Native Windows application, built using C# or C++ and running on Microsoft devices
    windows,
    // Web application, built using HTML, CSS, and JavaScript and accessible through a web browser on any device
    web,
    // Cross-platform application, built using frameworks like React Native, Flutter, or Xamarin that allow for a single codebase to be deployed across multiple platforms, providing a consistent user experience regardless of the underlying operating system or device
    cross
}

AppPlatform toAppPlatform(string value) {
    mixin(EnumSwitch("AppPlatform", "cross"));
}

AppPlatform[] toAppPlatforms(string[] values)
    => values.map!toAppPlatform.array;

string toString(AppPlatform value)
    => value.to!string; // This will return the enum member name as a string, e.g. "ios", "android", etc

string[] toStrings(AppPlatform[] values)
    => values.map!toString.array;
///
unittest {
    assert("ios".toAppPlatform == AppPlatform.ios);
    assert("Android".toAppPlatform == AppPlatform.android);
    assert("WINDOWS".toAppPlatform == AppPlatform.windows);
    assert("web".toAppPlatform == AppPlatform.web);
    assert("cross".toAppPlatform == AppPlatform.cross);

    assert("".toAppPlatform == AppPlatform.cross);
    assert("unknown".toAppPlatform == AppPlatform.cross);

    assert(AppPlatform.ios.toString == "ios");
    assert(AppPlatform.android.toString == "android");
    assert(AppPlatform.windows.toString == "windows");
    assert(AppPlatform.web.toString == "web");
    assert(AppPlatform.cross.toString == "cross");

    assert(["ios", "android", "windows", "web", "cross"].toAppPlatforms ==
            [
                AppPlatform.ios, AppPlatform.android, AppPlatform.windows,
                AppPlatform.web, AppPlatform.cross
            ]);
    assert([
        AppPlatform.ios, AppPlatform.android, AppPlatform.windows,
        AppPlatform.web, AppPlatform.cross
    ]. ==
        ["ios", "android", "windows", "web", "cross"]);
}

/// Lifecycle status of a registered mobile application
enum AppStatus : string {
    // Used for app registrations that are currently in development and have not yet been published, which may indicate that they are not yet available for deployment or use by end users
    draft = "draft",
    // Used for app registrations that are currently published and available for deployment or use by end users, which may indicate that they have passed any necessary testing and validation processes and are ready for production use
    active = "active",
    // Used for app registrations that are no longer recommended for use, which may indicate that they have been superseded by newer versions or have known issues that make them less desirable for deployment or use by end users, but may still be available for use in certain scenarios or for backward compatibility purposes
    deprecated_ = "deprecated",
    // Used for app registrations that are no longer active and have been withdrawn from availability, which may indicate that they have been removed from the system and are no longer accessible for deployment or use by end users, and may require cleanup or archival of any associated resources or data
    archived = "archived"
}

AppStatus toAppStatus(string value) {
    mixin(EnumSwitch("AppStatus", "draft"));
}

AppStatus[] toAppStatuses(string[] values)
    => values.map!toAppStatus.array;
string toString(AppStatus value)
    => cast(string)value; // This will return the enum member name as a string, e.g. "draft", "active", etc
string[] toStrings(AppStatus[] values)
    => values.map!toString.array;
///
unittest {
    assert("draft".toAppStatus == AppStatus.draft);
    assert("Active".toAppStatus == AppStatus.active);
    assert("DEPRECATED".toAppStatus == AppStatus.deprecated_);
    assert("archived".toAppStatus == AppStatus.archived);

    assert("".toAppStatus == AppStatus.draft);
    assert("unknown".toAppStatus == AppStatus.draft); // Default case

    assert(AppStatus.draft.toString == "draft");
    assert(AppStatus.active.toString == "active");
    assert(AppStatus.deprecated_.toString == "deprecated");
    assert(AppStatus.archived.toString == "archived");

    assert(["draft", "active", "deprecated", "archived"].toAppStatuses ==
            [
                AppStatus.draft, AppStatus.active, AppStatus.deprecated_,
                AppStatus.archived
            ]);
    assert(toStrings([
            AppStatus.draft, AppStatus.active, AppStatus.deprecated_,
            AppStatus.archived
        ]) ==
        ["draft", "active", "deprecated", "archived"]);
}

/// Lifecycle status of an app metadata definition
enum DefinitionStatus {
    // Initial state, not yet published
    draft,
    // Currently published and in use 
    published,
    // No longer recommended for use, but may still be available for use in certain scenarios or for backward compatibility purposes
    archived
}

DefinitionStatus toDefinitionStatus(string value) {
    mixin(EnumSwitch("DefinitionStatus", "draft"));
}

DefinitionStatus[] toDefinitionStatuses(string[] values)
    => values.map!toDefinitionStatus.array;
string toString(DefinitionStatus value)
    => value.to!string; // This will return the enum member name as a string, e.g. "draft", "published", etc
string[] toStrings(DefinitionStatus[] values)
    => values.map!toString.array;
///
unittest {
    assert("draft".toDefinitionStatus == DefinitionStatus.draft);
    assert("Published".toDefinitionStatus == DefinitionStatus.published);
    assert("ARCHIVED".toDefinitionStatus == DefinitionStatus.archived);

    assert("".toDefinitionStatus == DefinitionStatus.draft);
    assert("unknown".toDefinitionStatus == DefinitionStatus.draft);

    assert(DefinitionStatus.draft.toString == "draft");
    assert(DefinitionStatus.published.toString == "published");
    assert(DefinitionStatus.archived.toString == "archived");

    assert(["draft", "published", "archived"].toDefinitionStatuses ==
            [
                DefinitionStatus.draft, DefinitionStatus.published,
                DefinitionStatus.archived
            ]);
    assert(toStrings([
            DefinitionStatus.draft, DefinitionStatus.published,
            DefinitionStatus.archived
        ]) ==
        ["draft", "published", "archived"]);
}

/// Published release status of an app version
enum AppVersionStatus : string {
    // Used for app versions that are currently in development and have not yet been released, which may indicate that they are not yet available for deployment or use by end users
    pending = "pending",
    // Used for app versions that are currently published and available for deployment or use by end users, which may indicate that they have passed any necessary testing and validation processes and are ready for production use
    published = "published",
    // Used for app versions that are no longer recommended for use, which may indicate that they have been superseded by newer versions or have known issues that make them less desirable for deployment or use by end users, but may still be available for use in certain scenarios or for backward compatibility purposes
    deprecated_ = "deprecated",
    // Used for app versions that are no longer active and have been withdrawn from availability, which may indicate that they have been removed from the system and are no longer accessible for deployment or use by end users, and may require cleanup or archival of any associated resources or data
    withdrawn = "withdrawn"
}

AppVersionStatus toAppVersionStatus(string status) {
    switch (status.toLower) {
    case "pending":
        return AppVersionStatus.pending;
    case "published":
        return AppVersionStatus.published;
    case "deprecated":
        return AppVersionStatus.deprecated_;
    case "withdrawn":
        return AppVersionStatus.withdrawn;
    default:
        return AppVersionStatus.pending; // Default to pending if the input string does not match any known status
    }
}

AppVersionStatus[] toAppVersionStatuses(string[] statuses)
    => statuses.map!toAppVersionStatus.array;
string toString(AppVersionStatus value)
    => cast(string)value; // This will return the enum member name as a string, e.g. "pending", "published", etc
string[] toStrings(AppVersionStatus[] values)
    => values.map!toString.array;
///
unittest {
    assert("pending".toAppVersionStatus == AppVersionStatus.pending);
    assert("Published".toAppVersionStatus == AppVersionStatus.published);
    assert("DEPRECATED".toAppVersionStatus == AppVersionStatus.deprecated_);
    assert("withdrawn".toAppVersionStatus == AppVersionStatus.withdrawn);

    assert("".toAppVersionStatus == AppVersionStatus.pending);
    assert("unknown".toAppVersionStatus == AppVersionStatus.pending);

    assert(AppVersionStatus.pending.toString == "pending");
    assert(AppVersionStatus.published.toString == "published");
    assert(AppVersionStatus.deprecated_.toString == "deprecated");
    assert(AppVersionStatus.withdrawn.toString == "withdrawn");

    assert(["pending", "published", "deprecated", "withdrawn"].map!(toAppVersionStatus)
            .array ==
            [
                AppVersionStatus.pending, AppVersionStatus.published,
                AppVersionStatus.deprecated_, AppVersionStatus.withdrawn
            ]);
    assert(toStrings([
            AppVersionStatus.pending, AppVersionStatus.published,
            AppVersionStatus.deprecated_, AppVersionStatus.withdrawn
        ]) ==
        ["pending", "published", "deprecated", "withdrawn"]);
}

/// Enrollment and activity status of a mobile device
enum DeviceStatus {
    // Used for devices that have been enrolled in the system but may not yet be active or in use, which may require additional steps to complete the enrollment process and activate the device
    enrolled,
    // Used for devices that are currently active and in use, allowing them to receive app deployments, updates, and other management actions
    active,
    // Used for devices that have been suspended, which may indicate a temporary issue or policy violation
    suspended,
    // Used for devices that have been removed from the system, which may indicate that they are no longer in use and have been deleted from the system
    removed
}

DeviceStatus toDeviceStatus(string value) {
    mixin(EnumSwitch("DeviceStatus", "enrolled"));
}

DeviceStatus[] toDeviceStatuses(string[] values)
    => values.map!toDeviceStatus.array;
string toString(DeviceStatus value)
    => value.to!string; // This will return the enum member name as a string, e.g. "enrolled", "active", etc
string[] toStrings(DeviceStatus[] values)
    => values.map!toString.array;
///
unittest {
    assert("enrolled".toDeviceStatus == DeviceStatus.enrolled);
    assert("Active".toDeviceStatus == DeviceStatus.active);
    assert("SUSPENDED".toDeviceStatus == DeviceStatus.suspended);
    assert("removed".toDeviceStatus == DeviceStatus.removed);

    assert("".toDeviceStatus == DeviceStatus.enrolled);
    assert("unknown".toDeviceStatus == DeviceStatus.enrolled);

    assert(DeviceStatus.enrolled.toString == "enrolled");
    assert(DeviceStatus.active.toString == "active");
    assert(DeviceStatus.suspended.toString == "suspended");
    assert(DeviceStatus.removed.toString == "removed");

    assert(["enrolled", "active", "suspended", "removed"].toDeviceStatus ==
            [
                DeviceStatus.enrolled, DeviceStatus.active, DeviceStatus.suspended,
                DeviceStatus.removed
            ]);
    assert(toStrings([
            DeviceStatus.enrolled, DeviceStatus.active, DeviceStatus.suspended,
            DeviceStatus.removed
        ]) ==
        ["enrolled", "active", "suspended", "removed"]);
}

/// Status of a data synchronization session
enum SyncStatus {
    // Used for synchronization sessions that are currently pending and have not yet started, which may indicate that they are waiting for a scheduled time or for certain conditions to be met before they can begin
    pending,
    // Used for synchronization sessions that are currently in progress, which may indicate that they are actively transferring data between the mobile device and the backend system
    inProgress,
    // Used for synchronization sessions that have been completed successfully, which may indicate that the data transfer was successful and the session can be closed or archived
    completed,
    // Used for synchronization sessions that have encountered an error during the synchronization process, which may indicate that the data transfer was unsuccessful and may require troubleshooting or retrying the synchronization
    failed,
    // Used for synchronization sessions that have been cancelled, which may indicate that they were intentionally stopped before completion, either by the user or by the system, and may require cleanup or rollback of any partial data transfer
    cancelled
}

SyncStatus toSyncStatus(string value) {
    mixin(EnumSwitch("SyncStatus", "pending"));
}

SyncStatus[] toSyncStatuses(string[] values)
    => values.map!toSyncStatus.array;

string toString(SyncStatus value)
    => value.to!string; // This will return the enum member name as a string, e.g. "pending", "inProgress", etc

string[] toStrings(SyncStatus[] values)
    => values.map!toString.array;
///
unittest {
    assert("pending".toSyncStatus == SyncStatus.pending);
    assert("InProgress".toSyncStatus == SyncStatus.inProgress);
    assert("COMPLETED".toSyncStatus == SyncStatus.completed);
    assert("failed".toSyncStatus == SyncStatus.failed);
    assert("cancelled".toSyncStatus == SyncStatus.cancelled);

    assert("unknown".toSyncStatus == SyncStatus.pending);
    assert("".toSyncStatus == SyncStatus.pending);

    assert(SyncStatus.pending.toString == "pending");
    assert(SyncStatus.inProgress.toString == "inProgress");
    assert(SyncStatus.completed.toString == "completed");
    assert(SyncStatus.failed.toString == "failed");
    assert(SyncStatus.cancelled.toString == "cancelled");

    assert(["pending", "inProgress", "completed", "failed", "cancelled"].toSyncStatus ==
            [
                SyncStatus.pending, SyncStatus.inProgress, SyncStatus.completed,
                SyncStatus.failed, SyncStatus.cancelled
            ]);
    assert(toStrings([
            SyncStatus.pending, SyncStatus.inProgress, SyncStatus.completed,
            SyncStatus.failed, SyncStatus.cancelled
        ]) ==
        ["pending", "inProgress", "completed", "failed", "cancelled"]);
}

/// Synchronization direction
enum SyncDirection {
    // Used for synchronization sessions that are transferring data from the mobile device to the backend system, which may include actions like uploading logs, user data, or other information collected on the device
    upload,
    // Used for synchronization sessions that are transferring data from the backend system to the mobile device, which may include actions like downloading app updates, configuration changes, or other information needed on the device
    download,
    // Used for synchronization sessions that are transferring data in both directions between the mobile device and the backend system, which may include a combination of upload and download actions as part of a comprehensive synchronization process
    bidirectional
}

SyncDirection toSyncDirection(string value) {
    mixin(EnumSwitch("SyncDirection", "bidirectional"));
}

SyncDirection[] toSyncDirections(string[] values)
    => values.map!toSyncDirection.array;

string toString(SyncDirection value)
    => value.to!string; // This will return the enum member name as a string, e.g. "upload", "download", etc

string[] toStrings(SyncDirection[] values)
    => values.map!toString.array;
///
unittest {
    assert("upload".toSyncDirection == SyncDirection.upload);
    assert("Download".toSyncDirection == SyncDirection.download);
    assert("BIDIRECTIONAL".toSyncDirection == SyncDirection.bidirectional);

    assert("unknown".toSyncDirection == SyncDirection.bidirectional);
    assert("".toSyncDirection == SyncDirection.bidirectional);

    assert(SyncDirection.upload.toString == "upload");
    assert(SyncDirection.download.toString == "download");
    assert(SyncDirection.bidirectional.toString == "bidirectional");

    assert(["upload", "download", "bidirectional"].toSyncDirection ==
            [
                SyncDirection.upload, SyncDirection.download,
                SyncDirection.bidirectional
            ]);
    assert(toStrings([
            SyncDirection.upload, SyncDirection.download,
            SyncDirection.bidirectional
        ]) ==
        ["upload", "download", "bidirectional"]);
}

/// SAP backend system type for backend connections
enum BackendType {
    // SAP S/4HANA, the next-generation ERP suite from SAP that provides advanced capabilities for digital transformation and intelligent enterprise management
    s4hana,
    // SAP ECC (ERP Central Component), the previous generation ERP suite from SAP that is still widely used in many organizations and provides core ERP functionalities
    ecc,
    // SAP Business Technology Platform (BTP), a cloud-based platform that provides a wide range of services and tools for building, deploying, and managing applications and extensions in the SAP ecosystem
    btp,
    // SAP CRM (Customer Relationship Management), a suite of applications and tools for managing customer relationships, sales, marketing, and service processes in organizations
    crm,
    // Custom backend system, which may indicate a non-SAP system or a custom-built solution that is integrated with the mobile application management platform for specific use cases or requirements
    custom
}

BackendType toBackendType(string value) {
    mixin(EnumSwitch("BackendType", "custom"));
}

BackendType[] toBackendTypes(string[] values)
    => values.map!toBackendType.array;
string toString(BackendType value)
    => value.to!string; // This will return the enum member name as a string, e.g. "s4hana", "ecc", etc
string[] toStrings(BackendType[] values)
    => values.map!toString.array;
///
unittest {
    assert("s4hana".toBackendType == BackendType.s4hana);
    assert("ECC".toBackendType == BackendType.ecc);
    assert("BTP".toBackendType == BackendType.btp);
    assert("crm".toBackendType == BackendType.crm);

    assert("unknown".toBackendType == BackendType.custom);
    assert("".toBackendType == BackendType.custom);

    assert(BackendType.s4hana.toString == "s4hana");
    assert(BackendType.ecc.toString == "ecc");
    assert(BackendType.btp.toString == "btp");
    assert(BackendType.crm.toString == "crm");
    assert(BackendType.custom.toString == "custom");

    assert(["s4hana", "ecc", "btp", "crm", "unknown"].toBackendTypes ==
            [
                BackendType.s4hana, BackendType.ecc, BackendType.btp,
                BackendType.crm, BackendType.custom
            ]);
    assert([
        BackendType.s4hana, BackendType.ecc, BackendType.btp, BackendType.crm,
        BackendType.custom
    ].toStrings ==
        ["s4hana", "ecc", "btp", "crm", "custom"]);
}

/// Connectivity status of a backend connection
enum ConnectionStatus {
    // Used for backend connections that are currently active and able to communicate with the mobile application management platform, which may indicate that the connection is healthy and functioning as expected
    active,
    // Used for backend connections that are currently inactive and unable to communicate with the mobile application management platform, which may indicate that the connection is down, misconfigured, or experiencing issues that need to be resolved
    inactive,
    // Used for backend connections that have encountered an error during communication or operation, which may indicate that there are issues with the connection that require troubleshooting and resolution before it can be active again
    error,
    // Used for backend connections that are currently in a testing state, which may indicate that they are being validated or verified for connectivity and functionality before being marked as active or inactive, and may require monitoring and management during the testing process
    testing
}

ConnectionStatus toConnectionStatus(string value) {
    mixin(EnumSwitch("ConnectionStatus", "inactive"));
}

ConnectionStatus[] toConnectionStatuses(string[] values)
    => values.map!toConnectionStatus.array;
string toString(ConnectionStatus value)
    => value.to!string; // This will return the enum member name as a string, e.g. "active", "inactive", etc
string[] toStrings(ConnectionStatus[] values)
    => values.map!toString.array;
///
unittest {
    assert("active".toConnectionStatus == ConnectionStatus.active);
    assert("INACTIVE".toConnectionStatus == ConnectionStatus.inactive);
    assert("Error".toConnectionStatus == ConnectionStatus.error);
    assert("testing".toConnectionStatus == ConnectionStatus.testing);

    assert("unknown".toConnectionStatus == ConnectionStatus.inactive);
    assert("".toConnectionStatus == ConnectionStatus.inactive);

    assert(ConnectionStatus.active.toString == "active");
    assert(ConnectionStatus.inactive.toString == "inactive");
    assert(ConnectionStatus.error.toString == "error");
    assert(ConnectionStatus.testing.toString == "testing");

    assert(["active", "inactive", "error", "testing", "unknown"].toConnectionStatuses ==
            [
                ConnectionStatus.active, ConnectionStatus.inactive,
                ConnectionStatus.error, ConnectionStatus.testing,
                ConnectionStatus.inactive
            ]);
    assert([
        ConnectionStatus.active, ConnectionStatus.inactive, ConnectionStatus.error,
        ConnectionStatus.testing
    ].toStrings ==
        ["active", "inactive", "error", "testing"]);
}

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

DeploymentStatus[] toDeploymentStatuses(string[] values)
    => values.map!(toDeploymentStatus).array;
string toString(DeploymentStatus value)
    => value.to!string; // This will return the enum member name as a string, e.g. "pending", "deploying", etc
string[] toStrings(DeploymentStatus[] values)
    => values.map!toString.array;
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

    assert([
        "pending", "deploying", "deployed", "failed", "rolledBack", "unknown"
    ].toDeploymentStatuses ==
        [
            DeploymentStatus.pending, DeploymentStatus.deploying,
            DeploymentStatus.deployed, DeploymentStatus.failed,
            DeploymentStatus.rolledBack, DeploymentStatus.pending
        ]);
    assert([
        DeploymentStatus.pending, DeploymentStatus.deploying,
        DeploymentStatus.deployed, DeploymentStatus.failed,
        DeploymentStatus.rolledBack
    ].toStrings ==
        ["pending", "deploying", "deployed", "failed", "rolledBack"]);
}

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

DeploymentScope[] toDeploymentScope(string[] values)
    => values.map!(toDeploymentScope).array;
string toString(DeploymentScope value)
    => value.to!string; // This will return the enum member name as a string, e.g. "device", "group", etc
string[] toStrings(DeploymentScope[] values)
    => values.map!toString.array;
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
            [
                DeploymentScope.device, DeploymentScope.group,
                DeploymentScope.tenant, DeploymentScope.tenant
            ]);
    assert([
        DeploymentScope.device, DeploymentScope.group, DeploymentScope.tenant
    ].toStrings ==
        ["device", "group", "tenant"]);
}
