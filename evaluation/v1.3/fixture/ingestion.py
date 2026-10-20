"""Store events without changing opaque upstream identifiers."""


def store_event(events, source_id, payload):
    events[source_id] = payload


def get_event(events, source_id):
    return events.get(source_id)
