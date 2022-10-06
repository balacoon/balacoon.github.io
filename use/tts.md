---
title: "TTS"
permalink: /use/tts
toc: true
---

Balacoon TTS wraps text processing, extraction of relevant
features and speech generation. Package hides from the user
the implementation details: model architecture, neural inference
engine, etc. Some of those might change over time, but we will
try to maintain the same interface. For now, we don't ship
streaming synthesis, which would drastically reduce latency.
Instead, you have to wait for the whole utterance to be synthesized,
before accessing audio.

## Installing **balacoon_tts**

It's a simple python package to be installed via pip.

```bash
pip install -i https://pypi.fury.io/balacoon/ balacoon-tts
```

Data is returned as **numpy** arrays, so it should be available
as well. No strict requirements for the version, however.

## Getting model

**balacoon_tts** is just an engine, which requires models and resources
to initialize different components. Those are neatly packed into
addons, so all you need to do is to download one file.
Those are hosted in [HuggingFace Hub](https://huggingface.co/balacoon/tts).
Download it directly from the website:

```bash
# chose which model to download based on requirements/demos
wget https://huggingface.co/balacoon/tts/blob/main/en_us_cmuarctic_pt_univenet.addon
```

Or download it programmatically using **huggingface_hub**:

```python
from huggingface_hub import hf_hub_download
addon_path = hf_hub_download(repo_id="balacoon/tts", filename="en_us_cmuarctic_pt_univenet.addon")
```

## Running synthesis

That's it, you are all set to run synthesis.

```python
from balacoon_tts import TTS
# adjust the path to addon based on previous step
tts = TTS("path/to/en_us_cmuarctic_pt_univenet.addon")
# for multi-speaker models, this will return list of speakers
# that model supports. for single speaker - just an empty list
supported_speakers = tts.get_speakers()
speaker = supported_speakers[-1] if supported_speakers else ""
# finally run synthesis
samples = tts.synthesize("hello world", speaker)
# up to you what to do with the synthesized samples (np.int16 array)
# in this example we will save it to a file
import soundfile
soundfile.write("example.wav", samples, 24000)
```