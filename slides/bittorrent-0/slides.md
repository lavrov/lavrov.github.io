## Functional Bittorrent

<small>[Vitaly Lavrov](https://www.linkedin.com/in/vitaliy-lavrov-14b62042/) @ Amsterdam.scala</small>

---

## About me

- Doing programming for a living since 2010
- Using Scala as the main language from the day one
- Moving toward (more) functional programming

---

## Announcements

- [2.13.0 released](https://github.com/scala/scala/releases/tag/v2.13.0) 🎉
- [ScalaDays recordings](https://portal.klewel.com/watch/nice_url/scala-days-2019/) are online
- [Scala 3 Is Coming](https://info.lightbend.com/webinar-scala-3-is-coming-martin-odersky-shares-what-to-know-register.html) webinar with Martin Odersky on 11th of July 2019

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

## I'm not the only one

- [Haze](https://github.com/cronokirby/haze) (haskell, stm)
- [TorrentStream](https://github.com/Karasiq/torrentstream) (akka-streams)
- [Storrent](https://github.com/danluu/storrent) (akka)

--

## Bittorrent in a nutshell

--

<!-- .slide: data-background-size="900px" data-background="/assets/images/bittorrent-0/network-types.png" -->

--

<!-- .slide: data-background-size="900px" data-background="https://upload.wikimedia.org/wikipedia/commons/0/09/BitTorrent_network.svg" -->

--

## Protocol

- [Specification](https://www.bittorrent.org/beps/bep_0003.html)
- [Specification](https://wiki.theory.org/index.php/BitTorrentSpecification) in wiki style

---

## Grand Plan

--

<!-- .slide: data-background-size="900px" data-background="/assets/images/bittorrent-0/workflow.svg" -->

--

1. Peer wire protocol
2. DHT for peer discovery
3. Torrent metadata extension

---

## Implementation

--

## Torrent Metadata

(also known as `metainfo` or just torrent file)

- does not contain the content to be distributed
- contains information about those files, such as their names, sizes, folder structure, and cryptographic hash values for verifying file integrity
- is a bencoded dictionary

--

## Bencoding

Supports four different types of values:

- **byte strings**
- integers
- lists
- dictionaries (associative arrays)

--

## Bencoding

Single file
```
{
    'announce': 'http://bttracker.debian.org:6969/announce',
    'info':
    {
        'name': 'debian-503-amd64-CD-1.iso',
        'piece length': 262144,
        'length': 678301696,
        'pieces': <binary SHA1 hashes>
    }
}
```

--

## Bencoding

Multiple files
```
 {
     'announce': 'http://tracker.site1.com/announce',
     'info':
     {
         'name': 'directoryName',
         'piece length': 262144,
         'files':
         [
             {'path': ['111.txt'], 'length': 111},
             {'path': ['222.txt'], 'length': 222}
         ],
         'pieces': <binary SHA1 hashes>
     }
 }
```

--

### Bencoding

<small>

- Strings are length-prefixed base ten followed by a colon and the string. For example `4:spam` corresponds to `spam`.

- Integers are represented by an `i` followed by the number in base 10 followed by an `e`. For example `i3e` corresponds to `3` and `i-3e` corresponds to `-3`. Integers have no size limitation. `i-0e` is invalid. All encodings with a leading zero, such as `i03e`, are invalid, other than `i0e`, which of course corresponds to `0`.

- Lists are encoded as an `l` followed by their elements (also bencoded) followed by an `e`. For example `l4:spam4:eggse` corresponds to `['spam', 'eggs']`.

- Dictionaries are encoded as a `d` followed by a list of alternating keys and their corresponding values followed by an `e`. For example, `d3:cow3:moo4:spam4:eggse` corresponds to `{'cow': 'moo', 'spam': 'eggs'}` and `d4:spaml1:a1:bee` corresponds to `{'spam': ['a', 'b']}`. Keys must be strings and appear in sorted order (sorted as raw strings, not alphanumerics).

[Source](https://www.bittorrent.org/beps/bep_0003.html)

</small>

--

### Grammar (simplified)


```
digit           = '0' | '1' | ... | '9';

positive_number = digit, { digit }

number          = [ '-' ], positive_number;

integer         = 'i', number, 'e';

string          = positive_number, ':', byte string;

dictionary      = 'd', { string, value }, 'e';

value           = integer | string | dictionary;
```

<small>
❗ string: number specifies length of byte string
</small>

---

## Prepare environment

JDK

```sh
$ brew cask install adoptopenjdk8
```

--

[Mill build tool](http://www.lihaoyi.com/mill/)

```sh
$ brew install mill
```

--

[Visual Studio Code](https://code.visualstudio.com/Download)

<small>[Why?](https://portal.klewel.com/watch/webcast/scala-days-2019/talk/8/)</small>

```sh
$ brew cask install visual-studio-code
```
Plugins:
- [Live Share](https://visualstudio.microsoft.com/services/live-share/)
- [Scala (Metals)](https://marketplace.visualstudio.com/items?itemName=scalameta.metals)


--

[Intellij IDEA](https://www.jetbrains.com/idea/download/index.html)

```sh
$ brew cask install intellij-idea-ce
```

Inatall Scala plugin

Generate IDEA project

```sh
$ mill mill.scalalib.GenIdea/idea
```

---

Join shared session

<img width="200px" data-src="/assets/images/bittorrent-0/vscode-logo.png">

`Visual Studio Code`

---

Source code

[https://github.com/lavrov/bittorrent-workshop](https://github.com/lavrov/bittorrent-workshop)

```
$ git git@github.com:lavrov/bittorrent-workshop.git
```
