// =====================================================================
// アンパンマン OOP版 (4) 継承(Inheritance) 編
// ---------------------------------------------------------------------
// 参考: Lesson3 https://github.com/Rhizobium-gits/FUNDAMENTALS-OF-OBJECT-ORIENTED-PROGRAMMING/blob/main/Class/Lesson3.md
//
// この授業のテーマは「継承」。
//   - 共通点を「スーパークラス Spot」にまとめる
//   - 個別の見た目は「サブクラス」が extends で受け継いで上書き(override)する
// 今回はスーパークラス Spot を作り、Anpanman / Baikinman / Dokinchan の
// 3 つのサブクラスを定義する。
// =====================================================================

// --- グローバル変数 ---
// 配列の「型」をスーパークラス Spot にしている点に注目。
// サブクラスのインスタンス(Anpanman, Baikinman, Dokinchan)はすべて
// 「Spot の一種」なので、この一本の配列にまとめて入れられる。
// これが OOP の「ポリモーフィズム(多態性)」の典型例。
Spot[] spots = new Spot[3];

void setup() {
  size(1080, 680);
  smooth();
  // 毎フレーム位置を更新したいので noLoop() は使わない

  float scl = 0.45;       // フィールドを広く取った分、キャラは少し小さめ

  // アンパンマンは中央スタート、敵 2 体は別の位置に置く
  spots[0] = new Anpanman (width / 2.0, height / 2.0, scl);  // マウス追従 + 回避
  spots[1] = new Baikinman(260,  180, scl);                  // 跳ね回る
  spots[2] = new Dokinchan(820,  500, scl);                  // 跳ね回る
}

void draw() {
  background(255);

  // 同じ update() メッセージを送るだけで、
  // それぞれのサブクラスが自分の display() を実行してくれる。
  // 呼び出し側は中身が誰なのか気にしなくてよい(=ポリモーフィズム)。
  for (int i = 0; i < spots.length; i++) {
    spots[i].update();
  }
}


// =====================================================================
// スーパークラス Spot
// ---------------------------------------------------------------------
// 「画面上のどこかに居て、動いて、自分の姿を表示できるもの」の共通設計図。
// この授業の元ネタ(Lesson3)の Spot をベースに、拡大率 scl だけ追加してある。
// =====================================================================
class Spot {
  // ---- フィールド(全サブクラスが受け継ぐ) ----
  float x, y;             // 位置(画面内の中心座標)
  float speedX, speedY;   // 速度(サブクラスが使う。Anpanman は使わない)
  float scl = 1.0;        // 拡大倍率

  // ---- コンストラクタ ----
  // 引数なし版: 画面中央に立たせる(Lesson3 の Spot() に相当)
  Spot() {
    x = width / 2;
    y = height / 2;
  }

  // 引数あり版: 位置とサイズを指定して生成する
  Spot(float x, float y, float scl) {
    this.x = x;
    this.y = y;
    this.scl = scl;
  }

  // ---- メソッド ----
  // 動きの規則。サブクラスで上書き(override)してもよい。
  void move() {
    x += speedX;
    y += speedY;
  }

  // 描画。Spot のままでは「何も描かない」という空の振る舞い。
  // 各サブクラスが override して、自分の見た目を描く。
  void display() {
    // ここは空。サブクラスで実装される前提のフック。
  }

  // 1フレーム分の処理セット。move() してから display()。
  // サブクラスでも普通はこれをそのまま使う。
  void update() {
    move();
    display();
  }
}


// =====================================================================
// サブクラス 1: Anpanman extends Spot
// ---------------------------------------------------------------------
// Spot が持つ x, y, scl をそのまま使い、display() だけ自分用に上書きする。
// 「アンパンマンらしい見た目」だけがこのクラスの責任。
// =====================================================================
class Anpanman extends Spot {

  Anpanman(float x, float y, float scl) {
    super(x, y, scl);   // 親(Spot)のコンストラクタに委ねる
  }

  // move() を override:
  //   ・基本はマウス位置を目標にする
  //   ・配列 spots[] にいる「他のキャラ」が近づきすぎたら、
  //     その方向と逆向きの「反発ベクトル」を目標位置に足して避ける
  //   ・最後はイージング(目標との差の一定割合だけ動く)で滑らかに移動
  void move() {
    // 1. マウスを目標位置の初期値とする
    float tx = mouseX;
    float ty = mouseY;

    // 2. 自分以外の Spot との距離を見て、近すぎたら目標を押しのける
    float threshold = 270;   // この距離より近づくと反発し始める
    for (int i = 0; i < spots.length; i++) {
      Spot other = spots[i];
      if (other == this) continue;        // 自分自身は無視
      float dx = x - other.x;
      float dy = y - other.y;
      float d  = sqrt(dx * dx + dy * dy);
      if (d < threshold && d > 0.001) {
        // 距離が近いほど強く押し返す(線形に減衰)
        float push = (threshold - d) * 1.4;
        tx += dx / d * push;              // 相手から自分への単位ベクトル × 強さ
        ty += dy / d * push;
      }
    }

    // 3. 目標との差の 20% だけ動く (ease-out 的な追従)
    x += (tx - x) * 0.2;
    y += (ty - y) * 0.2;
  }

  // display() を override してアンパンマンの顔を描く
  void display() {
    pushMatrix();
    translate(x, y);
    scale(scl);

    drawFace();
    drawRedCircles();
    drawOutlineOverlay();
    drawHighlights();
    drawEyebrows();
    drawEyes();
    drawMouth();

    popMatrix();
  }

  // --- 以下、Lesson2(anpanman_three) と同じ部品メソッド ---

  void drawFace() {
    float faceR = 270;
    noStroke();
    fill(190, 140, 65);
    ellipse(0, 0, faceR * 2, faceR * 2);
    noFill();
    stroke(50, 35, 15);
    strokeWeight(6);
    ellipse(0, 0, faceR * 2, faceR * 2);
  }

  void drawRedCircles() {
    float cheekR = 82, noseR = 75, noseY = 60, spacing = 128;
    noStroke();
    fill(205, 35, 30);
    ellipse(-spacing, noseY, cheekR * 2, cheekR * 2);
    ellipse(0, noseY, noseR * 2, noseR * 2);
    ellipse(spacing, noseY, cheekR * 2, cheekR * 2);
  }

  void drawOutlineOverlay() {
    float cheekR = 82, noseR = 75, noseY = 60, spacing = 128;
    stroke(50, 35, 15);
    strokeWeight(5.5);
    noFill();
    float d = spacing;
    float cutL = acos((d*d + cheekR*cheekR - noseR*noseR) / (2.0 * d * cheekR));
    float cutN = acos((d*d + noseR*noseR - cheekR*cheekR) / (2.0 * d * noseR));
    arc(-spacing, noseY, cheekR * 2, cheekR * 2, cutL, TWO_PI - cutL);
    arc(0, noseY, noseR * 2, noseR * 2, PI + cutN, TWO_PI - cutN);
    arc(0, noseY, noseR * 2, noseR * 2, cutN, PI - cutN);
    arc(spacing, noseY, cheekR * 2, cheekR * 2, PI + cutL, PI + TWO_PI - cutL);
  }

  void drawHighlights() {
    float noseY = 60, spacing = 128, sq = 16;
    noStroke();
    fill(255);
    rect(-spacing + 15, noseY - 24, sq, sq);
    rect(0 + 12, noseY - 22, sq, sq);
    rect(spacing + 15, noseY - 24, sq, sq);
  }

  void drawEyebrows() {
    stroke(50, 35, 15);
    strokeWeight(5.5);
    noFill();
    arc(-68, -75, 72, 70, -PI + 0.2, -0.2);
    arc(68, -75, 72, 70, PI + 0.2, TWO_PI - 0.2);
  }

  void drawEyes() {
    noStroke();
    fill(15);
    ellipse(-68, -30, 28, 44);
    ellipse(68, -30, 28, 44);
  }

  void drawMouth() {
    float noseY = 60;
    stroke(50, 35, 15);
    strokeWeight(5);
    noFill();
    arc(0, noseY + 70, 210, 80, 0.12, PI - 0.12);
  }
}


// =====================================================================
// サブクラス 2: Baikinman extends Spot
// ---------------------------------------------------------------------
// 黒い顔・触角・紫の蝶ネクタイ風の帯・歯を見せたニヤリ笑い。
// Anpanman と同じく display() だけ上書きする。
// =====================================================================
class Baikinman extends Spot {

  Baikinman(float x, float y, float scl) {
    super(x, y, scl);
    // ランダムな速度を持たせる(Lesson3 と同じやり方)
    speedX = random(-3, 3);
    speedY = random(-3, 3);
  }

  // move() を override: 親の動きに「壁で跳ね返る」を足す
  //   super.move() で親の x += speedX; y += speedY; を呼んでから、
  //   フィールドの端を超えたら符号反転して跳ね返す。
  void move() {
    super.move();
    float r = 270 * scl;   // 顔のだいたいの半径
    if (x < r)          { x = r;          speedX = -speedX; }
    if (x > width - r)  { x = width - r;  speedX = -speedX; }
    if (y < r)          { y = r;          speedY = -speedY; }
    if (y > height - r) { y = height - r; speedY = -speedY; }
  }

  void display() {
    pushMatrix();
    translate(x, y);
    scale(scl);

    // 描画順 = レイヤー(後に描いた方が上に乗る)
    drawAntennae();      // 1. 触角(根元は次の頭に隠れる)
    drawHead();          // 2. 黒い頭
    drawEyePatches();    // 3. 上の方の薄ピンク楕円(目の部分)
    drawClosedEyes();    // 4. ピンク楕円の中の ^^ 閉じ目
    drawGrin();          // 5. 下半分の大きな歯のある口
    drawSash();          // 6. 真ん中を横切る紫の帯
    drawNose();          // 7. 帯の上に乗る紫の鼻

    popMatrix();
  }

  void drawAntennae() {
    // 触角の棒
    stroke(20);
    strokeWeight(9);
    noFill();
    line(-95, -230, -150, -300);
    line( 95, -230,  150, -300);
    // 触角の先端の黒い玉
    noStroke();
    fill(30);
    ellipse(-160, -312, 55, 55);
    ellipse( 160, -312, 55, 55);
  }

  void drawHead() {
    // 黒い顔(やや横長)
    noStroke();
    fill(40);
    ellipse(0, 0, 540, 480);
    noFill();
    stroke(20);
    strokeWeight(6);
    ellipse(0, 0, 540, 480);
  }

  void drawEyePatches() {
    // 顔の上半分にある左右の薄ピンク楕円(目の領域)
    noStroke();
    fill(255, 205, 215);
    ellipse(-115, -100, 210, 140);
    ellipse( 115, -100, 210, 140);
  }

  void drawClosedEyes() {
    // ^^ の形をした閉じ目(笑い目): 楕円の上半分(PI〜TWO_PI)を切り取って ∩ 形にする
    stroke(70, 35, 50);
    strokeWeight(8);
    noFill();
    arc(-115, -90, 120, 70, PI + 0.3, TWO_PI - 0.3);
    arc( 115, -90, 120, 70, PI + 0.3, TWO_PI - 0.3);
  }

  void drawGrin() {
    // 歯を見せたニヤリ笑いの口
    // (1) 角丸長方形の白い口(黒い輪郭)
    stroke(20);
    strokeWeight(6);
    fill(255);
    rect(-225, 50, 450, 175, 55);   // x, y, w, h, 角丸半径

    // (2) 中央のジグザグ線で歯を表現
    //     上下に交互に往復するので、上の歯(下向き三角)と
    //     下の歯(上向き三角)が噛み合った形になる
    noFill();
    strokeWeight(5);
    int teeth = 9;
    float halfW = 195;
    float topY  = 80;
    float botY  = 195;
    beginShape();
    for (int i = 0; i <= teeth; i++) {
      float xc = -halfW + (halfW * 2.0) * i / teeth;
      float yc = (i % 2 == 0) ? topY : botY;
      vertex(xc, yc);
    }
    endShape();
  }

  void drawSash() {
    // 真ん中を横切る紫の帯(蝶ネクタイ風)
    noStroke();
    fill(140, 100, 180);
    beginShape();
    vertex(-285, 10);
    vertex(-235, -25);
    vertex( 235, -25);
    vertex( 285, 10);
    vertex( 235, 45);
    vertex(-235, 45);
    endShape(CLOSE);
    // 縁取り
    stroke(20);
    strokeWeight(5);
    noFill();
    beginShape();
    vertex(-285, 10);
    vertex(-235, -25);
    vertex( 235, -25);
    vertex( 285, 10);
    vertex( 235, 45);
    vertex(-235, 45);
    endShape(CLOSE);
  }

  void drawNose() {
    // 帯の中央に乗る紫の鼻
    noStroke();
    fill(140, 100, 180);
    ellipse(0, 10, 80, 80);
    stroke(20);
    strokeWeight(5);
    noFill();
    ellipse(0, 10, 80, 80);
    // 白い四角ハイライト
    noStroke();
    fill(255);
    rect(-9, -2, 18, 18);
  }
}


// =====================================================================
// サブクラス 3: Dokinchan extends Spot
// ---------------------------------------------------------------------
// オレンジ色のたまご型の顔・1本の触角・大きな緑の瞳・まつげ。
// バイキンマンの仲間だが、見た目は別物。継承で姉妹クラスとして並べる。
// =====================================================================
class Dokinchan extends Spot {

  Dokinchan(float x, float y, float scl) {
    super(x, y, scl);
    // ドキンちゃんはちょっとゆっくりめに動く設定
    speedX = random(-2.2, 2.2);
    speedY = random(-2.2, 2.2);
  }

  // Baikinman と同じく「壁で跳ね返る」move() に上書き
  void move() {
    super.move();
    float r = 270 * scl;
    if (x < r)          { x = r;          speedX = -speedX; }
    if (x > width - r)  { x = width - r;  speedX = -speedX; }
    if (y < r)          { y = r;          speedY = -speedY; }
    if (y > height - r) { y = height - r; speedY = -speedY; }
  }

  void display() {
    pushMatrix();
    translate(x, y);
    scale(scl);

    drawAntenna();   // 1. 触角(1本)
    drawHead();      // 2. オレンジの顔
    drawCheeks();    // 3. ピンクの頬
    drawEyes();      // 4. 緑の大きな目
    drawEyelashes(); // 5. まつげ
    drawNose();      // 6. 小さな赤い鼻
    drawMouth();     // 7. 控えめな笑顔

    popMatrix();
  }

  void drawAntenna() {
    // 中央上から右にしなる触角の棒
    stroke(160, 50, 30);
    strokeWeight(8);
    noFill();
    bezier(5, -260, 25, -310, 50, -340, 65, -350);
    // 先端の小さな丸
    noStroke();
    fill(225, 90, 50);
    ellipse(70, -355, 38, 38);
    stroke(160, 50, 30);
    strokeWeight(5);
    noFill();
    ellipse(70, -355, 38, 38);
  }

  void drawHead() {
    // オレンジの卵型の顔(縦長)
    noStroke();
    fill(225, 90, 50);
    ellipse(0, 0, 500, 540);
    noFill();
    stroke(160, 50, 30);
    strokeWeight(6);
    ellipse(0, 0, 500, 540);
  }

  void drawCheeks() {
    // 頬は左右の 2 つだけ(アンパンマンと違って鼻にはピンクを使わない)
    noStroke();
    fill(255, 180, 180);
    ellipse(-150, 100, 90, 55);
    ellipse( 150, 100, 90, 55);
  }

  void drawEyes() {
    // 白目(縦長の大きな楕円)
    noStroke();
    fill(255);
    ellipse(-95, -30, 100, 140);
    ellipse( 95, -30, 100, 140);
    // 黒い輪郭
    stroke(20);
    strokeWeight(5);
    noFill();
    ellipse(-95, -30, 100, 140);
    ellipse( 95, -30, 100, 140);
    // 緑の虹彩(下寄り)
    noStroke();
    fill(35, 150, 120);
    ellipse(-95, -5, 65, 95);
    ellipse( 95, -5, 65, 95);
    // 白いハイライト(上寄り、小さな丸)
    fill(255);
    ellipse(-110, -40, 22, 26);
    ellipse( 80, -40, 22, 26);
  }

  void drawEyelashes() {
    // 目の外側上に生える 3 本ずつのまつげ
    stroke(20);
    strokeWeight(4);
    noFill();
    // 左目
    line(-150, -85, -180, -110);
    line(-138, -92, -160, -125);
    line(-125, -97, -140, -132);
    // 右目
    line( 150, -85,  180, -110);
    line( 138, -92,  160, -125);
    line( 125, -97,  140, -132);
  }

  void drawNose() {
    // 小さな赤い丸鼻
    noStroke();
    fill(220, 50, 40);
    ellipse(0, 55, 38, 38);
    stroke(120, 30, 20);
    strokeWeight(3);
    noFill();
    ellipse(0, 55, 38, 38);
  }

  void drawMouth() {
    // 小さく上向きの笑み
    stroke(160, 50, 30);
    strokeWeight(5);
    noFill();
    arc(0, 110, 90, 50, 0, PI);
  }
}
