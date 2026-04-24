# 講義ノート: オブジェクト指向プログラミング (継承)

日付: 2026-04-24
講師: 中西 泰人 先生
テーマ: クラスの継承 / 差分プログラミング / スーパークラスとサブクラス

---

## 1. 前回のおさらい

- 先週は **オブジェクト指向** の導入として **クラス** を学んだ。
- クラスとは、**変数とメソッドをひとまとまりにして扱う** 仕組み。
- この考え方の本質は「**中身が分からなくても使える**」こと。
  - 例: ギタリストは、ロックができればアンプの中身の仕組みを知らなくてもよい。
  - 「分からないからこそ、使いやすい」=抽象化の力。

### 今日のゴール

- オブジェクト指向の重要な概念である **継承 (inheritance)** を理解する。
- 継承によって「中身を知らなくても再利用できる」仕組みがさらに強化されることを体験する。

---

## 2. アンパンマンとバイキンマンのインスタンスを共存させる

### 2.1 準備

- Processing の **タブ機能** を使うと、クラスごとにファイルを分けてコードを整理できる。
- 矢印ボタン(タブの+マーク)から新しいタブを作り、クラスを別ファイルに分割。
- これにより **コードの構造が明確** になる。

### 2.2 共存させるコード構造

```processing
// メインタブ
Anpanman anpanman;
Baikinman baikinman1, baikinman2;

void setup() {
  size(800, 600);
  anpanman = new Anpanman();
  baikinman1 = new Baikinman();
  baikinman2 = new Baikinman();
}

void draw() {
  background(255);
  anpanman.setXY(mouseX, mouseY);
  anpanman.display();
  baikinman1.move();
  baikinman1.display();
  baikinman2.move();
  baikinman2.display();
}
```

- **スコープ** に注意: `setup()` と `draw()` の両方からアクセスしたい変数は、`{}` の外側(トップレベル)で宣言する。
- アンパンマンはマウス座標で動き、バイキンマンはふわふわ移動する。
- これだけで **衝突判定ゲーム** (追いかけっこ, 叩きゲーム等) のベースになる。

---

## 3. リファクタリング: 抽象化によってコードを整える

### 3.1 問題意識

```processing
// Before
anpanman.setXY(mouseX, mouseY);
anpanman.display();
baikinman.move();
baikinman.display();
```

呼び出し側の形がバラバラ。これを揃えたい。

### 3.2 `move()` メソッドの導入による抽象化

アンパンマンクラスに `move()` を追加し、内部で `setXY(mouseX, mouseY)` を行う。

```processing
// After
anpanman.move();
anpanman.display();
baikinman.move();
baikinman.display();
```

### 3.3 抽象化とは

- **複数のやることをまとめて、新しい名前を付ける行為**。
- 例え話: 「SFC に行く」という一言には、以下の詳細が隠れている。
  - 車に乗る → 鍵を開ける → エンジンをかける → Google Maps で検索 → バックして道に出る → … → 交差点で左折。
- 詳細を隠して **目的を主語に** できるのが抽象化の価値。

### 3.4 リファクタリングのメリット

- バグが減る。
- 後で読み返したときに分かりやすい(数ヶ月後の自分 / 他人が読んでもよい)。

---

## 4. 継承 (Inheritance) と差分プログラミング

### 4.1 継承とは

- 誰か(過去の自分・他の開発者・ライブラリ作者)が作った部品を **そのまま受け継ぎ**、変えたい部分だけ書き換える仕組み。
- 日常の例: ボルト・ナット・ネジは自作せずホームセンターで買う。→ 共通部品は品質が高く、再利用が楽。

### 4.2 Processing 自体が継承のお手本

- Processing のスケッチは、実は **`PApplet` クラスを継承したサブクラス** として動いている。
- ツール → Export Application で書き出した Java ソースを見ると:

```java
public class SketchName extends PApplet {
  ...
}
```

- `extends PApplet` = 「PApplet クラスを拡張(継承)している」。
- `setup()` / `draw()` / `mousePressed()` / `mouseX` などは **PApplet が用意してくれている** もの。
- 我々はそのうち **書き換えたいメソッドだけを上書き**して使っている。これが **差分プログラミング**。

### 4.3 用語の整理

- **スーパークラス (superclass)**: 継承される側 (親クラス)。矢印の向かう先。
- **サブクラス (subclass)**: 継承する側 (子クラス)。矢印を出している方。
- アンパンマンクラスがスポットクラスを継承するなら:
  - スポットクラス = スーパークラス
  - アンパンマンクラス = サブクラス

---

## 5. スーパークラス `Spot` を定義する

### 5.1 Spot クラス (スーパークラス)

アンパンマンとバイキンマンに共通する性質を抽出する。

```processing
class Spot {
  float x, y;
  float speedX, speedY;
  float diameter = 50;
  PImage img;

  Spot() {
    x = width / 2;
    y = height / 2;
  }

  void move() {
    x += speedX;
    y += speedY;
  }

  void display() {
    ellipse(x, y, diameter, diameter);
  }

  void update() {
    move();
    display();
  }
}
```

- `update()` は `move()` と `display()` をまとめて呼ぶ **さらなる抽象化** メソッド。
- 呼び出し側は「どちらが先か」を気にせず `update()` だけ呼べば良くなる。

### 5.2 Anpanman クラス (サブクラス)

```processing
class Anpanman extends Spot {
  Anpanman() {
    img = loadImage("anpanman.png");
  }

  void move() {
    x = mouseX;
    y = mouseY;
  }

  void display() {
    image(img, x, y);
  }
}
```

- `extends Spot` と書くことで、`x`, `y`, `speedX`, `speedY`, `img`, `update()` などを **継承** する。
- `move()` と `display()` は **オーバーライド (上書き)** している。

### 5.3 Baikinman クラス (サブクラス)

```processing
class Baikinman extends Spot {
  Baikinman() {
    img = loadImage("baikinman.png");
    speedX = random(-3, 3);
    speedY = random(-3, 3);
  }

  void display() {
    image(img, x, y);
  }
}
```

- `move()` は **オーバーライドせず**、スーパークラス `Spot` の `move()` をそのまま使う。
- `speedX` / `speedY` をコンストラクタでセットすることで、ふわふわ移動が実現する。

### 5.4 メインコードがすっきりする

```processing
Anpanman anpanman;
Baikinman baikinman1, baikinman2;

void setup() {
  size(800, 600);
  anpanman = new Anpanman();
  baikinman1 = new Baikinman();
  baikinman2 = new Baikinman();
}

void draw() {
  background(255);
  anpanman.update();
  baikinman1.update();
  baikinman2.update();
}
```

---

## 6. オーバーライド (Override) の挙動まとめ

| メソッド      | Spot(スーパー) | Anpanman | Baikinman |
|--------------|--------------|----------|-----------|
| `move()`     | 速度で移動   | マウス追従 (オーバーライド) | 継承 (速度で移動) |
| `display()`  | 白い円       | 画像描画 (オーバーライド) | 画像描画 (オーバーライド) |
| `update()`   | move+display | 継承     | 継承       |

- オーバーライドしなければ、スーパークラスの定義がそのまま使われる。
- オーバーライドしたメソッドだけ、そのサブクラス固有の振る舞いになる。

---

## 7. モジュール化と再利用性

教科書のまとめ (Processing 本 第25章より):

> モジュール化されたプログラムは、コードの部品がモジュールとして組み合わせられ、それぞれのモジュールは具体的なタスクを扱う。
> 変数は最も基本的な再利用手段であり、関数はタスクを抽象化してコードブロックを再利用可能にする。
> オブジェクト指向プログラミングは、変数と関数によるモジュール化をさらに拡張したものである。

- **関数(メソッド)での抽象化**: 人は「どう動いているか」より「何をするか」に関心を持つ。
- **クラスでの抽象化**: 変数とメソッドをひとまとめにして再利用。
- **継承での抽象化**: クラス同士をまとめる親クラスを用意して、さらに再利用性を高める。

---

## 8. 新しいキャラクターを増やしやすくなる

`Spot` を定義したことで、ドキンちゃんやしょくぱんまんなどの新キャラクターは:

1. `extends Spot` を付けてサブクラスを宣言
2. コンストラクタで `img` と `speedX/Y` を設定
3. 必要なら `move()` / `display()` をオーバーライド

という手順で簡単に追加できる。ジャムおじさんのように挙動が大きく違うキャラは、新しいメソッド(例: `bake()`)を追加することも考えられる。

---

## 9. 本日の課題

1. `Spot` クラスの **新しいサブクラス** を定義する (例: ドキンちゃん / ジャムおじさん / オリジナルキャラ)。
2. メインコードで **その新しいクラスのインスタンス** を生成する。
3. `update()` を呼び出して動作させる。
4. Processing メニューの **ツール → スケッチをアーカイブ** で zip ファイルを作成する。
   - 上書き保存されず、実行ごとに連番が付くので、区切りごとにアーカイブしておくと安心。
5. 生成した zip ファイルを **K-LMS** に提出する。

---

## 10. 今日のキーワード

- 継承 (inheritance) / `extends`
- 差分プログラミング
- スーパークラス / サブクラス
- オーバーライド (override)
- 抽象化 (abstraction)
- モジュール化 / 再利用性
- `PApplet` (Processing の全スケッチのスーパークラス)
