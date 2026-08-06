export const meta = {
  name: 'spec-verify-loop',
  description: '도메인/버전 단위 화면설계 검증 루프 — 기계검증 게이트 + 7축 셀프검토 병렬 교차검증 + 적대적 환각 제거. 탐지·제안만(docs 자동수정 없음), 구조화 리포트 반환.',
  whenToUse: '한 기획 사이클(요구사항→프로토타입→docs→화면설계서)을 돈 뒤, 그 도메인이 정상적으로 진행됐는지 자동 교차검증할 때.',
  phases: [
    { title: '기계검증', detail: 'scripts/check-docs.sh 실행·파싱' },
    { title: '교차검증', detail: '7개 검증축 병렬 탐지(deep 모드는 loop-until-dry)' },
    { title: '적대적 검증', detail: '지적마다 3개 독립 회의자가 반증 시도 → 환각 제거' },
  ],
}

// ── 입력 ─────────────────────────────────────────────────────────────
// args = { domain: "USER", version?: "v0.2", thoroughness?: "normal"|"deep" }
// (하니스가 args 를 JSON 문자열로 넘기는 경우도 있어 방어적으로 파싱)
let A = args
if (typeof A === 'string') {
  try { A = JSON.parse(A) } catch (e) { A = {} }
}
A = A || {}
const domain = A.domain || null
const version = A.version || null
const thoroughness = A.thoroughness || 'normal'
if (!domain) {
  throw new Error('spec-verify-loop: args.domain 필수 (예: {domain:"USER"}). 사이클 단위는 도메인/버전.')
}
const scope = version ? `도메인 ${domain} / 버전 ${version}` : `도메인 ${domain}`

// ── 스키마 ───────────────────────────────────────────────────────────
const MACHINE_SCHEMA = {
  type: 'object',
  additionalProperties: false,
  required: ['pass', 'fails', 'warns'],
  properties: {
    pass: { type: 'boolean', description: 'check-docs.sh 종료코드 0 이면 true' },
    fails: {
      type: 'array',
      items: {
        type: 'object', additionalProperties: false, required: ['section', 'message'],
        properties: { section: { type: 'string' }, message: { type: 'string' } },
      },
    },
    warns: {
      type: 'array',
      items: {
        type: 'object', additionalProperties: false, required: ['section', 'message'],
        properties: { section: { type: 'string' }, message: { type: 'string' } },
      },
    },
  },
}

const FINDINGS_SCHEMA = {
  type: 'object',
  additionalProperties: false,
  required: ['findings'],
  properties: {
    findings: {
      type: 'array',
      items: {
        type: 'object', additionalProperties: false,
        required: ['dim', 'file', 'line', 'excerpt', 'reason', 'severityGuess'],
        properties: {
          dim: { type: 'string', description: '검증축 키' },
          file: { type: 'string', description: '파일 경로(저장소 루트 기준)' },
          line: { type: 'string', description: '줄 번호 또는 범위. 모르면 "?"' },
          excerpt: { type: 'string', description: '문제가 된 원문 인용(짧게)' },
          reason: { type: 'string', description: '왜 문제인지 한 문장' },
          severityGuess: { type: 'string', enum: ['🔴', '🟡', '🟢'] },
        },
      },
    },
  },
}

const VERDICT_SCHEMA = {
  type: 'object',
  additionalProperties: false,
  required: ['real', 'severity', 'fix', 'confidence'],
  properties: {
    real: { type: 'boolean', description: '지적이 실재하면 true. 불확실하면 false(=반증).' },
    severity: { type: 'string', enum: ['🔴', '🟡', '🟢'] },
    fix: { type: 'string', description: '구체적 수정안(적용은 사람이 함). real=false 면 빈 문자열.' },
    confidence: { type: 'number', description: '0~1' },
  },
}

// ── 7개 검증축 (방법론 README.md "Phase 2 — 셀프 검토 프롬프트" 단일 진실) ──
const DIMS = [
  { key: '미정의 용어', probe: 'glossary.md 에 없는데 본문에 쓰인 용어. 표기 흔들림(같은 개념 다른 표기)도.' },
  { key: '문서 간 모순', probe: '같은 항목이 두 문서에서 다른 값/규칙으로 적힌 곳. 단일 진실 위반(같은 값이 두 곳에 복제).' },
  { key: '빠진 상태', probe: 'SCR 상태 매트릭스에서 정상 외 로딩·빈·에러·권한·오프라인 정의 누락. (적용불가는 N/A 명시면 OK)' },
  { key: '빠진 범위', probe: 'PRD Out of scope 에 명시 안 된 모호한 영역. "이번엔 안 함"이 안 적힌 경계.' },
  { key: '검증불가 표현', probe: "'빠르게·자연스럽게·직관적으로·적절히' 류 막연한 표현. 숫자·동작으로 바꿔야 할 곳." },
  { key: '빠진 비기능', probe: '성능·접근성·보안·다국어·데이터 보관/삭제 정의 누락.' },
  { key: '추적 끊김', probe: 'REQ ↔ SCR ↔ TC 매핑 누락. POL 에 사유·적용시점 누락. FLOW 분기·예외 행 누락.' },
]

const key = (f) => `${f.dim}|${f.file}|${f.line}|${String(f.excerpt).slice(0, 40)}`

// ── Phase 1 — 기계검증 게이트 ─────────────────────────────────────────
phase('기계검증')
const machineGate = await agent(
  `\`bash scripts/check-docs.sh\` 를 저장소 루트에서 실행하고 출력을 구조화하라.\n` +
  `- 줄 앞에 빨간 ✗ 표시(miss/실패) → fails 에. 노란 ! 표시(warn) → warns 에.\n` +
  `- 각 항목은 직전 "== N. 섹션명 ==" 헤더를 section 으로, 메시지 본문을 message 로.\n` +
  `- 마지막 줄이 "ALL GREEN" 이면 pass=true, "FAILED" 면 pass=false.\n` +
  `이 도메인(${scope})과 무관한 항목도 전역 게이트이므로 모두 포함하라.`,
  { label: 'machine:check-docs', phase: '기계검증', schema: MACHINE_SCHEMA },
)

// ── Phase 2 — 교차검증 fan-out (7축 병렬, deep 면 loop-until-dry) ──────
phase('교차검증')
const finderPrompt = (d) =>
  `너는 기획 문서 검증 전문가다. 검증 범위: ${scope}.\n` +
  `오직 한 축만 본다 → 「${d.key}」: ${d.probe}\n\n` +
  `읽을 것(존재하는 것만): 해당 도메인의 docs/domains/${domain}/ 하위 REQ·POL·SCR·TC, ` +
  `없으면 평탄 구조 docs/REQ.md·docs/POL.md·docs/screens/·docs/TC.md·docs/flows/ 중 이 도메인 관련분, ` +
  `그리고 공통 docs/glossary.md·docs/IA.md·docs/PRD.md·docs/_labels.md, ` +
  `매칭되는 prototype/*.designspec.html(있으면).\n\n` +
  `철칙: 추측해서 만들지 마라. 실제 문서에 근거가 있는 지적만 낸다. ` +
  `근거가 약하면 내지 마라(다음 단계에서 적대적으로 검증된다). ` +
  `각 지적에 정확한 file·line·원문 excerpt 를 붙여라. 모르는 line 은 "?".\n` +
  `이 축에 해당하는 문제가 없으면 findings: [] 를 반환하라(없는 문제를 지어내지 마라).`

const MAX_ROUNDS = thoroughness === 'deep' ? 4 : 1
const seen = new Set()
const fresh = []
let dry = 0
for (let round = 0; round < MAX_ROUNDS && dry < 2; round++) {
  const batch = (
    await parallel(
      DIMS.map((d) => () =>
        agent(finderPrompt(d), {
          label: `find:${d.key}${round > 0 ? `#${round + 1}` : ''}`,
          phase: '교차검증',
          schema: FINDINGS_SCHEMA,
        }),
      ),
    )
  )
    .filter(Boolean)
    .flatMap((r) => r.findings || [])

  const newOnes = batch.filter((f) => !seen.has(key(f)))
  if (newOnes.length === 0) {
    dry++
    log(`교차검증 라운드 ${round + 1}: 신규 0건 (dry ${dry}/2)`)
    continue
  }
  dry = 0
  newOnes.forEach((f) => seen.add(key(f)))
  fresh.push(...newOnes)
  log(`교차검증 라운드 ${round + 1}: 신규 ${newOnes.length}건 (누적 ${fresh.length})`)
}

// ── Phase 3 — 적대적 교차검증 (배리어: dedup 완료 후 일괄) ─────────────
phase('적대적 검증')
const LENSES = [
  { key: '근거-존재', ask: '인용된 excerpt 가 그 file 에 실제로 존재하고, 지적이 그 원문에서 직접 도출되는가? 없거나 오독이면 반증하라.' },
  { key: '단일진실-위반', ask: '이것이 방법론 5대 원리(단일 진실·ID 추적·모든 상태·Out of scope·GWT) 위반으로 실재하는가, 아니면 정상 표현을 과잉 지적한 것인가?' },
  { key: '추적-실재', ask: '추적/매핑/누락 지적이라면, 정말 누락인가 아니면 다른 문서·INDEX·N/A 명시로 이미 충족됐는가? 충족됐으면 반증하라.' },
]
const refutePrompt = (f, lens) =>
  `다음 검증 지적을 ${lens.key} 관점에서 반증(refute)하라. 기본 태도는 회의적이다 — 확신이 없으면 real=false.\n` +
  `${lens.ask}\n\n` +
  `[지적] 축=${f.dim} / 파일=${f.file}:${f.line}\n원문: ${f.excerpt}\n사유: ${f.reason}\n\n` +
  `실제 파일을 열어 확인하라. real=true 면 등급(🔴 사람 결정 필요 / 🟡 보강 / 🟢 경미)과 구체적 수정안(fix)을 제시하라(적용은 사람이 한다). real=false 면 fix 는 빈 문자열.`

const verified = await parallel(
  fresh.map((f) => () =>
    parallel(
      LENSES.map((lens) => () =>
        agent(refutePrompt(f, lens), {
          label: `verify:${f.dim}@${f.file}`,
          phase: '적대적 검증',
          schema: VERDICT_SCHEMA,
        }),
      ),
    ).then((votes) => ({ f, votes: votes.filter(Boolean) })),
  ),
)

// ── Phase 4 — 종합 ───────────────────────────────────────────────────
const confirmed = []
const dropped = []
for (const v of verified.filter(Boolean)) {
  const yes = v.votes.filter((x) => x && x.real)
  if (yes.length >= 2) {
    // 등급: 회의자들이 매긴 severity 중 가장 심각한 것 채택(🔴>🟡>🟢)
    const order = { '🔴': 3, '🟡': 2, '🟢': 1 }
    const severity = yes.map((x) => x.severity).sort((a, b) => order[b] - order[a])[0] || v.f.severityGuess
    const fix = (yes.find((x) => x.fix) || {}).fix || ''
    confirmed.push({ ...v.f, severity, fix, votesReal: yes.length, votesTotal: v.votes.length })
  } else {
    dropped.push({ ...v.f, votesReal: yes.length, votesTotal: v.votes.length })
  }
}

const order = { '🔴': 3, '🟡': 2, '🟢': 1 }
confirmed.sort((a, b) => order[b.severity] - order[a.severity])
const reds = confirmed.filter((c) => c.severity === '🔴').length
const ylws = confirmed.filter((c) => c.severity === '🟡').length
const grns = confirmed.filter((c) => c.severity === '🟢').length

let verdict
if (machineGate && machineGate.pass && confirmed.length === 0) verdict = 'GREEN'
else if (reds > 0) verdict = `사람 결정 필요 ${reds}건` + (ylws + grns ? ` (+보강 ${ylws}·경미 ${grns})` : '')
else verdict = `보강 ${ylws}·경미 ${grns}건` + (machineGate && !machineGate.pass ? ' + 기계검증 FAIL' : '')

log(`검증 완료 — 게이트: ${verdict} / 확정 ${confirmed.length}건, 환각 제거 ${dropped.length}건`)

return {
  domain,
  version,
  scope,
  thoroughness,
  machineGate,
  verdict,
  summary: { red: reds, yellow: ylws, green: grns, confirmed: confirmed.length, dropped: dropped.length },
  confirmed,
  dropped,
}
