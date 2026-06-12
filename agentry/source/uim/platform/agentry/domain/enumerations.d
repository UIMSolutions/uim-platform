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
AppPlatform toAppPlatform(string platform) {
    const map = [
        "ios": AppPlatform.ios,
        "android": AppPlatform.android,
        "windows": AppPlatform.windows,
        "web": AppPlatform.web,
        "cross": AppPlatform.cross
    ];
    return map.get(platform.toLower, AppPlatform.cross);
}

/// Lifecycle status of a registered mobile application
enum AppStatus {
    // Used for app registrations that are currently in development and have not yet been published, which may indicate that they are not yet available for deployment or use by end users
    draft, 
    // Used for app registrations that are currently published and available for deployment or use by end users, which may indicate that they have passed any necessary testing and validation processes and are ready for production use
    active,
    // Used for app registrations that are no longer recommended for use, which may indicate that they have been superseded by newer versions or have known issues that make them less desirable for deployment or use by end users, but may still be available for use in certain scenarios or for backward compatibility purposes
    deprecated_, 
    // Used for app registrations that are no longer active and have been withdrawn from availability, which may indicate that they have been removed from the system and are no longer accessible for deployment or use by end users, and may require cleanup or archival of any associated resources or data
    archived 
}
AppStatus toAppStatus(string status) {
    const map = [
        "draft": AppStatus.draft,
        "active": AppStatus.active,
        "deprecated": AppStatus.deprecated_,
        "archived": AppStatus.archived
    ];
    return map.get(status.toLower, AppStatus.draft);
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
DefinitionStatus toDefinitionStatus(string status) {
    const map = [
        "draft": DefinitionStatus.draft,
        "published": DefinitionStatus.published,
        "archived": DefinitionStatus.archived
    ];
    return map.get(status.toLower, DefinitionStatus.draft);
}

/// Published release status of an app version
enum AppVersionStatus {
    // Used for app versions that are currently in development and have not yet been released, which may indicate that they are not yet available for deployment or use by end users
    pending,
    // Used for app versions that are currently published and available for deployment or use by end users, which may indicate that they have passed any necessary testing and validation processes and are ready for production use
    published,
    // Used for app versions that are no longer recommended for use, which may indicate that they have been superseded by newer versions or have known issues that make them less desirable for deployment or use by end users, but may still be available for use in certain scenarios or for backward compatibility purposes
    deprecated_, 
    // Used for app versions that are no longer active and have been withdrawn from availability, which may indicate that they have been removed from the system and are no longer accessible for deployment or use by end users, and may require cleanup or archival of any associated resources or data
    withdrawn 
}
AppVersionStatus toAppVersionStatus(string status) {
    const map = [
        "pending": AppVersionStatus.pending,
        "published": AppVersionStatus.published,
        "deprecated": AppVersionStatus.deprecated_,
        "withdrawn": AppVersionStatus.withdrawn
    ];
    return map.get(status.toLower, AppVersionStatus.pending);
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
DeviceStatus toDeviceStatus(string status) {
    const map = [
        "enrolled": DeviceStatus.enrolled,
        "active": DeviceStatus.active,
        "suspended": DeviceStatus.suspended,
        "removed": DeviceStatus.removed
    ];
    return map.get(status.toLower, DeviceStatus.enrolled);
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
SyncStatus toSyncStatus(string status) {
    const map = [
        "pending": SyncStatus.pending,
        "inProgress": SyncStatus.inProgress,
        "completed": SyncStatus.completed,
        "failed": SyncStatus.failed,
        "cancelled": SyncStatus.cancelled
    ];
    return map.get(status.toLower, SyncStatus.pending);
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
SyncDirection toSyncDirection(string direction) {
    const map = [
        "upload": SyncDirection.upload,
        "download": SyncDirection.download,
        "bidirectional": SyncDirection.bidirectional
    ];
    return map.get(direction.toLower, SyncDirection.bidirectional);
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
BackendType toBackendType(string type) {
    const map = [
        "s4hana": BackendType.s4hana,
        "ecc": BackendType.ecc,
        "btp": BackendType.btp,
        "crm": BackendType.crm,
        "custom": BackendType.custom
    ];
    return map.get(type.toLower, BackendType.custom);
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
ConnectionStatus toConnectionStatus(string status) {
    const map = [
        "active": ConnectionStatus.active,
        "inactive": ConnectionStatus.inactive,
        "error": ConnectionStatus.error,
        "testing": ConnectionStatus.testing
    ];
    return map.get(status.toLower, ConnectionStatus.inactive);
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
DeploymentStatus toDeploymentStatus(string status) {
    const map = [
        "pending": DeploymentStatus.pending,
        "deploying": DeploymentStatus.deploying,
        "deployed": DeploymentStatus.deployed,
        "failed": DeploymentStatus.failed,
        "rolledBack": DeploymentStatus.rolledBack
    ];
    return map.get(status.toLower, DeploymentStatus.pending);
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
DeploymentScope toDeploymentScope(string scope_) {
    const map = [
        "device": DeploymentScope.device,
        "group": DeploymentScope.group,
        "tenant": DeploymentScope.tenant
    ];
    return map.get(scope_.toLower, DeploymentScope.tenant);
}
