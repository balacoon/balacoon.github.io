---
title: "Vocoding in TTS"
permalink: /use/backend/vocoding
---

Neural Text-to-Speech can be characterised as
production of speech waveform with neural network(s).
Most commonly this done with two-stage approach,
where `acoustic` model produces intermediate acoustic
representation (for ex. mel-spectrogram) given text,
and `vocoder` generates speech waveform.

To gain maximum possible audio quality, those two components
should depend on one another, i.e.

- should be trained jointly
- vocoder should be trained/fine-tuned on predicted
  acoustic parameters

But for research purposes it's sometimes okay to take
off-the-shelf vocoder and avoid costly retraining.
There are two prominent works in this direction:
[Univnet](https://arxiv.org/abs/2106.07889) and
[BigVGAN](https://arxiv.org/abs/2206.04658) that
attempt to deliver universal model, applicable to any
speech.

`Vocoder` from `balacoon_backend` provides easy to use
encapsulation that can be plugged into your acoustic model research.
Essentially you need just two methods:

- `analysis` - extracting acoustic features that can
  be further used for acoustic model training
- `synthesis` - generating audio, given predicted acoustic
  features

## Installing and getting resources

Similar to `balacoon_tts`, you should install a python package and
download vocoder addon from [backend resources](https://huggingface.co/balacoon/backend):

```bash
pip install -i https://pypi.fury.io/balacoon/ balacoon-backend
wget https://huggingface.co/balacoon/frontend/blob/main/univnet_vocoder.addon
```

## Running analysis-synthesis

Extracting acoustic features and synthesizing audio had never being easier:

```python
from balacoon_backend import Vocoder
vocoder = Vocoder("path/to/univnet_vocoder.addon")

# read some audio file you want to analyze
import soundfile as sf
in_samples, sample_rate = sf.read("some.wav")
# the only one supported for now
assert sample_rate == 24000
melspec = vocoder.analyze(in_samples)

# once you train your own acoustic model to predict melspec
# you can feed it to vocoder to predict audio
out_samples = vocoder.synthesize(melspec)
```
