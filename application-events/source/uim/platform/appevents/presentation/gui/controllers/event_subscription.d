/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.presentation.gui.controllers.event_subscription;

// import uim.platform.service;
// import uim.platform.appevents.application.dto;
// import uim.platform.appevents.application.usecases.manage.event_subscriptions;
// import uim.platform.appevents.domain.valueobjects;
// import uim.platform.appevents.presentation.gui.models.event_subscription;
// import uim.platform.appevents.presentation.gui.views.event_subscription;

import uim.platform.appevents;

mixin(ShowModule!());

@safe:


class GuiEventSubscriptionController {
    private GuiEventSubscriptionModel       _model;
    private GuiEventSubscriptionView        _view;
    private ManageEventSubscriptionsUseCase _useCase;

    this(ManageEventSubscriptionsUseCase useCase) {
        _useCase = useCase;
        _model   = new GuiEventSubscriptionModel();
        _view    = new GuiEventSubscriptionView();
    }

    Json getListDescriptor(TenantId tenantId) {
        auto list = _useCase.listEventSubscriptions(tenantId);
        _model.setItems(list);
        return _view.buildListDescriptor(_model);
    }

    Json getDetailDescriptor(TenantId tenantId, EventSubscriptionId id) {
        auto item = _useCase.getEventSubscription(tenantId, id);
        _model.setSelected(item, !item.isNull);
        return _view.buildDetailDescriptor(_model);
    }

    Json create(TenantId tenantId, EventSubscriptionDTO dto) {
        auto result = _useCase.createEventSubscription(dto);
        if (result.hasError) { _model.setError(result.message); return Json.emptyObject.set("error", result.message); }
        _model.setSuccess("Created: " ~ result.id);
        return Json.emptyObject.set("id", result.id).set("status", "success");
    }

    Json update(TenantId tenantId, EventSubscriptionDTO dto) {
        auto result = _useCase.updateEventSubscription(dto);
        if (result.hasError) { _model.setError(result.message); return Json.emptyObject.set("error", result.message); }
        _model.setSuccess("Updated: " ~ result.id);
        return Json.emptyObject.set("id", result.id).set("status", "success");
    }

    Json delete_(TenantId tenantId, EventSubscriptionId id) {
        auto result = _useCase.deleteEventSubscription(tenantId, id);
        if (result.hasError) { _model.setError(result.message); return Json.emptyObject.set("error", result.message); }
        _model.setSuccess("Deleted: " ~ result.id);
        return Json.emptyObject.set("id", result.id).set("status", "success");
    }
}
