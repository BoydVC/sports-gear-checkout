(function () {
  function esc(s) {
    return String(s == null ? "" : s)
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;");
  }

  async function loadHealth() {
    try {
      const h = await fetch("/api/health", { cache: "no-store" }).then((r) => r.json());
      const foot = document.getElementById("healthFoot");
      if (foot) {
        foot.textContent =
          "briefs_folded=" + (h.briefs_folded || []).join(",") +
          " · " + (h.demo_mode || "SYNTHETIC");
      }
      const sa = document.getElementById("servedAt");
      if (sa) sa.textContent = h.served_at_et || "—";
    } catch (_) {}
  }

  async function loadBrief087() {
    const el = document.getElementById("brief087Board");
    const badge = document.getElementById("brief087Badge");
    if (!el) return;
    try {
      const res = await fetch("/api/brief087", { cache: "no-store" });
      if (!res.ok) throw new Error("HTTP " + res.status);
      const b = await res.json();
      const lc = b.live_check || {};
      const board = b.gear_checkout_board || {};
      const bags = lc.bags || board.bags || [];
      const rows = bags
        .map((bag) => {
          return (
            `<span class="bag-pill">${esc(bag.owner)} · ${esc(bag.team)} · ` +
            `${esc(bag.checkout || "?")} · ${esc(bag.status || "EXAMPLE")}</span>`
          );
        })
        .join("");
      const inv = lc.inventory || board.inventory || {};
      const hold = lc.buy_hold || board.buy_hold || {};
      el.innerHTML =
        `<div><strong>Board honesty:</strong> ${esc(board.honesty || lc.honesty || "SYNTHETIC/EXAMPLE")}</div>` +
        `<div class="bag-row">${rows || "—"}</div>` +
        `<div>inventory · ${esc(inv.status || "EXAMPLE")} · checked_out=${esc(inv.checked_out)} · missing=${esc(inv.missing)} · proof=${esc(inv.proof)}</div>` +
        `<div style="margin-top:0.4rem">Hold · ${esc(hold.state || "HOLD")} · default=${esc(hold.default || "review_private")} · ` +
        `fake_live=${esc(lc.fake_live)} · merge_040=${esc((lc.cousin_brief_040 || {}).merge_apply)} · ` +
        `tz=${esc(lc.timezone || "America/New_York")} · ${esc(lc.served_at_et || "")}</div>`;
      if (badge) {
        badge.textContent =
          "auto_buy_gear=" + (lc.auto_buy_gear ?? 0) +
          " · fabricate_gear_inventory=" + (lc.fabricate_gear_inventory ?? 0) +
          " · fake_live=" + (lc.fake_live ?? 0);
      }
    } catch (e) {
      el.textContent = "Brief-087 load failed: " + e.message;
    }
  }

  loadHealth();
  loadBrief087();
  setInterval(loadHealth, 60000);
  setInterval(loadBrief087, 60000);
})();
