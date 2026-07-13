"""Exa search starter.

Configuration (from the Exa setup guide):
    - Integration : Python (exa-py 2.14.0)
    - Search type : auto  (balanced relevance and speed)
    - Content     : highlights  (token-efficient, query-relevant excerpts)

Usage:
    export EXA_API_KEY="your-key"        # or put it in exa/.env
    python search.py "your search query here"
    python search.py "latest GPU releases" --num-results 5
"""

import argparse
import os
import sys

try:
    from dotenv import load_dotenv

    load_dotenv()
except ImportError:  # python-dotenv is optional; env vars still work without it.
    pass

from exa_py import Exa


def search(query: str, num_results: int = 10):
    """Run a raw-retrieval Exa search and return the response object.

    This is Pattern 1 from the setup guide: inspect `results` directly and
    pass the per-result `highlights` into your own downstream logic / LLM.
    """
    api_key = os.environ.get("EXA_API_KEY")
    if not api_key:
        sys.exit(
            "EXA_API_KEY is not set. Export it or add it to exa/.env "
            "(copy exa/.env.example)."
        )

    exa = Exa(api_key=api_key)

    return exa.search(
        query,
        type="auto",
        num_results=num_results,
        contents={"highlights": True},
    )


def main() -> None:
    parser = argparse.ArgumentParser(description="Search the web with Exa.")
    parser.add_argument("query", help="The search query.")
    parser.add_argument(
        "-n",
        "--num-results",
        type=int,
        default=10,
        help="Number of results to return (default: 10).",
    )
    args = parser.parse_args()

    response = search(args.query, num_results=args.num_results)

    for i, result in enumerate(response.results, start=1):
        print(f"{i}. {result.title}")
        print(f"   {result.url}")
        for highlight in (result.highlights or []):
            print(f"   > {highlight.strip()}")
        print()


if __name__ == "__main__":
    main()
