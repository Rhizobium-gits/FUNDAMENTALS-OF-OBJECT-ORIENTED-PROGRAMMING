// 3体まとめて扱うので配列に入れておく。
// Anpanman[] は「Anpanman型のインスタンスを入れる箱が並んだもの」。
Anpanman[] anpans = new Anpanman[3];

void setup() {
  size(960, 360);
  smooth();
  noLoop();

  // 3 回 new することで、独立した 3 つのインスタンスが生まれる。
  //   中心間隔を 320 px にすれば、顔どうしの隙間は 320 - 297 = 23 px 確保される
  float scl = 0.55;
  float y   = 180;
  anpans[0] = new Anpanman(160, y, scl);   // 左
  anpans[1] = new Anpanman(480, y, scl);   // 中央
  anpans[2] = new Anpanman(800, y, scl);   // 右
}

void draw() {
  background(255);

  // 配列に入った 3 つのインスタンスに、順番に display() メッセージを送る。
  for (int i = 0; i < anpans.length; i++) {
    anpans[i].display();
  }
}

class Anpanman {

  Anpanman(float cx, float cy, float s) {
    this.cx = cx;
    this.cy = cy;
    this.s = s;
  }

  void display() {
    pushMatrix();
    translate(cx, cy);  
    scale(s);  

    drawFace();
    drawRedCircles();
    drawOutlineOverlay();
    drawHighlights();
    drawEyebrows();
    drawEyes();
    drawMouth();

    popMatrix();
  }

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
