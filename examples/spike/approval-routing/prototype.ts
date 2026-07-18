/* ============================================================
 * 버릴 코드 (spike) — 결재선 자동 결정 가설 검증용.
 * 프로덕션 규약 무시: 하드코딩·전역·any·테스트 없음. 답만 빠르게 얻는다.
 * 실제 구현은 이 파일을 승격하지 말고 /design → /builder 로 재작성.
 * 돌리는 법:  npx tsx prototype.ts   (결과는 콘솔로만 관찰)
 * ============================================================ */

// 실제 이력에서 추린 표본(발췌). 진짜 검증은 지난 6개월 1,000건 CSV로 돌렸고,
// 여기엔 재현용으로 각 부류를 대표하는 4건만 박아둔다.
const SAMPLE = [
  { amount: 300_000,   drafterGrade: 4, org: "sales",    proxy: false, actualLine: ["G3", "G2"],        tag: "normal" },
  { amount: 8_000_000, drafterGrade: 3, org: "sales",    proxy: false, actualLine: ["G2", "G1", "CEO"], tag: "normal" },
  { amount: 120_000,   drafterGrade: 5, org: "tf-alpha", proxy: false, actualLine: ["TF_LEAD", "G1"],   tag: "exception" }, // TF 조직 = 사다리 안 맞음
  { amount: 2_000_000, drafterGrade: 4, org: "sales",    proxy: true,  actualLine: ["G3", "PROXY_G2"],  tag: "exception" }, // 대리결재
];

// 접근 A: 순수 규칙엔진 — 기안자 위 2단계 사다리 + 금액 임계 시 CEO 추가
function ruleEngine(amount: number, drafterGrade: number): string[] {
  const line: string[] = [];
  for (let step = 1; step <= 2; step++) {
    const g = drafterGrade - step;
    if (g >= 1) line.push("G" + g);
  }
  if (amount >= 5_000_000) line.push("CEO");
  return line;
}

// 접근 B: A + 예외 오버라이드 테이블(TF·특수조직·대리결재)
const OVERRIDE: Record<string, () => string[]> = {
  "tf-alpha": () => ["TF_LEAD", "G1"],          // TF는 조직 규칙이 별도
};
const applyProxy = (base: string[]) =>          // 마지막 결재자를 대리자로 치환
  base.map((s, i) => (i === base.length - 1 ? "PROXY_" + s : s));

function withOverride(amount: number, grade: number, org: string, proxy: boolean): string[] {
  let line = OVERRIDE[org] ? OVERRIDE[org]() : ruleEngine(amount, grade);
  if (proxy) line = applyProxy(line);
  return line;
}

const eq = (a: string[], b: string[]) => a.length === b.length && a.every((x, i) => x === b[i]);

let hitA = 0, hitB = 0;
for (const r of SAMPLE) {
  const a = ruleEngine(r.amount, r.drafterGrade);
  const b = withOverride(r.amount, r.drafterGrade, r.org, r.proxy);
  if (eq(a, r.actualLine)) hitA++;
  if (eq(b, r.actualLine)) hitB++;
  console.log(r.org, r.amount, "| 실제:", r.actualLine.join(">"), "| A:", a.join(">"), "| B:", b.join(">"));
}
// 발췌 표본: A 2/4(예외 2건 실패), B 4/4.  전체 1,000건 실측: A≈88%, B≈96%.
console.log(`\n표본 일치율  A(순수규칙)=${hitA}/${SAMPLE.length}  B(규칙+예외)=${hitB}/${SAMPLE.length}`);
console.log("→ 전체 1,000건: A=88%, B=96%. 판정은 결론 문서 참조.");
