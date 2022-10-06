---
title: "en-US abbreviation detection"
last_modified_at: 2022-10-05T16:20:02-05:00
categories:
  - Blog
tags:
  - abbreviations
  - text normalization
---

Detecting abbreviations is cruicial for proper text normalization and subsequent pronunciation generation.
In the broad meaning, term "[abbreviation](https://en.wikipedia.org/wiki/Abbreviation)" means shortening, contraction, initialism or acronym.
In this post we would focus on initialisms - entities made up from initial letters of words, which are pronounced as separate letters.
It is important to detect those reliably in TTS frontend, because custom pronunciation generation is needed.
Additionally, proper detection of initialisms reduces ambiguity of identifying sentence boundaries.

Usually initialisms are written in capital letters, where each letter is follow by the dot, for example "F.B.I.".
It is also common to write initialism without dots, i.e. "AI", "USA" or "IBM".
Unfortunately sometimes it happens that initialisms are just written in lower case: "hr" or "www".

As a result following disambiguation problems are typical:
* **Confusing with single-letter words.** Simple case since the set of words is very limited ("I" and "a").
* **Confusing with roman numerals.** Even though roman numerals are rather rare, they are written as a sequence of capital letters from certain set, which can be easily confusing.* **Confusing with capitalized words.** Perhaps most frequent case, when capitalized word is recognized as initialism while its just editing specifics.
* **Confusing with acronyms.** Acronyms follow the same patterns as initialisms, but they are not spelled out, for ex. "NATO" or "AIDS".
* **Low-case abbreviations.** Rather rare situation, when abbreviation is not capitalized and is not marked anyhow.

Typical solution for the overall problem of abbreviations is summarized in [[1]](#1):

> A solid solution to the problem of upper-case tokens is to assume that in a well-developed system all genuine acronyms will appear in the lexicon.
> Upon encountering a capitalised token, we first check whether it is in the lexicon and, if so, just treat it as a normal word.
> If not, we then split the token into a series of single-character tokens and designate each as a letter.
> There is a possible alternative, where we examine upper-case tokens and attempt to classify them as either acronyms or letter sequences.
> Such a classification would be based on some notion of “pronounceability” such that if the token contains vowel characters in certain places then this might lead us to think that it is an acronym instead of a letter sequence.
> Experience has shown that this approach seldom works (at least in English) since there are plenty of potentially pronounceable tokens (e.g. USA and IRA) that sound absurd if we treat them as acronyms (e.g. /y uw s ax/ and /ay r ax/).
> If a mistake is to be made, it is generally better to pronounce an acronym as a letter sequence rather than the other way round.

## Simple cases

To narrow down the task, lets first outline usecases which should be spelled letter by letter without any ambiguity.

### [A-Za-z] character with the dot after it

This applies to both lower and upper cases (both "f.b.i." and "F.B.I." are possible).
We also assume that single character with the dot after it should be spelled out too.
It might be incorrect if article "a" or pronoun "I" is at the end of sentence.
But those cases are grammatically incorrect, so lets assume those cases are actually 
initialisms, shortened first names or list indices, i.e. should be spelled out.
Another potential issue - single roman digit at the end of the sentence.
For those cases lets assume its abbreviation unless its not in list of exceptions for roman numbers, such as "Clement I."
This rule can be expressed by simple acceptor [[2]](#2):

```python
delete_dot = pynutil.delete(".")
dot_abbr = pynini.closure((UPPER | (LOWER @ TO_UPPER)) + delete_dot, 1)
```

### consonants-only

When word consists of only consonants (both upper and lower case) there is no way to read it other than spelling.
The only gotcha is letter "y" which can act like vowel, for example "by". Acceptor looks like this:

```python
CONSONANTS = 'bcdfghjklmnpqrstvwxz'

def _any_element_lower(element_lst_):
    return pynini.union(*[pynini.accep(x.lower()) @ pynini.closure(TO_UPPER) for x in element_lst_])

def _any_element_upper(element_lst_):
    return pynini.union(*[pynini.accep(x.upper()) for x in element_lst_])

def _any_element(element_lst_):
    return _any_element_lower(element_lst_) | _any_element_upper(element_lst_)

consonant_abbr = pynini.closure(_any_element(CONSONANTS), 1)
```

### vowels only

When word contains only vowels, it should also be spelled out.
However single-letter is likely not an abbreviation (consider "I" or "U").
For upper case, it makes sense to treat any sequence of vowels starting from length 2 as abbreviation (for ex. "AI" or "IEEE").
For lower case, there are two-letters vowels-only words (for ex. interjection "oi").
So to be safe, only if words contain 3 lower-case vowels and more it should be considered abbreviation.

```python
VOWELS = 'aeiou'

vowel_abbr = pynini.closure(_any_element_upper(VOWELS), 2) |
             pynini.closure(_any_element_lower(VOWELS), 3)
```

## Vocabulary-based

As specified in quote from [[1]](#1), for non-obvious cases, dictionary-based disambiguation is needed.
Abbreviations without dots that have both vowels and consonants (both upper and lower case) can be quite confusing and
abbreviation dictionary allows to hot-fix issues.
However one may want to maintain multiple dictionaries.

### Acronyms vocabulary

Acronyms - are initialisms that are pronuounced rather than spelled.
I.e. purpose of this vocabulary is to contain "negative" examples, 
that shouldn't be classified as initialisms and should be pronounced 
following g2p rules for regular words. Typical examples are "NASA", "NATO" or "AIDS".

### Cased vocabulary

Some abbreviations should be treated as such only in specific case. 
For ex. "US" is a country, "us" is a first person plural pronoun in objective case.
On the first glance only upper case is expected in abbreviations,
but there might be mix of cases such as mRNA.

### Uncased vocabulary

Some abbreviations are case-independent and it doesnt matter which case they are written in,
they should be spelled. For ex. "usa", "uk" or "iq".

## Difficult-to-pronounce

When one looks at sequence of letters in a word, its fairly easy to guess if it should be pronounced or spelled.
Given that maintaining comprehensive dictionary of all the abbreviations is very laborous work,
it worth to have additional heuristic that would capture at least the most obvious cases of abbreviations that are not in vocabs.

In order to define what "difficult-to-prnounce" mean, it worth to collect some list of abbreviations and compare it with list of regular words.
One can even build classifier having such datasets, but we would be looking to keep it simple in order to be able to integrate 
such solution into FST-based text-normalization. 

### Datasets

Two datasets are composed and shared in [this repository](https://huggingface.co/datasets/balacoon/en_us_abbreviations).
One is slightly cleaner but significantly smaller, another is much larger, but likely contains
annotation errors.

### #1: cmudict & wiki based

Abbreviation dataset is composed by merging 3 resources: cmudict acronyms [[3]](#3); 
acronyms parsed from wikipedia [[4]](#4); book of acronyms and initialisms [[5]](#5).
Those resources are combined, excluding duplicates and regular words, to compose a dataset of
3.3k abbreviations. As negative examples, list of 125k words from cmudict is used.

### #2: kestrel based

Kestrel[[6]](#6) is Google text normalization system. By normalizing Wikipedia, a dataset for text-normalization
research was composed [[7]](#7). Dataset is not perfectly clean and certainly contains both false
alarms (regular words marked as abbreviations) as well as misses (abbreviations marked as regular words).
However the quantity of the data is massive which may outweigh the annotation mistakes.
To avoid long tail of semantically unreasonable input, both abbreviations and words can be filtered by frequency.
For example, taking only abbreviations/words that occur at least 4 times gives dataset of 48k abbreviations and 688k words.

### Abbreviations n-grams

Without building a classifier, the easiest way to detect sequences of characters that are difficult to read,
is to build n-grams and check which are frequent for abbreviations but
rare for regular words. This can be easily integrated into FST acceptor which would be able
to detect abbreviations that are not in any of the vocabularies. 
For both datasets, only n-grams which are never observed for regular words are selected.
Below are some examples, to give a taste what kind of letter sequences are abbreviation specific.
"^" - means start of word; "$" - end of it.
<details>
<summary>2-grams examples</summary>
<pre style="font-size: 14px">
QS
HX
QC
VB
PX
...
</pre>
</details>

<details>
<summary>3-grams examples</summary>
<pre style="font-size: 14px">
CC$
^MS
^CC
CR$
CP$
...
</pre>
</details>

<details>
<summary>4-grams examples</summary>
<pre style="font-size: 14px">
OPR$
FOC$
AEC$
^PST
^USC
CTL$
...
</pre>
</details>

Going forward, we should note that n-gram based detection fails miserably without a hard
limit on maximum word length. Its very common in free-form text, to have concatenations of several words without
whitespace. On the word boundaries, there might be very unusual letter sequences.
To avoid marking those as abbreviations, we suggest to consider if OOV word is abbreviation only
in case it is sufficiently short (less than 7 letters).

### Detecting abbreviations

Lets try to evaluate how often abbreviation-specific n-grams indicate abbreviation and 
if they can be used as a reliable detector.
This can be very briefly done using random examples from [[7]](#7) annotated manually.
This would also give an idea what is the quality of the kestrel-based abbreviation dataset.
Two usecases can be probed:
* how often LETTERS semiotic class is missed by n-gram based detection (approx. miss rate)
* how often abbreviation is getting incorrectly detected for PLAIN semiotic class (approx. false alarms)

Looking into the latter, it actually happens extremely rarely. For subset with 11M tokens,
just 35 cases. Within those cases, almost all of them - are concatenation of words (for ex. "GameGo") 
or concatenation of words and abbreviations (for ex. "pacRNA").
This can be avoided by applying n-gram based abbreviation detection only to upper-case text.

For the former, the performance is summarized in the table below, where TP - true positive, MR - miss rate,
FA - false alarm, TN - true negative.

| 100 usecases | Kestrel<br /> TP / FA | #1 dataset n-grams<br /> TP / MR / FA / TN | #2 dataset n-grams<br /> TP / MR / FA / TN |
| --- | --- | --- | --- |
| vowels+consonants marked as LETTERS semiotic class by Kestrel | 87 / 13 | 35 / 52 / 0 / 13 | 28 / 59 / 0 / 13 |

Kestrel falsely marks few words as abbreviations (13 out of random 100):
<details>
  <summary>Kestrel Abbreviation False Alarms</summary>
  <pre style="font-size: 14px">
AMORETTES
FROSTWORKS
FEILDEN
INTERIORBUREAU
MOSPEADA
HITAM
MAISURADZE
MAMMAN
SOURGENS
COGGER
SINOVI
BIKES
LISTU
  </pre>
  </details>

N-gram based approach generally has high miss rate.
N-grams from dataset #1: 52/100; from dataset #2: 59/100.
It can be seen that list of difficult-to-pronounce n-grams is incomplete.
For example, "KQ" hardly happens in regular words,
its just didn't happen in abbreviations from dataset.
N-grams selected from dataset #2, seems to be more permissive, because of bigger overlap between regular words and abbreviations.
On the positive, n-gram based approach doesn't produce any false alarms.

<details>
  <summary>Abbreviations that doesn't contain n-grams from dataset #1</summary>
  <pre style="font-size: 14px">
UDHR
APOBEC
GEMI
FREMM
USK
MHI
NEHM
ALK
WAKQ
SSAT
...
  </pre>
</details>

Overall list of n-grams that are difficult to pronounce is a good starting point for abbreviation detection.
It allows to keep abbreviation dictionaries smaller and generalize to unseen abbreviations at least somehow.

## Non-alpha characters in abbreviations

One more issue, that might introduce difficulties into detecting abbreviations - non-alpha characters.
There are few fairly frequent ones, that abbreviation detection should take care of.


### apostroph (')

Abbreviations may have suffix that should be taken into account when pronunciation is produced via spelling.
Most common suffixes are plural (s) or possessive marker ('s). The acceptor for it looks as following:

```python
s = pynini.union(pynini.accep('s'), pynini.cross('S', 's'))
suffix = pynini.accep('s') | (pynini.accep('\'') + s)
optional_suffix = pynini.closure(suffix, 0, 1)
```

It can be appended to any abbreviation described before.

### and (&)

Ampersand in commonly used inside an abbreviation to shorten "and" word. Typical examples are
"AT&T" or "R&D". This is fairly easy to handle, because ampersand surrounded by capital letters -
almost exclusively signalizes abbreviation.

```python
and_abbr = pynini.closure(UPPER, 1) + pynini.cross("&", " and ") + pynini.closure(UPPER, 1)
```

### hyphen (-)

Abbreviation may be connected to regular word or digits via hyphen. For example, something already
used in this post: "FST-based", or smth commonly used for naming: "T-800". This is more of a design issue of
text-normalization system. In general, it can be solved similar to how ranges are handeled (1990 - 1995 or 2 : 1),
i.e. by allowing custom token boundaries, other than space.

## References
<a id="1">[1]</a>
Paul Taylor. Text-to-speech Synthesis. [link](https://www.cambridge.org/core/books/texttospeech-synthesis/D2C567CEF939C7D15B2F1232992C7836)

<a id="2">[2]</a>
K. Gorman, R. Sporat. Finite-State Text Processing. [link](https://ieeexplore.ieee.org/document/9448597)

<a id="3">[3]</a>
Acronyms in CMUdict. [link](https://github.com/Alexir/CMUdict/blob/master/acronym-0.7b)

<a id="4">[4]</a>
List of Abbreviations. Wikipedia. [link](https://en.wikipedia.org/wiki/Lists_of_abbreviations)

<a id="5">[5]</a>
A Handbook of Acronyms and Initialisms: Volume 88. [link](https://play.google.com/store/books/details?id=xz7FY2gp0j8C&rdid=book-xz7FY2gp0j8C&rdot=1)

<a id="6">[6]</a>
P. Ebden, R. Sproat. The Kestrel TTS text normalization system [link](https://www.researchgate.net/publication/277932107_The_Kestrel_TTS_text_normalization_system)

<a id="7">[7]</a>
Sproat & Jaitly (2017). Text Normalization for English, Russian and Polish. [link](https://www.kaggle.com/richardwilliamsproat/text-normalization-for-english-russian-and-polish)