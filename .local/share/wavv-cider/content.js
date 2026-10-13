(() => {
  const GHL_HOSTS = ["app.guildofhonour.com", "app.gohighlevel.com"];
  const origins = [location.origin, ...Array.from(location.ancestorOrigins || [])];
  const inGhl = origins.some(o => GHL_HOSTS.some(h => o.includes(h)));
  if (!inGhl) return;

  const LIVE = /\bIn Call\s*\d{1,2}:\d{2}|\bEnd Call\b/;
  let live = false;

  setInterval(() => {
    const now = LIVE.test(document.body ? document.body.innerText : "");
    if (now !== live) {
      live = now;
      try {
        chrome.runtime.sendMessage({ event: now ? "call-start" : "call-end" });
      } catch (e) {}
    }
  }, 1000);
})();
