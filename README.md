# Sports Gear Checkout

Local TokenMax invent for **brief-087** — Hometown Aspire / Hornets / API gear bag + jersey checkout board.

- Bind: `127.0.0.1:4350`
- Honesty: EXAMPLE/SYNTHETIC until this-session dual_proof; never cyan LIVE inventory
- Hold: `review_private` before buy/replace; buy/replace/text_kids never default
- Cousin Gift Board brief-040: `merge_apply=false` (gift buy ≠ gear buy)
- Not KPD · no outbound · no on-demand cloud spend

## Run

```bash
./run.sh          # start
./run.sh test     # smoke
./run.sh stop
```

## Brief-087 fold (Family sports equipment checkout)

- `data/brief087.json` — law + EXAMPLE gear board (inventory null; Hold review_private).
- `GET /api/brief087` — law + `live_check` (`ok: true`, `fake_live: 0`).
- `GET /api/health` — `briefs_folded` includes `brief-087`.
- Scorecard zeros: `auto_buy_gear` · `fabricate_gear_inventory` · `auto_text_kids` · `auto_order_amazon` · `auto_charge_card` · `fabricate_price` · `auto_replace_jersey` · `fake_live_inventory` · `hold_timeout_buy` · `auto_share_checkout` · `burn_outbound`.
- 403 GET+POST: `/api/auto-buy-gear`, `/api/fabricate-gear-inventory`, `/api/auto-text-kids`, `/api/auto-order-amazon`, `/api/auto-charge-card`, `/api/fabricate-price`, `/api/auto-replace-jersey`, `/api/fake-live-inventory`, `/api/hold-timeout-buy`, `/api/auto-share-checkout`, `/api/burn-outbound` (+ `/api/gear/*`, `/api/jersey/auto-replace`, `/api/amazon/auto-order`). `also_refused_by` brief-040 (+ brief-013 notes).
- UI: **Brief-087 law · Family sports equipment checkout** + `loadBrief087`.

Does not touch Gift Board `:4324` or family sports photo desk `:4329`.
