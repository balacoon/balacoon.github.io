---
permalink: /demo/
title: "Demo"
toc: true
---

Before actually using Balacoon, you can check how it works.

# Text-to-Speech (TTS)

**balacoon_tts** [interactive demo](https://huggingface.co/spaces/balacoon/tts)
is hosted with amazing **Huggingface spaces**. Poke around and check naturalness
of generated speech. Latency and throughput is not descriptive though.

# Voice Conversion (VC)

As one of proprietary products we offer voice conversion - taking the recording of speech
and changing persona and inflection in it, while maintaining the message spoken.
There are two flavors that voice conversion come in.
*Interactive demo of the technology is provided upon request.*

## Any-to-Many VC

This allows to convert recording with any voice (for ex. yours), that was not seeing during
the training of the system to an audio by a speaker from pre-defined list.
Since target speaker is seeing during training, it allows to learn not only timbre
of speech but also prosodical characteristics.

Teaser:
{% include embed-audio.html src="/assets/demo_audio/vc/trump.mp3" name="Source audio from Donald Trump:" %}
{% include embed-audio.html src="/assets/demo_audio/vc/trump2obama_a2m.mp3" name="Same audio, converted to Barack Obama:" %}

## Any-to-Any VC

As in Any-to-Many, the voice identity in the input recording can be any.
The voice identity in the output audio is extracted from provided template recording.
I.e. you provide an audio you want to convert, recording of the person you want to mimic,
and you get the result where message and infliction are derived from the first audio,
but voice identity is borrowed from the second.

Teaser:
{% include embed-audio.html src="/assets/demo_audio/vc/meryl_streep.mp3" name="Source audio from Meryl Streep:" %}
{% include embed-audio.html src="/assets/demo_audio/vc/kratos_short.mp3" name="God of War, to borrow voice from:" %}
{% include embed-audio.html src="/assets/demo_audio/vc/streep2kratos_a2a.mp3" name="Meryl speaking as God of War:" %}
