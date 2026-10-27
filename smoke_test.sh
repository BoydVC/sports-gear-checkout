#!/usr/bin/env bash
# Sports Gear Checkout smoke — brief-087 invent fold.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
BASE="${BASE:-http://127.0.0.1:4350}"
PY="${PY:-python3}"
PASS=0
FAIL=0

ok() { echo "OK  $1"; PASS=$((PASS + 1)); }
bad() { echo "BAD $1"; FAIL=$((FAIL + 1)); }
check() {
  local name="$1"; shift
  if "$@" >/dev/null 2>&1; then ok "$name"; else bad "$name"; fi
}

echo "== Sports Gear Checkout smoke (brief-087) =="
echo "ROOT=$ROOT  BASE=$BASE"

check "data/brief087.json exists" test -f "$ROOT/data/brief087.json"
check "brief087 scorecard zeros" "$PY" -c '
import json
s=json.load(open("'"$ROOT"'/data/brief087.json"))["scorecard"]
for k in ("auto_buy_gear","fabricate_gear_inventory","auto_text_kids","auto_order_amazon","auto_charge_card","fabricate_price","auto_replace_jersey","fake_live_inventory","hold_timeout_buy","auto_share_checkout","burn_outbound"):
    assert s[k]==0, k
assert s["timezone"]=="America/New_York"
'
check "brief087 EXAMPLE board + cousin" "$PY" -c '
import json
b=json.load(open("'"$ROOT"'/data/brief087.json"))
board=b["gear_checkout_board"]
assert board["inventory"]["status"]=="EXAMPLE" and board["inventory"]["proof"] is None
assert board["inventory"]["checked_out"] is None
assert b["place"]=="Millersville, MD"
assert b["cousins"]["brief_040"]["merge_apply"] is False
assert b["merge_apply"] is False
assert set(b["lanes"])=={"Aspire","Hornets","API"}
bags=board["bags"]
assert any(x["team"]=="Aspire" for x in bags)
assert any(x["team"]=="Hornets" for x in bags)
assert any(x["team"]=="API" for x in bags)
'
check "UI Brief-087 panel" grep -q "Brief-087 law · Family sports equipment checkout" "$ROOT/static/index.html"
check "JS loader loadBrief087" grep -q "loadBrief087" "$ROOT/static/app.js"
check "README brief-087 note" grep -q "Brief-087 fold" "$ROOT/README.md"
check "server refuses listed gates" "$PY" -c '
t=open("'"$ROOT"'/server.py").read()
for ep in ("/api/auto-buy-gear","/api/fabricate-gear-inventory","/api/auto-text-kids","/api/auto-order-amazon","/api/auto-charge-card","/api/fabricate-price","/api/auto-replace-jersey","/api/fake-live-inventory","/api/hold-timeout-buy","/api/auto-share-checkout","/api/burn-outbound"):
    assert ep in t, ep
assert "REFUSED087" in t and "brief087_payload" in t
'

code=$(curl -s -o /tmp/sgc-health.json -w "%{http_code}" "$BASE/api/health" || echo 000)
[[ "$code" == "200" ]] && ok "GET /api/health 200" || bad "GET /api/health HTTP $code"
"$PY" -c '
import json
h=json.load(open("/tmp/sgc-health.json"))
assert h.get("ok") is True
assert "brief-087" in (h.get("briefs_folded") or [])
assert h.get("demo_mode")=="SYNTHETIC"
assert h.get("timezone")=="America/New_York"
assert h.get("place")=="Millersville, MD"
' && ok "health briefs_folded + SYNTHETIC" || bad "health payload"

code=$(curl -s -o /tmp/sgc-b87.json -w "%{http_code}" "$BASE/api/brief087" || echo 000)
[[ "$code" == "200" ]] && ok "GET /api/brief087 200" || bad "GET /api/brief087 HTTP $code"
"$PY" -c '
import json
b=json.load(open("/tmp/sgc-b87.json"))
assert b["brief_id"]=="brief-087"
lc=b["live_check"]
assert lc["ok"] is True and lc["fake_live"]==0
for k in ("auto_buy_gear","fabricate_gear_inventory","auto_text_kids","auto_order_amazon","auto_charge_card","fabricate_price","auto_replace_jersey","fake_live_inventory","hold_timeout_buy","auto_share_checkout","burn_outbound"):
    assert lc[k]==0, k
assert lc["inventory_proof_present"] is False
assert lc["dual_proof"] is False
assert lc["merge_apply"] is False
assert lc["cousin_brief_040"]["merge_apply"] is False
assert lc["pairs_brief013"] is True and lc["pairs_brief040"] is True
assert lc["buy_hold"]["state"]=="HOLD" and lc["buy_hold"]["default"]=="review_private"
assert lc["buy_hold"]["auto_buy"] is None
assert (lc.get("inventory") or {}).get("status")=="EXAMPLE"
assert (lc.get("inventory") or {}).get("proof") is None
for bag in lc.get("bags") or []:
    assert not bag.get("live_badge") and bag.get("proof") is None
assert "Aspire" in lc["lanes"] and "Hornets" in lc["lanes"] and "API" in lc["lanes"]
' && ok "brief-087 scorecard+live_check zeros, HOLDs" || bad "brief-087 law"

allr=1
for ep in auto-buy-gear fabricate-gear-inventory auto-text-kids auto-order-amazon auto-charge-card fabricate-price auto-replace-jersey fake-live-inventory hold-timeout-buy auto-share-checkout burn-outbound gear/auto-buy gear/fabricate-inventory gear/auto-replace gear/auto-order jersey/auto-replace amazon/auto-order; do
  for m in GET POST; do
    c=$(curl -s -o /tmp/sgc-refuse.json -w "%{http_code}" -X "$m" "$BASE/api/$ep" -H 'Content-Type: application/json' $([[ $m == POST ]] && echo "-d {}") || echo 000)
    [[ "$c" == "403" ]] || allr=0
  done
done
[[ "$allr" == "1" ]] && ok "403 GET+POST all gear gates" || bad "403 stubs incomplete"

curl -s -o /tmp/sgc-refuse-buy.json "$BASE/api/auto-buy-gear" || true
"$PY" -c '
import json
d=json.load(open("/tmp/sgc-refuse-buy.json"))
assert d.get("brief")=="brief-087" or d.get("brief_id")=="brief-087"
assert d.get("ok") is False
assert d.get("merge_apply") is False
also=d.get("also_refused_by") or []
assert "brief-040" in also, also
' && ok "refuse prefer brief-087 on auto-buy-gear cites 040" || bad "auto-buy-gear refuse body"

curl -s -o /tmp/sgc-refuse-inv.json "$BASE/api/fabricate-gear-inventory" || true
"$PY" -c '
import json
d=json.load(open("/tmp/sgc-refuse-inv.json"))
assert d.get("brief_id")=="brief-087"
also=d.get("also_refused_by") or []
assert "brief-040" in also, also
' && ok "refuse fabricate-gear-inventory cites 040" || bad "fabricate inventory refuse"

curl -s -o /tmp/sgc-refuse-bo.json "$BASE/api/burn-outbound" || true
"$PY" -c '
import json
d=json.load(open("/tmp/sgc-refuse-bo.json"))
assert d.get("brief_id")=="brief-087"
assert d.get("merge_apply") is False
' && ok "refuse burn-outbound brief-087" || bad "burn-outbound refuse"

curl -sf "$BASE/" | grep -q "Brief-087 law · Family sports equipment checkout" && ok "served UI panel brief-087" || bad "served UI missing panel"
curl -sf "$BASE/" | grep -q "Aspire" && ok "served UI Aspire lane" || bad "Aspire lane missing"
curl -sf "$BASE/" | grep -q "Hornets" && ok "served UI Hornets lane" || bad "Hornets lane missing"
curl -sf "$BASE/app.js" | grep -q "async function loadBrief087\|function loadBrief087\|loadBrief087" && ok "served app.js loadBrief087" || bad "served app.js loader"
# health alias
code=$(curl -s -o /dev/null -w "%{http_code}" "$BASE/health" || echo 000)
[[ "$code" == "200" ]] && ok "GET /health alias 200" || bad "GET /health HTTP $code"

# Do not touch Gift Board / photo desk — only note adjacency in README
check "README notes Gift Board adjacency only" grep -q "Gift Board" "$ROOT/README.md"
check "does not import gift-board path" bash -c '! grep -q "/workspace/tokenmax/gift-board" "'"$ROOT"'/server.py"'

TOTAL=$((PASS + FAIL))
echo "-- $PASS/$TOTAL passed ($FAIL failed) --"
if [[ "$FAIL" -eq 0 ]]; then
  echo "SMOKE PASS"
  exit 0
fi
echo "SMOKE FAIL"
exit 1
