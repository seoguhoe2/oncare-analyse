import uvicorn
import os, sys, io
from typing import List, Optional, Dict, Any
from dotenv import load_dotenv  #오픈API키 가져오는 함수

from fastapi import FastAPI     #파이썬 웹 프레임워크(백엔드에서 호출 가능하게 해줌)
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field

from fastapi import HTTPException

from openai import OpenAI



###### 환경설정 / 인코딩 ######
load_dotenv()                   #오픈API키 가져오는 함수

# 콘솔 UTF-8 강제 (Windows에서 한글 깨짐 방지)
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8")
sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding="utf-8")

client = OpenAI()  # OPENAI_API_KEY를 .env에서 자동 사용

app = FastAPI(title="OnCare AI Summary API", version="1.0.0")       #Fast API로 서버로 바꿈. 백엔드에서 호출가능하게 하려고

# (선택) CORS - 보통 AI 서버는 백엔드만 호출하니까 굳이 프론트 오픈 안 해도 됨(프론트에서 직접 Fast API호출시만 필요)
# app.add_middleware(
#     CORSMiddleware,
#     allow_origins=["*"],  # 개발용. 운영에서는 백엔드 주소만 허용 권장
#     allow_credentials=True,
#     allow_methods=["*"],
#     allow_headers=["*"],
# )


###### 요청/응답 모델 ######
class DailyLogForSummary(BaseModel):
    date: str = Field(..., description="YYYY-MM-DD")
    physical_meal: List[str] = Field(default_factory=list)
    physical_excretion: List[str] = Field(default_factory=list)
    physical_hygiene: List[str] = Field(default_factory=list)
    physical_mobility: List[str] = Field(default_factory=list)
    cognitive: List[str] = Field(default_factory=list)
    status_health: List[str] = Field(default_factory=list)
    status_mood: List[str] = Field(default_factory=list)
    status_sleep: List[str] = Field(default_factory=list)
    special_note: Optional[str] = Field(default=None, description="길면 잘라서 넣어도 됨")

class MonthlySummaryRequest(BaseModel):
    beneficiaryId: int
    month: str = Field(..., description="YYYY-MM")
    logs: List[DailyLogForSummary] = Field(default_factory=list)

class MonthlySummaryResponse(BaseModel):
    beneficiaryId: int
    month: str
    summaryText: str    #월별 AI요약 내용
    meta: Dict[str, Any] = Field(default_factory=dict)



###### 유틸: 프롬프트 구성 ######
# 로그가 너무 길어질 수 있으니, note는 120자 정도로 자르는 것을 권장
def build_prompt(req: MonthlySummaryRequest) -> str:
    lines = []
    for log in req.logs:
        note = (log.special_note or "").strip()
        if len(note) > 120:            
            note = note[:120] + "…"

        lines.append(
            f"- {log.date}\n"
            f"  • 신체(식사): {', '.join(log.physical_meal) if log.physical_meal else '-'}\n"
            f"  • 신체(배설): {', '.join(log.physical_excretion) if log.physical_excretion else '-'}\n"
            f"  • 신체(위생): {', '.join(log.physical_hygiene) if log.physical_hygiene else '-'}\n"
            f"  • 신체(이동): {', '.join(log.physical_mobility) if log.physical_mobility else '-'}\n"
            f"  • 인지/정서: {', '.join(log.cognitive) if log.cognitive else '-'}\n"
            f"  • 상태(신체): {', '.join(log.status_health) if log.status_health else '-'}\n"
            f"  • 상태(기분): {', '.join(log.status_mood) if log.status_mood else '-'}\n"
            f"  • 상태(수면): {', '.join(log.status_sleep) if log.status_sleep else '-'}\n"
            f"  • 특이사항: {note if note else '-'}"
        )

    logs_block = "\n".join(lines) if lines else "(해당 월 로그 없음)"

    # 비용/토큰 낭비되면 프롬프트 예시부분에 1개만 두기
    # 결과를 “월별 카드에 들어갈 문장”으로 만들기: 너무 길지 않게(1~2줄 정도)
    prompt = f"""
너는 장기요양 요양일지를 월별로 요약해주는 도우미야.
대상 독자는 관리자이며, 관리자는 이 요약을 통해 특정 수급자의 해당 월 건강상태 경향을 빠르게 파악해야 해.

아래 [일지 데이터]를 바탕으로 월 요약문을 작성해줘.
일지 데이터는 ‘여러 날짜’로 들어오거나 하나의 날짜로만 들어올 수 있어.

[사전 판단 규칙 (반드시 준수)]
요약을 작성하기 전에, 월 전체 일지 데이터를 기준으로 아래 항목들의 ‘등장 여부’를 먼저 판단한다.
- 통증
- 수면 부족
- 부종
- 피부 문제
- 기타 신체 이상
- 불안
- 우울
- 분노
- 낮잠 과다
- 배뇨/배변 실수
위 항목이 일지 데이터에 단 한 번도 명시적으로 등장하지 않으면,
해당 항목을 암시·추론·일반화하여 언급하는 것은 절대 금지한다.

또한, 일지에 명시되지 않은 신체활동 지원, 인지 및 정서지원, 상태 관찰 및 특이사항, 건강 문제·상태 변화·이상 소견을 생성하거나 추정하지 않는다.

[요약 목표]
- 월 전체 경향을 1~2문장으로 요약 (최대 160자)
- 자주 수행된 신체활동(식사/배설/위생/이동) 경향을 관찰된 범위 내에서만 반영
- 인지/정서 지원 경향을 관찰된 범위 내에서만 반영
- 상태(신체/기분/수면)는 관찰된 범위 내에서만 반영하며 단정적 표현은 금지하고 “관찰됨/주의 필요” 톤을 사용

[특이점 포함 규칙]
- 아래 조건 중 하나라도 충족되는 경우에만, 특이점을 1문장에 포함할 수 있다.:
  (1) 해당 월 전체에서 1회만 등장한 활동·상태·특이사항
  (2) special_note에 통증/부종/피부문제/수면부족/배뇨실수 등 주의 신호가 명시적으로 포함된 경우
  (3) 상태(신체/기분/수면)에서 해당 월 내 다른 일지와 비교해 1~2회만 다르게 명시된 경우
단, 위 특이점은 반드시 일지 데이터에 직접 등장한 표현만 사용하며, 반복되는 특이사항이 있을 경우 재발·지속 경향으로 간결히 강조한다. 

[주의점 작성 제한]
- 일지 데이터 전체에 주의 신호가 없는 경우, 통증·수면·정서 상태와 관련된 표현은 긍정·부정 모두 추가하지 않는다.
  이 경우, “전반적으로 안정적인 경향이 관찰됨” 수준의 표현까지만 허용한다.
- 안정 / 양호 / 평온 표현과 충돌되는 건강 주의 문구는 사용 금지한다.
- 특정 수급자에 대한 일지 데이터들을 기반으로 요약
- 일지 데이터에 없는 정보 요약 금지
- 개인정보 추정/생성 금지, 주어진 정보만 사용

[출력 형식]
- 한국어
- TEXT만 출력 (JSON/마크다운/불릿 금지)
- 프롬프트를 반복하거나 "다음은 요약입니다" 같은 메타 문장 금지
- 길이: 1~2문장, 최대 160자

[일지 데이터]
{logs_block}


[예시]
[요청 1]
(일지1) 
2025-12-03
-신체: 식사(아침, 점심), 배설(기저귀 1회), 위생(세면), 이동(체위 변경)
-인지/정서: 말벗
-상태: 기분(평온), 신체(건강 양호)
-특이사항: “전반적으로 안정적”

(일지2)
2025-12-10
-신체: 식사(점심, 저녁, 식사 준비), 배설(화장실 1회, 배뇨), 위생(구강 관리)
-인지/정서: 정서 지원
-상태: 기분(평온)
-특이사항: 없음

(일지3)
2025-12-28
-신체: 식사(아침, 간식), 이동(실내 이동, 보행 도움), 위생(옷 갈아입기)
-인지/정서: 말벗, 정서 지원
-상태: 신체(건강 양호)
-특이사항: “전반적으로 안정적”

[예시 답변 1]
해당 월은 식사 보조·배설 관리·위생 및 이동/체위 지원이 반복적으로 수행되었고, 말벗/정서지원이 함께 제공되며 전반적으로 안정적인 경향이 관찰됨.


[요청 2]
(일지1)
2025-11-02
신체: 식사(아침), 배설(배뇨), 위생(세면), 이동(체위 변경)
인지/정서: 말벗
상태: 기분(평온)
특이사항: “안정적”

(일지2)
2025-11-09
신체: 식사(점심, 식사 준비), 배설(기저귀 2회)
인지/정서: 정서 지원
상태: 신체(통증)
특이사항: “무릎 통증 호소”

(일지3)
2025-11-16
신체: 식사(저녁), 위생(구강 관리), 이동(실내 이동)
인지/정서: 말벗
상태: 수면(수면 부족)
특이사항: “수면 부족 호소”

(일지4)
2025-11-26
신체: 식사(아침), 배설(화장실 1회), 위생(세면), 이동(체위 변경)
인지/정서: 말벗
상태: 기분(평온)
특이사항: “안정적”

[예시 답변 2]
해당 월은 식사·배설·위생 및 체위 변경 중심의 돌봄이 반복되고 정서적 지지가 병행되며 전반적으로 안정적이나, 무릎 통증과 수면 부족이 단발성으로 관찰되어 재발 여부에 대한 주의가 필요함.

""".strip()

    return prompt



###### 헬스체크 (서버가 살아있는지 확인 가능) ######
## http://localhost:8000/health로 서버 실행 중인지 확인 가능 ##
@app.get("/health")
def health():
    return {"ok": True}




###### 월별 요약 API ######
@app.post("/summaries/monthly", response_model=MonthlySummaryResponse)
def summarize_monthly(req: MonthlySummaryRequest):
    try:
        prompt = build_prompt(req)

        result = client.responses.create(
            model="gpt-4o-mini",
            input=[{"role": "user", "content": prompt}],
            max_output_tokens=350,      #요약은 너무 길 필요가 없으니까 제한
        )

        text = (result.output_text or "").strip()

        if not text:
            raise HTTPException(status_code=502, detail="AI 요약 결과가 비어있습니다.")
        
        # usage에서 토큰 추출 (SDK 버전 차이를 대비해 안전하게)
        usage = getattr(result, "usage", None) or {}
        input_tokens = getattr(usage, "input_tokens", None)
        output_tokens = getattr(usage, "output_tokens", None)
        total_tokens = getattr(usage, "total_tokens", None)

        # usage가 dict로 오는 경우 대비
        if isinstance(usage, dict):
            input_tokens = usage.get("input_tokens", input_tokens)
            output_tokens = usage.get("output_tokens", output_tokens)
            total_tokens = usage.get("total_tokens", total_tokens)
        
        return MonthlySummaryResponse(
            beneficiaryId=req.beneficiaryId,
            month=req.month,
            summaryText=text,
            meta={"logsCount": len(req.logs), "model": "gpt-4o-mini",
                # 토큰 정보 추가
                "inputTokens": int(input_tokens or 0),
                "outputTokens": int(output_tokens or 0),
                "totalTokens": int(total_tokens or 0),},
        )
    except Exception as e:
        raise HTTPException(status_code=502, detail=f"AI 요약 생성 실패: {str(e)}")


# ---  FastAPI 서버 구동 ---
if __name__ == "__main__":
    # '0.0.0.0' = localhost, 127.0.0.1 및 외부 IP로 모두 접속 허용
    # port = 8000 (Java의 8080과 겹치지 않게 주의)
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
    
    ### (터미널창에 입력하면 실행됨) python -m uvicorn main:app --reload --port 8000 ###
