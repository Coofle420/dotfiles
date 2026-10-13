#!/usr/bin/env python3
import subprocess
from http.server import BaseHTTPRequestHandler, HTTPServer

HOST = "127.0.0.1"
PORT = 5055
CIDER_BUS = "org.mpris.MediaPlayer2.cider"
OBJ = "/org/mpris/MediaPlayer2"
IFACE = "org.mpris.MediaPlayer2.Player"

paused_by_us = False


def dbus(*args):
    r = subprocess.run(
        ["dbus-send", "--session", "--print-reply", f"--dest={CIDER_BUS}", OBJ, *args],
        capture_output=True, text=True,
    )
    print("dbus-send", " ".join(args), "->", r.returncode, r.stdout.strip(), r.stderr.strip(), flush=True)
    return r


def is_playing():
    return '"Playing"' in dbus("org.freedesktop.DBus.Properties.Get", f"string:{IFACE}", "string:PlaybackStatus").stdout


def call_start():
    global paused_by_us
    if is_playing():
        dbus(f"{IFACE}.Pause")
        paused_by_us = True


def call_end():
    global paused_by_us
    if paused_by_us:
        dbus(f"{IFACE}.Play")
    paused_by_us = False


ROUTES = {"/call-start": call_start, "/call-end": call_end}


class Handler(BaseHTTPRequestHandler):
    def _reply(self, code):
        self.send_response(code)
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "POST, OPTIONS")
        self.end_headers()

    def do_OPTIONS(self):
        self._reply(204)

    def do_POST(self):
        action = ROUTES.get(self.path)
        if action is None:
            self._reply(404)
            return
        action()
        self._reply(200)

    def log_message(self, fmt, *args):
        print(f"{self.address_string()} {fmt % args}", flush=True)


if __name__ == "__main__":
    HTTPServer((HOST, PORT), Handler).serve_forever()
