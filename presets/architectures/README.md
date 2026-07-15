# presets/architectures — 프로젝트 원형 카탈로그

`/flow:setup`(또는 `/flow:scaffold`)이 새 프로젝트의 **코드 원형**을 만들 때 참조하는 카탈로그. 원형은 **프롬프트로 생성하지 않고** 검증된 템플릿 repo를 **복제**한다(정확성·최신성 보장). 복제 후 `.git` 제거 → 프로젝트 이름·패키지 치환 → flow 문서층(`doc/`·`CLAUDE.md`) 연결.

> flow 코어는 스택 무관이다. 이 카탈로그(특히 eGov)는 **옵션 층**으로, 선택했을 때만 관여한다.

## 원형 카탈로그 (복제해 시작 — `/flow:setup`이 쓰는 키)

| 키 | 아키텍처 | 원형 소스 | 비고 |
|:---|:---|:---|:---|
| **`egov-msa`** ⭐ | **eGov MSA (클라우드 네이티브)** | `eGovFramework/egovframe-msa-edu` (164★) | Spring Boot **10 서비스**(Gateway·Eureka·Config·User·Portal·Board·Reserve×3) + Next.js/TS + **Docker·K8s** + MySQL·RabbitMQ·ELK·Zipkin·JWT |
| **`egov-msa-cc`** | eGov MSA (**신규·컴포넌트 풍부**) | `eGovFramework/egovframe-msa-common-components` (8★) | **Spring Boot 3.5.6 · Java 17 · Spring Cloud 2025** + 공통컴포넌트 23+3(Login·Author·Board·Search·Questionnaire·MobileId·Main) + KRDS. **신규 프로젝트 권장** |
| `egov-backend` | eGov 백엔드(FE 분리) | `eGovFramework/egovframe-template-simple-backend` (97★) | 프론트 `egovframe-template-simple-react`(261★) |
| `egov-homepage` | eGov 단순 홈페이지 | `eGovFramework/egovframe-simple-homepage-template` | 메인·회원·게시판 |
| `egov-enterprise` | eGov 내부업무 | `eGovFramework/egovframe-enterprise-business-template` | 권한·프로그램·메뉴 관리 |
| `egov-portal` | eGov 포털 | `eGovFramework/egovframe-portal-site-template` | 게시판·FAQ·Q&A·설문 |
| `spring-monolith` | 범용 Spring 모놀리식 | [Spring Initializr](https://start.spring.io) | eGov 아님. `spring init` 또는 start.spring.io |
| **`custom`** | **내가 지정** | 임의 git URL (사내 스타터·개인 보일러플레이트) | 아래 "커스텀 원형 추가" |
| `none` | 원형 없음 | — | 기존 코드에 flow만 얹음 |

> **MSA 원형은 위 2종** — 둘 다 Gateway·Eureka·Config를 각자 가진 **풀 MSA라 대체 관계(합치지 않음)**. 신규는 `egov-msa-cc`(최신) 권장, `egov-msa`(msa-edu, 2021 교육용)는 학습·참고 + 무거우니 슬림화. MSA 운영환경: `egovframe-operating-environment-msa`(Istio·OpenTelemetry).

## eGov 그 외 저장소 (원형 아님 — 갖다 쓰는 자원)

위 원형 표는 **복제해 시작**하는 것. 아래는 프로젝트에 **필요할 때 붙여 쓰는** eGov 자원(중복 없음).

**📦 라이브러리 — 기능 발췌**
| repo | ★ | 용도 |
|:---|:--:|:---|
| `egovframe-common-components` | 75 | **253개 공통 기능**(게시판·회원·권한·코드관리) 발췌해 내 프로젝트에 |
| `egovframe-runtime` | 46 | 표준프레임워크 실행환경 코어 모듈 |

**🛠 개발 도구·설치**
| repo | ★ | 용도 |
|:---|:--:|:---|
| `egovframe-development` | 29 | 개발 도구셋(코드 생성 등) |
| `egovframe-vscode-initializr` | 10 | VSCode 프로젝트 생성기(eGov판 Initializr) |
| `homebrew-egovframe` | 4 | macOS `brew`로 CLI 설치 |
| `egovframe-templates-download` | — | initializr용 템플릿 아카이브 |

**☁️ MSA 운영·클라우드 — 배포·운영 단계**
| repo | ★ | 용도 |
|:---|:--:|:---|
| `egovframe-operating-environment-msa` | 1 | Istio 서비스메시 · OpenTelemetry 관측 |
| `egovframe-ex-cloud-data-stream` | 1 | Spring Cloud Stream 예제 |

**🤖 신기술 · 📱 모바일**
| repo | ★ | 용도 |
|:---|:--:|:---|
| `egovframe-ai-rag` | 14 | Spring AI 기반 **RAG**(문서검색+LLM) |
| `egovframe-mobile-device-api` | 2 | **Flutter/Dart** 모바일 (최신) |
| `egovframe-mobile-device-api-legacy` | 5 | Android/iOS (구형) |

**📚 문서·학습**
| repo | ★ | 용도 |
|:---|:--:|:---|
| `egovframe-docs` | 29 | 표준프레임워크 **공식 가이드** |
| `egovframe-hands-on-guide` | 1 | 실습 따라하기 |
| `awesome-egovframe` | — | 커뮤니티 프로젝트 모음 |

> **MSA 추천 조합**: 시작 `egov-msa`(원형) → 기능 `egovframe-common-components` 발췌 → 운영 `egovframe-operating-environment-msa` → (선택) `egovframe-ai-rag`.

## 복제 절차 (scaffold가 수행)

```bash
# 예: eGov MSA 원형
git clone --depth 1 https://github.com/eGovFramework/egovframe-msa-edu tmp-egov
rm -rf tmp-egov/.git
# tmp-egov 내용을 프로젝트로 복사 → 프로젝트명·groupId·패키지 치환
# 그 뒤 flow 문서층(doc/·CLAUDE.md·workflow.config.json) 생성·연결
```

## 이름 치환 (복제 후 — 정체성만 바꾸고 기능명은 유지)

clone은 템플릿 이름(`msa-edu`·`org.egovframe.cloud`)을 **그대로** 가져온다. 폴더명은 복제 대상(예: `GREED`)이 되지만, **내부 이름은 안 바뀐다.** 규칙: **정체성 이름만 바꾸고 기능 이름은 둔다.**

| 대상 | 예 | 처리 |
|:---|:---|:---|
| **바꿈 (정체성)** | 패키지 루트 `org.egovframe.cloud` → `com.myco.greed` | **IDE Refactor > Rename Package** 권장 |
| | `groupId` `org.egovframe` → `com.myco` | build.gradle/pom 텍스트 치환 |
| | 프로젝트/문서 제목 `msa-edu` → `GREED` | 텍스트 치환 |
| **유지 (기능)** | `gateway`·`user-service`·`board-service`·`config`·`discovery` | **그대로** (기능을 뜻함, GREED에서도 gateway는 gateway) |
| | docker-compose·k8s 서비스명 | 그대로 (원하면만 변경) |

**flow vs 당신**: `/flow:setup`이 텍스트 치환(groupId·제목·단순 패키지 문자열)의 **초안**을 잡는다. 단 **패키지 rename은 파일 이동+`package`선언+`import`가 얽혀** 스크립트 치환이 위험하다 → **IDE refactor로 마무리 + `build`(컴파일)로 검증**을 권장. **완전 자동 아님**: 밑작업은 flow, 패키지 rename·검증은 사람.

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
