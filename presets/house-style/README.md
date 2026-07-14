# presets/house-style — 스택 프리셋 (씨앗)

> 3층 중 **② 스택 프리셋층**. 새 프로젝트의 `doc/ref/patterns/`로 **복사해서 시작하는 씨앗**이다. 여기 있는 것은 AI가 직접 참조하는 정본이 아니다 — 복사 후 프로젝트 실제 코드에 맞게 조정된 로컬본이 정본이다.

## house-style이란

당신(팀)의 **주력 스택 표준**을 담는 자리다. 스택을 하나만 쓰면 프리셋도 이 하나면 충분하다. 실제로 다른 스택 프로젝트가 생기면 그때 `presets/<다른-스택>/`를 추가한다. (미리 멀티스택을 짓지 말 것 — 유지보수 낭비.)

## 채워 넣을 것 (당신 주력 스택 기준)

이 폴더에 아래를 당신 표준으로 작성해 두면, 새 프로젝트가 복사만 하면 된다:

```
presets/house-style/
├── patterns/
│   ├── api-contract/     — 계약 골격 (스택 언어로)
│   ├── task-doc/         — 설계 문서 골격
│   ├── layout/           — 폴더 구조·계층 규약
│   └── error-handling/   — 에러 봉투·핸들러 골격
├── CLAUDE.md             — 스택 고정값이 채워진 CLAUDE.md 초안
└── workflow.config.json   — 스택에 맞는 contract.gate·test.command
```

> 지금은 비어 있다. 첫 실전 프로젝트를 워크플로우로 진행하면서 잘 정리된 패턴을 이곳으로 역추출(extract)하면, 두 번째 프로젝트부터 복사로 시작할 수 있다.

## 새 프로젝트 세팅 순서

```bash
# 1) 프로젝트 템플릿 복사
cp -r <이 repo>/project-template/. ./my-project/

# 2) house-style 프리셋을 patterns 정본으로 복사 (준비돼 있으면)
cp -r <이 repo>/presets/house-style/patterns/. ./my-project/doc/ref/patterns/

# 3) 워크플로우 플러그인 설치
#    (my-project에서 Claude Code 실행 후)
#    /plugin marketplace add <이 repo 경로 또는 nrwoodpsh/setting-ai>
#    /plugin install flow@setting-ai --scope project

# 4) CLAUDE.md·workflow.config.json을 이 프로젝트에 맞게 채움
```
