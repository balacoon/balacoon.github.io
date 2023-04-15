---
title: "Balacoon TTS Package"
permalink: /use/tts/package
toc: true
---

Balacoon TTS wraps text analysis and speech generation into a single Python package. 
Below is a step-by-step tutorial on how to generate speech.

## Installing **balacoon_tts**

Install the package via pip.

```bash
pip install -i https://pypi.fury.io/balacoon/ balacoon-tts
```

You will also need **numpy**.

## Getting model

**balacoon_tts** is just an engine that requires models and resources
to initialize different components. We pack them into
addons, so all you need to do is to download one file.
Addons are available in [HuggingFace Hub](https://huggingface.co/balacoon/tts).
Download it directly from the website:

```bash
# chose which model to download based on requirements/demos
wget https://huggingface.co/balacoon/tts/resolve/main/en_us_cmuartic_jets_cpu.addon
```

Or download it programmatically using **huggingface_hub**:

```python
from huggingface_hub import hf_hub_download
addon_path = hf_hub_download(repo_id="balacoon/tts", filename="en_us_cmuartic_jets_cpu.addon")
```

*balacoon_tts* requires addons compiled for CPU, so pick those with *_cpu* suffix.

## Running synthesis

That's it. You are all set to run synthesis.

```python
import wave
from balacoon_tts import TTS
# adjust the path to the addon based on the previous step
tts = TTS("path/to/en_us_cmuartic_jets_cpu.addon")
# this will return a list of speakers that model supports.
supported_speakers = tts.get_speakers()
speaker = supported_speakers[-1]
# finally run synthesis
samples = tts.synthesize("hello world", speaker)
# up to you what to do with the synthesized samples (np.int16 array)
# in this example we will save them to a file
with wave.open("example.wav", "w") as fp:
    fp.setparams((1, 2, tts.get_sampling_rate(), len(samples), "NONE", "NONE"))
    fp.writeframes(samples)
```

## Running streaming synthesis

In some applications, low latency is crucial,
and waiting for the whole sentence to be synthesized before sending it to the user is unacceptable.
Balacoon TTS supports streaming synthesis, which allows generating the audio chunks iteratively.
So the user can listen to the previous audio fragment while the next one is being synthesized.
It comes with a cost of approximately 2x slower synthesis due to redundant computations
but allows the creation of responsive applications.

```python
from balacoon_tts import TTS, SpeechUtterance
# create tts as before
tts = TTS("path/to/en_us_cmuartic_jets_cpu.addon")
# select speaker for synthesis
supported_speakers = tts.get_speakers()
speaker = supported_speakers[-1]
# create an utterance, which will hold the syntheis state
utterance = SpeechUtterance("hello world")
# run synthesis in a loop
while True:
    samples = tts.synthesize_chunk(utterance, speaker)
    if len(samples) == 0:
        # all the samples were already generated
        break
    # send produced samples to the user,
    # for example play them back.
    playback(samples)
```
