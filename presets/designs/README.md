# presets/designs — 디자인 스펙 소스 (`/flow:theme`)

`/flow:theme`가 적용하는 디자인 시스템 스펙(토큰 + 컴포넌트). 두 소스:

> **정확도가 중요하면 ② 로컬 다운로드 권장** — 온라인 자동(①)은 웹 변환 과정에서 토큰이 부정확할 수 있다.

## ① getdesign.md (온라인 카탈로그, 75+)

AI 에이전트용 디자인 스펙 제공 서비스.
- **목록**: `https://getdesign.md/design-md` (apple·stripe·figma·notion·claude·shopify·slack·spotify …)
- **개별**: `https://getdesign.md/{brand}/design-md`
- `/flow:theme`가 목록을 fetch해 고르게 하고, 선택한 스펙을 읽어 토큰을 추출한다.

## ② 로컬 파일 (권장·정확)

- getdesign.md 사이트에서 `DESIGN.md`를 **직접 다운로드** → 프로젝트 **`doc/ref/theme/`**에 넣기 → `/flow:theme @doc/ref/theme/DESIGN-x.md`
- 사내 디자인시스템을 이 형식의 md로 만들어 `doc/ref/theme/`에 두면 **팀 표준 테마**.
- **원문 그대로라 토큰이 정확** — 온라인 자동(①)보다 신뢰도 높음.

## 스펙 형식 (getdesign.md 표준)

frontmatter에 토큰과 컴포넌트:
```yaml
colors:     { primary: "#0066cc", ink: "#1d1d1f", canvas: "#ffffff", ... }
typography: { hero-display: {fontFamily, fontSize, fontWeight, lineHeight, letterSpacing}, body: {...} }
rounded:    { sm: 8px, lg: 18px, pill: 9999px }
spacing:    { xs: 8px, lg: 24px, section: 80px }
components: { button-primary: { backgroundColor: "{colors.primary}", rounded: "{rounded.pill}", ... } }
```
+ 본문에 Overview·Do/Don't·Responsive 등 원칙. (예: Apple 스펙 — 토큰 참조 `{colors.primary}` 형식)

## 적용 범위 (theme의 3-tier)

| Tier | 무엇 | theme가 하는 것 |
|:---|:---|:---|
| **1. 토큰** | 색·타이포·radii·spacing | ✅ **전면 자동** — CSS vars / Tailwind / MUI 테마 생성 |
| **2. 컴포넌트** | button·card·input·nav 룩 | 🟡 **핵심 반자동** — 프로젝트 컴포넌트에 매핑 |
| **3. 구조** | 레이아웃·IA 재설계 | ❌ **안 함** — 원칙만 `doc/ref/patterns`에 참고 기록 |

> 독점 폰트(SF Pro 등)는 대체 폰트(Inter 등)로. 정부 서비스면 KRDS 표준 충돌 주의.
