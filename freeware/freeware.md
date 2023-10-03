---
title: "Freeware"
permalink: /freeware/
---

Balacoon provides some free-to-use software for speech synthesis.
You can try out our **balacoon_tts** [interactive demo](https://huggingface.co/spaces/balacoon/tts)
on HuggingFace to get the idea. We distribute:
 - Python packages: freely available pre-compiled wheels for Linux and RaspberryPi to plug into your applications. Other platforms still need to be supported. Let us know what should be a priority.
 - Docker images: Linux-based self-hosted TTS service on the NVIDIA GPU that can replace costly cloud providers and serve hundreds of parallel requests.

 Couple of features, why you might want to use Balacoon instead of any other open-source solution
 - Fastest synthesis on CPU with specialized **light** models. It can generate speech on a RaspberryPi in real time!
 - Streaming synthesis with a constant latency. You can start playing back the generated speech almost immediately after the request while the rest is being generated.
 - Custom text normalization module (conversion of text from written form into a spoken form) that covers much more cases than opensource solutions, which typically leave this problem up to a user.
 - Service solution that efficiently utilizes a GPU to serve generated speech to many users.

Check the available tools on the left. You can start with [TTS](tts/package.md).
