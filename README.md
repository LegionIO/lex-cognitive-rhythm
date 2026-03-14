# lex-cognitive-rhythm

A LegionIO cognitive architecture extension that models biological cognitive rhythms. Sinusoidal oscillators track six cognitive dimensions over ultradian (90-minute) or circadian (24-hour) cycles, enabling the agent to identify peak and trough periods for different types of work.

## What It Does

Manages a set of **rhythms**, each tied to one of six cognitive dimensions:

- `alertness`, `creativity`, `focus`, `analytical`, `social`, `emotional`

Each rhythm oscillates sinusoidally. The engine answers questions like: "Is this a good time for creative work?" or "When will my focus dimension next peak?"

## Usage

```ruby
require 'lex-cognitive-rhythm'

client = Legion::Extensions::CognitiveRhythm::Client.new

# Register an ultradian focus rhythm
client.add_cognitive_rhythm(name: 'focus_ultradian', rhythm_type: :ultradian, dimension: :focus, amplitude: 0.8)
# => { success: true, rhythm_id: :rhythm_1, name: "focus_ultradian", dimension: :focus }

# Register a circadian alertness rhythm with a phase offset
client.add_cognitive_rhythm(name: 'alertness_daily', rhythm_type: :circadian, dimension: :alertness, amplitude: 0.9, phase_offset: 28_800)
# => { success: true, rhythm_id: :rhythm_2, name: "alertness_daily", dimension: :alertness }

# Register a custom-period creativity rhythm
client.add_cognitive_rhythm(name: 'creativity_cycle', rhythm_type: :custom, dimension: :creativity, period: 7200, amplitude: 0.7)
# => { success: true, rhythm_id: :rhythm_3, name: "creativity_cycle", dimension: :creativity }

# Check current value for a dimension
client.dimension_rhythm_value(dimension: :focus)
# => { success: true, dimension: :focus, value: 0.63 }

# Is now a good time for analytical work?
client.optimal_for_task(dimension: :analytical)
# => { success: true, dimension: :analytical, optimal: false }

# When will focus next peak?
client.best_time_for_task(dimension: :focus, within: 7200)
# => { success: true, dimension: :focus, best_time: "2026-03-14T15:30:00Z", within_seconds: 7200 }

# Full cognitive profile across all 6 dimensions
client.cognitive_rhythm_profile
# => { success: true, profile: { alertness: { value: 0.72, phase_label: :rising, amplitude_label: :high, optimal: false }, ... } }

# Which dimensions are currently at peak?
client.peak_cognitive_dimensions
# => { success: true, dimensions: [:creativity], count: 1 }

# Which dimensions are at trough?
client.trough_cognitive_dimensions
# => { success: true, dimensions: [:social, :emotional], count: 2 }

# Current state — all 6 dimensions at a glance
client.current_rhythm_state
# => { success: true, state: { alertness: 0.72, creativity: 0.91, focus: 0.63, analytical: 0.44, social: 0.21, emotional: 0.38 } }
```

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

MIT
