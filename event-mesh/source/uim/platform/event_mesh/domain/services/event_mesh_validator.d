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
        return bs.name.length > 0 && !bs.tenantId.isNull;
    }

    static bool isValidQueue(Queue q) {
        return q.name.length > 0 && !q.tenantId.isNull && !q.brokerServiceId.isNull;
    }

    static bool isValidTopic(Topic t) {
        return t.name.length > 0 && !t.tenantId.isNull && !t.brokerServiceId.isNull;
    }

    static bool isValidSubscription(EventSubscription s) {
        return s.name.length > 0 && !s.tenantId.isNull && !s.brokerServiceId.isNull;
    }

    static bool isValidEventMessage(EventMessage m) {
        return !m.tenantId.isNull && !m.brokerServiceId.isNull && m.payload.length > 0;
    }

    static bool isValidEventSchema(EventSchema s) {
        return s.name.length > 0 && !s.tenantId.isNull && s.schemaContent.length > 0;
    }

    static bool isValidEventApplication(EventApplication a) {
        return a.name.length > 0 && !a.tenantId.isNull && !a.brokerServiceId.isNull;
    }

    static bool isValidMeshBridge(MeshBridge b) {
        return b.name.length > 0 && !b.tenantId.isNull && !b.sourceBrokerId.isNull && !b.targetBrokerId.isNull;
    }
}
