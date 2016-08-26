# mecab-ipadic-NEologd : Neologism dictionary for MeCab
[![Build Status](https://travis-ci.org/neologd/mecab-ipadic-neologd.svg?branch=master)](https://travis-ci.org/neologd/mecab-ipadic-neologd)

## 詳細な情報
mecab-ipadic-NEologd に関する詳細な情報(サンプルコードなど)は以下の Wiki に書いてあります。

- https://github.com/neologd/mecab-ipadic-neologd/wiki/Home.ja

## mecab-ipadic-NEologd とは
mecab-ipadic-NEologd は、多数のWeb上の言語資源から得た新語を追加することでカスタマイズした MeCab 用のシステム辞書です。

Web上の文書の解析をする際には、この辞書と標準のシステム辞書(ipadic)を併用することをオススメします。

## 特徴
### 利点
- MeCab の標準のシステム辞書では正しく分割できない固有表現などの語の表層(表記)とフリガナの組を約266.5万組(重複エントリを含む)採録しています
- この辞書の更新は開発サーバ上で自動的におこなわれます
    - 少なくとも毎週 2 回更新される予定です
        - 月曜日と木曜日
- Web上の言語資源を活用しているので、更新時に新しい固有表現を採録できます
    - 現在使用している資源は以下のとおりです
        - はてなキーワードのダンプデータ
        - 郵便番号データダウンロード
        - 日本全国駅名一覧のコーナー
        - 人名(姓/名)エントリデータ
        - IPA 辞書に採録されていない副詞をエントリ化したデータ
        - IPA 辞書に採録されていない形容詞をエントリ化したデータ
        - IPA 辞書に採録されていない形容動詞をエントリ化したデータ
        - IPA 辞書に採録されていない感動詞エントリをエントリ化したデータ
        - 一般名詞の表記ゆれ文字列とその原型の組のリストをエントリ化したデータ
        - サ変接続名詞の表記ゆれ文字列とその原型の組のリストをエントリ化したデータ
        - Unicode 6.0 以下の絵文字に手作業で読み仮名を付与したデータ
        - 初期状態の iOS デバイスまたは Android デバイスで入力できる顔文字に手作業で読み仮名を付与したデータ
        - 日本の山の名前を収集したリスト
        - IPA 辞書に含まれるエントリの読み仮名に関する明らかなエラー(誤字・脱字など)を修正するパッチ
        - Web からクロールした大量の文書データ
    - 今後も他の新たな言語資源から抽出した固有表現などの語を採録する予定です

### 欠点
- 固有表現の分類が不十分です
    - 例えば一部の人名と製品名が同じ固有表現カテゴリに分類されています
- 固有表現では無い語も固有表現として登録されています
- 固有表現の表記とフリガナの対応づけを間違っている場合があります
    - すべての固有表現とフリガナの組に対する人手による検査を実施していないためです
- Web上の資源が更新されないなら、新しい固有表現は辞書に追加されません
- 追加した副詞の品詞情報が全て'副詞,一般,*,*,*,*'になっている
- 対応している文字コードは UTF-8 のみです
    - インストール済みの MeCab が使用している ipadic が UTF-8 版である必要があります

## 使用開始
### 推奨空きメモリ領域
- 標準インストール時(オプション未指定の場合)
    - 必須: 空き 1.5GByte
    - 推奨: 空き 5GByte
        - インストールされるバイナリファイルのサイズが約900MByteです
            - 今後も段々大きくなります
        - 仮想マシンに割り当てたメモリが少なくとも 2GB 以上でないと十分なメモリ領域を確保できずコンパイルに失敗します

#### 空きメモリ領域が足りない場合
メモリ領域の少ない仮想マシンにインストールする場合はエントリ数を減らすオプションを指定してください。

下記の --ignore で始まるオプションを全て指定すると、インストールされる辞書のバイナリデータのサイズを 300MByte 程度削減できます。

    ./bin/install-mecab-ipadic-neologd -n -y\
    --ignore_adverb\
    --ignore_interject\
    --ignore_noun_ortho\
    --ignore_noun_sahen_conn_ortho\
    --ignore_adjective_std\
    --ignore_adjective_verb

上記のコマンドを実行すると、インストーラーは追加の副詞(--ignore_adverb)と追加の感動詞(--ignore_interject)と一般名詞の表記ゆれ(--ignore_noun_ortho)とサ変接続名詞の表記ゆれ(--ignore_noun_sahen_conn_ortho)と追加の形容詞(--ignore_adjective_std)と追加の形容動詞(--ignore_adjective_verb)のための辞書エントリをインストールしません。

--ignore で始まるオプションは特定の辞書をインストールしない時に使います。

また下記の様に "--eliminate-redundant-entry" オプションを指定した場合は、正規化済みの日本語テキストを単語分割するための別称・異表記・表記揺れなどを一切考慮できない辞書を、512MByte 程度の空きメモリ領域があればインストールできます。

    ./bin/install-mecab-ipadic-neologd -n -y\
    --eliminate-redundant-entry\

とはいえ、"--eliminate-redundant-entry" オプションは開発側としては一切オススメしません。

その他のインストール時のオプションは下記のコマンドで確認できます。

    ./bin//install-mecab-ipadic-neologd --help

### 動作に必要なもの

インストール時に mecab-ipadic をベースにビルド処理をするために必要な環境やライブラリがあります。

apt、yum や homebrew でインストールするか、自前でコンパイルしてインストールして下さい。

- C++ コンパイラ
    - GCC-4.4.7 と Apple LLVM version 6.0 で動作を確認しています
- iconv (libiconv)
    - 辞書のコード変換に使います
- mecab
    - MeCab 本体です
    - bin/mecab と bin/mecab-config を使います
- mecab-ipadic
    - MeCab 用の辞書のひとつです
        - インストール時のテストに使います
        - ソースコードからインストールするときは以下の手順で文字コードを UTF-8 インストールして下さい

    ./configure --with-charset=utf8; make; sudo make install

- xz
    - mecab-ipadic-NEologd のシードの解凍に unxz を使います

他にも足りないものがあったら適時インストールして下さい。

#### 例
- CentOS の場合

    $ sudo rpm -ivh http://packages.groonga.org/centos/groonga-release-1.1.0-1.noarch.rpm

    $ sudo yum install mecab mecab-devel mecab-ipadic git make curl xz

- Fedora の場合

    $ sudo yum install mecab mecab-devel mecab-ipadic git make curl xz

- Ubuntu の場合

    $ sudo aptitude install mecab libmecab-dev mecab-ipadic-utf8 git make curl xz-utils file

- Mac OSX の場合

    $ brew install mecab mecab-ipadic git curl xz

### mecab-ipadic-NEologd をインストールする準備

辞書の元になるデータの配布と更新は GitHub 経由で行います。

初回は以下のコマンドでgit cloneしてください。

    $ git clone --depth 1 https://github.com/neologd/mecab-ipadic-neologd.git

または

    $ git clone --depth 1 git@github.com:neologd/mecab-ipadic-neologd.git

もしも、リポジトリの全変更履歴を入手したい方は「--depth 1」を消してcloneして下さい。

全変更履歴のデータサイズは変動しますが、ピーク時は約 1GB となり、かなり大容量ですのでご注意下さい。

### mecab-ipadic-NEologd のインストールと更新
#### Step.1
上記の準備でcloneしたリポジトリに移動します。

    $ cd mecab-ipadic-neologd

#### Step.2
以下のコマンドを実行して結果を確認する画面で「yes」と入力すると、sudo 権限で最新版がインストール(初回実行時以降は更新)されます。

    $ ./bin/install-mecab-ipadic-neologd -n

インストール先はオプション未指定の場合 mecab-config に従って決まります。

以下のコマンドを実行すると確認できます。

    $ echo `mecab-config --dicdir`"/mecab-ipadic-neologd"

複数の MeCab をインストールしている場合は、任意の mecab-config にパスを通して下さい。

cron(説明は省略します)などで自動的に更新したい場合に便利なオプションは既にあります。

例えば下記の様な 2 行を crontab などに書いた場合は、火・金曜日の午前 3 時に解析結果を確認せずに(-y)ユーザ権限(-u)で指定したディレクリトリに(-p [/path/to/user/directory])ある辞書ファイルが更新されます。

    00 03 * * 2 ./bin/install-mecab-ipadic-neologd -n -y -u -p /path/to/user/directory > /path/to/log/file
    00 03 * * 5 ./bin/install-mecab-ipadic-neologd -n -y -u -p /path/to/user/directory > /path/to/log/file

その他のインストール時に指定できるオプションは以下で確認できます。

    $ ./bin/install-mecab-ipadic-neologd -h

### mecab-ipadic-NEologd の使用方法
mecab-ipadic-NEologd を使いたいときは、MeCab の -d オプションにカスタムシステム辞書のパス(例: */lib/mecab/dic/mecab-ipadic-neologd/)を指定してください。

#### 例 (CentOS 上でインストールした場合)

    $ mecab -d /usr/local/lib/mecab/dic/mecab-ipadic-neologd/

## MeCabの実行結果の例
### mecab-ipadic-NEologd をシステム辞書として使った場合
    $echo "10日放送の「中居正広のミになる図書館」（テレビ朝日系）で、SMAPの中居正広が、篠原信一の過去の勘違いを明かす一幕があった。" | mecab -d /usr/local/lib/mecab/dic/mecab-ipadic-neologd
    10日    名詞,固有名詞,一般,*,*,*,10日,トオカ,トオカ
    放送    名詞,サ変接続,*,*,*,*,放送,ホウソウ,ホーソー
    の      助詞,連体化,*,*,*,*,の,ノ,ノ
    「      記号,括弧開,*,*,*,*,「,「,「
    中居正広のミになる図書館        名詞,固有名詞,一般,*,*,*,中居正広のミになる図書館,ナカイマサヒロノミニナルトショカン,ナカイマサヒロノミニナルトショカン
    」      記号,括弧閉,*,*,*,*,」,」,」
    （      記号,括弧開,*,*,*,*,（,（,（
    テレビ朝日      名詞,固有名詞,組織,*,*,*,テレビ朝日,テレビアサヒ,テレビアサヒ
    系      名詞,接尾,一般,*,*,*,系,ケイ,ケイ
    ）      記号,括弧閉,*,*,*,*,）,）,）
    で      助詞,格助詞,一般,*,*,*,で,デ,デ
    、      記号,読点,*,*,*,*,、,、,、
    SMAP    名詞,固有名詞,一般,*,*,*,SMAP,スマップ,スマップ
    の      助詞,連体化,*,*,*,*,の,ノ,ノ
    中居正広        名詞,固有名詞,人名,*,*,*,中居正広,ナカイマサヒロ,ナカイマサヒロ
    が      助詞,格助詞,一般,*,*,*,が,ガ,ガ
    、      記号,読点,*,*,*,*,、,、,、
    篠原信一        名詞,固有名詞,人名,*,*,*,篠原信一,シノハラシンイチ,シノハラシンイチ
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

#### どこに効果が出ている?
- Mecab は mecab-ipadic-NEologd に収録された語を正しく分割できました
    - 「中居正広のミになる図書館」は2011年後半に生まれた新しい語です
        - この語はWeb上の言語資源が更新されたので正しく分割できました
- mecab-ipadic-NEologd に収録されているほとんどの語にフリガナが付いています

### 標準のシステム辞書(ipadic-2.7.0)を使った場合
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

## 研究結果の評価や再現などに使いたい場合
以下に更新を止めた辞書をリリースしています。

- https://github.com/neologd/mecab-ipadic-neologd/releases/

以下の用途でご利用いただく場合は便利でしょう。

- 研究結果の評価実験
- 他人の研究結果の再現
- 永遠に更新しない形態素解析結果の作成

言語処理を始めたばかりの方や上記以外の多くの用途には master branch の最新版の使用を推奨します。

## インストールで行き詰まった場合
以下のコマンドを実行すると mecab-ipadic-NEologd の Yum リポジトリをシステムに登録し、さらに RPM ファイル(気まぐれ更新)をインストールできます。

最新版をインストールしたい場合は利用しないで下さい。

### RHEL 6 or CentOS 6

    // インストール先は /usr/lib64/mecab/dic/mecab-ipadic-neologd/ 以下
    $ sudo rpm -ivh http://packages.groonga.org/centos/groonga-release-1.1.0-1.noarch.rpm
    $ sudo yum install mecab mecab-devel mecab-ipadic
    $ curl -L https://goo.gl/int4Th | sh

## 今後の発展
継続して開発しますので、気になるところはどんどん改善されます。

ユーザの8割が気になる部分を優先して改善します。

## Bibtex

もしも mecab-ipadic-NEologd を論文や書籍、アプリ、サービスから参照して下さる場合は、以下の bibtex をご利用ください。

    @misc{sato2015mecabipadicneologd,
        title  = {Neologism dictionary based on the language resources on the Web for Mecab},
        author = {Toshinori, Sato},
        url    = {https://github.com/neologd/mecab-ipadic-neologd},
        year   = {2015}
    }

## Star please !!
mecab-ipadic-NEologd 使ってみて良い結果が得られた時は、ぜひこのリポジトリの Star ボタンを押して下さい。

とても大きな励みになります。

## Copyrights
Copyright (c) 2015-2016 Toshinori Sato (@overlast) All rights reserved.

ライセンスは Apache License, Version 2.0 です。下記をご参照下さい。

- https://github.com/neologd/mecab-ipadic-neologd/blob/master/COPYING
