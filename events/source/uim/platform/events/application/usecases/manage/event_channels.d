/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.application.usecases.manage.event_channels;

import uim.platform.events;

// mixin(ShowModule!());

@safe:

class ManageEventChannelsUseCase {
    private EventChannelRepository repo;

    this(EventChannelRepository repo) { this.repo = repo; }

    EventChannel getChannel(TenantId tenantId, EventChannelId id) { return repo.findById(tenantId, id); }
    EventChannel[] listChannels(TenantId tenantId) { return repo.find(tenantId); }
    EventChannel[] listByService(TenantId tenantId, MessagingServiceId serviceId) { return repo.findByService(tenantId, serviceId); }
    EventChannel[] listByNamespace(TenantId tenantId, string namespace) { return repo.findByNamespace(tenantId, namespace); }

    CommandResult createChannel(EventChannelDTO dto) {
        EventChannel ec;
        ec.id = dto.channelId;
        ec.tenantId = dto.tenantId;
        ec.serviceId = dto.serviceId;
        ec.name = dto.name;
        ec.description = dto.description;
        ec.namespace = dto.namespace;
        ec.topicName = dto.topicName;
        ec.asyncapiDefinition = dto.asyncapiDefinition;
        ec.maxRetentionPeriod = dto.maxRetentionPeriod;
        ec.maxPartitions = dto.maxPartitions;
        ec.createdBy = dto.createdBy;
        if (!EventsValidator.isValidEventChannel(ec))
            return CommandResult(false, "", "Invalid event channel data");
        repo.save(ec);
        return CommandResult(true, ec.id.value, "");
    }

    CommandResult updateChannel(EventChannelDTO dto) {
        auto existing = repo.findById(dto.tenantId, dto.channelId);
        if (existing.isNull) return CommandResult(false, "", "Event channel not found");
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.asyncapiDefinition.length > 0) existing.asyncapiDefinition = dto.asyncapiDefinition;
        if (dto.maxRetentionPeriod.length > 0) existing.maxRetentionPeriod = dto.maxRetentionPeriod;
        if (dto.maxPartitions.length > 0) existing.maxPartitions = dto.maxPartitions;
        if (!dto.updatedBy.isNull) existing.updatedBy = dto.updatedBy;
        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteChannel(TenantId tenantId, EventChannelId id) {
        auto ec = repo.findById(tenantId, id);
        if (ec.isNull) return CommandResult(false, "", "Event channel not found");
        repo.remove(ec);
        return CommandResult(true, ec.id.value, "");
    }
}
