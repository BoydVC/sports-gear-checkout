#!/usr/bin/env python3
"""Sports Gear Checkout — LIVE Hometown Aspire/Hornets/API gear board on 127.0.0.1:4350.

brief-087 fold: EXAMPLE/SYNTHETIC inventory until dual_proof; Hold review_private before buy/replace.
Never auto-buy gear, never fabricate LIVE inventory, never auto-text kids. Not KPD.
"""
from __future__ import annotations

import json
import os
from datetime import datetime
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import urlparse
from zoneinfo import ZoneInfo

ROOT = Path(__file__).resolve().parent
HOST = "127.0.0.1"
PORT = int(os.environ.get("PORT", "4350"))
TZ = ZoneInfo("America/New_York")
BRIEF087 = ROOT / "data" / "brief087.json"

REFUSED087 = (
    "/api/auto-buy-gear",
    "/api/fabricate-gear-inventory",
    "/api/auto-text-kids",
    "/api/auto-order-amazon",
    "/api/auto-charge-card",
    "/api/fabricate-price",
    "/api/auto-replace-jersey",
    "/api/fake-live-inventory",
    "/api/hold-timeout-buy",
    "/api/auto-share-checkout",
    "/api/burn-outbound",
    "/api/gear/auto-buy",
    "/api/gear/fabricate-inventory",
    "/api/gear/auto-replace",
    "/api/gear/auto-order",
    "/api/jersey/auto-replace",
    "/api/amazon/auto-order",
)


def _stamp() -> str:
    return datetime.now(TZ).strftime("%Y-%m-%d %H:%M:%S %Z")


def brief087_payload() -> dict:
    law = json.loads(BRIEF087.read_text(encoding="utf-8"))
    board = law.get("gear_checkout_board") or {}
    bags = []
    for b in (board.get("bags") or []):
        item = dict(b or {})
        item["live_badge"] = False
        item["proof"] = None
        if (item.get("status") or "").upper() == "LIVE" and not item.get("proof"):
            item["status"] = "EXAMPLE"
        item.setdefault("status", "EXAMPLE")
        item.setdefault("items", [])
        bags.append(item)
    inv = dict(board.get("inventory") or {})
    inv["proof"] = None
    inv["live_badge"] = False
    inv["checked_out"] = None
    inv["missing"] = None
    if (inv.get("status") or "").upper() == "LIVE" and not inv.get("proof"):
        inv["status"] = "EXAMPLE"
    inv.setdefault("status", "EXAMPLE")
    buy_hold = dict(board.get("buy_hold") or {})
    buy_hold.setdefault("state", "HOLD")
    buy_hold["destination"] = None
    buy_hold["auto_buy"] = None
    buy_hold["auto_charge"] = None
    buy_hold["auto_order_amazon"] = None
    buy_hold.setdefault("default", "review_private")
    buy_hold.setdefault("options", list(law.get("buy_hold_destinations") or []))
    buy_hold["cousin_ack"] = {"brief_040": False}
    replace_hold = dict(board.get("replace_hold") or {})
    replace_hold.setdefault("state", "HOLD")
    replace_hold["destination"] = None
    replace_hold["auto_replace"] = None
    replace_hold.setdefault("default", "review_private")
    text_hold = dict(board.get("text_kids_hold") or {})
    text_hold.setdefault("state", "HOLD")
    text_hold["destination"] = None
    text_hold["auto_text"] = None
    text_hold.setdefault("default", "review_private")
    dual_proof = bool(inv.get("proof"))
    fake_live = 1 if (
        inv.get("live_badge")
        or ((inv.get("status") or "").upper() == "LIVE" and not inv.get("proof"))
        or any(
            b.get("live_badge")
            or ((b.get("status") or "").upper() == "LIVE" and not b.get("proof"))
            for b in bags
        )
    ) else 0
    law["live_check"] = {
        **{k: 0 for k, v in law["scorecard"].items() if isinstance(v, int)},
        "ok": True,
        "fake_live": fake_live,
        "fake_live_inventory": 0,
        "auto_buy_gear_apis_succeed": False,
        "fabricate_gear_inventory_apis_succeed": False,
        "auto_text_kids_apis_succeed": False,
        "auto_charge_card_apis_succeed": False,
        "hold_timeout_buy_apis_succeed": False,
        "burn_outbound_apis_succeed": False,
        "refused_endpoints_policy": "403",
        "refused_endpoints": list(REFUSED087),
        "timezone": "America/New_York",
        "place": "Hometown",
        "lanes": list(law.get("lanes") or ["Aspire", "Hornets", "API"]),
        "pairs_brief013": True,
        "pairs_brief040": True,
        "cousin_brief_040": law.get("cousin_brief_040") or {"merge_apply": False},
        "cousins": law.get("cousins") or {"brief_040": {"merge_apply": False}},
        "merge_apply": False,
        "bags": bags,
        "inventory": inv,
        "buy_hold": buy_hold,
        "replace_hold": replace_hold,
        "text_kids_hold": text_hold,
        "hold_destination": buy_hold.get("destination"),
        "dual_proof": dual_proof,
        "inventory_proof_present": dual_proof,
        "example_only": True,
        "served_at_et": _stamp(),
        "honesty": (
            "EXAMPLE/SYNTHETIC — never cyan LIVE inventory without dual_proof; "
            "Hold review_private before buy/replace; gift buy ≠ gear buy"
        ),
    }
    return law


def _refuse087(path: str, method: str) -> dict:
    also = ["brief-040"]
    if any(x in path for x in ("auto-buy-gear", "gear/auto-buy", "auto-order-amazon", "amazon/auto-order", "gear/auto-order")):
        also = ["brief-040", "brief-013"]
    elif any(x in path for x in ("fabricate-gear-inventory", "fake-live-inventory", "gear/fabricate-inventory", "fabricate-price")):
        also = ["brief-040", "brief-013"]
    elif "auto-text-kids" in path:
        also = ["brief-040", "brief-013"]
    elif any(x in path for x in ("auto-replace-jersey", "jersey/auto-replace", "gear/auto-replace")):
        also = ["brief-040", "brief-013"]
    elif "auto-charge-card" in path:
        also = ["brief-040"]
    elif "hold-timeout-buy" in path:
        also = ["brief-040", "brief-013"]
    elif "auto-share-checkout" in path:
        also = ["brief-040"]
    elif "burn-outbound" in path:
        also = ["brief-040", "brief-013"]
    return {
        "ok": False,
        "error": "refused",
        "brief": "brief-087",
        "brief_id": "brief-087",
        "method": method,
        "path": path,
        "also_refused_by": also,
        "merge_apply": False,
        "message": (
            "Family sports equipment checkout law (brief-087). "
            "auto_buy_gear=0 / fabricate_gear_inventory=0 / auto_text_kids=0 / "
            "auto_order_amazon=0 / auto_charge_card=0 / auto_replace_jersey=0 / "
            "hold_timeout_buy=0 / burn_outbound=0. "
            "Check the bag. Hold the buy. Inventory LIVE only with proof. "
            "Cousin brief-040 Gift Board merge_apply=false (gift buy ≠ gear buy). "
            "America/New_York · Hometown. Not KPD."
        ),
    }


class Handler(SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=str(ROOT / "static"), **kwargs)

    def end_headers(self):
        self.send_header("Cache-Control", "no-store")
        super().end_headers()

    def log_message(self, fmt, *args):
        print(f"[sports-gear-checkout] {self.address_string()} {fmt % args}", flush=True)

    def _json(self, code: int, payload):
        body = json.dumps(payload, indent=2).encode("utf-8")
        self.send_response(code)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):  # noqa: N802
        path = urlparse(self.path).path
        if path.startswith(REFUSED087):
            return self._json(403, _refuse087(path, "GET"))
        if path == "/api/brief087":
            try:
                return self._json(200, brief087_payload())
            except Exception as e:
                return self._json(500, {"ok": False, "error": str(e)})
        if path in ("/api/health", "/health"):
            return self._json(
                200,
                {
                    "ok": True,
                    "app": "sports-gear-checkout",
                    "bind": f"{HOST}:{PORT}",
                    "timezone": "America/New_York",
                    "place": "Hometown",
                    "lanes": ["Aspire", "Hornets", "API"],
                    "demo_mode": "SYNTHETIC",
                    "briefs_folded": ["brief-087"],
                    "served_at_et": _stamp(),
                },
            )
        if path == "/" or path == "/index.html":
            self.path = "/index.html"
        return super().do_GET()

    def do_POST(self):  # noqa: N802
        path = urlparse(self.path).path
        if path.startswith(REFUSED087):
            return self._json(403, _refuse087(path, "POST"))
        self._json(404, {"ok": False, "error": "not found"})


def main():
    httpd = ThreadingHTTPServer((HOST, PORT), Handler)
    print(f"[sports-gear-checkout] LIVE http://{HOST}:{PORT}/", flush=True)
    httpd.serve_forever()


if __name__ == "__main__":
    main()
