---
title: "Text Normalization"
permalink: /use/frontend/learn_to_normalize
---

**Frontend** utilizes pre-packed grammars,
to expand written text into the spoken form.
[Pynini](https://www.openfst.org/twiki/bin/view/GRM/Pynini)
is used to write grammars that tokenize input text,
classify tokens into semiotic classes and verbalize them.

Use **learn_to_normalize**
([github](https://github.com/balacoon/learn_to_normalize), 
[documentation](../../../packages_docs/learn_to_normalize/index.html))
package to adjust text normalization rules and create custom addons for your needs.
We store text normalization rules in separate repositories, one per locale:

- [english](https://github.com/balacoon/en_us_normalization)
