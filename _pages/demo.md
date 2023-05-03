---
permalink: /demo/
title: "Demo"
toc: true
---

Here you can listen to examples of what Balacoon has to offer.

# Text-to-Speech (TTS)

**balacoon_tts** [interactive demo](https://huggingface.co/spaces/balacoon/tts)
is hosted with amazing **Huggingface spaces**. Poke around and check naturalness
of generated speech.

# Disruptive technologies

Neural Text-to-Speech delivers new levels of naturalness as well as new applications.
For instance, we can alternate different speech factors, such as speaker identity,
expressivity, or recording conditions. In Balacoon, we investigate newly emerged techniques,
exploring their potential. In case of broader interest, we plan to ship them as services.

## Voice Conversion

This technology lets to change **who** is speaking in the audio.
We just need a short example of how the target voice sounds.
Voice Conversion has been known for decades now. But only recently,
it became possible to do it for arbitrary input audio:
for speakers unseen at the training stage of a system.

Example:
{% include embed-audio.html src="/assets/demo_audio/vc/meryl_streep.mp3" name="Source audio from Meryl Streep:" %}
{% include embed-audio.html src="/assets/demo_audio/vc/kratos_short.mp3" name="God of War, to borrow voice from:" %}
{% include embed-audio.html src="/assets/demo_audio/vc/streep2kratos_a2a.mp3" name="Meryl speaking in voice of God of War:" %}

You can try it yourself in our app:
[<img src="../assets/images/google-play-badge.png" alt="voice conversion app" width="200">](https://play.google.com/store/apps/details?id=com.app.vc)
