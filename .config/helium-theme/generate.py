#!/usr/bin/env python3
"""Generate a Chromium theme manifest from the active Noctalia custom palette."""
import json, os, sys
home = os.path.expanduser("~")
pal = json.load(open(f"{home}/.config/noctalia/palettes/DarkPurple.json"))["dark"]
rgb = lambda h: [int(h[i:i+2], 16) for i in (1, 3, 5)]
c = {k: rgb(v) for k, v in pal.items() if isinstance(v, str)}
manifest = {
    "manifest_version": 3,
    "name": "Noctalia Purple",
    "version": "1.0",
    "theme": {
        "colors": {
            "frame": c["mSurface"],
            "frame_inactive": c["mSurface"],
            "frame_incognito": rgb("#0a0614"),
            "frame_incognito_inactive": rgb("#0a0614"),
            "toolbar": c["mSurfaceVariant"],
            "tab_text": c["mOnSurface"],
            "tab_background_text": c["mOnSurfaceVariant"],
            "bookmark_text": c["mOnSurface"],
            "toolbar_button_icon": c["mPrimary"],
            "button_background": c["mSurfaceVariant"],
            "ntp_background": c["mSurface"],
            "ntp_text": c["mOnSurface"],
            "ntp_link": c["mPrimary"],
            "ntp_header": c["mSurface"],
            "omnibox_background": c["mSurface"],
            "omnibox_text": c["mOnSurface"],
            "background_tab": c["mSurface"],
            "background_tab_inactive": c["mSurface"],
        },
        "tints": {"buttons": [0.74, 0.5, 0.95], "frame": [-1, -1, -1]},
        "properties": {"ntp_background_alignment": "center"},
    },
}
out = os.path.join(home, ".config/helium-theme/manifest.json")
json.dump(manifest, open(out, "w"), indent=2)
print("wrote", out)
