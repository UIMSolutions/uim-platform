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
string toString(AppPlatform value) {
    return value.to!string; // This will return the enum member name as a string, e.g. "ios", "android", etc
}
///
unittest {
    assert(toAppPlatform("ios") == AppPlatform.ios);
    assert(toAppPlatform("Android") == AppPlatform.android);
    assert(toAppPlatform("WINDOWS") == AppPlatform.windows);
    assert(toAppPlatform("web") == AppPlatform.web);
    assert(toAppPlatform("cross") == AppPlatform.cross);
    assert(toAppPlatform("unknown") == AppPlatform.cross);

    assert(AppPlatform.ios.toString == "ios");
    assert(AppPlatform.android.toString == "android");
    assert(AppPlatform.windows.toString == "windows");
    assert(AppPlatform.web.toString == "web");
    assert(AppPlatform.cross.toString == "cross");
}

/// Lifecycle status of a registered mobile application
enum AppStatus : string{
    // Used for app registrations that are currently in development and have not yet been published, which may indicate that they are not yet available for deployment or use by end users
    draft = "draft", 
    // Used for app registrations that are currently published and available for deployment or use by end users, which may indicate that they have passed any necessary testing and validation processes and are ready for production use
    active = "active",
    // Used for app registrations that are no longer recommended for use, which may indicate that they have been superseded by newer versions or have known issues that make them less desirable for deployment or use by end users, but may still be available for use in certain scenarios or for backward compatibility purposes
    deprecated_ = "deprecated", 
    // Used for app registrations that are no longer active and have been withdrawn from availability, which may indicate that they have been removed from the system and are no longer accessible for deployment or use by end users, and may require cleanup or archival of any associated resources or data
    archived = "archived" 
}
AppStatus toAppStatus(string status) {
    switch(status.toLower) {
        case "draft": return AppStatus.draft;
        case "active": return AppStatus.active;
        case "deprecated": return AppStatus.deprecated_;
        case "archived": return AppStatus.archived;
        default: return AppStatus.draft; // Default to draft if the input string does not match any known status
    }
}
string toString(AppStatus value) {
    return cast(string)value; // This will return the enum member name as a string, e.g. "draft", "active", etc
}
///
unittest {
    assert(toAppStatus("draft") == AppStatus.draft);
    assert(toAppStatus("Active") == AppStatus.active);
    assert(toAppStatus("DEPRECATED") == AppStatus.deprecated_);
    assert(toAppStatus("archived") == AppStatus.archived);
    assert(toAppStatus("unknown") == AppStatus.draft);

    assert(AppStatus.draft.toString == "draft");
    assert(AppStatus.active.toString == "active");
    assert(AppStatus.deprecated_.toString == "deprecated");
    assert(AppStatus.archived.toString == "archived");
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
string toString(DefinitionStatus value) {
    return value.to!string; // This will return the enum member name as a string, e.g. "draft", "published", etc
}
///
unittest {
    assert(toDefinitionStatus("draft") == DefinitionStatus.draft);
    assert(toDefinitionStatus("Published") == DefinitionStatus.published);
    assert(toDefinitionStatus("ARCHIVED") == DefinitionStatus.archived);
    assert(toDefinitionStatus("unknown") == DefinitionStatus.draft);

    assert(DefinitionStatus.draft.toString == "draft");
    assert(DefinitionStatus.published.toString == "published");
    assert(DefinitionStatus.archived.toString == "archived");   
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
    switch(status.toLower) {
        case "pending": return AppVersionStatus.pending;
        case "published": return AppVersionStatus.published;
        case "deprecated": return AppVersionStatus.deprecated_;
        case "withdrawn": return AppVersionStatus.withdrawn;
        default: return AppVersionStatus.pending; // Default to pending if the input string does not match any known status
    }
}
string toString(AppVersionStatus value) {
    return cast(string)value; // This will return the enum member name as a string, e.g. "pending", "published", etc
}
///
unittest {
    assert(toAppVersionStatus("pending") == AppVersionStatus.pending);
    assert(toAppVersionStatus("Published") == AppVersionStatus.published);
    assert(toAppVersionStatus("DEPRECATED") == AppVersionStatus.deprecated_);
    assert(toAppVersionStatus("withdrawn") == AppVersionStatus.withdrawn);
    assert(toAppVersionStatus("unknown") == AppVersionStatus.pending);

    assert(AppVersionStatus.pending.toString == "pending");
    assert(AppVersionStatus.published.toString == "published");
    assert(AppVersionStatus.deprecated_.toString == "deprecated");
    assert(AppVersionStatus.withdrawn.toString == "withdrawn"); 
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
string toString(DeviceStatus value) {
    return value.to!string; // This will return the enum member name as a string, e.g. "enrolled", "active", etc
}
///
unittest {
    assert(toDeviceStatus("enrolled") == DeviceStatus.enrolled);
    assert(toDeviceStatus("Active") == DeviceStatus.active);
    assert(toDeviceStatus("SUSPENDED") == DeviceStatus.suspended);
    assert(toDeviceStatus("removed") == DeviceStatus.removed);
    assert(toDeviceStatus("unknown") == DeviceStatus.enrolled);

    assert(DeviceStatus.enrolled.toString == "enrolled");
    assert(DeviceStatus.active.toString == "active");
    assert(DeviceStatus.suspended.toString == "suspended");
    assert(DeviceStatus.removed.toString == "removed"); 
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
string toString(SyncStatus value) {
    return value.to!string; // This will return the enum member name as a string, e.g. "pending", "inProgress", etc
}
///
unittest {
    assert(toSyncStatus("pending") == SyncStatus.pending);
    assert(toSyncStatus("InProgress") == SyncStatus.inProgress);
    assert(toSyncStatus("COMPLETED") == SyncStatus.completed);
    assert(toSyncStatus("failed") == SyncStatus.failed);
    assert(toSyncStatus("cancelled") == SyncStatus.cancelled);
    assert(toSyncStatus("unknown") == SyncStatus.pending);

    assert(SyncStatus.pending.toString == "pending");
    assert(SyncStatus.inProgress.toString == "inProgress");
    assert(SyncStatus.completed.toString == "completed");
    assert(SyncStatus.failed.toString == "failed");
    assert(SyncStatus.cancelled.toString == "cancelled"); 
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
string toString(SyncDirection value) {
    return value.to!string; // This will return the enum member name as a string, e.g. "upload", "download", etc
}
///
unittest {
    assert(toSyncDirection("upload") == SyncDirection.upload);
    assert(toSyncDirection("Download") == SyncDirection.download);
    assert(toSyncDirection("BIDIRECTIONAL") == SyncDirection.bidirectional);
    assert(toSyncDirection("unknown") == SyncDirection.bidirectional);

    assert(SyncDirection.upload.toString == "upload");
    assert(SyncDirection.download.toString == "download");
    assert(SyncDirection.bidirectional.toString == "bidirectional"); 
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
string toString(BackendType value) {
    return value.to!string; // This will return the enum member name as a string, e.g. "s4hana", "ecc", etc
}
///
unittest {
    assert(toBackendType("s4hana") == BackendType.s4hana);
    assert(toBackendType("ECC") == BackendType.ecc);
    assert(toBackendType("BTP") == BackendType.btp);
    assert(toBackendType("crm") == BackendType.crm);
    assert(toBackendType("unknown") == BackendType.custom);

    assert(BackendType.s4hana.toString == "s4hana");
    assert(BackendType.ecc.toString == "ecc");
    assert(BackendType.btp.toString == "btp");
    assert(BackendType.crm.toString == "crm");
    assert(BackendType.custom.toString == "custom"); 
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
string toString(ConnectionStatus value) {
    return value.to!string; // This will return the enum member name as a string, e.g. "active", "inactive", etc
}
///
unittest {
    assert(toConnectionStatus("active") == ConnectionStatus.active);
    assert(toConnectionStatus("INACTIVE") == ConnectionStatus.inactive);
    assert(toConnectionStatus("Error") == ConnectionStatus.error);
    assert(toConnectionStatus("testing") == ConnectionStatus.testing);
    assert(toConnectionStatus("unknown") == ConnectionStatus.inactive);

    assert(ConnectionStatus.active.toString == "active");
    assert(ConnectionStatus.inactive.toString == "inactive");
    assert(ConnectionStatus.error.toString == "error");
    assert(ConnectionStatus.testing.toString == "testing");
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
string toString(DeploymentStatus value) {
    return value.to!string; // This will return the enum member name as a string, e.g. "pending", "deploying", etc
}
///
unittest {
    assert(toDeploymentStatus("pending") == DeploymentStatus.pending);
    assert(toDeploymentStatus("DEPLOYING") == DeploymentStatus.deploying);
    assert(toDeploymentStatus("Deployed") == DeploymentStatus.deployed);
    assert(toDeploymentStatus("failed") == DeploymentStatus.failed);
    assert(toDeploymentStatus("rolledBack") == DeploymentStatus.rolledBack);
    assert(toDeploymentStatus("unknown") == DeploymentStatus.pending);

    assert(DeploymentStatus.pending.toString == "pending");
    assert(DeploymentStatus.deploying.toString == "deploying");
    assert(DeploymentStatus.deployed.toString == "deployed");
    assert(DeploymentStatus.failed.toString == "failed");
    assert(DeploymentStatus.rolledBack.toString == "rolledBack");
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
string toString(DeploymentScope value) {
    return value.to!string; // This will return the enum member name as a string, e.g. "device", "group", etc
}
///
unittest {
    assert(toDeploymentScope("device") == DeploymentScope.device);
    assert(toDeploymentScope("GROUP") == DeploymentScope.group);
    assert(toDeploymentScope("Tenant") == DeploymentScope.tenant);
    assert(toDeploymentScope("unknown") == DeploymentScope.tenant);

    assert(DeploymentScope.device.toString == "device");
    assert(DeploymentScope.group.toString == "group");
    assert(DeploymentScope.tenant.toString == "tenant"); 
}
