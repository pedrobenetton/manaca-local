import React, { useEffect, useState } from "react";

function App() {
  const [msg, setMsg] = useState("");

  useEffect(() => {
    fetch("/api/hello")
      .then(res => res.json())
      .then(data => setMsg(data.message));
  }, []);

  return (
    <div style={{ padding: 40 }}>
      <h1>MyCrystApp</h1>
      <p>Backend says: {msg}</p>
    </div>
  );
}

export default App;
