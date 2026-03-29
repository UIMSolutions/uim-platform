module analytics.app.usecases.widgets;

import analytics.domain.entities.widget;
import analytics.domain.repositories.widget_repository;
import analytics.domain.values.common;
import analytics.domain.values.chart_type;
import analytics.app.dto.widget_dto;
import std.conv : to;

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
