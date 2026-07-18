# spike/approval-routing — 버릴 코드 ⚠️

`/flow:spike`가 만든 **throwaway 실험 코드**다. 유지보수·drift·계약 게이트 대상이 아니다.

- **목적**: "결재선을 조직도+금액 규칙만으로 자동 결정 가능한가"를 실제 이력에 대고 확인만.
- **검증 결론**: [`doc/analysis/spike-approval-routing-20260716.md`](../../doc/analysis/spike-approval-routing-20260716.md)
- **승격된 지식**: ADR [`0002-approval-line-rule-engine.md`](../../doc/decisions/0002-approval-line-rule-engine.md) · 사실 [`ref/architecture/approval-routing.md`](../../doc/ref/architecture/approval-routing.md)

> 이 폴더 코드는 **프로덕션에 승격 금지**. 실제 구현은 승격된 ADR을 입고 `/design → /builder`로 다시 짠다.
> 남길 가치가 있는 건 이미 위 두 경로로 빠져나갔고, 여기 코드는 "그때 이렇게 확인했다"는 증거로만 둔다.
