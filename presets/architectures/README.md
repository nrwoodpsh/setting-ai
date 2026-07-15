# presets/architectures — 프로젝트 원형 카탈로그

`/flow:setup`(또는 `/flow:scaffold`)이 새 프로젝트의 **코드 원형**을 만들 때 참조하는 카탈로그. 원형은 **프롬프트로 생성하지 않고** 검증된 템플릿 repo를 **복제**한다(정확성·최신성 보장). 복제 후 `.git` 제거 → 프로젝트 이름·패키지 치환 → flow 문서층(`doc/`·`CLAUDE.md`) 연결.

> flow 코어는 스택 무관이다. 이 카탈로그(특히 eGov)는 **옵션 층**으로, 선택했을 때만 관여한다.

## 카탈로그

| 키 | 아키텍처 | 원형 소스 | 비고 |
|:---|:---|:---|:---|
| `egov-backend` | eGov 백엔드(FE 분리) | `eGovFramework/egovframe-template-simple-backend` | 프론트는 `egovframe-template-simple-react` |
| `egov-homepage` | eGov 단순 홈페이지 | `eGovFramework/egovframe-simple-homepage-template` | 메인·회원·게시판 |
| `egov-enterprise` | eGov 내부업무 | `eGovFramework/egovframe-enterprise-business-template` | 권한·프로그램·메뉴 관리 |
| `egov-portal` | eGov 포털 | `eGovFramework/egovframe-portal-site-template` | 게시판·FAQ·Q&A·설문 |
| `egov-msa` | eGov MSA(클라우드 네이티브) | `eGovFramework/egovframe-msa-edu` | 게이트웨이·디스커버리 등 |
| `spring-monolith` | 범용 Spring 모놀리식 | [Spring Initializr](https://start.spring.io) | eGov 아님. `spring init` 또는 start.spring.io |
| **`custom`** | **내가 지정** | 임의 git URL (사내 스타터·개인 보일러플레이트) | 아래 "커스텀 원형 추가" |
| `none` | 원형 없음 | — | 기존 코드에 flow만 얹음 |

> 공통 기능(253개)이 필요하면 `eGovFramework/egovframe-common-components`를 참조·발췌.

## 복제 절차 (scaffold가 수행)

```bash
# 예: eGov MSA 원형
git clone --depth 1 https://github.com/eGovFramework/egovframe-msa-edu tmp-egov
rm -rf tmp-egov/.git
# tmp-egov 내용을 프로젝트로 복사 → 프로젝트명·groupId·패키지 치환
# 그 뒤 flow 문서층(doc/·CLAUDE.md·workflow.config.json) 생성·연결
```

## 커스텀 원형 추가 (내 스타터 쓰기)

eGov·Spring 말고 **당신 것**을 쓰는 두 방법:

1. **즉석 지정**: `/flow:setup` 실행 중 "원형은 `https://github.com/우리회사/사내-스타터` 로 해줘"처럼 **repo URL을 직접 주면** 그걸 복제한다(같은 절차: clone → `.git` 삭제 → 복사).
2. **카탈로그 등록**: 이 파일 위 표에 한 줄 추가해 팀 표준으로 고정.
   ```
   | our-backend | 사내 백엔드 표준 | github.com/우리회사/backend-starter | 우리 컨벤션 반영 |
   ```
   그러면 다음부터 `/flow:setup`이 그 원형도 후보로 제안한다.

> 요건: 복제해서 그대로 쓸 수 있는 **동작하는 스타터 repo**면 된다(public/사내 git 모두). 사내 private repo면 setup 실행 환경에 git 접근 권한이 있어야 한다.

## 원형 선택 후 flow가 하는 일

1. 원형 복제(위) → 프로젝트에 실제 코드 구조 생김.
2. `workflow.config.json`을 그 스택에 맞게 채움(예: eGov=Java/Maven → `contract.gate`·`test.command`=`./mvnw`/`./gradlew`).
3. `doc/ref/architecture/`에 "이 원형은 egov-msa다 + 주요 모듈 맵"을 기록.
4. `doc/ref/domains/`·`patterns/`를 원형의 실제 구조에서 역추출 제안.

## 주의

- eGov 템플릿은 **Java·버전 호환성**이 있다(예: JDK 8/11/17, eGov 4.x). 복제 후 `workflow.config`의 빌드·테스트 명령이 실제로 도는지 `/setup`이 한 번 실행해 확인한다.
- 라이선스: eGov는 Apache 2.0 계열. 복제 시 원 라이선스·NOTICE 유지.
- 이 카탈로그의 repo·경로는 바뀔 수 있으니, scaffold는 복제 전 존재를 확인한다.
