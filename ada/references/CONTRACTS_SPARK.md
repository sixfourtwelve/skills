# Ada Contracts and Incremental SPARK

Use this reference for executable contracts, assertion policy, proof boundaries, and GNATprove.

## Public Contracts

Put stable obligations in specs using `Pre`, `Post`, `Type_Invariant`, `Type_Invariant'Class`, `Static_Predicate`, `Dynamic_Predicate`, and `Default_Initial_Condition` where each expresses a useful truth.

```ada
procedure Deposit (A : in out Account; Sum : Amount)
  with Pre  => Sum > 0,
       Post => Balance (A) = Balance (A)'Old + Sum;
```

For functions use `F'Result` in postconditions. Keep contract expressions deterministic, terminating, and free of externally visible side effects because assertion policy controls evaluation. Contracts document and check caller/programmer obligations; if hostile input must always be rejected, perform explicit validation rather than relying on a disabled precondition.

Enabled failures raise `Ada.Assertions.Assertion_Error`. Set `Assertion_Policy` deliberately in project/build profiles, normally checking contracts and assertions in development/test. Exercise the production policy too. Never recommend blanket `Suppress` or `-gnatp`: removed checks can turn detectable failures into erroneous execution.

## Class-Wide Contracts

Use `Pre'Class`/`Post'Class` on tagged primitives to preserve substitutability. Applicable inherited class-wide preconditions behave as alternatives (the call fails only when all applicable class-wide preconditions fail); applicable class-wide postconditions must all hold. Do not casually strengthen an overriding precondition or duplicate contracts without analyzing inheritance. Mark overrides explicitly.

## Incremental SPARK

Use `SPARK_Mode` for selected logic where proof value justifies modeling cost. Typical proof-facing aspects include `Global`, `Depends`, `Abstract_State`, `Refined_State`, `Initializes`, `Pre`, `Post`, loop invariants/variants, and deliberately modeled `Exceptional_Cases`.

A practical branch:

1. Select deterministic, high-value packages and state the desired guarantees.
2. Make them valid SPARK; isolate unsupported/foreign/resource machinery in thin Ada boundary packages.
3. Run flow analysis for initialization and data dependencies.
4. Run proof for run-time-error freedom and selected functional contracts.
5. Review every unproved check, assumption, suppressed message, and external contract.

SPARK is a substantial Ada subset, not “Ada with no pointers or concurrency.” It supports access types under an ownership policy and restricted tasking/protected objects under supported profiles. Controlled types are forbidden, so keep controlled resources outside proof regions and specify their boundary precisely. Do not impose SPARK or a safety runtime profile on ordinary code that has no such requirement.

## GNATprove and CI

Inspect the pinned project and installed manual before choosing switches. A representative strict CI invocation is:

```fish
gnatprove -P app.gpr --mode=prove --checks-as-errors=on --proof-warnings=on
```

This is illustrative, not a command to run blindly. GNATprove can otherwise exit successfully while checks remain unproved; `--checks-as-errors=on` makes that CI policy explicit. `--proof-warnings=on` can expose suspicious unreachable/inconsistent contracts but does not establish consistency. Pin GNATprove/prover versions, proof level/timeouts, project switches, and retained reports; version changes can alter results. Separate “valid SPARK,” flow-clean, run-time-error proof, and functional proof in reports.

Proof complements tests: test foreign boundaries, exceptional behavior, integration, and assumptions that proof does not cover.

## Review Checklist

- Will the contract be checked under the active assertion policy?
- Is hostile input explicitly validated where required?
- Are class-wide contracts substitutable across overrides?
- What exact packages, properties, and proof modes are in scope?
- Are non-SPARK boundaries thin and accurately contracted?
- Does CI fail on unproved checks and preserve diagnostics?
- Are tool/prover versions and assumptions pinned?

## Authoritative Primary Sources

- [Ada 2022 RM 6.1.1, Preconditions and Postconditions](http://www.ada-auth.org/standards/22rm/html/RM-6-1-1.html)
- [Ada 2022 RM 7.3.2, Type Invariants](http://www.ada-auth.org/standards/22rm/html/RM-7-3-2.html)
- [Ada 2022 RM 11.4.2, Pragmas Assert and Assertion_Policy](http://www.ada-auth.org/standards/22rm/html/RM-11-4-2.html)
- [SPARK User's Guide, Introduction](https://docs.adacore.com/spark2014-docs/html/ug/en/introduction.html)
- [SPARK User's Guide, GNATprove](https://docs.adacore.com/spark2014-docs/html/ug/en/gnatprove.html)
- [SPARK User's Guide, How to Run GNATprove](https://docs.adacore.com/spark2014-docs/html/ug/en/source/how_to_run_gnatprove.html)
- [SPARK User's Guide, Language Restrictions](https://docs.adacore.com/spark2014-docs/html/ug/en/source/language_restrictions.html)
