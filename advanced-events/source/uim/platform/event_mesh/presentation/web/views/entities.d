/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.presentation.web.views.entities;

import std.array : appender;
import std.format : format;

import uim.platform.event_mesh;

mixin(ShowModule!());

@safe:

private string renderListPage(string title, string[] rows) {
    auto html = appender!string();
    html.put("<!doctype html><html><head><meta charset=\"utf-8\">");
    html.put("<title>");
    html.put(title);
    html.put("</title>");
    html.put("<style>");
    html.put("body{font-family:Verdana,sans-serif;margin:1.5rem;}");
    html.put("h1{margin-bottom:1rem;}ul{padding-left:1.2rem;}li{padding:0.2rem 0;}");
    html.put("</style></head><body>");
    html.put("<h1>");
    html.put(title);
    html.put("</h1><ul>");

    foreach (row; rows) {
        html.put("<li>");
        html.put(row);
        html.put("</li>");
    }

    html.put("</ul></body></html>");
    return html.data;
}

private string renderJsonPage(string title, Json payload) {
    auto html = appender!string();
    html.put("<!doctype html><html><head><meta charset=\"utf-8\">");
    html.put("<title>");
    html.put(title);
    html.put("</title>");
    html.put("<style>");
    html.put("body{font-family:Verdana,sans-serif;margin:1.5rem;}");
    html.put("pre{background:#f2f2f2;padding:1rem;border-radius:6px;overflow:auto;}");
    html.put("</style></head><body><h1>");
    html.put(title);
    html.put("</h1><pre>");
    html.put(payload.toPrettyString());
    html.put("</pre></body></html>");
    return html.data;
}

private string renderMutationPage(string title, CommandResult result) {
    auto payload = Json.emptyObject
        .set("success", !result.hasError)
        .set("id", result.id)
        .set("message", result.message);
    return renderJsonPage(title, payload);
}

class WebBrokerServiceView {
    string renderIndex(BrokerService[] entities) const {
        string[] rows;
        rows.reserve(entities.length);
        foreach (e; entities) rows ~= format("%s | %s | %s", e.id.value, e.name, e.region);
        return renderListPage("Broker Services", rows);
    }

    string renderDetails(BrokerService entity) const {
        return renderJsonPage("Broker Service Details", entity.toJson);
    }

    string renderMutation(CommandResult result) const {
        return renderMutationPage("Broker Service Command Result", result);
    }
}

class WebQueueView {
    string renderIndex(Queue[] entities) const {
        string[] rows;
        rows.reserve(entities.length);
        foreach (e; entities) rows ~= format("%s | %s", e.id.value, e.name);
        return renderListPage("Queues", rows);
    }

    string renderDetails(Queue entity) const {
        return renderJsonPage("Queue Details", entity.toJson);
    }

    string renderMutation(CommandResult result) const {
        return renderMutationPage("Queue Command Result", result);
    }
}

class WebTopicView {
    string renderIndex(Topic[] entities) const {
        string[] rows;
        rows.reserve(entities.length);
        foreach (e; entities) rows ~= format("%s | %s", e.id.value, e.name);
        return renderListPage("Topics", rows);
    }

    string renderDetails(Topic entity) const {
        return renderJsonPage("Topic Details", entity.toJson);
    }

    string renderMutation(CommandResult result) const {
        return renderMutationPage("Topic Command Result", result);
    }
}

class WebSubscriptionView {
    string renderIndex(EventSubscription[] entities) const {
        string[] rows;
        rows.reserve(entities.length);
        foreach (e; entities) rows ~= format("%s | %s", e.id.value, e.name);
        return renderListPage("Subscriptions", rows);
    }

    string renderDetails(EventSubscription entity) const {
        return renderJsonPage("Subscription Details", entity.toJson);
    }

    string renderMutation(CommandResult result) const {
        return renderMutationPage("Subscription Command Result", result);
    }
}

class WebEventMessageView {
    string renderIndex(EventMessage[] entities) const {
        string[] rows;
        rows.reserve(entities.length);
        foreach (e; entities) rows ~= format("%s | %s", e.id.value, e.topicString);
        return renderListPage("Event Messages", rows);
    }

    string renderDetails(EventMessage entity) const {
        return renderJsonPage("Event Message Details", entity.toJson);
    }

    string renderMutation(CommandResult result) const {
        return renderMutationPage("Event Message Command Result", result);
    }
}

class WebEventSchemaView {
    string renderIndex(EventSchema[] entities) const {
        string[] rows;
        rows.reserve(entities.length);
        foreach (e; entities) rows ~= format("%s | %s | %s", e.id.value, e.name, e.version_);
        return renderListPage("Event Schemas", rows);
    }

    string renderDetails(EventSchema entity) const {
        return renderJsonPage("Event Schema Details", entity.toJson);
    }

    string renderMutation(CommandResult result) const {
        return renderMutationPage("Event Schema Command Result", result);
    }
}

class WebEventApplicationView {
    string renderIndex(EventApplication[] entities) const {
        string[] rows;
        rows.reserve(entities.length);
        foreach (e; entities) rows ~= format("%s | %s", e.id.value, e.name);
        return renderListPage("Event Applications", rows);
    }

    string renderDetails(EventApplication entity) const {
        return renderJsonPage("Event Application Details", entity.toJson);
    }

    string renderMutation(CommandResult result) const {
        return renderMutationPage("Event Application Command Result", result);
    }
}

class WebMeshBridgeView {
    string renderIndex(MeshBridge[] entities) const {
        string[] rows;
        rows.reserve(entities.length);
        foreach (e; entities) rows ~= format("%s | %s", e.id.value, e.name);
        return renderListPage("Mesh Bridges", rows);
    }

    string renderDetails(MeshBridge entity) const {
        return renderJsonPage("Mesh Bridge Details", entity.toJson);
    }

    string renderMutation(CommandResult result) const {
        return renderMutationPage("Mesh Bridge Command Result", result);
    }
}
