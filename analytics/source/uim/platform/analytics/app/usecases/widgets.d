module uim.platform.analytics.app.usecases.widgets;

import uim.platform.analytics.domain.entities.widget;
import uim.platform.analytics.domain.repositories.widget;
import uim.platform.analytics.domain.values.common;
import uim.platform.analytics.domain.values.chart_type;
import uim.platform.analytics.app.dto.widget;
import std.conv : to;
import uim.platform.analytics;

mixin(ShowModule!());
@safe:
class WidgetUseCases {
    private WidgetRepository repo;

    this(WidgetRepository repo) {
        this.repo = repo;
    }

    WidgetResponse create(CreateWidgetRequest req) {
        ChartType ct;
        try {
            ct = req.chartType.to!ChartType;
        } catch (Exception) {
            ct = ChartType.Bar;
        }
        auto w = Widget.create(req.title, ct, req.datasetId, req.userId);
        repo.save(w);
        return WidgetResponse.fromEntity(w);
    }

    WidgetResponse getById(string id) {
        return WidgetResponse.fromEntity(repo.findById(EntityId(id)));
    }

    WidgetResponse[] list() {
        WidgetResponse[] result;
        foreach (w; repo.findAll())
            result ~= WidgetResponse.fromEntity(w);
        return result;
    }

    void remove(string id) {
        repo.remove(EntityId(id));
    }
}
