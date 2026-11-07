#!/usr/bin/env python3
"""Writes build/source.json: an AltStore-style app source that Feather can follow for updates."""
import json, os, datetime

repo = os.environ.get("GITHUB_REPOSITORY", "gleamhairfree/genshin-up")
build = os.environ.get("BUILD_NUMBER", "1")
tag = f"build-{build}"
ipa = os.path.join(os.path.dirname(__file__), "..", "build", "GenshinTracker.ipa")
size = os.path.getsize(ipa)
version = f"1.0.{build}"
now = datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
download = f"https://github.com/{repo}/releases/download/{tag}/GenshinTracker.ipa"
icon = f"https://raw.githubusercontent.com/{repo}/main/Resources/Icons/AppIcon60x60@3x.png"
notes = os.environ.get("RELEASE_NOTES", "").strip() or f"Build {build}"
description = ("A Genshin Impact to-do tracker: daily/weekly checklist, character roster, "
               "material planner, domain schedule and wish savings.")

source = {
    "name": "Teyvat Tracker",
    "identifier": "com.sideload.genshintracker.source",
    "subtitle": "Genshin Impact to-do tracker",
    "description": description,
    "iconURL": icon,
    "website": f"https://github.com/{repo}",
    "tintColor": "#D9AD59",
    "apps": [{
        "name": "Teyvat Tracker",
        "bundleIdentifier": "com.sideload.genshintracker",
        "developerName": "gleamhairfree",
        "subtitle": "Genshin Impact to-do tracker",
        "localizedDescription": description,
        "iconURL": icon,
        "tintColor": "#D9AD59",
        "category": "utilities",
        "versions": [{
            "version": version,
            "buildVersion": build,
            "date": now,
            "localizedDescription": notes,
            "downloadURL": download,
            "size": size,
            "minOSVersion": "16.0",
        }],
        # Older-format fields, for apps that read the flat layout.
        "version": version,
        "versionDate": now,
        "versionDescription": notes,
        "downloadURL": download,
        "size": size,
    }],
    "news": [],
}

out = os.path.join(os.path.dirname(__file__), "..", "build", "source.json")
with open(out, "w") as f:
    json.dump(source, f, indent=2)
print(f"Wrote source.json for {version} ({size} bytes)")
