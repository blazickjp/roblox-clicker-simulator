# Game Changelog

Tracking iterative improvements made during heartbeats.

---

## 2026-01-30 (Initial Build)

### v1.0 - Full Feature Build
- Built complete clicker simulator with pets, zones, achievements, codes, daily rewards
- ~4,000 lines of Luau code
- Rojo project structure

### v1.1 - Socratic Review (Sub-agent)
- **Problem found:** Early game was too slow/grindy
- **Changes:**
  - Starting coins: 0 → 50
  - First 10 clicks give 10x bonus (starter boost)
  - Base coins/click: 1 → 3
  - Basic Egg cost: 500 → 100
  - Auto-Click cost: 200 → 100
  - Codes panel auto-shows for new players
- **Result:** First pet within 2 minutes instead of 5+ minutes

---

## Heartbeat Iterations

### HB-1: Jackpot Event (16:19 PST)
**Task:** New Idea - Add ONE small delightful surprise

**Socratic thinking:** 
- Q: What makes kids tell their friends about a game?
- A: Rare, exciting moments they can brag about
- Q: What's missing from the current click loop?
- A: A "holy crap!" moment that's rare but memorable

**Change:** Added JACKPOT event
- 0.5% chance per click (rare enough to be special)
- 50x coin multiplier (big enough to feel amazing)
- Rainbow flash + 100 particle explosion
- Creates "DID YOU SEE THAT?!" moments

### HB-2: Egg Teasers (16:25 PST)
**Task:** Kid Test - What would confuse a 9-year-old?

**Socratic thinking:**
- Q: Would a kid know what's inside an egg before buying?
- A: No! They just see "Basic Egg 💰100" — boring, no excitement
- Q: What makes kids excited to buy loot boxes/eggs?
- A: Knowing what COULD be inside! The possibility of something rare!

**Change:** Added teaser text to each egg button
- Basic: "🐕🐱 Cute pets!"
- Golden: "🐉 Epic chance!"
- Mythic: "👑 15% LEGENDARY!"

Kids now see the *possibility* before spending coins.

### HB-3: Balance Check (16:30 PST)
**Task:** Are the numbers fun? Test the progression math.

**Analysis:**
- First upgrade: Click 1 (50 coins from welcome + first click)
- First pet: Click 2 (110 coins with starter boost)
- First rebirth: ~30-60 seconds of active play
- Rebirth costs double each time (10K → 20K → 40K → ...)

**Verdict:** ✅ Balance is GOOD
- Early game is fast (instant gratification)
- Exponential rebirth costs create "one more!" loop
- No changes needed

*Future iterations will be logged below*
