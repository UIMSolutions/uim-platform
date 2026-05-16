/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.domain.services.event_mesh_validator;

import uim.platform.event_mesh;

mixin(ShowModule!());

@safe:

struct EventMeshValidator {
    static bool isValidBrokerService(BrokerService bs) {
        return bs.name.length > 0 && !bs.tenantId.isEmpty;
    }

    static bool isValidQueue(Queue q) {
        return q.name.length > 0 && !q.tenantId.isEmpty && !q.serviceId.isEmpty;
    }

    static bool isValidTopic(Topic t) {
        return t.name.length > 0 && !t.tenantId.isEmpty && !t.serviceId.isEmpty;
    }

    static bool isValidSubscription(EventSubscription s) {
        return s.name.length > 0 && !s.tenantId.isEmpty && !s.serviceId.isEmpty;
    }

    static bool isValidEventMessage(EventMessage m) {
        return !m.tenantId.isEmpty && !m.serviceId.isEmpty && m.payload.length > 0;
    }

    static bool isValidEventSchema(EventSchema s) {
        return s.name.length > 0 && !s.tenantId.isEmpty && s.schemaContent.length > 0;
    }

    static bool isValidEventApplication(EventApplication a) {
        return a.name.length > 0 && !a.tenantId.isEmpty /* && !a.serviceId.isEmpty */; // TODO: add serviceId to EventApplication
    }

    static bool isValidMeshBridge(MeshBridge b) {
        return b.name.length > 0 && !b.tenantId.isEmpty && !b.sourceServiceId.isEmpty && !b.targetServiceId.isEmpty;
    }
}
