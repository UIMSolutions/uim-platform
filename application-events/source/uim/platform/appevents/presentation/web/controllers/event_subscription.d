/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.presentation.web.controllers.event_subscription;

import uim.platform.service;
import uim.platform.appevents.application.dto;
import uim.platform.appevents.application.usecases.manage.event_subscriptions;
import uim.platform.appevents.domain.valueobjects;
import uim.platform.appevents.presentation.web.models.event_subscription;
import uim.platform.appevents.presentation.web.views.event_subscription;

@safe:

class WebEventSubscriptionController {
    private WebEventSubscriptionModel       _model;
    private WebEventSubscriptionView        _view;
    private ManageEventSubscriptionsUseCase _useCase;

    this(ManageEventSubscriptionsUseCase useCase) {
        _useCase = useCase;
        _model   = new WebEventSubscriptionModel();
        _view    = new WebEventSubscriptionView();
    }

    Json list(TenantId tenantId) {
        auto list = _useCase.listEventSubscriptions(tenantId);
        _model.setItems(list);
        return _view.renderList(_model);
    }

    Json get(TenantId tenantId, EventSubscriptionId id) {
        auto item = _useCase.getEventSubscription(tenantId, id);
        _model.setSelected(item, !item.isNull);
        return _view.renderDetail(_model);
    }

    Json create(TenantId tenantId, EventSubscriptionDTO dto) {
        auto result = _useCase.createEventSubscription(dto);
        if (result.hasError) return _view.renderError(result.message);
        return _view.renderSuccess("Subscription created: " ~ result.id)
            .set("id", result.id);
    }

    Json update(TenantId tenantId, EventSubscriptionDTO dto) {
        auto result = _useCase.updateEventSubscription(dto);
        if (result.hasError) return _view.renderError(result.message);
        return _view.renderSuccess("Subscription updated: " ~ result.id)
            .set("id", result.id);
    }

    Json delete_(TenantId tenantId, EventSubscriptionId id) {
        auto result = _useCase.deleteEventSubscription(tenantId, id);
        if (result.hasError) return _view.renderError(result.message);
        return _view.renderSuccess("Subscription deleted: " ~ result.id);
    }
}
