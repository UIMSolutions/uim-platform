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
        return bs.name.length > 0 && bs.tenantId.length > 0;
    }

    static bool isValidQueue(Queue q) {
        return q.name.length > 0 && q.tenantId.length > 0 && q.brokerServiceId.length > 0;
    }

    static bool isValidTopic(Topic t) {
        return t.name.length > 0 && t.tenantId.length > 0 && t.brokerServiceId.length > 0;
    }

    static bool isValidSubscription(EventSubscription s) {
        return s.name.length > 0 && s.tenantId.length > 0 && s.brokerServiceId.length > 0;
    }

    static bool isValidEventMessage(EventMessage m) {
        return m.tenantId.length > 0 && m.brokerServiceId.length > 0 && m.payload.length > 0;
    }

    static bool isValidEventSchema(EventSchema s) {
        return s.name.length > 0 && s.tenantId.length > 0 && s.schemaContent.length > 0;
    }

    static bool isValidEventApplication(EventApplication a) {
        return a.name.length > 0 && a.tenantId.length > 0 && a.brokerServiceId.length > 0;
    }

    static bool isValidMeshBridge(MeshBridge b) {
        return b.name.length > 0 && b.tenantId.length > 0 && b.sourceBrokerId.length > 0 && b.targetBrokerId.length > 0;
    }
}
