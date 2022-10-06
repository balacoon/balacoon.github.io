---
title: "Text processing in TTS"
permalink: /use/frontend
toc: true
---

Lately there is a trend of building end-to-end
speech synthesis models, i.e. neural networks that
generate audio directly from letters. This approach
however has severe limitations:

- data for text normalization (expansion of written
  form into spoken form) is sparse. For edge cases
  it's easier to write rules than collect enough training
  data.
- pronunciation generation requires human-in-the-loop
  kind of supervision. It should be easy to fix pronunciation
  issues without re-training speech production system.
- complexity of written systems vary greatly between languages.

More conventional approach is to feed speech production models
with phonemes, i.e. sounds that needs to be synthesized.
And this is the work for a **Frontend** - to produce phonemes
given text. **balacoon_frontend** does it for you,
so you can focus on developing speech production module.

## Installing and getting resources

Similar to **balacoon_tts**, you should install a python package and
download addon from [frontend resources](https://huggingface.co/balacoon/frontend):

```bash
pip install -i https://pypi.fury.io/balacoon/ balacoon-frontend
wget https://huggingface.co/balacoon/frontend/blob/main/en_us_frontend.addon
```

## Processing text

We speculate that it's more convenient to store all the information
about utterance in a serializable data structure, which maintains
relationships between tokens, words and phonemes.

```python
from balacoon_frontend import Frontend, LinguisticUtterance
frontend = Frontend("path/to/en_us_frontend.addon")
# now create an utterance based on text you want to analyze
utterance = LinguisticUtterance("As of 19/08/2021, 0.5kg of rice costs 1.34$")
# analyze the text and add information to the utterance
frontend.process(utterance)
```

A lot of useful staff can be extracted from the utterance now.
Some typical usage is listed below.


### Getting spoken form of the text

Example above contains date, measure, money quantity which are shortened
in a written form. To get a spoken form:

```python
print(utterance.normalized_text())
```

### Traversing the utterance

Utterance is a data structure, composed of tokens, words, pronunciations and phonemes.
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

For training/inference of speech production models, one simply
needs encoded phonemes, i.e. phonemes mapped to integers.
**Frontend** has a predefined mapping per locale, where each phoneme
is associated with an integer. There is an access method that allows
to get encoded sequence directly:

```python
tts_input = utterance.get_encoded_phonemes()
```

### Store/Load the utterance

For training of speech production models, one might want to preprocess
all the training utterances and store them on the disk.
**LinguisticUtterance** supports serialization for this purpose.

```python
utterance.save("utterance1.pb")
# later on you can load it and do same operations as above
restored = LinguisticUtterance.load("utterance1.pb")
```

### Tweaking normalization and pronunciation

Most popular frontend nowadays is [phonemizer](https://github.com/bootphon/phonemizer),
which is a wrapper around academic speech synthesis toolkits:
[eSpeak](https://github.com/espeak-ng/espeak-ng) and [Festival](https://github.com/festvox/festival).
It works great as a starting point, but it also has a few drawbacks.
It is not as easy to integrate, techniques used are rather outdated.
But most importantly, it does not encourage continuous improvements to the Frontend.
Text normalization and pronunciation generation, has a long tail of errors.
We share all pronunciation resources and normalization rules,
in hope that frontend can be continuously improved or at least tweaked for
specific purpose. More up-to-date approaches (for instance, FST-based text normalization),
makes it much easier to work with. Check subsections for details. 