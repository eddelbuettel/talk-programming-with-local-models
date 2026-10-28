
# Agentic Statistical Programming with Local Models: A Reproducible Demo

## Local models motivation

- No per-token billing, no running meter. free to experiment
- No intellectual property leakage 
- No code leakage
- Nobody else gets your data or code (cf recent controversy on math paper result)
- Old-school autonomous computing (laptop without wifi ...)
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


