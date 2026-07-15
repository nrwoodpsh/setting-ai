# 추천 도구 (LSP · MCP) — /setup이 제안하는 것

`/flow:setup`은 스택을 감지해 아래를 **제안**한다. **무단 설치는 하지 않는다** — 설정만 기록하고, 바이너리 설치·크리덴셜 입력은 사용자가 한다(보안).

## LSP (Language Server) — 코드 "의미" 이해

LSP를 붙이면 Claude Code가 grep이 아니라 **타입·정의·참조·실시간 컴파일 에러**로 코드를 이해한다. `/flow:builder`·`/flow:review`의 정확도가 크게 오른다.

| 스택 | LSP 서버 | 설치(사용자) |
|:---|:---|:---|
| **Java/Spring/eGov** | Eclipse JDT (`jdtls`) | JDK + jdtls |
| TypeScript/Node | `typescript-language-server` | `npm i -g typescript-language-server typescript` |
| Python | `pyright` | `npm i -g pyright` (또는 pyright-python) |
| Go | `gopls` | `go install golang.org/x/tools/gopls@latest` |

설정 위치: 프로젝트 `.lsp.json` (또는 플러그인 `lspServers`). `/setup`이 감지 스택에 맞는 항목을 초안으로 써주고, **서버 바이너리가 설치돼 있는지 확인**한 뒤 안내한다.

> eGov/Spring 프로젝트라면 **jdtls를 붙이는 걸 강력 권장** — 계약 게이트(tsc)와 별개로 Java 컴파일 수준 진단을 얻는다.

## MCP (외부 도구 연결)

| MCP | 용도 | 주의 |
|:---|:---|:---|
| **DB (읽기 전용)** | 스키마 조회 → `doc/ref/db-schema` 자동 채움, 설계 시 실제 컬럼 확인 | **읽기 전용**으로. 접속정보는 사용자가 입력. 운영 DB 직접 접속은 CLAUDE.md 가드레일로 금지 |
| **Git** | 브랜치·커밋 메타 조회 | 로컬 git으로 충분한 경우 생략 가능 |
| Filesystem | 특정 외부 경로 접근 | 범위 최소화 |

설정 위치: 프로젝트 `.mcp.json` 또는 `.claude/settings.json`의 `mcpServers`. `/setup`이 **제안 → 사용자 승인 → 설정 기록**. **크리덴셜(DB 접속 등)은 반드시 사용자가 채운다.**

## 발행·통합 (마무리 단계 — `/flow:publish`)

개발 결과를 외부로 내보낼 때.

| 도구 | 용도 | 설정 |
|:---|:---|:---|
| **Notion MCP** ⭐ | 설계·개발 결과를 Notion 페이지로 발행 | `claude mcp add --transport http notion https://mcp.notion.com/mcp` 또는 설정→커넥터→Notion(OAuth) |
| docx·pdf 스킬 | 설계서·결과 문서(Word/PDF) 생성 | Claude Code 내장/마켓 스킬 |
| Slack MCP | 완료·배포 알림 | 설정→커넥터→Slack(OAuth) |
| google-drive MCP | 산출물 저장·공유 | claude.ai 커넥터 경유 권장 |

> 커뮤니티 스킬(content-repurposing 등)은 실존·소속이 확인되지 않아, 이 워크플로우는 **공식 커넥터·문서 스킬만** 채택한다. 발행처·크리덴셜은 사용자가 설정.

### Notion 연결 (한 번, 수동)

`/flow:publish`를 쓰려면 Notion MCP가 연결돼 있어야 한다. **인증은 AI가 대신 못 한다**(당신 워크스페이스 접근 허가 = 보안).

1. **연결**: OAuth(설정→커넥터→Notion) 또는 `claude mcp add --transport http notion https://mcp.notion.com/mcp`. 야간 자동 발행(헤드리스)이면 **API 토큰 방식** 필요.
2. **공유(닻)**: 통합은 **공유된 부모(DB/페이지) 안에서만** 쓸 수 있다. 발행할 부모를 통합에 공유하고, 그 ID를 `workflow.config.json`의 `publish.notionParent`에 둔다(없으면 첫 발행 때 물어보고 저장).
3. 이후 `/flow:publish`는 그 부모 아래에 **도메인/기능별 페이지를 없으면 생성·있으면 갱신**한다(지정 불필요).

## 원칙

- **제안하되 강요·무단설치 금지.** 설정은 심되, 바이너리·비밀정보는 사람이.
- MCP는 **세션당 컨텍스트 토큰을 먹는다** — 실제로 쓸 것만 켠다.
- eGov 기본 추천: **LSP=jdtls**, **MCP=DB 읽기전용**(스키마) + (선택)Git.
