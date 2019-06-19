## Functional Bittorrent

<small>[Vitaly Lavrov](https://www.linkedin.com/in/vitaliy-lavrov-14b62042/) @ Amsterdam.scala</small>

---

## About me

- Doing programming for a living since 2010
- Using Scala as the main language from the day one
- Leaning toward (more) functional programming

---

## Announcements

- [2.13.0 released](https://github.com/scala/scala/releases/tag/v2.13.0) 🎉
- [ScalaDays recordings](https://portal.klewel.com/watch/nice_url/scala-days-2019/) are online
- [Scala 3 Is Coming](https://info.lightbend.com/webinar-scala-3-is-coming-martin-odersky-shares-what-to-know-register.html) webinar with Martin Odersky

---

## Goals

- Introduce Scala to new people
- Show how it can be used for fun and profit
- Solving real world problems

---

## Why Bittorrent?

- Mutable state
- Concurrency
- Networking
- I ❤️ testing it

--

## Prepare environment

```sh
$ brew cask install adoptopenjdk8
$ brew install mill
$ brew cask install visual-studio-code
```
Install plugins in Visual Studio
- [Live Share](https://visualstudio.microsoft.com/services/live-share/)
- [Scala (Metals)](https://marketplace.visualstudio.com/items?itemName=scalameta.metals)

---

Join shared session

<img width="200px" data-src="/assets/images/bittorrent-0/vscode-logo.png">

`Visual Studio Code`

---

## Protocol

- [Specification](https://www.bittorrent.org/beps/bep_0003.html)
- [Specification](https://wiki.theory.org/index.php/BitTorrentSpecification) in wiki style

--

<!-- .slide: data-background-size="900px" data-background="https://upload.wikimedia.org/wikipedia/commons/0/09/BitTorrent_network.svg" -->

--

### Bencoding

<small>

- Strings are length-prefixed base ten followed by a colon and the string. For example `4:spam` corresponds to `spam`.

- Integers are represented by an `i` followed by the number in base 10 followed by an `e`. For example `i3e` corresponds to `3` and `i-3e` corresponds to `-3`. Integers have no size limitation. `i-0e` is invalid. All encodings with a leading zero, such as `i03e`, are invalid, other than `i0e`, which of course corresponds to `0`.

- Lists are encoded as an `l` followed by their elements (also bencoded) followed by an `e`. For example `l4:spam4:eggse` corresponds to `['spam', 'eggs']`.

- Dictionaries are encoded as a `d` followed by a list of alternating keys and their corresponding values followed by an `e`. For example, `d3:cow3:moo4:spam4:eggse` corresponds to `{'cow': 'moo', 'spam': 'eggs'}` and `d4:spaml1:a1:bee` corresponds to `{'spam': ['a', 'b']}`. Keys must be strings and appear in sorted order (sorted as raw strings, not alphanumerics).

</small>

--

### Bencoding


```
zero_digit      = '0';

non_zero_digit  = '1' | ... | '9';

digit           = zero_digit | non_zero_digit;

positive_number = zero_digit | ( non_zero_digit, { digit } )

number          = [ '-' ], positive_number;

integer         = 'i', number, 'e';

string          = positive_number, ':', byte string;

dictionary      = 'd', { string, value }, 'e';

value           = integer | string | dictionary;
```

<small>
❗ string: number specifies length of byte string
</small>