---
title: "Text processing in TTS"
permalink: /freeware/frontend
toc: true
---

Lately, there has been a trend of building end-to-end
speech synthesis models, i.e., neural networks that
generate audio directly from characters.
This approach, however, has severe limitations:

- data for text normalization (expanding written
  form into a spoken form) is sparse. For edge cases,
  it's easier to write rules than collect enough training
  data.
- pronunciation generation requires human-in-the-loop
  kind of supervision. It should be easy to fix pronunciation
  issues without re-training the speech production system.
- complexity of written systems varies significantly between languages.

A more conventional approach is to feed speech production models
with phonemes - sounds to be uttered.
And this is the work for a **Frontend** - to produce phonemes
given a text. **balacoon_frontend** does it for you,
so you can focus on developing the speech production module.

## Installing package and getting resources

Similar to **balacoon_tts**, you should install a python package and
download the addon from [frontend resources](https://huggingface.co/balacoon/frontend):

```bash
pip install -i https://pypi.fury.io/balacoon/ balacoon-frontend
wget https://huggingface.co/balacoon/frontend/resolve/main/en_us_frontend.addon
```

## Processing text

We speculate that it's more convenient to store all the information
about utterance in a serializable data structure, which maintains
relationships between tokens, words, and phonemes.

```python
from balacoon_frontend import Frontend, LinguisticUtterance
frontend = Frontend("path/to/en_us_frontend.addon")
# now create an utterance based on the text you want to analyze
utterance = LinguisticUtterance("As of 19/08/2021, 0.5kg of rice costs 1.34$")
# analyze the text and add information to the utterance
frontend.process(utterance)
```

You can get much useful information from the utterance now.
Some typical usage is listed below.


### Getting spoken form of the text

The example above contains a date, measure, and money quantity shortened in a written form.
To get a spoken form:

```python
print(utterance.normalized_text())
```

### Traversing the utterance

The utterance is a data structure composed of tokens, words, pronunciations, and phonemes.
You can iterate through those, accessing different fields.

```python
# utterance consists of tokens
for token in utterance.get_tokens():
    # demonstrating different fields of token abstraction
    print("{} is located at [{}:{}] in the original text, "
          "has {} as punctuation mark after it".format(
      token.name(), token.start_index(),
      token.end_index(), token.right_punct()
    ))
    # tokens are normalized into words
    for word in token.get_words():
        print("{} is word in this token".format(word.name()))
        num = len(word.get_pronunciations())
        print("It has {} pronunciation variants".format(num))
        # pronunciation is a list of phonemes.
        # each word can have multiple possible pronuncations.
        # one can select suitable pronunciation based on
        # audio (if available) or semantics.
        # by default, first pronunciation from list returned
        pronunciation = word.get_pronunciation()
        pron_str = pronunciation.to_string()
        print("Pronunciation is: {}".format(pron_str))
        # iterate over phonemes in pronunciation.
        for phoneme in pronunciation.get_phonemes():
            print("{} is a phoneme with id {}".format(
              phoneme.name(), phoneme.id()))
```

### Encoded pronunciations

For training/inference of speech production models, one 
needs encoded phonemes, i.e., phonemes mapped to integers.
**Frontend** has a predefined mapping, where each phoneme
is associated with an integer. There is an access method that allows
getting encoded sequences directly:

```python
phonemes = utterance.encode()
stresss = utterance.encode_stress()
```

### Store/Load the utterance

For the training of speech production models, one should preprocess all the training utterances and store them on the disk.
**LinguisticUtterance** supports serialization for this purpose.

```python
utterance.save("utterance1.pb")
# later on you can load it and do same operations as above
restored = LinguisticUtterance.load("utterance1.pb")
```

## Fallback to eSpeak

In the event that the Balacoon Frontend does not support a particular locale,
there is a possibility to use eSpeak as a secondary option.
eSpeak has built-in support for a large number of locales and can serve as a viable alternative.

To use eSpeak, download the addon:

```bash
wget https://huggingface.co/balacoon/frontend/resolve/main/espeak_frontend.addon
```

And provide the path during initialization:

```python
frontend = Frontend("path/to/espeak_frontend.addon", "en_us", "espeak")
```

The rest of the usage is the same as the default Balacoon Frontend.
However, eSpeak can only be used for pronunciation extraction.
Tokenization and normalization are not available through eSpeak and will be mocked for compatibility purposes.

eSpeak phonemes are mapped to the unified Balacoon phoneme set.
Not all locales have a mapping yet, you can check
[our eSpeak fork](https://github.com/balacoon/espeak-ng#creating-espeak-addon-for-balacoon-frontend) for more information.