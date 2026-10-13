// ---- edit the tiles here ----
const TILES = [
  { name: "Reddit",   url: "https://www.reddit.com" },
  { name: "Twitch",   url: "https://www.twitch.tv" },
  { name: "YouTube",  url: "https://www.youtube.com" },
  { name: "X",        url: "https://x.com" },
  { name: "Basecamp", url: "https://app.basecamp.com" },
];
const USERNAME = "tree";

const $ = (id) => document.getElementById(id);
function tick() {
  const d = new Date();
  $("time").textContent = d.toLocaleTimeString([], { hour: "2-digit", minute: "2-digit", hour12: false });
  $("date").textContent = d.toLocaleDateString([], { weekday: "long", month: "long", day: "numeric" });
  const h = d.getHours();
  const part = h < 5 ? "Still up" : h < 12 ? "Good morning" : h < 18 ? "Good afternoon" : "Good evening";
  $("greeting").textContent = `${part}, ${USERNAME}`;
}
tick(); setInterval(tick, 1000);

const tiles = $("tiles");
for (const t of TILES) {
  const a = document.createElement("a");
  a.className = "tile"; a.href = t.url;
  const img = document.createElement("img");
  img.alt = ""; img.src = `chrome-extension://${chrome.runtime.id}/_favicon/?pageUrl=${encodeURIComponent(t.url)}&size=64`;
  const label = document.createElement("span"); label.textContent = t.name;
  a.append(img, label); tiles.append(a);
}

$("search").addEventListener("submit", (e) => {
  e.preventDefault();
  const q = $("q").value.trim(); if (!q) return;
  if (/^[a-z][a-z0-9+.-]*:\/\//i.test(q)) { location.href = q; }
  else if (/^[^\s]+\.[a-z]{2,}(\/\S*)?$/i.test(q)) { location.href = "https://" + q; }
  else { chrome.search.query({ text: q, disposition: "CURRENT_TAB" }); }
});
