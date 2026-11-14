/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.application.usecases.manage.devices;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

class ManageDevicesUseCase : IManageDevicesUseCase {
  protected IDeviceRepository repo;
  protected IMobileApplicationRepository applications;
  protected IAgentryEventPublisher events;

  /// applications may be null (no referential check).
  this(IDeviceRepository repo, IMobileApplicationRepository applications = null, IAgentryEventPublisher events = null) {
    this.repo = repo;
    this.applications = applications;
    this.events = events is null ? new NullEventPublisher : events;
  }

  MobileDevice[] listDevices(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  MobileDevice[] listByMobileApplication(TenantId tenantId, MobileApplicationId appId) {
    return repo.findByMobileApplication(tenantId, appId);
  }

  MobileDevice[] listByStatus(TenantId tenantId, DeviceStatus status) {
    return repo.findByStatus(tenantId, status);
  }

  MobileDevice[] listByGroup(TenantId tenantId, string groupName) {
    return repo.findByGroup(tenantId, groupName);
  }

  MobileDevice getDevice(TenantId tenantId, DeviceId id) {
    return repo.findById(tenantId, id);
  }

  UsecaseResult enrollDevice(DeviceDTO dto) {
    return guarded(() {
      if (!dto.deviceId.isNull && repo.existsById(dto.tenantId, dto.deviceId))
        return conflict("Device '" ~ dto.deviceId.value ~ "' is already enrolled");

      auto device = newEntity!(MobileDevice)(dto.tenantId, dto.deviceId, dto.createdBy);
      device.mobileApplicationId = dto.applicationId;
      device.status = DeviceStatus.enrolled;
      device.enrolledAt = nowStdTime();
      device.lastSeenAt = device.enrolledAt;

      MobileApplication app;
      if (applications !is null && !dto.applicationId.isNull) {
        app = applications.findById(dto.tenantId, dto.applicationId);
        if (app.isNull)
          return rejected("Mobile application '" ~ dto.applicationId.value ~ "' does not exist");
        device.platform = app.platform;
      }

      string[] errors;
      apply(device, dto, errors);
      errors ~= AgentryValidator.validate(device);
      if (errors.length)
        return invalid(errors);
      if (!app.isNull && app.status == AppStatus.archived)
        return rejected("Devices cannot be enrolled for an archived application");

      repo.save(device);
      return created(device.id.value, "Device enrolled");
    });
  }

  UsecaseResult updateDevice(DeviceDTO dto) {
    return guarded(() {
      auto device = repo.findById(dto.tenantId, dto.deviceId);
      if (device.isNull)
        return notFound("Device", dto.deviceId.value);

      string[] errors;
      apply(device, dto, errors);
      DeviceStatus status = device.status;
      if (readEnum(dto.status, status, "status", errors))
        ensureTransition("MobileDevice", device.status, status);
      device.status = status;
      errors ~= AgentryValidator.validate(device);
      if (errors.length)
        return invalid(errors);

      touch(device, dto.updatedBy);
      repo.update(device);
      return succeeded(device.id.value, "Device updated");
    });
  }

  UsecaseResult setDeviceStatus(TenantId tenantId, DeviceId id, DeviceStatus status, UserId by) {
    return guarded(() {
      auto device = repo.findById(tenantId, id);
      if (device.isNull)
        return notFound("Device", id.value);
      ensureTransition("MobileDevice", device.status, status);
      auto previous = device.status;
      device.status = status;
      touch(device, by);
      repo.update(device);
      events.publish(AgentryTopics.deviceStatusChanged, Json.emptyObject
          .set("tenantId", tenantId.value).set("id", id.value)
          .set("from", enumValue(previous)).set("to", enumValue(status)));
      return succeeded(device.id.value, "Device is now " ~ enumValue(status));
    });
  }

  UsecaseResult removeDevice(TenantId tenantId, DeviceId id) {
    auto device = repo.findById(tenantId, id);
    if (device.isNull)
      return notFound("Device", id.value);
    repo.remove(device);
    return succeeded(device.id.value, "Device removed");
  }

  protected void apply(ref MobileDevice device, const DeviceDTO dto, ref string[] errors) {
    assignIf(device.deviceName, dto.deviceName);
    assignIf(device.deviceModel, dto.deviceModel);
    assignIf(device.manufacturer, dto.manufacturer);
    assignIf(device.osVersion, dto.osVersion);
    assignIf(device.appVersionInstalled, dto.appVersionInstalled);
    assignIf(device.pushToken, dto.pushToken);
    assignIf(device.userEmail, dto.userEmail);
    assignIf(device.groupName, dto.groupName);
    assignIf(device.mdmDeviceId, dto.mdmDeviceId);
    if (!dto.userId.isNull)
      device.userId = dto.userId;
    device.isManaged = dto.isManaged;
    readEnum(dto.platform, device.platform, "platform", errors);
  }
}

///
unittest {
  mixin(ShowTest!("ManageDevicesUseCase"));

  auto uc = new ManageDevicesUseCase(new DeviceRepository());
  auto t = TenantId("t1");
  DeviceDTO dto;
  dto.tenantId = t;
  dto.applicationId = MobileApplicationId("app-1");
  dto.deviceName = "Tech-01";
  dto.osVersion = "17.4";
  dto.platform = "ios";
  dto.groupName = "north";
  auto r = uc.enrollDevice(dto);
  assert(r.isSuccess, r.message);
  auto id = DeviceId(r.id);
  assert(uc.getDevice(t, id).enrolledAt > 0);
  assert(uc.listByGroup(t, "north").length == 1);

  assert(uc.setDeviceStatus(t, id, DeviceStatus.active, UserId("u")).isSuccess);
  assert(uc.setDeviceStatus(t, id, DeviceStatus.enrolled, UserId("u")).code == 422);
  dto.deviceId = id;
  dto.status = "bogus";
  assert(uc.updateDevice(dto).code == 400);
}
