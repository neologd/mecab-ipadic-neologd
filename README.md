# mecab-ipadic-NEologd : Neologism dictionary for MeCab
<img src="https://raw.githubusercontent.com/neologd/mecab-ipadic-neologd/images/neologd-logo-September2016.png" width="250">

[![Build Status](https://travis-ci.org/neologd/mecab-ipadic-neologd.svg?branch=master)](https://travis-ci.org/neologd/mecab-ipadic-neologd)

## For Japanese
README.ja.md is written in Japanese.

- https://github.com/neologd/mecab-ipadic-neologd/blob/master/README.ja.md

## Documentation
You can find more detailed documentation and examples in the following wiki.

- https://github.com/neologd/mecab-ipadic-neologd/wiki/Home

## Overview
mecab-ipadic-NEologd is customized system dictionary for MeCab.

This dictionary includes many neologisms (new word), which are extracted from many language resources on the Web.

When you analyze the Web documents, it's better to use this system dictionary and default one (ipadic) together.

## Pros and Cons
### Pros
- Recorded about 3.08 million pairs(including duplicate entries) of surface/furigana(kana indicating the pronunciation of kanji) of the words such as the named entity that can not be tokenized correctly using default system dictionary of MeCab.
- Update process of this dictionary will automatically run on development server.
    - I'm planning to renew this dictionary at least updating twice weekly
        - Every Monday and Thursday
- When renewing by utilizing the language resources on Web, a new named entity can be recorded.
    - The resources are being utilized at present are as follows.
        - Dump data of hatena keyword
        - Japanese postal code number data download (ken_all.lzh)
        - The name-of-the-station list of whole country of Japan
        - The entry data of the person names (last name / first name)
        - The entry data of Unicode emojis (version 9.0)
        - The entry data of Kaomoji strings
        - The entry data of adverbs
        - The entry data of adjectives
        - The entry data of adjective verbs
        - The entry data of interjections
        - The entry data of orthographic variant of general nouns
        - The entry data of orthographic variant of nouns used as verb form
- A lot of documents, which crawled from Web
    - I'm planning to record the words such as the named entity, which will be extracted from other new language resource.

### Cons
- Classification of the named entity is insufficient
    - Ex. Some person names and a product name are classified into the same named entity category.
- Not named entity word is recorded as named entity too.
- Since the manual checking to all the named entities can't conduct, it may have made a mistake in matching of surface of the named entity and furigana of the named entity.
- Corresponding to only UTF-8
    - You should install the UTF-8 version of MeCab

## Getting started

### Memory requirements
- Required: 1.5GB of RAM
- Recommend: 5GB of RAM
    - Current maximum binary size is 1.1GB

### Dependencies

We build mecab-ipadic-NEologd using the source code of mecab-ipadic at installing phase.

You should install following libraries using apt or yum, homebrew, source-code.

- C++ Compiler
    - Operation on GCC-4.4.7 and Apple LLVM version 6.0 are confirmed
- iconv (libiconv)
    - Use to convert the character code of IPADIC
- mecab
    - We use bin/mecab and bin/mecab-config
- mecab-ipadic
    - One of a dictionary of MeCab
        - Use to test at the time of installation
        - If you install it using source code, you should select the UTF-8 as a character code

    ./configure --with-charset=utf8; make; sudo make install

- xz
    - Use to decompress a xz package of a seed of mecab-ipadic-NEologd

Please install at any time other lack library.

#### Examples
- On CentOS

    $ sudo rpm -ivh http://packages.groonga.org/centos/groonga-release-1.1.0-1.noarch.rpm

    $ sudo yum install mecab mecab-devel mecab-ipadic git make curl xz

- On Fedora

    $ sudo yum install mecab mecab-devel mecab-ipadic git make curl xz

- On Ubuntu

    $ sudo aptitude install mecab libmecab-dev mecab-ipadic-utf8 git make curl xz-utils file

- On MacOSX

    $ brew install mecab mecab-ipadic git curl xz

### Preparation of installing
A seed data of the dictionary will distribute via GitHub repository.

In first time, you should execute the following command to 'git clone'.

    $ git clone --depth 1 https://github.com/neologd/mecab-ipadic-neologd.git

OR

    $ git clone --depth 1 git@github.com:neologd/mecab-ipadic-neologd.git

If you need all log of mecab-ipadic-neologd.git, you should clone the repository without '--depth 1'

### How to install/update mecab-ipadic-NEologd
#### Step.1
Move to a directory of the repository which was cloned in the above preparation.

    $ cd mecab-ipadic-neologd

#### Step.2

You can install or can update(overwritten) the recent mecab-ipadic-NEologd by following command.

    $ ./bin/install-mecab-ipadic-neologd -n

You can check the directory path to install it.

    $ echo `mecab-config --dicdir`"/mecab-ipadic-neologd"

If you installed some mecab-config, you should set the path of the mecab-config which you want to use.

If you use following command, you can check useful command line option.

    $ ./bin/install-mecab-ipadic-neologd -h

### How to use mecab-ipadic-NEologd
When you want to use mecab-ipadic-NEologd, you should set the path of custom system dictionay(*/lib/mecab/dic/mecab-ipadic-neologd/) as -d option of MeCab.

#### Example (on CentOS)
$ mecab -d /usr/local/lib/mecab/dic/mecab-ipadic-neologd/

## Example of output of MeCab
### When you use mecab-ipadic-NEologd
    $ echo "8月3日に放送された「中居正広の金曜日のスマイルたちへ」(TBS系)で、1日たった5分でぽっこりおなかを解消するというダイエット方法を紹介。キンタロー。のダイエットにも密着。" | mecab -d /usr/local/lib/mecab/dic/mecab
    8月3日	名詞,固有名詞,一般,*,*,*,8月3日,ハチガツミッカ,ハチガツミッカ
    に	助詞,格助詞,一般,*,*,*,に,ニ,ニ
    放送	名詞,サ変接続,*,*,*,*,放送,ホウソウ,ホーソー
    さ	動詞,自立,*,*,サ変・スル,未然レル接続,する,サ,サ
    れ	動詞,接尾,*,*,一段,連用形,れる,レ,レ
    た	助動詞,*,*,*,特殊・タ,基本形,た,タ,タ
    「	記号,括弧開,*,*,*,*,「,「,「
    中居正広の金曜日のスマイルたちへ	名詞,固有名詞,一般,*,*,*,中居正広の金曜日のスマイルたちへ,ナカイマサヒロノキンヨウビノスマイルタチヘ,ナカイマサヒロノキンヨービノスマイルタチヘ
    」(	記号,一般,*,*,*,*,*
    TBS	名詞,固有名詞,一般,*,*,*,TBS,ティービーエス,ティービーエス
    系	名詞,接尾,一般,*,*,*,系,ケイ,ケイ
    )	記号,一般,*,*,*,*,*
    で	助動詞,*,*,*,特殊・ダ,連用形,だ,デ,デ
    、	記号,読点,*,*,*,*,、,、,、
    1日	名詞,固有名詞,一般,*,*,*,1日,ツイタチ,ツイタチ
    たった	副詞,助詞類接続,*,*,*,*,たった,タッタ,タッタ
    5分	名詞,固有名詞,一般,*,*,*,5分,ゴフン,ゴフン
    で	助詞,格助詞,一般,*,*,*,で,デ,デ
    ぽっこり	副詞,一般,*,*,*,*,ぽっこり,ポッコリ,ポッコリ
    おなか	名詞,一般,*,*,*,*,おなか,オナカ,オナカ
    を	助詞,格助詞,一般,*,*,*,を,ヲ,ヲ
    解消	名詞,サ変接続,*,*,*,*,解消,カイショウ,カイショー
    する	動詞,自立,*,*,サ変・スル,基本形,する,スル,スル
    という	助詞,格助詞,連語,*,*,*,という,トイウ,トユウ
    ダイエット方法	名詞,固有名詞,一般,*,*,*,ダイエット方法,ダイエットホウホウ,ダイエットホウホー
    を	助詞,格助詞,一般,*,*,*,を,ヲ,ヲ
    紹介	名詞,サ変接続,*,*,*,*,紹介,ショウカイ,ショーカイ
    。	記号,句点,*,*,*,*,。,。,。
    キンタロー。	名詞,固有名詞,一般,*,*,*,キンタロー。,キンタロー,キンタロー
    に	助詞,格助詞,一般,*,*,*,に,ニ,ニ
    も	助詞,係助詞,*,*,*,*,も,モ,モ
    密着	名詞,サ変接続,*,*,*,*,密着,ミッチャク,ミッチャク
    。	記号,句点,*,*,*,*,。,。,。
    EOS

#### What's the point of the above result

- MeCab can parse the words which are recorded in mecab-ipadic-NEologd correctly
    - "中居正広の金曜日のスマイルたちへ(To Friday's smile by Masahiro Nakai)" is a new word
        - This word could parse correctly because of updating of the language resources on Web
- Almost all of the entry of mecab-ipadic-NEologd has the value of furigana field
- Recording frequent time expressions and quantitative expressions in advance
- Expressions frequently appearing in News and SNS will be made into one word
- Positively make the name of famous people Named Entity
- Famous "。 is the end of sentence" problem solved

### When you use default system dictionary
    $ echo "8月3日に放送された「中居正広の金曜日のスマイルたちへ」(TBS系)で、1日たった5分でぽっこりおなかを解消するというダイエット方法を紹介。キンタロー。にも密着。" | mecab
    8	名詞,数,*,*,*,*,*
    月	名詞,一般,*,*,*,*,月,ツキ,ツキ
    3	名詞,数,*,*,*,*,*
    日	名詞,接尾,助数詞,*,*,*,日,ニチ,ニチ
    に	助詞,格助詞,一般,*,*,*,に,ニ,ニ
    放送	名詞,サ変接続,*,*,*,*,放送,ホウソウ,ホーソー
    さ	動詞,自立,*,*,サ変・スル,未然レル接続,する,サ,サ
    れ	動詞,接尾,*,*,一段,連用形,れる,レ,レ
    た	助動詞,*,*,*,特殊・タ,基本形,た,タ,タ
    「	記号,括弧開,*,*,*,*,「,「,「
    中居	名詞,固有名詞,人名,姓,*,*,中居,ナカイ,ナカイ
    正広	名詞,固有名詞,人名,名,*,*,正広,マサヒロ,マサヒロ
    の	助詞,連体化,*,*,*,*,の,ノ,ノ
    金曜日	名詞,副詞可能,*,*,*,*,金曜日,キンヨウビ,キンヨービ
    の	助詞,連体化,*,*,*,*,の,ノ,ノ
    スマイル	名詞,一般,*,*,*,*,スマイル,スマイル,スマイル
    たち	名詞,接尾,一般,*,*,*,たち,タチ,タチ
    へ	助詞,格助詞,一般,*,*,*,へ,ヘ,エ
    」(	名詞,サ変接続,*,*,*,*,*
    TBS	名詞,一般,*,*,*,*,*
    系	名詞,接尾,一般,*,*,*,系,ケイ,ケイ
    )	名詞,サ変接続,*,*,*,*,*
    で	助詞,格助詞,一般,*,*,*,で,デ,デ
    、	記号,読点,*,*,*,*,、,、,、
    1	名詞,数,*,*,*,*,*
    日	名詞,接尾,助数詞,*,*,*,日,ニチ,ニチ
    たっ	動詞,自立,*,*,五段・タ行,連用タ接続,たつ,タッ,タッ
    た	助動詞,*,*,*,特殊・タ,基本形,た,タ,タ
    5	名詞,数,*,*,*,*,*
    分	名詞,接尾,助数詞,*,*,*,分,フン,フン
    で	助動詞,*,*,*,特殊・ダ,連用形,だ,デ,デ
    ぽ	形容詞,接尾,*,*,形容詞・アウオ段,ガル接続,ぽい,ポ,ポ
    っ	動詞,非自立,*,*,五段・カ行促音便,連用タ接続,く,ッ,ッ
    こり	動詞,自立,*,*,一段,連用形,こりる,コリ,コリ
    おなか	名詞,一般,*,*,*,*,おなか,オナカ,オナカ
    を	助詞,格助詞,一般,*,*,*,を,ヲ,ヲ
    解消	名詞,サ変接続,*,*,*,*,解消,カイショウ,カイショー
    する	動詞,自立,*,*,サ変・スル,基本形,する,スル,スル
    という	助詞,格助詞,連語,*,*,*,という,トイウ,トユウ
    ダイエット	名詞,サ変接続,*,*,*,*,ダイエット,ダイエット,ダイエット
    方法	名詞,一般,*,*,*,*,方法,ホウホウ,ホーホー
    を	助詞,格助詞,一般,*,*,*,を,ヲ,ヲ
    紹介	名詞,サ変接続,*,*,*,*,紹介,ショウカイ,ショーカイ
    。	記号,句点,*,*,*,*,。,。,。
    キンタロー	名詞,一般,*,*,*,*,*
    。	記号,句点,*,*,*,*,。,。,。
    に	助詞,格助詞,一般,*,*,*,に,ニ,ニ
    も	助詞,係助詞,*,*,*,*,も,モ,モ
    密着	名詞,サ変接続,*,*,*,*,密着,ミッチャク,ミッチャク
    。	記号,句点,*,*,*,*,。,。,。
    EOS

## To evaluate or to reproduce a research result
We release the tag for mainly research purpose.

- https://github.com/neologd/mecab-ipadic-neologd/releases/

It is very useful for the following applications.

- Experiments for evaluation of a research result
- Reproducibility of a experimental result of others
- Creation of the processing results of morphological analysis that doesn't update forever

If you are the beginner of NLP, I recommend that you use the latest version of master branch.

## Bibtex

Please use the following bibtex, when you refer mecab-ipadic-NEologd from your papers.

    @INPROCEEDINGS{sato2017mecabipadicneologdnlp2017,
        author    = {Toshinori Sato, Taiichi Hashimoto and Manabu Okumura},
        title     = {Implementation of a word segmentation dictionary called mecab-ipadic-NEologd and study on how to use it effectively for information retrieval (in Japanese)},
        booktitle = "Proceedings of the Twenty-three
        Annual Meeting of the Association for Natural Language Processing",
        year      = "2017",
        pages     = "NLP2017-B6-1",
        publisher = "The Association for Natural Language Processing",
    }
    @INPROCEEDINGS{sato2016neologdipsjnl229,
        author    = {Toshinori Sato, Taiichi Hashimoto and Manabu Okumura},
        title     = {Operation of a word segmentation dictionary generation system called NEologd (in Japanese)},
        booktitle = "Information Processing Society of Japan, Special Interest Group on Natural Language Processing (IPSJ-SIGNL)",
        year      = "2016",
        pages     = "NL-229-15",
        publisher = "Information Processing Society of Japan",
    }
    @misc{sato2015mecabipadicneologd,
        title  = {Neologism dictionary based on the language resources on the Web for Mecab},
        author = {Toshinori, Sato},
        url    = {https://github.com/neologd/mecab-ipadic-neologd},
        year   = {2015}
    }

## Star please !!
Please star this github repository if mecab-ipadic-NEologd is very useful to your project ;)

## Copyrights
Copyright (c) 2015-2018 Toshinori Sato (@overlast) All rights reserved.

We select the 'Apache License, Version 2.0'. Please check following link.

- https://github.com/neologd/mecab-ipadic-neologd/blob/master/COPYING
