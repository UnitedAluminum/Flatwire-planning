# Rod and Order Allocation — Worked Examples (workbook content)

**Project:** United Aluminum (UAL) — Flat Wire Mill Module
**Document Type:** Source content for a generated client deliverable
**Renders to:** `MVP-1/SRS/FlatWire_OrderAllocationExamples.xlsx` via [`build_allocation_examples_xlsx.py`](build_allocation_examples_xlsx.py)

> **This file is the only place the workbook's prose is authored.** Edit it and re-run the generator; **never edit the `.xlsx`**. The subject matter is `LatestDocument/RodOrderAllocation_WorkedExamples.md` — that document is the internal trace with table and register names, this one is the client-facing wording.

> **Recovered, not re-authored.** The generator and this file were lost (never committed — only a `__pycache__` artifact survived), so this content was extracted from the shipped workbook on 25 Aug 2026 to restore the source. It therefore matches what the client already holds, cell for cell.

> **Syntax.** `## Sheet: <tab name>` starts a sheet. `!widths` sets column widths. `!freeze` sets the frozen pane. Each row is one line prefixed by its kind — `title:`, `subtitle:`, `section:`, `header:`, `data:` — with cells separated by `|`. A bare `blank:` emits an empty row. `<br>` is a line break inside a cell.

---

## Sheet: Read Me

!widths A=28 B=150
!freeze A4

title: Rod and Order Allocation — Worked Examples
subtitle: Generated from the design of record on August 24, 2026. Never edit this workbook - edit the source and rebuild.
blank:
header: Item | Detail
data: Purpose | We have written down how the mill will handle rods that are shared between orders, and we need you to check that it matches how you actually work. This workbook states each rule in plain language and then shows it twice — once where the system accepts what the operator does, and once where it refuses — with real weights and lengths. Where a rule is our interpretation rather than something you told us, the last sheet asks the question outright.
data: How to read an example | Every example names the rule it demonstrates, so you can read a rule on the second sheet and then look at its two examples. The outcome column is colour-coded: green where the system accepts, red where it refuses, amber where it warns someone but lets the line carry on. If an example describes something you would expect the system to allow, that is exactly the kind of thing we need to hear.
data: What we need from you | Two things. First, tell us where an example describes behaviour you would not want — a refusal that should be allowed, or an acceptance that should not be. Second, answer the questions on the last sheet. One of them, Q48, we cannot design around: if planning can put two orders needing different mill settings on the same rod, then the rod cannot stay mounted across that boundary and the operator has to check it out and back in.
data: Rod weight | Three different rod weights are in circulation between your planning spreadsheet, the recording of our call, and the supply contracts. We have not picked one. The full-run sheets are worked twice, once at 4,000 lb per rod and once at 8,760 lb, so you can see that the rules hold either way and tell us which figure is real. Everything on those two sheets is computed from that one number, so nothing else has to change once you confirm it.
data: Reading order | Start with The Rules, then Worked Examples. The two single-spool traces show one rod and then a welded pair in detail. Order Handoff shows what happens at the moment one order becomes the next on a rod that is still turning. The two full-run sheets reproduce your own planning spreadsheet's output end to end, and Orders Across the Run lays orders over it. Finish on What We Need Confirmed.
data: One caution | Everything here is generated from our design documents, so it says what we currently intend to build — not what has been built and tested. Where a figure depends on something still open, the sheet says so rather than showing a number we cannot stand behind. ---
blank:
section: Glossary - the only place shorthand appears in this workbook
header: Term | What it means
data: Allocation | The pounds of a particular rod that planning has assigned to a particular order
data: Pairing | One rod worked against one order. A rod shared between two orders has two pairings
data: Payoff | The stand the rod is mounted on. Both rod-fed lines share one, which is why the one-order-at-a-time rule is checked there and not per line
data: Shared rod | A rod whose material is split between two orders, so it carries the boundary between them
data: Boundary | The point inside a shared rod where one order's material ends and the next order's begins
data: Part | The material one rod puts onto one spool. A rod normally spans several spools, and a welded spool has parts from two rods
data: Welded spool | A spool wound from two rods, joined at the drawing line when the first ran out
data: Lead part | The part that went onto a spool last. It comes off first, so it is the spool's face at the finishing line
data: Notification point | The counter reading at which the operator is told an order's allocated weight has been reached
data: Overrun | Material produced between the notification and the operator confirming the order complete
data: Part-used rod | A rod returned to stock with material still on it, and picked up again later
data: Issued | Metal taken from stock. Distinct from produced, which is what came out as finished coils

---

## Sheet: The Rules

!widths A=8 B=20 C=62 D=30 E=52 F=22
!freeze C6
!filter A5:F29

title: The Rules
subtitle: Generated from the design of record on August 24, 2026. Never edit this workbook - edit the source and rebuild.
subtitle: Twenty-four rules. The first nine are the operating rules you gave us on the call — we have restated them so you can check we heard them right. The remaining fifteen are the checks the system performs to enforce them. Each row lists the examples that demonstrate it.
blank:
header: Rule | Kind | What it says | When it applies | If it is broken | Examples
data: R01 | Agreed operating rule | Planning decides which rods go to which orders, how many pounds of a shared rod belong to each order, and the sequence the rods should be worked in. The shopfloor reads that; it does not author it. | Whenever a rod is presented at the payoff. | The operator cannot create an allocation. If the rod is not allocated to the order they want, a supervisor has to authorise a substitution. | E001, E002
data: R02 | Agreed operating rule | One order at a time at the rod payoff, worked through to completion. No order is left part-filled while another runs. | At the rod-fed lines. The finishing line is not bound by it and carries on cutting the previous order's spools. | A second order cannot be opened while one is still open at that payoff. The check sits in the data rather than only in the screen, so two operators working at once cannot both succeed. | E003, E004
data: R03 | Agreed operating rule | Inside an order, the operator picks the sequence. Whatever suits the floor is acceptable. | To the rods that lie wholly inside the order. | Nothing is refused on these rods — that is the point of the rule. The constraint applies only to rods shared with a neighbouring order. | E005, E006
data: R04 | Agreed operating rule | A rod shared between two orders is worked once, straight through. It is therefore the last rod of the order finishing and the first rod of the order starting, and it cannot sit anywhere in the middle. | Every time an order boundary falls inside a rod. | Presenting a shared rod anywhere but at the boundary is refused. | E007, E008
data: R05 | Agreed operating rule | An order's rods fall into three groups: at most one shared with the previous order, which must run first; its own rods, in any sequence; and at most one shared with the next order, which must run last. | Whenever the system works out what the operator may present next. | A rod offered out of its group is refused. Within the operator's own rods, full rods come before part-used ones. | E009, E010
data: R06 | Agreed operating rule | The point inside a shared rod where one order ends is held as a weight, and turned into a length once, at the start of the pairing, using the gauge and width actually running. The operator sees and works in feet. | At the start of each pairing on a shared rod. | A length cannot be offered as the split point. Length is not preserved through drawing and rolling — the same weight is roughly seven times longer once finished — so a length measured on the rod could not be compared against the line counter. | E011, E012
data: R07 | Agreed operating rule | A rod carrying a boundary is checked in once, when it is mounted, and stays mounted while the boundary is crossed. There is no dismount, no remount and no second check-in. | At every order boundary that falls inside a rod. | A second scan of a running rod is treated as a duplicate and refused. Accepting it would open a second run and re-send the machine settings in the middle of running material. | E013, E014
data: R08 | Agreed operating rule | The system tracks what has been run against the current order and tells the operator when its allocated weight is reached. | Continuously while an order is running. | The notification is raised by the system the moment the point is passed, and is held until answered — so closing the screen does not lose it. | E015, E016
data: R09 | Agreed operating rule | Reaching the allocated weight does not close the order. The operator marks it complete, and only then does the next order begin. The line keeps running in between, and what it produces in that gap is recorded rather than thrown away. | At the end of every order. | The next order cannot be started until the previous one is confirmed. Material produced in the gap is kept as an overrun against the order that produced it. | E017, E018
data: R10 | System check | A new order cannot be started at a payoff while another is still open there. | At check-in. | Refused. Both rod-fed lines share one physical payoff, so the check is on the payoff and not on the line name — otherwise one stand could hold two open orders. | E019, E020, E060
data: R11 | System check | Rods are presented in group sequence: the incoming shared rod, then full rods of the order's own, then part-used ones, then the outgoing shared rod. | At staging and again at check-in. | Refused outright. This is a refusal and not something a supervisor can override. | E021, E022
data: R12 | System check | A rod shared with a neighbouring order sits at one end of the order, never in the middle. | At staging and again at check-in. | Refused. An order lying wholly inside a single rod is the special case: that rod is both the first and the last, and it is the order's only rod. | E023, E024, E059
data: R13 | System check | The rod shared with the next order runs last within this one. | At staging and again at check-in. | Refused while any of the order's own rods are still unrun. | E025, E026
data: R14 | System check | Nothing belonging to the next order can be worked until the operator has confirmed the current one complete. | At check-in. | Refused. The confirmation is what triggers the next order, so there is no path around it. | E027, E028
data: R15 | System check | The order chosen at check-in has to be one of the live allocations planning made for that rod. | At staging and again at check-in. | Refused. A supervisor-authorised substitution is the way to run an unallocated rod. | E029, E030
data: R16 | System check | The allocations on a rod must fit together end to end and account for the whole rod, with no overlap and no gap. | When an allocation is recorded or changed. | Refused. An overlap would attribute the same pounds to two orders, and a gap would leave metal belonging to none. | E031, E032, E057
data: R17 | System check | An order that has an allocated weight has at least one rod to run it against. | When an allocation is recorded. | Refused. There would be nothing to work. | E033, E034, E052
data: R18 | System check | Producing past the allocated weight warns the operator and, past a set point, tells a supervisor. It never stops the line. | While an order is past its notification point and not yet confirmed. | Nothing is refused. Stopping the line mid-rod would scrap continuous material, so the overrun is recorded and escalated instead. We do not yet know what the bound should be — that is Q50. | E035, E036, E050, E051
data: R19 | System check | Running a rod that planning did not allocate to the order needs a supervisor to authorise it, and the authorisation is recorded. | At check-in. | Refused without the authorisation. The credential itself is never stored, only who authorised it and why. | E037, E038, E053
data: R20 | System check | When planning changes an allocation, the old one is replaced rather than edited, and work can only be booked against the live one. | At check-in. | Refused. Work already done keeps a record of the figures the floor was actually given, so a later re-plan never rewrites history. | E039, E040, E055
data: R21 | System check | A rod that is mounted and turning is not checked in a second time. | At check-in, including at an order boundary. | Refused as a duplicate scan. Accepting it would open a second run and re-send the machine settings mid-material. | E041, E042, E054
data: R22 | System check | The order starting on a rod that is already mounted has to run the same mill settings as the order finishing on it, because the settings were sent once at check-in and cannot be re-sent without another check-in. | At the moment the operator confirms one order and the next begins. | The crossing is refused, not the order: the operator is told to check the rod out and back in. Whether planning can put two orders with different settings on one rod at all is Q48, and it is the most important question open. | E043, E044
data: R23 | System check | Every finished coil is cut from a single spool. It never draws on two. | At coil completion. | Refused. This is your own planning spreadsheet's rule — welding happens at the drawing line, and the finishing line cuts and restarts. | E045, E046
data: R24 | System check | The parts on a spool add up to the spool's weight, and all the parts off a rod add up to the rod's weight, within the normal weight tolerance. | When a spool is completed, and when a rod is checked out — not continuously. | Refused at that closing moment. It is deliberately not checked as you go: a rod's parts accumulate over days across several spools, so for most of a rod's life the sums legitimately do not balance. --- | E047, E048, E049, E056, E058

---

## Sheet: Worked Examples

!widths A=7 B=8 C=12 D=44 E=60 F=46 G=74 H=40
!freeze D6
!filter A5:H65

title: Worked Examples
subtitle: Generated from the design of record on August 24, 2026. Never edit this workbook - edit the source and rebuild.
subtitle: Every rule appears at least twice: once where the system accepts what the operator does, and once where it refuses or escalates. Green is accepted, red refused, amber warned but allowed to continue. Filter the Rule column to see one rule's cases together, or the Outcome column to read all the refusals at once. Every figure shown is computed from the same conversion the system will use.
blank:
header: No. | Rule | Outcome | What it shows | Set-up | What the operator does | What the system does | Figures
data: E001 | R01 | Accept | Planning owns the pairing | Planning allocates 5,000 lb of a 8,760 lb rod to order 100500 and 3,760 lb to order 100700. | The operator opens the rod at the payoff and reads its orders. | Both orders are shown, in planning sequence, with the pounds allocated to each. The screen offers no way to change them. | 5,000 lb + 3,760 lb = 8,760 lb
data: E002 | R01 | Refuse | The shopfloor cannot author an allocation | The same rod, with no allocation recorded by planning for the order the operator wants to run. | The operator tries to run the rod against that order. | Refused. The order is not among the ones planning allocated to this rod, and the shopfloor cannot create one. A supervisor may authorise a substitution instead.
data: E003 | R02 | Accept | One order at a time at a payoff | Order 100500 is running at the rod payoff. | The operator finishes it, marks it complete, and starts order 100700. | Accepted. The next order begins only once the previous one is confirmed complete, so no order is left part-filled while another runs.
data: E004 | R02 | Refuse | A second order cannot be opened alongside the first | Order 100500 is running at the rod payoff and has not been confirmed complete. | Order 100700 is started at the same payoff. | Refused. The rule is held in the data, not only in the screen, so two operators working at once cannot both succeed.
data: E005 | R03 | Accept | Rods inside an order may run in any sequence | Order 100500 has three rods; the last is shared with order 100700. | The operator runs the two unshared rods in whichever sequence suits the floor. | Both sequences of the two unshared rods are accepted. Only the shared rod is fixed. | exactly 2 permitted sequences
data: E006 | R03 | Refuse | That freedom does not extend to the shared rod | The same three-rod order. | The operator runs the shared rod first. | Refused. A shared rod is fixed at one end of the order; the freedom applies only to the rods that lie wholly inside it.
data: E007 | R04 | Accept | A shared rod runs once, continuously | A rod split 5,000 lb to order 100500 and 3,760 lb to order 100700. | The operator runs it to the boundary, confirms 100500, and carries straight on. | Accepted. The rod is the last of the outgoing order and the first of the incoming one, and it is never cut in two. | boundary at 5,000 lb of 8,760 lb
data: E008 | R04 | Refuse | A shared rod cannot sit in the middle | Order 100500 has three rods, one of which is shared with order 100700. | The operator runs the shared rod second of the three. | Refused. A shared rod can only be first or last within its order, because it has to sit at the boundary.
data: E009 | R05 | Accept | The three roles a rod can take in an order | Order 100500 has one rod shared with the previous order, two of its own, and one shared with the next. | The operator works through all four. | Accepted in this shape: the incoming shared rod, then the two unshared rods in either sequence, then the outgoing shared rod. | exactly 2 permitted sequences
data: E010 | R05 | Refuse | Nothing follows the outgoing shared rod | Order 100500 has two unshared rods and one shared with order 100700. | The operator runs an unshared rod after the shared one. | Refused. Once the rod that carries the boundary has run, the order is finished.
data: E011 | R06 | Accept | The split point is one figure, held in pounds | A rod split at 5,000 lb of 8,760 lb, running alloy 1100 at the drawing line. | The system works out where to notify the operator. | The allocated pounds are converted to a length once, at the start of the pairing, at the gauge and width actually running. The operator sees and acts on feet. | 5,000 lb at 0.0809 lb per ft, so notify at 61,843 ft
data: E012 | R06 | Refuse | The boundary cannot be recorded as a length | The same rod. | A length is offered as the split point instead of a weight. | Refused. Length is not preserved through drawing and rolling, so a length measured on the rod cannot be compared against the line counter. Weight is preserved, so weight is what is stored. | 900 lb is 11,132 ft at the drawing line and 76,531 ft once finished
data: E013 | R07 | Accept | One mount, one check-in, two orders | A rod carrying the boundary between orders 100500 and 100700. | The operator crosses the boundary. | Accepted. The rod is checked in once, at mount, and stays mounted. No dismount, no remount, no second check-in. | one check-in, one run, two order records
data: E014 | R07 | Refuse | A mounted rod is not checked in twice | The same rod, already mounted and running. | The operator scans it again at the boundary. | Refused as a duplicate scan. Treating it as a fresh check-in would open a second run and re-send the machine settings in the middle of running material.
data: E015 | R08 | Accept | The notification is raised by the system, not the screen | Order 100500 is allocated 5,000 lb on a rod running at the drawing line. | The line passes the computed notification point. | The notification is raised the moment the point is passed, and is re-delivered if the screen dropped and reconnected. It is not a reminder the screen works out for itself. | notify at 61,843 ft
data: E016 | R08 | Escalate | The notification is not lost with the screen | The same order, with the operator screen closed when the point is passed. | The operator reopens the screen. | The outstanding notification is still there and is shown again. It is held until it is answered.
data: E017 | R09 | Accept | Only the operator closes an order | Order 100500 has reached its allocated 5,000 lb. | The operator marks the order complete. | Accepted, and only now does order 100700 begin. The system never closes an order by itself.
data: E018 | R09 | Escalate | The overrun in between is kept, not discarded | The same order, with the operator confirming 50 lb past the notification. | The line keeps running while the operator finishes what they are doing. | Two weights are recorded, one at the notification and one at the confirmation, and the difference between them is kept as real production to attribute. The line is never stopped for it. | notified at 5,000 lb, confirmed at 5,050 lb, overrun 50 lb
data: E019 | R10 | Accept | A new order opens once the previous one is confirmed | Order 100500 at the rod payoff has been marked complete. | The operator starts order 100700 on the same rod. | Accepted. The payoff holds exactly one open order at a time.
data: E020 | R10 | Refuse | Two open orders at one payoff | Order 100500 is still open at the rod payoff. | Order 100700 is started at the same payoff. | Refused. The two rod-fed lines share one physical payoff, so the check is on the payoff and not on the line -- otherwise the same stand could hold two open orders under two line names.
data: E021 | R11 | Accept | Full rods run before part-used ones | Order 100500 has two unshared full rods and one part-used rod returned to stock earlier. | The operator runs a full rod first. | Accepted. Full rods come before part-used ones within the unshared set.
data: E022 | R11 | Refuse | A part-used rod offered ahead of a full one | The same order. | The operator offers the part-used rod while a full rod is still unrun. | Refused outright. This is not offered as an override -- it is a refusal.
data: E023 | R12 | Accept | The incoming shared rod runs first | Order 100700 begins with the rod it shares with order 100500. | The operator continues on that rod. | Accepted. It is already mounted and running, so nothing can precede it.
data: E024 | R12 | Refuse | Something offered ahead of the incoming shared rod | Order 100700 shares its first rod with order 100500 and has one other rod. | The operator offers the other rod first. | Refused. The shared rod is mid-flow on the payoff; nothing may precede it.
data: E025 | R13 | Accept | The outgoing shared rod runs last | Order 100500 has two unshared rods and one shared with order 100700. | The operator runs both unshared rods, then the shared one. | Accepted.
data: E026 | R13 | Refuse | The outgoing shared rod offered mid-order | The same order. | The operator offers the shared rod while an unshared rod is still unrun. | Refused. It has to be last, because it carries the boundary into the next order.
data: E027 | R14 | Accept | The confirmation is what starts the next order | Order 100500 has reached its allocation and the operator confirms it. | Order 100700 begins on the same rod. | Accepted. The confirmation is the trigger, so there is no way to begin the next order without it.
data: E028 | R14 | Refuse | The next order cannot be worked before the confirmation | Order 100500 has reached its allocation and has not been confirmed. | The operator tries to begin order 100700. | Refused. Reaching the allocated weight is a notification, not a closure.
data: E029 | R15 | Accept | The order is one planning allocated to this rod | The rod carries allocations for orders 100500 and 100700. | The operator selects order 100500. | Accepted.
data: E030 | R15 | Refuse | An order the rod is not allocated to | The same rod. | The operator selects order 100421, which is not among its allocations. | Refused. The order has to be one of the rod's live allocations.
data: E031 | R16 | Accept | The allocations cover the rod exactly | A 8,760 lb rod allocated 5,000 lb to order 100500 and 3,760 lb to order 100700. | The allocation is recorded. | Accepted. The two ranges meet at the boundary and together account for the whole rod, with no gap and no overlap. | 0 to 5,000 lb, then 5,000 lb to 8,760 lb
data: E032 | R16 | Refuse | Allocations that overlap or leave a gap | The same rod, with the second allocation starting below the point the first one ended. | The allocation is recorded. | Refused. Overlapping ranges would attribute the same pounds to two orders, and a gap would leave metal belonging to none.
data: E033 | R17 | Accept | An order with an allocation has at least one rod | Order 100500 is allocated 5,000 lb across one rod. | The allocation is recorded. | Accepted.
data: E034 | R17 | Refuse | An order allocated no rod at all | Order 100500 is created with an allocated weight but no rod. | The allocation is recorded. | Refused. There is nothing to run it against.
data: E035 | R18 | Accept | A small overrun is recorded and the line runs on | Order 100500 allocated 5,000 lb; the operator confirms 50 lb past the notification. | The line keeps running throughout. | Accepted and recorded. Nothing is stopped. | overrun 50 lb against 5,000 lb
data: E036 | R18 | Escalate | A large overrun warns and escalates, but still does not stop | The same order, with the operator not responding for much longer. | The overrun passes the configured bound. | The operator is warned and a supervisor is told. The line still does not stop -- stopping mid-rod scraps continuous material. The bound itself is not yet agreed, which is question Q50.
data: E037 | R19 | Accept | A substitution with supervisor authorisation | A rod that planning did not allocate to order 100500 is the only one available. | A supervisor authorises the substitution and it is recorded against them. | Accepted, and the authorisation is kept with the record. The credential itself is never stored.
data: E038 | R19 | Refuse | A substitution without it | The same rod and order. | The operator tries to run it without authorisation. | Refused.
data: E039 | R20 | Accept | The live allocation is the one that is run | Planning re-plans order 100500; the old allocation is replaced by a new one. | The operator runs against the new allocation. | Accepted. Re-planning adds a replacement and marks the old one superseded -- it never edits history.
data: E040 | R20 | Refuse | A superseded allocation cannot be run against | The same order. | The operator runs against the replaced allocation. | Refused.
data: E041 | R21 | Accept | The rod is checked in once | A rod carrying the boundary between orders 100500 and 100700. | The operator checks it in at mount. | Accepted, and it stays mounted across the boundary.
data: E042 | R21 | Refuse | A running rod scanned again | The same rod, mounted and running. | The operator scans it a second time. | Refused as a duplicate. A second check-in would open a second run and re-send the machine settings mid-material.
data: E043 | R22 | Accept | The incoming order runs the same settings | Orders 100500 and 100700 on one rod call for the same gauge, width and edge. | The operator crosses the boundary. | Accepted. The settings were sent once, at check-in, and both orders run on them.
data: E044 | R22 | Refuse | The incoming order needs different settings | Order 100700 on the same rod calls for a different gauge. | The operator tries to cross the boundary mounted. | The crossing is refused, not the order: the operator is told to check the rod out and back in so the settings can be re-sent. Whether planning can do this at all is question Q48, the most important one open.
data: E045 | R23 | Accept | A finished coil draws on one spool | A 1,800 lb spool is cut into coils between 800 lb and 900 lb. | A coil is completed. | Accepted. Every parent of the coil comes from that one spool.
data: E046 | R23 | Refuse | A coil drawing on two spools | Two spools are on the finishing line in sequence. | A coil is recorded with parents from both. | Refused. This is the client planner's own rule -- welding happens at the drawing line, and the finishing line cuts and restarts.
data: E047 | R24 | Accept | The parts add up at the closing moment | A 1,800 lb spool wound from two rods. | The spool is completed. | Accepted. The parts sum to the spool weight, inside the 2 % tolerance.
data: E048 | R24 | Refuse | The parts do not add up | The same spool, with one part mis-recorded. | The spool is completed. | Refused at the closing moment. It is deliberately not checked continuously: a rod's parts accumulate over days across several spools, so for most of a rod's life the sums legitimately do not balance.
data: E049 | R24 | Escalate | A shared rod runs out before the outgoing order is satisfied | A rod allocated 5,000 lb to order 100500 runs out 320 lb short. | The rod is exhausted. | Order 100500 is left short by 320 lb and the reason is recorded as the rod running out. The incoming order's claim on that rod is cancelled and its next rod becomes first, which is legal because the incoming shared rod is optional. Whether an unplanned rod may top it up is question Q52. | shortfall 320 lb
data: E050 | R18 | Accept | The operator confirms early | Order 100500 allocated 5,000 lb; the operator confirms before the notification. | The operator marks it complete. | Permitted -- the confirmation is what counts. The difference is recorded as a negative overrun. Where the unconsumed allocation goes is question Q51. | confirmed early against 5,000 lb
data: E051 | R18 | Escalate | The operator overruns significantly | Order 100500 allocated 5,000 lb; the operator responds much later. | The line runs well past the notification. | Captured, warned and escalated -- never prevented. No bound is agreed yet, which is question Q50.
data: E052 | R17 | Escalate | The order is short after every planned rod is consumed | Every rod allocated to order 100500 has run and the order is still short. | The last rod closes. | The order is reported short. It needs a substitution or a planner decision; the system does not invent one.
data: E053 | R19 | Accept | An unplanned rod is substituted in | No allocated rod is available for order 100500. | A supervisor authorises a different rod. | Accepted, recorded as a substitution against the authorising supervisor.
data: E054 | R21 | Escalate | The rod is taken off the line mid-order | Order 100500 is running when the rod has to come off. | A supervisor checks the rod out with footage already run. | The pairing closes as abandoned and names the checkout that removed it. This uses the existing supervisor checkout -- no new mechanism.
data: E055 | R20 | Accept | Planning re-plans after processing has begun | Order 100500 is part-run when planning changes the allocation. | The new allocation is recorded. | The old allocation is superseded rather than edited, and what has already run keeps a snapshot of the figures the floor was actually given.
data: E056 | R24 | Accept | Leftover material goes back to stock | A rod is part-used when its last allocated order closes. | The operator checks the rod out. | The remainder is recorded against the rod and it returns to stock as a part-used rod, which is what makes it a part-used rod next time.
data: E057 | R16 | Accept | A rod shared by three or more orders | A 8,760 lb rod is split across three orders. | The allocation is recorded. | Accepted with no change of shape: the ranges simply chain, and the middle order is both first and last on that rod. This is the case that would have needed a redesign had the split point been stored as its own figure.
data: E058 | R24 | Accept | The conversion formula changes after records exist | Closed records exist that used the current factor. | The factor or its basis is changed. | Closed records are never recalculated. Each one states the factor, the basis and the formula version it actually used.
data: E059 | R12 | Refuse | An order inside one rod is that rod's only claim | Order 100500 lies wholly inside one rod, so that rod is both its first and its last. | A second rod is allocated to the same order. | Refused. An order that lies wholly inside one rod has exactly one rod, and code that assumes its first and last rods are different rows is wrong.
data: E060 | R10 | Refuse | The order queue has no gaps | The payoff queue runs orders 100500 then 100700. | An order is inserted with a position that leaves a gap in the queue. | Refused. Positions in the queue are consecutive, so there is never an ambiguous "next".

---

## Sheet: One Rod, One Order

!widths A=10 B=14 C=14 D=20 E=12 F=100
!freeze B6
!filter A5:F9

title: One Rod, One Order
subtitle: Generated from the design of record on August 24, 2026. Never edit this workbook - edit the source and rebuild.
subtitle: The simplest case, and the common one. A single rod is drawn down onto three spools, each part gets its own identity, and the first spool is followed through to the coils cut from it. No weld falls inside it, so every coil has exactly one parent.
blank:
header: Step | Part | Spool | Weight | Length on the spool | Notes
data: Part 1 of the rod | R00001A | SP-00001 | 1,800 lb | 0 to 22,263 ft | The rod is drawn down onto this spool. Each part gets its own identity, and the sequence number is what records the order they went on.
data: Part 2 of the rod | R00001B | SP-00002 | 1,800 lb | 0 to 22,263 ft | The rod is drawn down onto this spool. Each part gets its own identity, and the sequence number is what records the order they went on.
data: Part 3 of the rod | R00001C | SP-00003 | 400 lb | 0 to 4,947 ft | The rod is drawn down onto this spool. Each part gets its own identity, and the sequence number is what records the order they went on.
data: Total |  |  | 4,000 lb |  | The three parts account for the whole rod exactly.
blank:
section: What the first spool becomes at the finishing line
header: Coil | Identity | Weight | Length | Parents | Notes
data: Coil 1 | R00001D | 900 lb | 76,531 ft | 1 | One parent, because no weld falls inside this spool.
data: Coil 2 | R00001E | 900 lb | 76,531 ft | 1 | One parent, because no weld falls inside this spool.

---

## Sheet: Two Rods, One Spool

!widths A=10 B=14 C=14 D=18 E=12 F=26 G=10 H=22 I=66
!freeze B6
!filter A5:F8

title: Two Rods, One Spool
subtitle: Generated from the design of record on August 24, 2026. Never edit this workbook - edit the source and rebuild.
subtitle: The welded case — a rod runs out and the next is welded in behind it to finish the spool. Nine of the twenty-three spools on your own planning run look like this, so it is the normal minority rather than an edge case. The spool is unwound last on, first off, which is what decides which coil the weld ends up in and therefore what each certificate has to name. If a spool actually unwinds the other way round, this sheet is wrong and we need to know — that is Q45.
blank:
header: Order it went on | Part | Rod | Weight | Length on the spool | Notes
data: 1 of 2 | R00001C | R00001 | 400 lb | 0 to 4,947 ft | The outgoing rod runs out and the next is welded in behind it.
data: 2 of 2 | R00002A | R00002 | 1,400 lb | 4,947 to 22,263 ft | The incoming rod finishes the spool, so it is the last material on.
data: Total |  |  | 1,800 lb |  | The spool carries two rods. Its face at the finishing line is the part that went on last, R00002A, because that is the first material off.
blank:
section: What the finishing line makes from it, unwinding last on first off
header: Coil | Identity | Weight | Length | From rod | Length within the coil | Share | Weight from that rod | Notes
data: Coil 1 | R00002AA | 900 lb | 76,531 ft | R00002 | 0 to 76,531 ft | 100.0 % | 900 lb | One rod, so one identity. The identity is built from the part of the rod this coil was cut from, R00002A, which is why it carries two letters where a spool part carries one.
data: Coil 2 | R00002AB | 900 lb | 76,531 ft | R00002 | 0 to 42,517 ft | 55.6 % | 500 lb | The weld falls inside this coil, so it comes from two rods and carries an identity for each. This one covers the 500 lb from R00002 and is built from the same rod part as coil 1, R00002A, taking the next free letter.
data:  | R00001CA |  |  | R00001 | 42,517 to 76,531 ft | 44.4 % | 400 lb | And this one covers the 400 lb from R00001. It is built from that rod's part R00001C, and it is the first coil off that part, so it takes the first letter. This is the same pairing your own planning sheet writes as R00002AA - R00001CA. Both identities go into the coil records your other systems read, each carrying only its own weight, so the two add up to the coil's 900 lb and nothing is counted twice.
blank:
note: A coil made from one rod has one identity; a coil made from two has two. The certificate names every rod that contributed and how much came from each, which is what welding wire has to be able to show.

---

## Sheet: Order Handoff

!widths A=34 B=22 C=18 D=104
!freeze B6
!filter A5:D13

title: Order Handoff
subtitle: Generated from the design of record on August 24, 2026. Never edit this workbook - edit the source and rebuild.
subtitle: What happens at the moment one order becomes the next on a rod that is still turning. The rod is checked in once and stays mounted throughout. Two weights are recorded — one when the allocated weight is reached and one when you confirm — and the difference between them is the overrun. The closing counter reading of one order is the opening reading of the next, so the boundary is a single figure rather than two that could disagree.
blank:
header: From | To | What causes it | What is recorded
data: - | Pending | the rod passes validation at staging or at check-in | the pairing is recorded, with the planned position and a snapshot of the allocation
data: Pending | InProgress | for the first order, check-in is acknowledged; for every later order on the same rod, the previous order being marked complete is the trigger -- there is no second check-in | the starting counter reading, and the reading at which the notification will be raised
data: InProgress | ThresholdReached | the line passes the computed notification point | the crossing time, the weight latched at that instant, and the notification
data: InProgress | Closed | the operator marks the order complete before the allocated weight | closed early; the difference against the allocation is recorded as negative
data: InProgress or ThresholdReached | Closed | the rod runs out first | closed as rod exhausted, with the shortfall against the allocation
data: InProgress or ThresholdReached | Closed | the rod is taken off the line mid-order | closed as rod abandoned, naming the checkout that removed it
data: ThresholdReached | Closed | the operator marks the order complete | the confirmation, the second weight latch, the overrun between the two latches, the closing counter reading and the consumed weight with the factor and basis used. The rod stays on the line and is handed to the next order, not released
data: Pending | Voided | re-planning replaces the allocation before it starts | voided as superseded
blank:
section: The same handoff as figures, on the seeded rod weight
header: Moment | Counter reading | Weight | Notes
data: Rod mounted and checked in | 0 ft | 0 lb | One check-in for the whole rod. The machine settings are sent now, once, and they stand for both orders.
data: First order running | 0 ft | 0 lb | Its allocation is 5,000 lb, converted to a length once, here, at 0.0809 lb per ft.
data: Notification point reached | 61,843 ft | 5,000 lb | The weight at this instant is latched and never re-read. The line keeps running and the rod is not dismounted.
data: Operator confirms the order | 62,461 ft | 5,050 lb | A second weight is latched. The overrun of 50 lb between the two latches is kept as real production to attribute, not discarded.
data: Second order begins, same rod | 62,461 ft | 0 lb | No dismount, no remount, no second check-in. The first order's closing reading is the second order's opening reading, so the boundary is one figure and not two that could disagree.
data: Second order notification point | 108,967 ft | 3,760 lb | Its allocation is 3,760 lb. Note that only 3,710 lb of rod is left, because the overrun came out of it - so this order will finish 50 lb short unless another rod tops it up.
subtitle: The two readings in the middle are the same figure on purpose: one order closes and the next opens at the same point on the counter.
subtitle: This timeline deliberately shows an overrun rather than a clean handover, because the consequence is easy to miss - the 50 lb produced past the first order's allocation came out of the rod, so the second order starts with less than planned. That is why the overrun is recorded against the order that produced it. Where the shortfall should go is question Q52.

---

## Sheet: Processing Order Options

!widths A=46 B=62 C=18 D=60 E=70
!freeze B6
!filter A5:E10

title: Processing Order Options
subtitle: Generated from the design of record on August 24, 2026. Never edit this workbook - edit the source and rebuild.
subtitle: For each shape an order can take, every sequence the operator is permitted to work the rods in, and what is refused. The count is the number of genuinely different sequences, and it grows quickly — the system checks each rod as it is presented rather than working out the whole list, but the list is shown here so you can see the freedom is real.
blank:
header: Order shape | Rods and their roles | Permitted sequences | They are | What is refused
data: Three rods, the last shared with the next order | R1A - wholly inside this order, so it may run in any position; R1B - wholly inside this order, so it may run in any position; R1C - shared with the next order, so it must run last | 2 | R1A then R1B then R1C  \|  R1B then R1A then R1C | Running the shared rod before the other two.
data: Two rods, the first shared with the previous order | R1C - shared with the previous order, so it must run first; R1D - wholly inside this order, so it may run in any position | 1 | R1C then R1D | Running the unshared rod first.
data: One rod only - the order lies wholly inside it | R1C - the order lies wholly inside this one rod, so it is both first and last | 1 | R1C | Adding a second rod to the order at all.
data: Two unshared rods, one of them part-used | R2A - wholly inside this order, so it may run in any position; R2B - wholly inside this order, so it may run in any position, and part-used | 1 | R2A then R2B | Running the part-used rod before the full one.
data: Shared at both ends, two unshared rods between | R3A - shared with the previous order, so it must run first; R3B - wholly inside this order, so it may run in any position; R3C - wholly inside this order, so it may run in any position; R3D - shared with the next order, so it must run last | 2 | R3A then R3B then R3C then R3D  \|  R3A then R3C then R3B then R3D | Anything before the incoming shared rod, or after the outgoing one.

---

## Sheet: Weight and Footage

!widths A=26 B=60 C=88 D=10 E=12 F=18 G=22 H=20 I=62
!freeze C6
!filter A5:I25

title: Weight and Footage
subtitle: Generated from the design of record on August 24, 2026. Never edit this workbook - edit the source and rebuild.
subtitle: There is no single pounds-per-foot figure — it depends on the gauge and width running, and the drawing line and the finishing line differ by about seven times in cross-section. This sheet shows the conversion for every alloy, both lines and both edge profiles, alongside the figure published in our design so you can see they agree. A round edge holds less metal than the rectangle around it, and the difference matters most at the thick gauge.
blank:
header: Alloy | Line | Gauge | Width | Edge | Pounds per foot | Published to four places | A 900 lb coil is | Notes
data: '1100 | Drawing | 0.1100 in | 0.625 in | square | '0.080850 | '0.0809 | 11,132 ft | Gauge times width times twelve times density.
data: '1100 | Drawing | 0.1100 in | 0.625 in | round | '0.077796 | '0.0778 | 11,569 ft | A round edge holds less metal than the rectangle around it, and the difference matters most at the thick gauge.
data: '1100 | Finishing | 0.0160 in | 0.625 in | square | '0.011760 | '0.0118 | 76,531 ft | Gauge times width times twelve times density.
data: '1100 | Finishing | 0.0160 in | 0.625 in | round | '0.011695 | '0.0117 | 76,953 ft | A round edge holds less metal than the rectangle around it, and the difference matters most at the thick gauge.
data: '1350 | Drawing | 0.1100 in | 0.625 in | square | '0.080355 | '0.0804 | 11,200 ft | Gauge times width times twelve times density.
data: '1350 | Drawing | 0.1100 in | 0.625 in | round | '0.077320 | '0.0773 | 11,640 ft | A round edge holds less metal than the rectangle around it, and the difference matters most at the thick gauge.
data: '1350 | Finishing | 0.0160 in | 0.625 in | square | '0.011688 | '0.0117 | 77,002 ft | Gauge times width times twelve times density.
data: '1350 | Finishing | 0.0160 in | 0.625 in | round | '0.011624 | '0.0116 | 77,427 ft | A round edge holds less metal than the rectangle around it, and the difference matters most at the thick gauge.
data: '3003 | Drawing | 0.1100 in | 0.625 in | square | '0.081675 | '0.0817 | 11,019 ft | Gauge times width times twelve times density.
data: '3003 | Drawing | 0.1100 in | 0.625 in | round | '0.078590 | '0.0786 | 11,452 ft | A round edge holds less metal than the rectangle around it, and the difference matters most at the thick gauge.
data: '3003 | Finishing | 0.0160 in | 0.625 in | square | '0.011880 | '0.0119 | 75,758 ft | Gauge times width times twelve times density.
data: '3003 | Finishing | 0.0160 in | 0.625 in | round | '0.011815 | '0.0118 | 76,176 ft | A round edge holds less metal than the rectangle around it, and the difference matters most at the thick gauge.
data: '5052 | Drawing | 0.1100 in | 0.625 in | square | '0.080108 | '0.0801 | 11,235 ft | Gauge times width times twelve times density.
data: '5052 | Drawing | 0.1100 in | 0.625 in | round | '0.077082 | '0.0770 | 11,676 ft | A round edge holds less metal than the rectangle around it, and the difference matters most at the thick gauge.
data: '5052 | Finishing | 0.0160 in | 0.625 in | square | '0.011652 | '0.0117 | 77,240 ft | Gauge times width times twelve times density.
data: '5052 | Finishing | 0.0160 in | 0.625 in | round | '0.011588 | '0.0116 | 77,667 ft | A round edge holds less metal than the rectangle around it, and the difference matters most at the thick gauge.
data: '6061 | Drawing | 0.1100 in | 0.625 in | square | '0.080438 | '0.0804 | 11,189 ft | Gauge times width times twelve times density.
data: '6061 | Drawing | 0.1100 in | 0.625 in | round | '0.077399 | '0.0774 | 11,628 ft | A round edge holds less metal than the rectangle around it, and the difference matters most at the thick gauge.
data: '6061 | Finishing | 0.0160 in | 0.625 in | square | '0.011700 | '0.0117 | 76,923 ft | Gauge times width times twelve times density.
data: '6061 | Finishing | 0.0160 in | 0.625 in | round | '0.011636 | '0.0116 | 77,348 ft | A round edge holds less metal than the rectangle around it, and the difference matters most at the thick gauge.
blank:
section: How the notification point is worked out, and what basis was used
header: Basis | What it means | When it is used
data: IntegratedRunReading | summed across the run from the live gauge and width readings | Preferred. Summing across the run avoids stacking the gauge and width tolerances, which could otherwise put a perfectly in-specification coil outside the weight tolerance.
data: Measured | the gauge and width actually measured | Where a measured gauge and width are available but not a full run history.
data: Nominal | the ordered gauge and width | The fallback at the finishing line run on its own, which does not broadcast a live gauge.
data: Override | a figure entered by hand | A figure entered by hand, recorded as such.
blank:
subtitle: Whichever basis is used, the factor and the basis are recorded against the finished record, so a later change to the formula never alters a historical figure.
subtitle: The dimensional basis itself is still open - it is question Q10, and it affects every weight in this workbook.

---

## Sheet: Order Completion

!widths A=12 B=14 C=12 D=24 E=10 F=20 G=34
!freeze B6
!filter A5:C10

title: Order Completion
subtitle: Generated from the design of record on August 24, 2026. Never edit this workbook - edit the source and rebuild.
subtitle: The five states an order can be in, and how a coil made from two rods is attributed between them. The attribution is by the length each rod contributed, not by counting the parents — a coil made of 500 lb from one rod and 400 lb from another is not two 450 lb halves, and calling it that would misstate both certificates.
blank:
header: Status | When an order is in it | Worked figure
data: Not started | nothing has been run against it | nothing run yet
data: In progress | at least one rod is running against it | 6,000 lb of 14,000 lb run so far
data: Pending operator confirmation | the allocated weight is reached and the operator has not yet marked it complete | 14,000 lb reached, waiting on the operator
data: Complete | every rod is finished and the weight produced is at or above the allocation, inside the weight tolerance | 14,000 lb allocated, 13,820 lb produced - at or above 13,720 lb, the 2 % floor
data: Short | every rod is finished and the weight produced is below the allocation by more than the tolerance | 14,000 lb allocated, 13,520 lb produced - below the 13,720 lb floor
blank:
section: Attributing a coil to its parents by length, not by counting them
header: Coil | Coil weight | Parent | Length contributed | Share | Attributed weight | If parents were merely counted
data: Coil 2 | 900 lb | R00002 | 0 to 42,517 ft | 55.6 % | 500 lb | would be 450 lb - wrong for both
data: Coil 2 | 900 lb | R00001 | 42,517 to 76,531 ft | 44.4 % | 400 lb | would be 450 lb - wrong for both
blank:
subtitle: Two yield figures follow from this and they are not the same number: what was produced against what was actually run, and what was produced against what was issued from stock. They differ by the metal still on a part-used rod, so publishing either one as "the" yield would be wrong.
subtitle: Which of them fulfilment is measured in, and which the certificate states, is question Q53.

---

## Sheet: Full Planned Run

!widths A=10 B=14 C=12 D=34 E=30 F=12 G=62
!freeze B6
!filter A5:G29

title: Full Planned Run - 4,000 lb rods
subtitle: Generated from the design of record on August 24, 2026. Never edit this workbook - edit the source and rebuild.
subtitle: Your own planning spreadsheet's run, reproduced end to end and then checked against the totals it publishes. Spool sizing is constrained by whether the finishing line can cut shippable coils from the result, which is why the final spool is lifted rather than left as a short tail. The order asked for 40,000 lb and the run produces 40,400 lb for exactly that reason.
blank:
header: Spool | Weight | Rods on it | Parts | Coils cut from it | Welded | Notes
data: 1 | 1,800 lb | 1 | R00001A 1,800 lb | 900 lb + 900 lb | no | One rod only.
data: 2 | 1,800 lb | 1 | R00001B 1,800 lb | 900 lb + 900 lb | no | One rod only.
data: 3 | 1,800 lb | 2 | R00001C 400 lb; R00002A 1,400 lb | 900 lb + 900 lb | yes | A weld falls inside this spool, so a coil cut across it has two parents.
data: 4 | 1,800 lb | 1 | R00002B 1,800 lb | 900 lb + 900 lb | no | One rod only.
data: 5 | 1,800 lb | 2 | R00002C 800 lb; R00003A 1,000 lb | 900 lb + 900 lb | yes | A weld falls inside this spool, so a coil cut across it has two parents.
data: 6 | 1,800 lb | 1 | R00003B 1,800 lb | 900 lb + 900 lb | no | One rod only.
data: 7 | 1,800 lb | 2 | R00003C 1,200 lb; R00004A 600 lb | 900 lb + 900 lb | yes | A weld falls inside this spool, so a coil cut across it has two parents.
data: 8 | 1,800 lb | 1 | R00004B 1,800 lb | 900 lb + 900 lb | no | One rod only.
data: 9 | 1,800 lb | 2 | R00004C 1,600 lb; R00005A 200 lb | 900 lb + 900 lb | yes | A weld falls inside this spool, so a coil cut across it has two parents.
data: 10 | 1,800 lb | 1 | R00005B 1,800 lb | 900 lb + 900 lb | no | One rod only.
data: 11 | 1,800 lb | 1 | R00005C 1,800 lb | 900 lb + 900 lb | no | One rod only.
data: 12 | 1,800 lb | 2 | R00005D 200 lb; R00006A 1,600 lb | 900 lb + 900 lb | yes | A weld falls inside this spool, so a coil cut across it has two parents.
data: 13 | 1,800 lb | 1 | R00006B 1,800 lb | 900 lb + 900 lb | no | One rod only.
data: 14 | 1,800 lb | 2 | R00006C 600 lb; R00007A 1,200 lb | 900 lb + 900 lb | yes | A weld falls inside this spool, so a coil cut across it has two parents.
data: 15 | 1,800 lb | 1 | R00007B 1,800 lb | 900 lb + 900 lb | no | One rod only.
data: 16 | 1,800 lb | 2 | R00007C 1,000 lb; R00008A 800 lb | 900 lb + 900 lb | yes | A weld falls inside this spool, so a coil cut across it has two parents.
data: 17 | 1,800 lb | 1 | R00008B 1,800 lb | 900 lb + 900 lb | no | One rod only.
data: 18 | 1,800 lb | 2 | R00008C 1,400 lb; R00009A 400 lb | 900 lb + 900 lb | yes | A weld falls inside this spool, so a coil cut across it has two parents.
data: 19 | 1,800 lb | 1 | R00009B 1,800 lb | 900 lb + 900 lb | no | One rod only.
data: 20 | 1,800 lb | 1 | R00009C 1,800 lb | 900 lb + 900 lb | no | One rod only.
data: 21 | 1,800 lb | 1 | R00010A 1,800 lb | 900 lb + 900 lb | no | One rod only.
data: 22 | 1,800 lb | 1 | R00010B 1,800 lb | 900 lb + 900 lb | no | One rod only.
data: 23 | 800 lb | 2 | R00010C 400 lb; R00011A 400 lb | 800 lb | yes | A weld falls inside this spool, so a coil cut across it has two parents.
data: Total | 40,400 lb | 11 | 32 parts | 45 coils | 9 welded | 23 spools from 11 rods. 44,000 lb issued, 40,400 lb produced, 91.82 % of the metal issued.
blank:
subtitle: The order asked for 40,000 lb and the run produces 40,400 lb. That is the final spool being lifted to 800 lb rather than left as a tail too small to cut into a shippable coil - working as intended, not overproduction.
subtitle: Rod weight here is 4,000 lb (planner basis). The other sheet runs the same order at the other weight, and the rules hold either way.

---

## Sheet: Heavier Rod Run

!widths A=10 B=14 C=12 D=34 E=30 F=12 G=62
!freeze B6
!filter A5:G29

title: Heavier Rod Run - 8,760 lb rods
subtitle: Generated from the design of record on August 24, 2026. Never edit this workbook - edit the source and rebuild.
subtitle: Your own planning spreadsheet's run, reproduced end to end and then checked against the totals it publishes. Spool sizing is constrained by whether the finishing line can cut shippable coils from the result, which is why the final spool is lifted rather than left as a short tail. The order asked for 40,000 lb and the run produces 40,400 lb for exactly that reason.
blank:
header: Spool | Weight | Rods on it | Parts | Coils cut from it | Welded | Notes
data: 1 | 1,800 lb | 1 | R00001A 1,800 lb | 900 lb + 900 lb | no | One rod only.
data: 2 | 1,800 lb | 1 | R00001B 1,800 lb | 900 lb + 900 lb | no | One rod only.
data: 3 | 1,800 lb | 1 | R00001C 1,800 lb | 900 lb + 900 lb | no | One rod only.
data: 4 | 1,800 lb | 1 | R00001D 1,800 lb | 900 lb + 900 lb | no | One rod only.
data: 5 | 1,800 lb | 2 | R00001E 1,560 lb; R00002A 240 lb | 900 lb + 900 lb | yes | A weld falls inside this spool, so a coil cut across it has two parents.
data: 6 | 1,800 lb | 1 | R00002B 1,800 lb | 900 lb + 900 lb | no | One rod only.
data: 7 | 1,800 lb | 1 | R00002C 1,800 lb | 900 lb + 900 lb | no | One rod only.
data: 8 | 1,800 lb | 1 | R00002D 1,800 lb | 900 lb + 900 lb | no | One rod only.
data: 9 | 1,800 lb | 1 | R00002E 1,800 lb | 900 lb + 900 lb | no | One rod only.
data: 10 | 1,800 lb | 2 | R00002F 1,320 lb; R00003A 480 lb | 900 lb + 900 lb | yes | A weld falls inside this spool, so a coil cut across it has two parents.
data: 11 | 1,800 lb | 1 | R00003B 1,800 lb | 900 lb + 900 lb | no | One rod only.
data: 12 | 1,800 lb | 1 | R00003C 1,800 lb | 900 lb + 900 lb | no | One rod only.
data: 13 | 1,800 lb | 1 | R00003D 1,800 lb | 900 lb + 900 lb | no | One rod only.
data: 14 | 1,800 lb | 1 | R00003E 1,800 lb | 900 lb + 900 lb | no | One rod only.
data: 15 | 1,800 lb | 2 | R00003F 1,080 lb; R00004A 720 lb | 900 lb + 900 lb | yes | A weld falls inside this spool, so a coil cut across it has two parents.
data: 16 | 1,800 lb | 1 | R00004B 1,800 lb | 900 lb + 900 lb | no | One rod only.
data: 17 | 1,800 lb | 1 | R00004C 1,800 lb | 900 lb + 900 lb | no | One rod only.
data: 18 | 1,800 lb | 1 | R00004D 1,800 lb | 900 lb + 900 lb | no | One rod only.
data: 19 | 1,800 lb | 1 | R00004E 1,800 lb | 900 lb + 900 lb | no | One rod only.
data: 20 | 1,800 lb | 2 | R00004F 840 lb; R00005A 960 lb | 900 lb + 900 lb | yes | A weld falls inside this spool, so a coil cut across it has two parents.
data: 21 | 1,800 lb | 1 | R00005B 1,800 lb | 900 lb + 900 lb | no | One rod only.
data: 22 | 1,800 lb | 1 | R00005C 1,800 lb | 900 lb + 900 lb | no | One rod only.
data: 23 | 800 lb | 1 | R00005D 800 lb | 800 lb | no | One rod only.
data: Total | 40,400 lb | 5 | 27 parts | 45 coils | 4 welded | 23 spools from 5 rods. 43,800 lb issued, 40,400 lb produced, 92.24 % of the metal issued.
blank:
subtitle: The order asked for 40,000 lb and the run produces 40,400 lb. That is the final spool being lifted to 800 lb rather than left as a tail too small to cut into a shippable coil - working as intended, not overproduction.
subtitle: Rod weight here is 8,760 lb (seeded basis). The other sheet runs the same order at the other weight, and the rules hold either way.

---

## Sheet: Orders Across the Run

!widths A=12 B=10 C=14 D=12 E=46 F=14 G=26 H=18 I=62
!freeze D6
!filter A5:I19

title: Orders Across the Run
subtitle: Generated from the design of record on August 24, 2026. Never edit this workbook - edit the source and rebuild.
subtitle: Three orders laid across that same run, so the rules are visible at production volume rather than on a two-rod example. Two rods here carry a boundary between neighbouring orders. Note that a boundary falling exactly where one rod ends and the next begins shares no rod at all — that case is perfectly legal, which is why a shared first rod is optional rather than expected.
blank:
header: Order | Release | Allocated | Rod | Role | From this rod | Rod-local range | Permitted sequences | Notes
data: '100421 | A | 18,000 lb | R00001 | wholly inside this order, so it may run in any position | 4,000 lb | 0 to 4,000 lb | '24 | Wholly inside this order.
data:  |  |  | R00002 | wholly inside this order, so it may run in any position | 4,000 lb | 0 to 4,000 lb |  | Wholly inside this order.
data:  |  |  | R00003 | wholly inside this order, so it may run in any position | 4,000 lb | 0 to 4,000 lb |  | Wholly inside this order.
data:  |  |  | R00004 | wholly inside this order, so it may run in any position | 4,000 lb | 0 to 4,000 lb |  | Wholly inside this order.
data:  |  |  | R00005 | shared with the next order, so it must run last | 2,000 lb | 0 to 2,000 lb |  | This rod carries the boundary, so it is checked in once and stays mounted across it.
data: '100500 | A | 13,900 lb | R00005 | shared with the previous order, so it must run first | 2,000 lb | 2,000 to 4,000 lb | '2 | This rod carries the boundary, so it is checked in once and stays mounted across it.
data:  |  |  | R00006 | wholly inside this order, so it may run in any position | 4,000 lb | 0 to 4,000 lb |  | Wholly inside this order.
data:  |  |  | R00007 | wholly inside this order, so it may run in any position | 4,000 lb | 0 to 4,000 lb |  | Wholly inside this order.
data:  |  |  | R00008 | shared with the next order, so it must run last | 3,900 lb | 0 to 3,900 lb |  | This rod carries the boundary, so it is checked in once and stays mounted across it.
data: '100700 | A | 8,500 lb | R00008 | shared with the previous order, so it must run first | 100 lb | 3,900 to 4,000 lb | '6 | This rod carries the boundary, so it is checked in once and stays mounted across it.
data:  |  |  | R00009 | wholly inside this order, so it may run in any position | 4,000 lb | 0 to 4,000 lb |  | Wholly inside this order.
data:  |  |  | R00010 | wholly inside this order, so it may run in any position | 4,000 lb | 0 to 4,000 lb |  | Wholly inside this order.
data:  |  |  | R00011 | wholly inside this order, so it may run in any position | 400 lb | 0 to 400 lb |  | Wholly inside this order.
data: Total |  | 40,400 lb |  |  |  |  |  | The three orders together account for the whole run.
subtitle: Two rods here carry a boundary and are shared between neighbouring orders. A boundary that happens to fall exactly where one rod ends and the next begins shares no rod at all - that case is legal and needs no handoff, which is why the incoming shared rod is optional rather than required.

---

## Sheet: What We Need Confirmed

!widths A=12 B=12 C=70 D=62 E=68 F=40
!freeze C6
!filter A5:F14

title: What We Need Confirmed
subtitle: Generated from the design of record on August 24, 2026. Never edit this workbook - edit the source and rebuild.
subtitle: The questions we could not answer from what we have. Each carries what we would do if we had to decide today, so a simple confirmation is enough where you agree. Q48 is the one we most need: it decides whether a rod can ever stay mounted across an order boundary. ---
blank:
header: Question | Priority | What we need to know | What it affects | What we suggest | Your answer
data: Q48 | Critical | Can planning put two orders needing different mill settings — a different gauge, width or edge — on the same rod? | Whether a rod can stay mounted across an order boundary at all. The settings are sent to the machine once, at check-in, so a boundary between two orders needing different settings cannot be crossed while the rod stays mounted. | Treat it as a refusal to cross while mounted rather than a refusal of the order: the operator checks the rod out and back in so the settings can be re-sent. We already know the two orders share an alloy, but alloy is not gauge, width or edge.
data: Q49 | High | Where a rod is shared between two orders but no weld is involved, does the shared rod still have to be last in the outgoing order? | Whether the sequence rule is universal or only applies where a weld is being carried across. | Keep it in both cases. One rule is easier to work to than two, and we have no evidence that the no-weld case behaves differently.
data: Q50 | High | How much production past an order's allocated weight is acceptable before someone is told, and who is told? | When the operator is warned and when a supervisor is involved. We are confident the line should never stop for it. | A configurable warning point for the operator and a higher one that notifies a supervisor, with neither stopping the line. We need the two figures from you.
data: Q51 | Medium | If the operator confirms an order complete before its allocated weight is reached, what happens to the pounds that were allocated but not run? | Whether the order shows short, or the remainder moves to the next order, or it returns to stock. | Leave the order short and show it, rather than quietly moving the weight somewhere else. A visible shortfall can be acted on; a silent reallocation cannot.
data: Q52 | High | When a shared rod runs out before the outgoing order has had its allocated weight, may an unplanned rod be brought in to top it up, or does the order stay short? | Whether the floor can recover from a short rod on its own or has to wait for planning. | Allow it behind a supervisor authorisation, recorded as a substitution.
data: Q53 | High | Is an order counted as fulfilled on the pounds consumed at the drawing line or the pounds produced as finished coils — and which of the two does the welding wire certificate state? | When an order can be called complete, and what the certificate says. | Produced pounds for both, since that is what ships. We would also publish the two yield figures separately rather than combining them, because metal run and metal issued are not the same and either alone would mislead.
data: Q54 | High | When the operator confirms an order complete, does the spool being wound at that moment also finish, or may one spool carry material from two orders? | Whether the finishing line can be told where inside a spool one order ends and the next begins. It has to cut there and today cannot work it out. | Let the spool carry on and record where the boundary falls inside it. Ending the spool early would waste part of a carrier and there is a limited number of them.
data: Q55 | Low | Should the reusable spool carriers be numbered differently from the material wound on them? | Only how likely someone is to read one for the other on a screen or a label. Nothing can be confused inside the system. | If the carriers have not been stencilled yet, give them a different prefix. If they have, leave them — the exposure is small.
data: Q59 | Medium | Other parts of the plant mint coil identities from the same pool of letters. Could one of them be handed an identity that a flat wire spool part already holds? | Only the traceability record, and only if it happened while a rod was mid-way through being drawn onto spools. Nothing in the plant would fail. | Accept it and watch for it. Preventing it would mean writing flat wire's spool parts into the shared plant records, which is a much larger change than the risk warrants, and a clash would be visible at the point it was used.

---
