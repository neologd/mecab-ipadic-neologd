# README

## For Japanese
README.ja.md is written in Japanese.

- https://github.com/neologd/mecab-ipadic-neologd/blob/master/README.ja.md

## Documentation
You can find more detailed documentation and examples in the following wiki.

- https://github.com/neologd/mecab-ipadic-neologd/wiki/Home

## Overview
mecab-ipadic-neologd is customized system dictionary for MeCab.

This dictionary includes many neologisms (new word), which are extracted from many language resources on the Web.

When you analyze the Web documents, it's better to use this system dictionary and default one (ipadic) together.

## Pros and Cons
### Pros
- Recorded about 1.56 million pairs(including duplicate entries) of surface/furigana(kana indicating the pronunciation of kanji) of the words such as the named entity that can not be tokenized correctly using default system dictionary of MeCab.
- Update process of this dictionary will automatically run on development server.
    - I'm planning to renew this dictionary in monthly beginning of the month and middle of the month.
- When renewing by utilizing the language resources on Web, a new named entity can be recorded.
    - The resources are being utilized at present are as follows.
        - Dump data of hatena keyword
        - Japanese postal code number data download (ken_all.lzh)
        - The name-of-the-station list of the Japan whole country
        - A lot of documents, which crawled from Web
    - I'm planning to record the words such as the named entity, which will be extracted from other new language resource.

### Cons
- Classification of the named entity is insufficient
    - Ex. A person name and a product name are classified into the same named entity category.
- Not named entity word is recorded as named entity too.
- Since the manual checking to all the named entities can't conduct, it may have made a mistake in matching of surface of the named entity and furigana of the named entity.
- Unless the language resources on Web are updated, a new named entity won't add to the dictionary.

## Getting started
### Preparation of installing
A seed data of the dictionary will distribute via GitHub repository.

In first time, you should execute the following command to 'git clone'.

    $ git clone https://github.com/neologd/mecab-ipadic-neologd.git

OR

    $ git clone git@github.com:neologd/mecab-ipadic-neologd.git

### How to install/update mecab-ipadic-neologd
#### Step.1
Move to a directory of the repository which was cloned in the above preparation.

    $ cd mecab-ipadic-neologd

#### Step.2
Update to the latest state.

    $ git pull

#### Step.3
You can install or can update(overwritten) the recent mecab-ipadic-neologd by following command.

    $ ./bin/install-mecab-ipadic-neologd

### How to use mecab-ipadic-neologd
When you want to use mecab-ipadic-neologd, you should set the path of custom system dictionay(*/lib/mecab/dic/mecab-ipadic-neologd/) as -d option of MeCab.

#### Example (on CentOS)
$ mecab -d /usr/local/lib/mecab/dic/mecab-ipadic-neologd/

## Example of output of MeCab
### When you use mecab-ipadic-neologd
    $echo "10日放送の「中居正広のミになる図書館」（テレビ朝日系）で、SMAPの中居正広が、篠原信一の過去の勘違いを明かす一幕があった。" | mecab -d /usr/local/lib/mecab/dic/mecab-ipadic-neologd
    10日    名詞,固有名詞,一般,*,*,*,10日,トオカ,トオカ
    放送    名詞,サ変接続,*,*,*,*,放送,ホウソウ,ホーソー
    の      助詞,連体化,*,*,*,*,の,ノ,ノ
    「      記号,括弧開,*,*,*,*,「,「,「
    中居正広のミになる図書館        名詞,固有名詞,一般,*,*,*,中居正広のミになる図書館,ナカイマサヒロノミニナルトショカン,ナカイマサヒロノミニナルトショカン」
    記号,括弧閉,*,*,*,*,」,」,」
    （      記号,括弧開,*,*,*,*,（,（,（
    テレビ朝日      名詞,固有名詞,組織,*,*,*,テレビ朝日,テレビアサヒ,テレビアサヒ
    系      名詞,接尾,一般,*,*,*,系,ケイ,ケイ
    ）      記号,括弧閉,*,*,*,*,）,）,）
    で      助詞,格助詞,一般,*,*,*,で,デ,デ
    、      記号,読点,*,*,*,*,、,、,、
    SMAP    名詞,固有名詞,一般,*,*,*,SMAP,スマップ,スマップ
    の      助詞,連体化,*,*,*,*,の,ノ,ノ
    中居正広        名詞,固有名詞,一般,*,*,*,中居正広,ナカイマサヒロ,ナカイマサヒロ
    が      助詞,格助詞,一般,*,*,*,が,ガ,ガ
    、      記号,読点,*,*,*,*,、,、,、
    篠原信一        名詞,固有名詞,一般,*,*,*,篠原信一,シノハラシンイチ,シノハラシンイチ
    の      助詞,連体化,*,*,*,*,の,ノ,ノ
    過去    名詞,副詞可能,*,*,*,*,過去,カコ,カコ
    の      助詞,連体化,*,*,*,*,の,ノ,ノ
    勘違い  名詞,サ変接続,*,*,*,*,勘違い,カンチガイ,カンチガイ
    を      助詞,格助詞,一般,*,*,*,を,ヲ,ヲ
    明かす  動詞,自立,*,*,五段・サ行,基本形,明かす,アカス,アカス
    一幕    名詞,一般,*,*,*,*,一幕,ヒトマク,ヒトマク
    が      助詞,格助詞,一般,*,*,*,が,ガ,ガ
    あっ    動詞,自立,*,*,五段・ラ行,連用タ接続,ある,アッ,アッ
    た      助動詞,*,*,*,特殊・タ,基本形,た,タ,タ
    。      記号,句点,*,*,*,*,。,。,。
    EOS

#### What's the point of the above result

- MeCab can parse the words which are recorded in mecab-ipadic-neologd correctly.
    - "中居正広のミになる図書館(Masahiro Nakai's library to improve an ability)" is a new word.
        - This word could parse correctly because of updating of the language resources on Web.
- Almost all of the entry of mecab-ipadic-neologd has the value of furigana field.

### When you use default system dictionary
    $echo "10日放送の「中居正広のミになる図書館」（テレビ朝日系）で、SMAPの中居正広が、篠原信一の過去の勘違いを明かす一幕があった。" | mecab
    10      名詞,数,*,*,*,*,*
    日      名詞,接尾,助数詞,*,*,*,日,ニチ,ニチ
    放送    名詞,サ変接続,*,*,*,*,放送,ホウソウ,ホーソー
    の      助詞,連体化,*,*,*,*,の,ノ,ノ
    「      記号,括弧開,*,*,*,*,「,「,「
    中居    名詞,固有名詞,人名,姓,*,*,中居,ナカイ,ナカイ
    正広    名詞,固有名詞,人名,名,*,*,正広,マサヒロ,マサヒロ
    の      助詞,連体化,*,*,*,*,の,ノ,ノ
    ミ      名詞,一般,*,*,*,*,ミ,ミ,ミ
    に      助詞,格助詞,一般,*,*,*,に,ニ,ニ
    なる    動詞,自立,*,*,五段・ラ行,基本形,なる,ナル,ナル
    図書館  名詞,一般,*,*,*,*,図書館,トショカン,トショカン
    」      記号,括弧閉,*,*,*,*,」,」,」
    （      記号,括弧開,*,*,*,*,（,（,（
    テレビ朝日      名詞,固有名詞,組織,*,*,*,テレビ朝日,テレビアサヒ,テレビアサヒ
    系      名詞,接尾,一般,*,*,*,系,ケイ,ケイ
    ）      記号,括弧閉,*,*,*,*,）,）,）
    で      助詞,格助詞,一般,*,*,*,で,デ,デ
    、      記号,読点,*,*,*,*,、,、,、
    SMAP    名詞,固有名詞,組織,*,*,*,*
    の      助詞,連体化,*,*,*,*,の,ノ,ノ
    中居    名詞,固有名詞,人名,姓,*,*,中居,ナカイ,ナカイ
    正広    名詞,固有名詞,人名,名,*,*,正広,マサヒロ,マサヒロ
    が      助詞,格助詞,一般,*,*,*,が,ガ,ガ
    、      記号,読点,*,*,*,*,、,、,、
    篠原    名詞,固有名詞,人名,姓,*,*,篠原,シノハラ,シノハラ
    信一    名詞,固有名詞,人名,名,*,*,信一,シンイチ,シンイチ
    の      助詞,連体化,*,*,*,*,の,ノ,ノ
    過去    名詞,副詞可能,*,*,*,*,過去,カコ,カコ
    の      助詞,連体化,*,*,*,*,の,ノ,ノ
    勘違い  名詞,サ変接続,*,*,*,*,勘違い,カンチガイ,カンチガイ
    を      助詞,格助詞,一般,*,*,*,を,ヲ,ヲ
    明かす  動詞,自立,*,*,五段・サ行,基本形,明かす,アカス,アカス
    一幕    名詞,一般,*,*,*,*,一幕,ヒトマク,ヒトマク
    が      助詞,格助詞,一般,*,*,*,が,ガ,ガ
    あっ    動詞,自立,*,*,五段・ラ行,連用タ接続,ある,アッ,アッ
    た      助動詞,*,*,*,特殊・タ,基本形,た,タ,タ
    。      記号,句点,*,*,*,*,。,。,。
    EOS


## Bibtex

    @misc{sato2015mecabipadicneologd,
        title  = {Neologism dictionary based on the language resources on the Web for Mecab},
        author = {Toshinori, Sato},
        url    = {https://github.com/neologd/mecab-ipadic-neologd},
        year   = {2015}
    }

## Copyrights
Copyright (c) 2015 Toshinori Sato (@overlast) All rights reserved.
