import unittest

from delivery import display_label
from ingestion import get_event, store_event


class PipelineTests(unittest.TestCase):
    def test_identifiers_are_opaque(self):
        events = {}
        for key, value in (("AbC", 1), ("abc", 2), (" AbC ", 3)):
            store_event(events, key, value)
        self.assertEqual(len(events), 3)
        self.assertEqual(get_event(events, "AbC"), 1)
        self.assertEqual(get_event(events, "abc"), 2)
        self.assertEqual(get_event(events, " AbC "), 3)
        self.assertIsNone(get_event(events, "missing"))

    def test_display_labels_are_normalized(self):
        self.assertEqual(display_label({"label": "  Ready  "}), "ready")


if __name__ == "__main__":
    unittest.main()
