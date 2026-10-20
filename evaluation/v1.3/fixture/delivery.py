"""Prepare human-facing display labels."""


def normalize_label(label):
    return label.strip().lower()


def display_label(event):
    return normalize_label(event["label"])
