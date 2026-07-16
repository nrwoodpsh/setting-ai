# automation — 헤드리스·이벤트 자동화 (플러그인과 별도 층)

flow 플러그인(대화형)을 **재사용**하는 자동화 층. 플러그인 자체가 아니라, git 이벤트·CI·스케줄이 flow를 부르거나 결정론적으로 게이트한다.

## git-hooks/ — 드리프트 체크 (`drift-hook.sh`, config로 모드 선택)

`workflow.config.json`의 **`drift.mode`**로 동작을 고른다. 하나의 스크립트(`drift-hook.sh`)를 `.git/hooks/`의 **pre-commit·post-commit·pre-push 3개 이름**으로 설치하면, **config만 바꿔도 재설치 없이** 모드가 바뀐다. 누가 커밋/푸시하든(Sourcetree·IDE·CLI) 발화하는 **실제 git 훅** — 결정론적(AI·비용 없음, `autosync` 제외).

| `drift.mode` | 동작 | 발화 stage |
|:---|:---|:---|
| `off` | 아무것도 안 함 | — |
| **`warn`** *(기본)* | 소스만 반영되고 문서 안 맞으면 **알림만**(비차단) | 커밋 직후 (post-commit) |
| `block` | 소스만 있으면 **push 차단** (우회: `git push --no-verify`) | push 직전 (pre-push) |
| `autosync` *(실험적)* | `claude -p`로 문서 동기화해 **같은 커밋에 포함** — 느림·토큰비용, `claude` CLI·인증 필요 | 커밋 전 (pre-commit) |

판정: 소스(= `doc/` 밖·`.md` 아님) 변경이 있는데 `doc/design`·`doc/summary`가 없으면 드리프트.

### 설치 — `/flow:setup`이 자동으로
`/flow:setup`이 `drift-hook.sh`를 3개 훅 이름으로 복사·실행권한 부여한다(**수동 불필요**). 수동:
```bash
H=~/.claude/plugins/marketplaces/setting-ai/automation/git-hooks/drift-hook.sh
for h in pre-commit post-commit pre-push; do cp "$H" ".git/hooks/$h"; chmod +x ".git/hooks/$h"; done
```
모드 변경은 프로젝트 `workflow.config.json`의 `drift.mode`만 고치면 된다(재설치 X).

### git 훅은 clone마다 필요 (보안상 자동공유 안 됨)
- **정석**: `/flow:setup`이 각 clone에서 설치(팀원도 setup 시 함께).
- **공유 강화**: `.githooks/`에 두고 `git config core.hooksPath .githooks`(setup이 설정) → 파일은 git으로 공유, 활성화만 clone당 1회.
- husky·pre-commit(framework)을 이미 쓰면 그쪽에 등록해도 된다.

## 버전 관리 (플러그인 배포 — 이 setting-ai repo에서만)

**설치측 캐시 키가 버전**이다(`cache/setting-ai/flow/<버전>/`). 내용을 바꿔도 **버전이 그대로면** `/plugin marketplace update`가 "이미 있음"으로 보고 **재복사를 안 한다.** → **플러그인을 바꾸면 반드시 버전 업.**

**버전은 두 파일에 같은 값**: `plugins/flow/.claude-plugin/plugin.json` + `.claude-plugin/marketplace.json`(flow 항목). 손으로 두 곳 맞추면 실수하므로 스크립트로:

```bash
scripts/bump-version.sh minor    # 기능 추가 (0.2.0 → 0.3.0)  ← 두 파일 원자적으로
scripts/bump-version.sh patch    # 수정      (0.2.0 → 0.2.1)
scripts/bump-version.sh major    # 깨지는 변경 (0.2.0 → 1.0.0)
git commit -am "chore: bump flow <새버전>" && git push
```

**까먹음 방지 (pre-push 가드)** — `plugins/flow/**`가 바뀌었는데 버전이 안 올랐으면 **push를 막는다**:
```bash
# setting-ai repo에서 1회 설치:
cp automation/git-hooks/pre-push-version-guard .git/hooks/pre-push && chmod +x .git/hooks/pre-push
```
> 이 가드는 **플러그인 소스(setting-ai) repo 전용**이다(consumer 프로젝트의 drift-hook과 별개). 우회: `git push --no-verify`.

**흐름**: 플러그인 수정 → `bump-version.sh minor` → commit·push → 설치측 `/plugin marketplace update setting-ai` + `/reload-plugins`로 반영.

## CI·스케줄 (헤드리스 flow 호출) — 선택

- **PR 리뷰 게이트**: GitHub Actions에서 `claude -p "/flow:review 이 diff"` → 코멘트.
- **드리프트 게이트(서버사이드)**: 로컬 `drift-hook`은 `git push --no-verify`로 우회되니, PR에서 한 번 더 막고 싶으면 Actions로. 코드 변경이 있는데 `doc/summary/` 갱신이 없으면 실패 — 로컬 훅(우회 가능) + 이 게이트(우회 불가)로 이중 방어.
  ```yaml
  # .github/workflows/drift-gate.yml
  name: Drift Gate
  on: pull_request
  jobs:
    check:
      runs-on: ubuntu-latest
      steps:
        - uses: actions/checkout@v4
          with: { fetch-depth: 0 }
        - name: 코드 변경엔 doc/summary 동반 확인
          run: |
            BASE=${{ github.event.pull_request.base.sha }}
            HEAD=${{ github.event.pull_request.head.sha }}
            CODE=$(git diff --name-only $BASE $HEAD | grep -Ev '^(doc/|\.claude/|\.github/|.*\.md$)' | wc -l)
            SUM=$(git diff --name-only $BASE $HEAD | grep -E '^doc/summary/' | wc -l)
            if [ "$CODE" -gt 0 ] && [ "$SUM" -eq 0 ]; then
              echo "::error::코드 변경이 있으나 doc/summary/ 갱신 없음. /flow:sync 실행 후 다시 푸시."; exit 1
            fi
  ```
- **야간/완료 발행**: 스케줄 → `claude -p "/flow:publish"` → Notion.
- 제약: CI에 API 인증 필요, 대화형 OAuth MCP(Notion 등)는 헤드리스에서 토큰 방식 인증 필요, 실행마다 토큰 비용. **무인 커밋 금지** — 리포트/PR까지만.
- (선택) 완전 자동 버전업: push 시 GitHub Action이 `plugins/flow` 변경 감지해 자동 bump — 봇 커밋이 생기니, 위 pre-push 가드 + 수동 bump가 더 단순·권장.
