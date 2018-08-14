# mecab-ipadic-NEologd : Neologism dictionary for MeCab
<img src="https://raw.githubusercontent.com/neologd/mecab-ipadic-neologd/images/neologd-logo-September2016.png" width="250">

[![Build Status](https://travis-ci.org/neologd/mecab-ipadic-neologd.svg?branch=master)](https://travis-ci.org/neologd/mecab-ipadic-neologd)

## 詳細な情報
mecab-ipadic-NEologd に関する詳細な情報(サンプルコードなど)は以下の Wiki に書いてあります。

- https://github.com/neologd/mecab-ipadic-neologd/wiki/Home.ja

## mecab-ipadic-NEologd とは
mecab-ipadic-NEologd は、多数のWeb上の言語資源から得た新語を追加することでカスタマイズした MeCab 用のシステム辞書です。

Web上の文書の解析をする際には、この辞書と標準のシステム辞書(ipadic)を併用することをオススメします。

## 特徴
### 利点
- MeCab の標準のシステム辞書では正しく分割できない固有表現などの語の表層(表記)とフリガナの組を約308万組(重複エントリを含む)採録しています
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
        - 一般名詞/固有名詞の表記ゆれ文字列とその原型の組のリストをエントリ化したデータ
        - サ変接続名詞の表記ゆれ文字列とその原型の組のリストをエントリ化したデータ
        - SNS 上に現れやすい崩れ表記語と同様のパターンをもつ語をエントリ化したデータ
        - Unicode 9.0 以下の絵文字に手作業で読み仮名を付与したデータ
        - 初期状態の iOS デバイスまたは Android デバイスで入力できる顔文字に手作業で読み仮名を付与したデータ
        - 日本の山の名前を収集したリスト
        - IPA 辞書に含まれるエントリの読み仮名に関する明らかなエラー(誤字・脱字など)を修正するパッチ
        - IPA 辞書に含まれるエントリの形態素生起コストを修正するパッチ
        - 時間表現や数値表現をあらかじめ定義したパターンによって生成してエントリ化したデータ
        - ニュース記事から抽出した新語や未知語をエントリ化したデータ
        - ネット上で流行した単語や慣用句やハッシュタグをエントリ化したデータ
        - Web からクロールした大量の文書データ
    - 今後も他の新たな言語資源から抽出した固有表現などの語を採録する予定です

### 欠点
- 固有表現の分類が不十分です
    - 例えば一部の人名と製品名が同じ固有表現カテゴリに分類されています
- 固有表現では無い語も固有表現として登録されています
- 固有表現の表記とフリガナの対応づけを間違っている場合があります
    - すべての固有表現とフリガナの組に対する人手による検査を実施していないためです
- 追加した副詞の品詞情報が全て'副詞,一般,*,*,*,*'になっている
- 対応している文字コードは UTF-8 のみです
    - インストール済みの MeCab が使用している ipadic が UTF-8 版である必要があります

## 使用開始
### 推奨空きメモリ領域
- 標準インストール時(オプション未指定の場合)
    - 必須: 空き 1.5GByte
    - 推奨: 空き 5GByte
        - 標準インストール時のバイナリファイルのサイズは約850MByteです
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
    --ignore_adjective_verb\
    --ignore_ill_formed_words

上記のコマンドを実行すると、インストーラーは追加の副詞(--ignore_adverb)と追加の感動詞(--ignore_interject)と一般名詞/固有名詞の表記ゆれ(--ignore_noun_ortho)とサ変接続名詞の表記ゆれ(--ignore_noun_sahen_conn_ortho)と追加の形容詞(--ignore_adjective_std)と追加の形容動詞(--ignore_adjective_verb)とSNSなどで見かける崩れ表記語(--ignore_ill_formed_words)のための辞書エントリをインストールしません。

--ignore で始まるオプションは特定の辞書をインストールしない時に使います。

また下記の様に "--eliminate-redundant-entry" オプションを指定した場合は、正規化済みの日本語テキストを単語分割するための別称・異表記・表記揺れなどを一切考慮できない辞書を、512MByte 程度の空きメモリ領域があればインストールできます。

    ./bin/install-mecab-ipadic-neologd -n -y\
    --eliminate-redundant-entry\

とはいえ、"--eliminate-redundant-entry" オプションは開発側としては一切オススメしません。
その他のインストール時のオプションは下記のコマンドで確認できます。

    ./bin/install-mecab-ipadic-neologd --help

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

#### 例: 動作に必要なライブラリのインストール
- CentOS の場合

    $ sudo rpm -ivh http://packages.groonga.org/centos/groonga-release-1.1.0-1.noarch.rpm

    $ sudo yum install mecab mecab-devel mecab-ipadic git make curl xz

- Fedora の場合

    $ sudo yum install mecab mecab-devel mecab-ipadic git make curl xz

- Ubuntu の場合

    $ sudo aptitude install mecab libmecab-dev mecab-ipadic-utf8 git make curl xz-utils file

- macOS の場合

    $ brew install mecab mecab-ipadic git curl xz

- Windows 10 バージョン 1607 以降の場合

    BoW(Bash on Ubuntu on Windows)をインストールすれば、BoW 環境内に MeCab と mecab-ipadic-NEologd をインストールできます。

    - Bash on Ubuntu on Windows (beta) をインストールする
        - 公式ドキュメント:[Bash on Ubuntu on Windows : Microsoft - Developer Network](https://msdn.microsoft.com/ja-jp/commandline/wsl/install_guide)

    BoW 環境で以下を実行します。

    $ sudo aptitude update

    $ sudo aptitude upgrade

    $ sudo aptitude install make automake autoconf autotools-dev m4 mecab libmecab-dev mecab-ipadic-utf8 git make curl xz-utils file

    $ sudo sed -i -e 's%/lib/mecab/dic%/share/mecab/dic%' /usr/bin/mecab-config

    この後は Linux や macOS と同じです。

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

### 全部入りな mecab-ipadic-NEologd を簡単にインストールする方法
標準インストールでは一部の辞書ファイルがインストールされません。

オプションで個別に指定しても良いですが、-a オプションを指定すると全部入り状態でインストールできます。

    $ ./bin/install-mecab-ipadic-neologd -n -a

全部入りな辞書を構築する際の最低メモリ使用量は2GByte弱です。

### mecab-ipadic-NEologd の使用方法
mecab-ipadic-NEologd を使いたいときは、MeCab の -d オプションにカスタムシステム辞書のパス(例: */lib/mecab/dic/mecab-ipadic-neologd/)を指定してください。

#### 例 (CentOS 上でインストールした場合)

    $ mecab -d /usr/local/lib/mecab/dic/mecab-ipadic-neologd/

## MeCabの実行結果の例
### mecab-ipadic-NEologd をシステム辞書として使った場合

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

#### どこに効果が出ている?
- Mecab は mecab-ipadic-NEologd に収録された語を正しく分割できました
    - 「中居正広の金曜日のスマイルたちへ」は2016年前半に生まれた新しい語です
        - この語はWeb上の言語資源が更新されたので正しく分割できました
- mecab-ipadic-NEologd に収録されているほとんどの語にフリガナが付いています
- 「8月3日」と「1日」と「5分」が1語になっています
    - 頻出な時間表現や数量表現をあらかじめ収録しています
        - 読み仮名については間違うことも多いです
        - ニュースに頻出ではない範囲の表現は未収録です
- 「ぽっこり」を副詞として検出している
    - あらかじめ資源を作成して拡張してます
- 「ダイエット方法」が1語になっている
    - ニュースやSNSで頻出する表現は1語にしていきます
- 「キンタロー。」が1語になっている
    - 有名な人名は積極的に固有名詞にします
        - 自動生成の都合で人名に分類されない場合もあります
            - 更新されるごとに、だんだん直っていきます
    - 有名な「。が文末になる問題」を解決しています

### 標準のシステム辞書(ipadic-2.7.0)を使った場合

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

    @INPROCEEDINGS{sato2017mecabipadicneologdnlp2017,
        author    = {佐藤敏紀, 橋本泰一, 奥村学},
        title     = {単語分かち書き辞書 mecab-ipadic-NEologd の実装と情報検索における効果的な使用方法の検討},
        booktitle = "言語処理学会第23回年次大会(NLP2017)",
        year      = "2017",
        pages     = "NLP2017-B6-1",
        publisher = "言語処理学会",
    }
    @INPROCEEDINGS{sato2016neologdipsjnl229,
        author    = {佐藤敏紀, 橋本泰一, 奥村学},
        title     = {単語分かち書き用辞書生成システム NEologd の運用 — 文書分類を例にして —},
        booktitle = "自然言語処理研究会研究報告",
        year      = "2016",
        pages     = "NL-229-15",
        publisher = "情報処理学会",
    }
    @misc{sato2015mecabipadicneologd,
        author = {Toshinori, Sato},
        title  = {Neologism dictionary based on the language resources on the Web for Mecab},
        url    = {https://github.com/neologd/mecab-ipadic-neologd},
        year   = {2015}
    }

## よろしければアンケートにご回答ください

よろしければ[mecab-ipadic-NEologdの利用状況アンケート](https://goo.gl/dcRhsJ)にご協力ください。

何処でどの様に使われているかを知ることで、我々が高いモチベーションを維持できます。

お礼と言うほどではありませんが、ご希望でしたら「ご協力頂いた方のIDの文字列とその読み仮名を辞書へ登録する」ことを試みます(登録できない場合もあります)。

## Star please !!
mecab-ipadic-NEologd 使ってみて良い結果が得られた時は、ぜひこのリポジトリの Star ボタンを押して下さい。

とても大きな励みになります。

## Copyrights
Copyright (c) 2015-2018 Toshinori Sato (@overlast) All rights reserved.

ライセンスは Apache License, Version 2.0 です。下記をご参照下さい。

- https://github.com/neologd/mecab-ipadic-neologd/blob/master/COPYING
