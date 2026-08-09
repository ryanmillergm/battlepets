import { useEffect, useState } from "react";

type ServiceHealth = { status: string; service: string; version: number };

const sections = ["Battlepets", "Specialty cards", "Rarities", "Packs", "Exchange recipes", "Moderation", "Operations"];

export function App() {
  const [health, setHealth] = useState<ServiceHealth | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [active, setActive] = useState(sections[0]);

  useEffect(() => {
    fetch("/api/health")
      .then(async (response) => {
        if (!response.ok) throw new Error(`Service returned ${response.status}`);
        return response.json() as Promise<ServiceHealth>;
      })
      .then(setHealth)
      .catch((reason: unknown) => setError(reason instanceof Error ? reason.message : "Service unavailable"));
  }, []);

  return (
    <div className="shell">
      <aside>
        <div className="brand">BATTLEPETS</div>
        <div className="subtitle">ADMIN WORKSHOP</div>
        <nav>
          {sections.map((section) => (
            <button className={active === section ? "active" : ""} key={section} onClick={() => setActive(section)}>{section}</button>
          ))}
        </nav>
      </aside>
      <main>
        <header>
          <div>
            <h1>{active}</h1>
            <p>Draft, validate, preview, and publish versioned game content.</p>
          </div>
          <div className={`status ${health ? "online" : "offline"}`}>
            {health ? `API ${health.status} · v${health.version}` : error ?? "Connecting…"}
          </div>
        </header>

        <section className="notice">
          <strong>Development scaffold</strong>
          <span>Editing remains locked until authenticated admin APIs and audit logging are connected.</span>
        </section>

        <section className="cards">
          <article>
            <span className="eyebrow">CONTENT SAFETY</span>
            <h2>Validated effects only</h2>
            <p>Pet abilities and specialty cards will use preset triggers, targets, conditions, and effects. Arbitrary code is never accepted.</p>
          </article>
          <article>
            <span className="eyebrow">PUBLISHING</span>
            <h2>Version every change</h2>
            <p>Published definitions are snapshotted into matches so edits cannot alter battles already underway.</p>
          </article>
          <article>
            <span className="eyebrow">RELEASE GATES</span>
            <h2>Fail closed</h2>
            <p>Child online access, chat, payments, and voice remain disabled until their independent reviews are complete.</p>
          </article>
        </section>

        <section className="empty-state">
          <div className="pixel-pet">BP</div>
          <h2>{active} editor is next</h2>
          <p>The navigation and service-health shell are ready. CRUD forms will activate with the secured M2 endpoints.</p>
        </section>
      </main>
    </div>
  );
}
