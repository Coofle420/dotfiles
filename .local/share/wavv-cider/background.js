chrome.runtime.onMessage.addListener((msg) => {
  if (msg && (msg.event === "call-start" || msg.event === "call-end")) {
    fetch(`http://127.0.0.1:5055/${msg.event}`, { method: "POST" }).catch(() => {});
  }
});
