---
title: "Balacoon phonemeset"
last_modified_at: 2023-03-16T16:20:02-05:00
categories:
  - Blog
tags:
  - frontend
---

Text-to-speech assumes the implicit or explicit conversion of input text into a sequence of sounds to be pronounced. Defining a set of all possible sounds (or phonemes) for the language can spark quite a debate. Fortunately, neural speech synthesis is quite flexible and can tolerate almost any annotation as long as it is consistent. This post describes how the phoneme set for the Balacoon Frontend is composed.

Ideally, we prefer a single unified phoneme set for all the locales. It would reduce the mess with mapping phonemes to inputs of neural networks. And make multi-lingual TTS easier, as the study shows [[1]](#1).
The standard approach is to use [International Phonetic Alphabet (IPA)](https://en.wikipedia.org/wiki/International_Phonetic_Alphabet) or its ASCII counterpart [X-SAMPA](https://en.wikipedia.org/wiki/X-SAMPA).
Of course, modern computers support Unicode and can deal with IPA, but editing pronunciation dictionaries by hand can be challenging. Other TTS frontends either take this path or maintain a mapping from locale-specific phoneme set to X-SAMPA.

## Basic phoneme set
To define a basic phoneme set, we go to the X-SAMPA wiki page and collect all the phonemes listed there. Some of them belong to exotic locales but let's keep them just in case. Putting together all the pulmonic and non-pulmonic consonants, vowels, affricates, and coarticulated phonemes, we get 107 items. It might be incomplete since pronunciation dictionaries commonly introduce additional locale-specific phonemes, such as merged vowels. For example, for US English, one can typically find:
* "aI" as in "price"
* "aU" as in "flower"
* "eI" as in "shade"
* "OI" as in "choice"
* "oU" as in "boat"

We make the questionable decision to keep those phonemes separate. It's easier to merge phonemes rather than split them, and we would like to keep the phoneme set as narrow as possible. On the negative side, we must decide which of the two merged phonemes should get stress or modification marks, if any.

## Allophones
Basic phonemes can have a great degree of variation in their pronunciation. Modifications of a phoneme are called allophones. Phonemes can be prolongated, have nasalization, palatalization, etc. The number of variations is significant. Moreover, they can overlap. Fortunately, a particular modification can be applied only to a subset of phonemes.
We compose a set of allophones based on [espeak-ng](https://github.com/espeak-ng/espeak-ng/tree/master/phsource) and [Google Cloud Text-to-Speech](https://cloud.google.com/text-to-speech/docs/phonemes).

Both support multiple locales and will allow us to oversee all the possibilities.
* `:` marks prolongation and can be applied to 41 phonemes. 
* `~` marks nasalization and can be stacked with prolongation. It applies to 29 phonemes.
* `'` or `_j` denotes palatalization, which can affect 21 consonants.
* ``` indicates rhotacization, applied to 11 phonemes
* `_d` means dental consonants. It occurs for 9 phonemes.
* `_h` marks aspiration, which appears for 13 phonemes.
* `_<`, `_>`, `_o`, `_"` denotes implosives, ejectives, lowered and centralized vowels. They did not occur in espeak-ng or Google docs, including only those 13 explicitly mentioned on X-SAMPA wiki.

Wiki mentions other modifications too, but since they do not appear in TTS systems, we omit them to keep the size of the phoneme set manageable. Combining collected allophones with the basic phonemes, we get a set of 244 entries.

## Stress and tone
While stress and tone are also modifications of basic phonemes, we treat them differently. Both stress and tone apply to all vowels and their allophones. Adding them as-is would increase the size of the phoneme set immensely. Instead, we maintain stress and tone as separate input stream for speech modeling.

Usually, stress marks apply to syllables.
But since Balacoon Frontend does not perform syllabification, nucleus of a syllable is getting marked:
* `"` marks primary stress
* `%` denotes secondary stress.

Both symbols are added in front of a phoneme. Tones as marked as:
* `_B` for extra-low tone
* `_L` for low tone
* `_F` for falling tone
* `_B_L` for low-rising tone
* `_M` for mid-tone
* `_R_F` for rising-falling tone
* `_R` for rising tone
* `_H` for high tone
* `_H_T` for high-rising tone
* `_T` for extra-high tone

## Mapping phonemes to integers for neural speech production models
Neural TTS takes phoneme indices as inputs. Having a fixed phoneme set, we can define a unified mapping. That simplifies model deployment and makes combining datasets for multi-lingual text-to-speech easier. Apart from phonemes, it is also common to augment input with some service tokens, such as pauses, word boundaries, etc. We reserve the first 10 positions of the mapping for service tokens:
* 0 - end token: added at the end of the encoded sequence. This matches the default padding value for modeling frameworks. It is an artificial token, and it always has zero duration.
* 1 - start token: added at the beginning of the encoded sequence. Mirrors end token. It may have zero or non-zero duration. 
* 2 - word boundary without pause. It is a token that signalizes the boundary between the words in fluent speech. It always has zero duration.
* 3 - word boundary with a pause. It is a token that indicates a break between two words. It always has a non-zero duration.
* 4 - falling tone sentence boundary. It is a token inserted on terminal punctuation, associated with falling intonation (`.` or `!`). It can happen at the end of an utterance, just before the end token, or in the middle if multiple sentences are synthesized together. Sentence boundary may or may not have silence associated with it.
* 5 - raising tone sentence boundary. Same as above but, inserted on terminal punctuation associated with raising intonation (`?`).

We reserve indices from 6 to 9 for any additional service tokens that might be helpful for Speech Synthesis. The phoneme set defined previously starts from index 10 and spans to 253.
According to the definition above, we separately encode stress and tone in order, starting from index 1. Index 0 is reserved for phonemes without stress and for padding.

The complete phoneme set can be found within [learn_to_normalize](https://github.com/balacoon/learn_to_pronounce/tree/main/data).
We did a trial of a freshly composed unified phoneme set, by mapping CMUDict and underlying ARPABET. It worked smoothly, notes on the process can be found [here](https://github.com/balacoon/en_us_pronunciation/blob/f683b7c4d9ad8baad048b3ff8bb9f8e900ccab43/cmudict/README.md). We hope that pronunciation dictionaries in other locales wouldn't pose a difficulty either. Which will pave the way to a frictionless multi-lingual TTS.

## References
<a id="1">[1]</a>
Sanchez, A., Falai, A., Zhang, Z., Angelini, O., & Yanagisawa, K. (2022). Unify and Conquer: How Phonetic Feature Representation Affects Polyglot Text-To-Speech (TTS). [link](https://arxiv.org/abs/2207.01547)
