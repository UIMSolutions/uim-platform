/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.application.usecases.manage.message_bindings;

import uim.platform.events;

mixin(ShowModule!());

@safe:

class ManageMessageBindingsUseCase {
    private IMessageBindingRepository repo;

    this(IMessageBindingRepository repo) { this.repo = repo; }

    MessageBinding getBinding(TenantId tenantId, MessageBindingId id) { return repo.findById(tenantId, id); }
    MessageBinding[] listBindings(TenantId tenantId) { return repo.findByTenant(tenantId); }
    MessageBinding[] listByClient(TenantId tenantId, MessageClientId clientId) { return repo.findByClient(tenantId, clientId); }
    MessageBinding[] listByService(TenantId tenantId, MessagingServiceId serviceId) { return repo.findByService(tenantId, serviceId); }

    UsecaseResult createBinding(MessageBindingDTO dto) {
        MessageBinding mb;
        mb.id = dto.bindingId;
        mb.tenantId = dto.tenantId;
        mb.clientId = dto.clientId;
        mb.serviceId = dto.serviceId;
        mb.queueId = dto.queueId;
        mb.channelId = dto.channelId;
        mb.name = dto.name;
        mb.description = dto.description;
        mb.bindingType = dto.bindingType;
        mb.createdBy = dto.createdBy;
        if (!EventsValidator.isValidMessageBinding(mb))
            return UsecaseResult(false, "", "Invalid message binding data");
        repo.save(mb);
        return UsecaseResult(true, mb.id.value, "");
    }

    UsecaseResult updateBinding(MessageBindingDTO dto) {
        auto existing = repo.findById(dto.tenantId, dto.bindingId);
        if (existing.isNull) return UsecaseResult(false, "", "Message binding not found");
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.bindingType.length > 0) existing.bindingType = dto.bindingType;
        if (!dto.updatedBy.isNull) existing.updatedBy = dto.updatedBy;
        repo.update(existing);
        return UsecaseResult(true, existing.id.value, "");
    }

    UsecaseResult deleteBinding(TenantId tenantId, MessageBindingId id) {
        auto mb = repo.findById(tenantId, id);
        if (mb.isNull) return UsecaseResult(false, "", "Message binding not found");
        repo.remove(mb);
        return UsecaseResult(true, mb.id.value, "");
    }
}

///
unittest {
    auto repo = new MessageBindingRepository();
    auto usecase = new ManageMessageBindingsUseCase(repo);
    auto tenantId = TenantId("test-tenant");

    // Test create
    MessageBindingDTO createDto;
    createDto.tenantId = tenantId;
    createDto.messageBindingId = MessageBindingId("messageBinding-1");
    createDto.name = "Test MessageBinding";
    auto createResult = usecase.createBinding(createDto);
    assert(createResult.success, createResult.message);

    // Test list
    auto items = usecase.listBindings(tenantId);
    assert(items.length == 1);

    // Test get
    auto item = usecase.getBinding(tenantId, MessageBindingId("messageBinding-1"));
    assert(!item.isNull);

    // Test update
    MessageBindingDTO updateDto;
    updateDto.tenantId = tenantId;
    updateDto.messageBindingId = MessageBindingId("messageBinding-1");
    updateDto.name = "Updated MessageBinding";
    auto updateResult = usecase.updateBinding(updateDto);
    assert(updateResult.success, updateResult.message);

    // Test delete
    auto deleteResult = usecase.deleteBinding(tenantId, MessageBindingId("messageBinding-1"));
    assert(deleteResult.success, deleteResult.message);
    assert(usecase.listBindings(tenantId).length == 0);

}
