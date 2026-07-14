# task-{name}-{YYYYMMDD}.md

> `/design` 산출물. 자연어 설계만 담는다. 타입·Endpoint·에러코드는 계약 파일이 정본이므로 여기 중복 작성 금지.

## 1. Requirements

- **Scenario**: {{어떤 상황에서 누가 무엇을 하는가}}
- **Objective**: {{이 작업이 달성하려는 것}}
- **Acceptance Criteria** (측정 가능, 3개 이상):
  - [ ] AC1: {{예: 목록 API가 200ms 이내 응답}}
  - [ ] AC2: {{예: 잘못된 파라미터 시 EX002 반환}}
  - [ ] AC3: {{...}}

## 2. UI/UX (해당 시)

{{레이아웃·인터랙션·상태 흐름}}

## 3. Logic

{{핵심 알고리즘·계산식·쿼리 개요. 자연어 + 필요 시 의사코드}}

## 4. Implementation Split (해당 시)

- **BE**: {{책임}}
- **FE**: {{책임}}

## 5. File Map

- `[New] {{경로}}` — {{역할}}
- `[Mod] {{경로}}` — {{변경 내용}}

## 6. Verification

- 명령: {{예: `npm test -- example`}}
- 통과 조건: Exit 0, {{AC 매핑}}

## 7. History

| 일시 | 단계 | 내용 |
|:---|:---|:---|
| {{YYYYMMDD HH:MM}} | /design | 최초 설계 |
