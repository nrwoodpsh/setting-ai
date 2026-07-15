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

## CI·스케줄 (헤드리스 flow 호출) — 선택

- **PR 리뷰 게이트**: GitHub Actions에서 `claude -p "/flow:review 이 diff"` → 코멘트.
- **야간/완료 발행**: 스케줄 → `claude -p "/flow:publish"` → Notion.
- 제약: CI에 API 인증 필요, 대화형 OAuth MCP(Notion 등)는 헤드리스에서 토큰 방식 인증 필요, 실행마다 토큰 비용. **무인 커밋 금지** — 리포트/PR까지만.
