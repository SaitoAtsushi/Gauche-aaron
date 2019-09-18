# Implementation of Aaron's virtual machine

このプログラムは [Aaron 氏による仮想機械](https://takumim97.hatenablog.com/entry/2019/09/10/091018)の実装です。
プログラムはアセンブリ言語形式で表現します。

## 特徴
このプログラムの設計思想・特徴としては以下のようなものがあります。

- [Gauche](http://practical-scheme.net/gauche/index-j.html) の機能を積極的に使う
    - 命令のディスパッチには Gauche のオブジェクトシステムを活用する
    - プログラムの解釈には Gauche の PEG パーサコンビネータを活用する

## 実行環境要件

[Gauche](http://practical-scheme.net/gauche/index-j.html) のバージョン 0.9.9_pre1 を前提として書いています。
それが実行可能である環境を用意してください。
Gauche が多少古いバージョンであっても実行可能である可能性はありますが、試験していません。

## 原形と異なる部分

Aaron 氏が提案しているレジスタマシンとは以下のような部分で異なっています。

- 空命令は存在しません。
- 原形では命令が存在しない箇所は空命令があるものとみなしますが、このプログラムでは命令が存在しないインデックスが与えられるとエラーになります。
- メモリの初期状態を与える方法はありません。 必要であれば `save` 命令で陽に値を書き込む必要があります。

## 文法

このプログラムが解釈するプログラムの各行は以下のいずれかの形式をとります。

- `[ラベル] 空白 命令 空白 オペランド [空白] [; コメント]`
- `[空白] [; コメント]`

(ここでは `[` `]` で囲んだ要素は省略可能であることを表します) 

### 命令、及びオペランド

このプログラムで書くことのできる命令、及びそれぞれの命令が受け取ることのできるオペランドは以下の通りです。

- `incr index value`
- `decr address value`
- `save index value`
- `halt`

### オペランドの表現

#### index

`index` としては二種類の表現が可能です。

|種類|記法|説明|
|---|---|---|
|直接記法|整数|記述された値を番地にもつレジスタを表す|
|関節記法| `[` 整数 `]` | `[` と `]` で囲まれた整数を番地にもつレジスタに格納されている値を番地にもつレジスタを表す。

### value

`value` としては四種類の表現が可能です。

|種類|記法|説明|
|---|---|---|
|即値|整数|記述された値がそのまま値となる|
|レジスタ値| `[` 整数 `]` | `[` と `]` で囲まれた整数をもつレジスタに格納されている値を使う|
|ポインタ値| `[[` 整数 `]]` | `[[` と `]]` で囲まれた整数をもつレジスタに格納されている値を番地にもつレジスタに格納されている値を使う|
|プログラムカウンタ|pc|現在のプログラムカウンタの値を使う|


### address

|種類|記法|説明|
|---|---|---|
|即値|整数|記述された値がそのまま値となる|
|レジスタ値| `[` 整数 `]` | `[` と `]` で囲まれた整数をもつレジスタに格納されている値を使う|
|プログラムカウンタ|pc|現在のプログラムカウンタの値を使う|
|ラベル|ラベル名|同名のラベルがつけられた命令のアドレスを表す|

### 文法の形式表現

このプログラムが解釈可能な文法を EBNF で形式表現したものは以下です。

```
program = line* comment*
line    = ident delim+ command comment | delim+ command comment | comment line
ident   = [a-zA-Z] [a-zA-Z0-9]*
delim   = #x20 | #x9
command = incr | decr | save | halt
comment = delim* (';' [^#xA])? #xA
sep     = delim* ',' delim*
incr    = "incr" delim+ index (sep value)?
decr    = "decr" delim+ index sep address (sep value)?
save    = "save" delim+ index sep value
halt    = "halt"
index   = num | '[' delim* num delim* ']'
value   = index | "pc" | "[[" delim* num delim* "]]" 
address = index | "pc" | ident
num     = ('-'? [1-9][0-9]*) | '0'
```

### 文法の注意点
- プログラムは行の集合であり、行の最後は改行で終わるという POSIX の考え方を採用しています。 つまり、ファイルの終端の直前は常に改行であることを要求します。

## インストール方法

```console
$ git clone https://github.com/SaitoAtsushi/Gauche-aaron.git
$ cd Gauche-aaron
$ ./configure
$ make install
```

## スタンドアロン実行ファイルの生成とインストール

上の手順では必要なライブラリとスクリプトを Gauche 管理下のディレクトリにインストールしますが、単独の実行可能ファイルの方が都合が良いかもしれません。
その場合には以下の手順をとることで実行ファイルを生成・インストールできます。

```console
$ git clone https://github.com/SaitoAtsushi/Gauche-aaron.git
$ cd Gauche-aaron
$ ./configure
$ make standalone-install
```

## 実行方法

コマンドから、プログラムのファイル名を与えるとそれを解釈・実行して結果を標準出力に表示します。

```console
$ gosh aaron-asm [filename]
```

単独の実行ファイルをインストール出来ている場合には `aaron-asm` コマンドをそのまま実行できます。

```
$ aaron-asm [filename]
```