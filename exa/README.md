# Exa Search (Python)

A minimal, runnable [Exa](https://exa.ai) search integration scaffolded from the
setup guide.

**Configuration**

| Setting      | Value                                          |
|--------------|------------------------------------------------|
| Integration  | Python (`exa-py==2.14.0`)                       |
| Search type  | `auto` — balanced relevance and speed (default) |
| Content      | `highlights` — token-efficient excerpts         |

## Setup

```bash
cd exa
pip install -r requirements.txt

cp .env.example .env
# edit .env and set EXA_API_KEY, or: export EXA_API_KEY="your-key"
```

Get an API key at https://dashboard.exa.ai.

## Run

```bash
python search.py "your search query here"
python search.py "latest GPU releases" --num-results 5
```

Each result prints its title, URL, and query-relevant highlights.

## What's here

`search.py` implements **Pattern 1 (raw retrieval)** from the guide — it inspects
`results` directly and exposes `highlights` so you can feed them into your own
agent or LLM:

```python
exa.search(
    query,
    type="auto",
    num_results=10,
    contents={"highlights": True},
)
```

## Where to go next

- **Structured / grounded output** — add an `output_schema` (and optional
  `system_prompt`) to the same `exa.search(...)` call to get synthesized JSON in
  `response.output.content` with field-level citations in `response.output.grounding`.
- **Content modes** — swap `{"highlights": True}` for
  `{"text": {"max_characters": 20000}}` (full text, RAG) or
  `{"summary": {"query": "..."}}` (LLM-written summary per result). Note: the
  Python SDK uses `snake_case` inside nested dicts (`max_characters`).
- **Known URLs** — use `exa.get_contents([...], highlights=True)` when you already
  have URLs and just need their content.
- **Freshness** — add `contents={"maxAgeHours": 0}` to force a livecrawl instead
  of using cached content.

Canonical reference:
https://docs.exa.ai/reference/search-api-guide-for-coding-agents
