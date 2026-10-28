
# Agentic Statistical Programming with Local Models: A Demo

## Local models motivation

- No per-token billing, no running meter. free to experiment, no subscription, no lock-in
- No intellectual property leakage 
- No code leakage, no data leakage, no spying on activity
- Nobody else gets your data or code (cf recent controversy on math paper result)
- Supports old-school autonomous and off-line computing (laptop without wifi, remote area without broadband, ...)
- Mix and match: do first tasks with (simpler, cheaper) local model, refine with frontier model
- More control: 
  - your machine, your upgrades, your versions 
  - whereas cloud services 'can disappear / change'
- Interface fully compatible with different hosting (e.g. I can also point to campus resource)

## Requirements

- Bigger is of course better---but consumer GPUs sufficient
- Our demo here uses a reasonably recent moderately decent workstation: 16gb vram

## Open Model Choice

- Multiple runners, landscape changes frequently and rapidly 
- Here we use ollama, have also deployed llama.cpp 

## Ollama

- Available for all relevant OSs, can be launched in 'serve' mode
- We use Linux where running as background service is common
- In addition, an apt repo is being curated by lingfish making updates automatic
- Ollama provides many models directly (i.e. `ollama pull model_name:type`)
- Ollama gets paid if one uses them a in-the-cloud inference service (not out focus)
- Local parameterisation
  - ollama run network port open to local network
  - possible to connect from other machine (i.e. laptop connect to server)
  - set certain parameter (context windows etc)
  
## Clients

- OpenCode is nice, can be used with bubblewrap, difference between v1 and v2 ?
- pi is nice, have used with container
- RStudio ('chat' works, code suggestions require paid service)
- Positron ('chat' works, code suggestions require paid service)
- Emacs modes
- VS Code modes / plugins (not covered)

## Importance of AGENTS.md

- Context is lost, so reset / preset with explicit instructions

## Planned Time and Date

- The tentative date is Wednesday, November 18, 2026 at 12:00h ("noon")
Chicago/CST time corresponding to 10:00h San Franciso/PST, 13:00h New
York/EST, 18:00h London/GMT, 19:00h Berlin/CET).
- Delivery is planned to be via YouTube! using [OBS][obs].  A recording may
be made available via [my channel][channel].

[obs]: https://obsproject.com/
[channel]: https://www.youtube.com/@DirkEddelbuettel/videos


