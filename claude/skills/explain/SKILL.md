---
name: explain
description: Explain anything (a codebase, a diff, a model's output, a paper, a concept, a result) in the format that is fastest to understand, climbing a ladder from controlled-English prose to a diagram, an interactive HTML page and a narrated explainer video. Use in any project whenever the user asks to explain, understand, walk through, visualise or make sense of something, and whenever a long answer would be easier to grasp as a picture or a page.
---

# Explain

As agents do more of the work, the user's job moves up to oversight and understanding. Explanations are now cheap to build, so build the one that is fastest to understand, then throw it away. Pick the highest rung that fits the request and the time; each rung beats the one below it.

## 1. Writing: ASD-STE100, softened

Write explanations in Simplified Technical English, about 80% of the way to the ASD-STE100 spec. The strict spec reads stiff; the softened version reads clean.

- **One idea per sentence.** Procedure sentences of 20 words or fewer, descriptive ones of 25 or fewer.
- **Active voice, present tense**, subject first: "The scheduler gives each rank a chunk."
- **One word, one meaning.** Pick a term, define it once, and never swap in a synonym.
- **Plain, common verbs** (use, show, start, stop), not nominalisations ("perform an initialisation of").
- **Steps as numbered imperatives**, one action each. Put a warning before the step it applies to.
- **Short paragraphs**, six sentences or fewer, each opening with its point.
- **Exact names.** Keep identifiers, numbers and technical names precise; the softening relaxes the dictionary, never the precision.

## 2. Diagrams

If the idea has parts, flow, state or time, draw it before writing about it. Use a Mermaid block in chat or markdown: a flowchart for flow, a sequence diagram for messages between actors, a state diagram for lifecycles. For anything shown to others, draw inline SVG through the **anatomy** skill or **artifact-diagramming**. Label every arrow with what moves along it.

## 3. Web pages

For anything with more than one layer, build a single-file interactive HTML explainer and publish it as an Artifact, through **atelier** and **artifact-design**. Let the reader drive the idea: sliders for parameters, step buttons through an algorithm, hover to reveal values, a toggle between before and after. Put the one-sentence answer at the top, then the interactive figure, then the detail.

## 4. Explainer videos

For a topic worth watching, make a 3Blue1Brown-style video, fully local and free:

1. **Script** the narration in softened STE, scene by scene, 60 to 180 seconds in total.
2. **Animate** with Manim Community in a `uv` project (`uv init explainer`, `uv add manim`): one `Scene` per beat of the script, dark background, one accent colour, objects that transform into each other instead of cutting.
3. **Narrate** with Piper (`uv add piper-tts`, voice `en_US-lessac-medium`) or Kokoro for warmer audio. Use ElevenLabs only if the user supplies a key.
4. **Mux** with ffmpeg, timing each scene to its audio clip, and render at 1080p60.
5. **Watch** a few frames (`ffmpeg -ss <t> -frames:v 1 f.png`) before handing over the MP4 path.

## Choosing

| Request | Rung |
|:--|:--|
| quick question in chat | 1, plus a Mermaid diagram if there is structure |
| how a system or diff works | 2, then 3 if the user will come back to it |
| a concept to learn or teach | 3 |
| "make a video", or a topic to share widely | 4 |

When unsure, answer in softened STE and offer the next rung in one line.
