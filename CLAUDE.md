# lex-cognitive-rhythm

**Level 3 Leaf Documentation**
- **Parent**: `/Users/miverso2/rubymine/legion/extensions-agentic/CLAUDE.md`
- **Gem**: `lex-cognitive-rhythm`
- **Version**: 0.1.0
- **Namespace**: `Legion::Extensions::CognitiveRhythm`

## Purpose

Models biological cognitive rhythms as sinusoidal oscillators. Each rhythm tracks a specific cognitive dimension (alertness, creativity, focus, analytical, social, emotional) and oscillates with a period (ultradian ~90min, circadian ~24hr, or custom). The engine computes real-time values, phase labels, and optimal timing windows — enabling the agent to adapt its behavior based on cognitive readiness in each dimension.

## Gem Info

- **Gemspec**: `lex-cognitive-rhythm.gemspec`
- **Require**: `lex-cognitive-rhythm`
- **Ruby**: >= 3.4
- **License**: MIT
- **Homepage**: https://github.com/LegionIO/lex-cognitive-rhythm

## File Structure

```
lib/legion/extensions/cognitive_rhythm/
  version.rb
  helpers/
    constants.rb       # Period constants, dimension list, phase/amplitude label tables
    rhythm.rb          # Rhythm class — single sinusoidal oscillator
    rhythm_engine.rb   # RhythmEngine — manages all rhythms, aggregate queries
  runners/
    cognitive_rhythm.rb  # Runner module — public API
  client.rb
```

## Key Constants

| Constant | Value | Meaning |
|---|---|---|
| `ULTRADIAN_PERIOD` | 5400 | 90-minute cycle in seconds |
| `CIRCADIAN_PERIOD` | 86_400 | 24-hour cycle in seconds |
| `MAX_RHYTHMS` | 20 | Hard cap on registered rhythms |
| `MAX_HISTORY` | 200 | Ring buffer size (defined, not currently used) |
| `DEFAULT_PHASE_OFFSET` | 0.0 | Phase offset for new rhythms |

`COGNITIVE_DIMENSIONS`: `[:alertness, :creativity, :focus, :analytical, :social, :emotional]`

Phase labels (by phase fraction 0.0..1.0):
- `0.0..0.25` = `:rising`, `0.25..0.5` = `:peak`, `0.5..0.75` = `:falling`, `0.75..1.0` = `:trough`

Amplitude labels:
- `0.8+` = `:high`, `0.6..0.8` = `:moderate_high`, `0.4..0.6` = `:moderate`, `0.2..0.4` = `:moderate_low`, `<0.2` = `:low`

## Key Classes

### `Helpers::Rhythm`

A single sinusoidal oscillator for one cognitive dimension.

- `value_at(time)` — sinusoidal value: `amplitude * (0.5 + 0.5 * sin(2π * elapsed / period))`; range `[0, amplitude]`
- `current_value` — `value_at(Time.now.utc)`
- `phase_at(time)` — fractional position in current cycle: `(elapsed % period) / period`
- `current_phase` — `phase_at(Time.now.utc)`
- `phase_label` — `:rising`, `:peak`, `:falling`, or `:trough`
- `amplitude_label` — `:high`, `:moderate_high`, `:moderate`, `:moderate_low`, or `:low`
- `peak?` / `trough?` / `rising?` / `falling?` — boolean convenience predicates

IDs are sequential symbols: `:rhythm_1`, `:rhythm_2`, etc.

### `Helpers::RhythmEngine`

Registry and query engine for all cognitive rhythms.

- `add_rhythm(name:, rhythm_type:, dimension:, period:, amplitude:, phase_offset:)` — resolves period from type; returns nil if at `MAX_RHYTHMS` or period is nil for `:custom`
- `remove_rhythm(rhythm_id:)` — deletes by id; returns `{ success:, rhythm_id: }` or `{ success: false, reason: :not_found }`
- `dimension_value(dimension:)` — mean `current_value` across all rhythms for that dimension
- `current_state` — hash of all 6 `COGNITIVE_DIMENSIONS` to their current mean values
- `optimal_for(dimension:)` — true if any rhythm for that dimension is at `:peak` phase
- `best_time_for(dimension:, within: 3600)` — scans next `within` seconds in 60s steps to find time with highest projected value
- `synchronize(rhythm_ids:)` — aligns phase offsets of listed rhythms to match the first rhythm's current phase
- `cognitive_profile` — per-dimension hash with `{ value:, phase_label:, amplitude_label:, optimal: }`
- `peak_dimensions` / `trough_dimensions` — lists which of the 6 dimensions are currently at peak/trough

## Runners

Module: `Legion::Extensions::CognitiveRhythm::Runners::CognitiveRhythm`

| Runner | Key Args | Returns |
|---|---|---|
| `add_cognitive_rhythm` | `name:`, `rhythm_type:`, `dimension:`, `period:` (custom only), `amplitude:`, `phase_offset:` | `{ success:, rhythm_id:, name:, dimension: }` |
| `remove_cognitive_rhythm` | `rhythm_id:` | `{ success:, rhythm_id: }` or `{ success: false, reason: }` |
| `current_rhythm_state` | — | `{ success:, state: }` (all 6 dimensions) |
| `dimension_rhythm_value` | `dimension:` | `{ success:, dimension:, value: }` |
| `optimal_for_task` | `dimension:` | `{ success:, dimension:, optimal: }` |
| `best_time_for_task` | `dimension:`, `within:` | `{ success:, dimension:, best_time:, within_seconds: }` |
| `cognitive_rhythm_profile` | — | `{ success:, profile: }` (per-dimension detail) |
| `peak_cognitive_dimensions` | — | `{ success:, dimensions:, count: }` |
| `trough_cognitive_dimensions` | — | `{ success:, dimensions:, count: }` |
| `cognitive_rhythm_stats` | — | `{ success:, rhythm_count:, rhythms:, current_state: }` |

Note: `engine` is a private memoized method (no `engine:` injection keyword on runners — unlike most other extensions in this category).

## Integration Points

- No actors defined; rhythm values evolve passively with real time — no tick required
- Can feed `lex-tick` phase handlers via `lex-cortex` to gate actions on cognitive readiness
- `best_time_for_task` is useful for scheduling — tells `lex-scheduler` when a given dimension will peak
- `synchronize` allows aligning multiple rhythms (e.g., after a known sleep/wake event)
- All state is in-memory per `RhythmEngine` instance

## Development Notes

- Period for `:ultradian` and `:circadian` types is resolved automatically; `:custom` requires explicit `period:` or `add_rhythm` returns nil
- `synchronize` uses `instance_variable_set` to mutate `@phase_offset` directly on Rhythm objects (bypasses attr_reader)
- `dimension_value` returns `0.0` for dimensions with no registered rhythms
- `best_time_for_task` scans in 60-second increments; resolution is 1 minute, within default 1 hour
- `MAX_HISTORY` is defined but the `@history` array is allocated and never populated in the current implementation
