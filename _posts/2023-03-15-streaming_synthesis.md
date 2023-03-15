---
title: "Balacoon TTS version 0.1.0"
last_modified_at: 2023-03-15T16:20:02-05:00
categories:
  - Blog
tags:
  - text-to-speech
---

We're excited to announce the release of Balacoon TTS 0.1.0,
the latest version of our text-to-speech package.
This new version includes two major updates that will significantly enhance its functionality.
1) We switch to the use of ONNX as the neural backend. It allowed us to drop the torch libraries and reduce the package size by a factor of 3, making it much more lightweight and easy to use. Using ONNX also provided a 1.4x speedup in synthesis speed
2) We add streaming synthesis API for low latency applications. While streaming synthesis is generally 2x slower due to redundant computations, it allows for audio to be sent back to the user immediately after the first chunk is produced, making it ideal for real-time applications. You can find the usage example in the [docs](https://balacoon.com/use/tts/package#running-streaming-synthesis).

One caveat is that the update to support streaming synthesis required us to retrain the [TTS models](https://huggingface.co/balacoon/tts).
So you will need to update both package and addons. 