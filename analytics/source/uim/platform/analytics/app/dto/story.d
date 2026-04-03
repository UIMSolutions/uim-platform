module uim.platform.analytics.app.dto.story;

// import std.conv : to;
import uim.platform.analytics.domain.entities.story;
import uim.platform.analytics;

mixin(ShowModule!());
@safe:
struct CreateStoryRequest {
    string title;
    string description;
    string ownerId;
}

struct StoryResponse {
    string id;
    string title;
    string description;
    string ownerId;
    string visibility;
    string status;
    SectionResponse[] sections;
    string[] tags;

    static StoryResponse fromEntity(Story s) {
        if (s is null) return StoryResponse.init;

        SectionResponse[] secs;
        foreach (sec; s.sections)
            secs ~= SectionResponse(sec.id.value, sec.heading, sec.narrative);

        return StoryResponse(
            s.id.value,
            s.title,
            s.description,
            s.ownerId.value,
            s.visibility.to!string,
            s.status.to!string,
            secs,
            s.tags,
        );
    }
}

struct SectionResponse {
    string id;
    string heading;
    string narrative;
}
