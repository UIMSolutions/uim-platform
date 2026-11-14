/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.application.usecases.manage_webhooks;

import uim.platform.events;

mixin(ShowModule!());

@safe:

class ManageWebhooksUseCase : IManageWebhooks {
  protected IWebhookRepository webhooks;
  protected IQueueRepository queues;

  this(IWebhookRepository webhooks, IQueueRepository queues) {
    this.webhooks = webhooks;
    this.queues = queues;
  }

  Webhook[] listWebhooks(TenantId tenantId) {
    return webhooks.findAll(tenantId);
  }

  Webhook getWebhook(TenantId tenantId, WebhookId id) {
    return webhooks.findById(tenantId, id).required("Webhook '" ~ id.value ~ "'");
  }

  Webhook createWebhook(CreateWebhookRequest r) {
    auto queue = queues.findById(r.tenantId, QueueId(r.queueId)).required("Queue '" ~ r.queueId ~ "'");
    Webhook w;
    stampCreated!(Webhook, WebhookId)(w, r.tenantId, r.actor, r.id);
    if (webhooks.existsById(r.tenantId, w.id))
      throw EventsException.conflict("Webhook '" ~ w.id.value ~ "' already exists");
    w.queueId = queue.id;
    w.serviceId = queue.serviceId;
    w.name = r.name.strip;
    w.description = r.description;
    w.url = r.url.strip;
    w.headers = r.headers;
    w.exemptHandshake = r.exemptHandshake;
    w.authenticationType = parseDomainEnumOr!WebhookAuthType(r.authenticationType, WebhookAuthType.none, "authenticationType");
    w.credentials = r.credentials;
    w.tokenUrl = r.tokenUrl;
    w.clientId = r.clientId;
    w.deliveryMode = parseDomainEnumOr!WebhookDeliveryMode(r.deliveryMode, WebhookDeliveryMode.atLeastOnce, "deliveryMode");
    w.batchSize = r.batchSize > 0 ? r.batchSize : 10;
    w.validate();
    webhooks.save(w);
    return w;
  }

  Webhook updateWebhook(UpdateWebhookRequest r) {
    auto w = getWebhook(r.tenantId, r.id);
    r.name.applyTo(w.name);
    r.description.applyTo(w.description);
    if (r.status.isSet) {
      w.status = parseDomainEnum!WebhookStatus(r.status.value, "status");
      if (w.status == WebhookStatus.active)
        w.lastError = ""; // re-activation clears the failure
    }
    r.url.applyTo(w.url);
    r.headers.applyTo(w.headers);
    r.exemptHandshake.applyTo(w.exemptHandshake);
    applyEnum(r.authenticationType, w.authenticationType, "authenticationType");
    r.credentials.applyTo(w.credentials);
    r.tokenUrl.applyTo(w.tokenUrl);
    r.clientId.applyTo(w.clientId);
    applyEnum(r.deliveryMode, w.deliveryMode, "deliveryMode");
    r.batchSize.applyTo(w.batchSize);
    w.validate();
    stampUpdated(w, r.actor);
    webhooks.save(w);
    return w;
  }

  void deleteWebhook(TenantId tenantId, WebhookId id) {
    getWebhook(tenantId, id);
    webhooks.removeById(tenantId, id);
  }
}
