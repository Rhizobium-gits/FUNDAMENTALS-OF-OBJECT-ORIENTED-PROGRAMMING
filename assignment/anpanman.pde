void setup() {
  size(600, 600);
  smooth();
  noLoop();
}

void draw() {
  background(255);
  translate(width / 2, height / 2);

  // === 1. 顔 ===
  float faceR = 270;
  noStroke();
  fill(190, 140, 65);
  ellipse(0, 0, faceR * 2, faceR * 2);
  noFill();
  stroke(50, 35, 15);
  strokeWeight(6);
  ellipse(0, 0, faceR * 2, faceR * 2);

  // === 2. 赤い丸3つ ===
  float cheekR = 82;
  float noseR = 75;
  float noseY = 60;
  float spacing = 128;

  noStroke();
  fill(205, 35, 30);
  ellipse(-spacing, noseY, cheekR * 2, cheekR * 2);
  ellipse(0, noseY, noseR * 2, noseR * 2);
  ellipse(spacing, noseY, cheekR * 2, cheekR * 2);

  // === 3. 輪郭（外側のみ） ===
  stroke(50, 35, 15);
  strokeWeight(5.5);
  noFill();

  // 左ほっぺと鼻の交差角度
  // 2円の交差: d=spacing, r1=cheekR, r2=noseR
  // 左ほっぺ側の角度: cos(a) = (d^2 + r1^2 - r2^2) / (2*d*r1)
  float d = spacing;
  float cosA_L = (d * d + cheekR * cheekR - noseR * noseR) / (2.0 * d * cheekR);
  float cutL = acos(cosA_L);
  // 鼻側の角度: cos(a) = (d^2 + r2^2 - r1^2) / (2*d*r2)
  float cosA_N = (d * d + noseR * noseR - cheekR * cheekR) / (2.0 * d * noseR);
  float cutN = acos(cosA_N);

  // 左ほっぺ（右側を除外）
  arc(-spacing, noseY, cheekR * 2, cheekR * 2, cutL, TWO_PI - cutL);
  // 鼻（左右を除外）
  arc(0, noseY, noseR * 2, noseR * 2, PI + cutN, TWO_PI - cutN);  // 上弧
  arc(0, noseY, noseR * 2, noseR * 2, cutN, PI - cutN);            // 下弧
  // 右ほっぺ（左側を除外）
  arc(spacing, noseY, cheekR * 2, cheekR * 2, PI + cutL, PI + TWO_PI - cutL);

  // === 4. 白い四角ハイライト ===
  noStroke();
  fill(255);
  float sq = 16;
  rect(-spacing + 15, noseY - 24, sq, sq);
  rect(0 + 12, noseY - 22, sq, sq);
  rect(spacing + 15, noseY - 24, sq, sq);

  // === 5. 眉毛（太めのアーチ） ===
  stroke(50, 35, 15);
  strokeWeight(5.5);
  noFill();
  arc(-68, -75, 72, 70, -PI + 0.2, -0.2);
  arc(68, -75, 72, 70, PI + 0.2, TWO_PI - 0.2);

  // === 6. 目（大きめの縦長楕円） ===
  noStroke();
  fill(15);
  ellipse(-68, -30, 28, 44);
  ellipse(68, -30, 28, 44);

  // === 7. 口 ===
  // 赤丸の下寄りを横切る。両端がほっぺの内側あたり
  stroke(50, 35, 15);
  strokeWeight(5);
  noFill();
  arc(0, noseY + 70, 210, 80, 0.12, PI - 0.12);
}
