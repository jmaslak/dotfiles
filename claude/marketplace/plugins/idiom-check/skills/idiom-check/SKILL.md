---
name: idiom-check
description: This skill should be used when the user asks "is this idiomatic?", "is this pythonic?", "check my idioms", "validate idiomatic usage", "is this good Lisp?", "is this good Perl?", "review code style for idioms", "does this follow language conventions?", or asks whether code follows the natural patterns of its language. Provides a framework for analyzing code idiomaticity across all languages.
version: 0.1.0
---

# Idiom Check Skill

Guidance for analyzing code idiomaticity: whether code uses the language as a fluent practitioner would write it, not merely whether it is correct.

## When to Apply

Apply this guidance when the user:
- Asks if code is idiomatic, pythonic, or follows language conventions
- Wants idiom review on a file or inline code snippet
- Asks about language best practices for a specific pattern
- Shares code and wants to know if it "looks right" in the language

The user can also invoke `/check-idioms [file]` to run a structured idiom check on any file.

## What "Idiomatic" Means

Idiomatic code uses language features the way the language was designed to be used. A fluent practitioner could have written it without thinking. The goal is not just correctness but naturalness: would a language expert pause when reading this?

## Analysis Process

1. **Read the full file first.** Context matters — a pattern might look non-idiomatic in isolation but be correct given surrounding constraints.

2. **Identify the language** from the file extension or user statement. Apply language-specific idiom knowledge.

3. **Look for the common failure modes:**
   - Bringing habits from another language (e.g., writing C-style loops in Python)
   - Not using the standard library for common tasks
   - Verbose code where the language has concise built-ins
   - Manual resource management where the language has automatic patterns
   - Ignoring the language's preferred error handling style
   - Using old-style constructs when modern equivalents exist

4. **For each violation:**
   - Give the exact line number(s)
   - Show the current code
   - Show the idiomatic equivalent
   - Explain briefly why the idiomatic form is preferred

5. **Be direct.** If the code is non-idiomatic, say so and show the fix. Don't soften it.

## Scope Boundaries

Analyze idioms only — not architecture, not algorithm choice, not naming (unless it violates a clear language convention like snake_case in Python or SCREAMING_SNAKE for constants). Do not flag stylistic preferences that lack language-community backing.

## Output Structure

Report issues in severity order:
1. **Clear violations** — patterns no fluent speaker would write
2. **Opportunities** — patterns that work but miss idiomatic shortcuts

End with: total count and an overall rating: Poor / Fair / Good / Excellent.
