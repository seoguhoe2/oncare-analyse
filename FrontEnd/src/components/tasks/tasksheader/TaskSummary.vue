<template>
  <div class="summary-grid">
    
    <div class="summary-card orange">
      <div class="card-content">
        <div class="card-header">
          <span class="status-icon">⚠️</span>
          <span class="card-title">나의 결재 대기</span>
        </div>
        <p class="card-desc">내가 지금 승인해야 할 문서</p>
        <div class="card-bottom">
          <span class="count">3건</span>
          <div class="sub-info">
            <span class="dot red"></span> 긴급 2건
            <span class="dot orange"></span> 일반 1건
          </div>
        </div>
      </div>
      <div class="bg-icon">📝</div>
    </div>

    <div class="summary-card yellow">
      <div class="card-content">
        <div class="card-title">승인 대기중</div>
        <p class="card-desc">내가 올린 결재</p>
        <div class="card-bottom">
          <span class="count">1건</span>
        </div>
      </div>
      <div class="bg-icon">🕒</div>
    </div>

    <div class="summary-card green">
      <div class="card-content">
        <div class="card-title">승인됨</div>
        <p class="card-desc">내가 올린 결재</p>
        <div class="card-bottom">
          <span class="count">1건</span>
        </div>
      </div>
      <div class="bg-icon">✅</div>
    </div>

    <div class="summary-card red">
      <div class="card-content">
        <div class="card-title">반려됨</div>
        <p class="card-desc">내가 올린 결재</p>
        <div class="card-bottom">
          <span class="count">0건</span>
        </div>
      </div>
      <div class="bg-icon">❎</div>
    </div>

  </div>
</template>

<style scoped>
.summary-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr); /* 4열 그리드 */
  gap: 16px;
  margin-top: 10px;
  margin-bottom: 24px;
}

.summary-card {
  position: relative;
  border-radius: 12px;
  padding: 20px;
  height: 120px;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  border: 1px solid transparent;
  overflow: hidden;
}

/* 카드별 테마 색상 */
/* Orange */
.summary-card.orange { background-color: #fff7ed; border-color: #ffedd5; }
.summary-card.orange .card-title { color: #9a3412; }
.summary-card.orange .card-desc { color: #c2410c; }
.summary-card.orange .count { color: #9a3412; }
.summary-card.orange .bg-icon { color: #ffedd5; }

/* Yellow */
.summary-card.yellow { background-color: #fefce8; border-color: #fef08a; }
.summary-card.yellow .card-title { color: #854d0e; }
.summary-card.yellow .card-desc { color: #a16207; }
.summary-card.yellow .count { color: #854d0e; }
.summary-card.yellow .bg-icon { color: #fef08a; }

/* Green */
.summary-card.green { background-color: #f0fdf4; border-color: #bbf7d0; }
.summary-card.green .card-title { color: #166534; }
.summary-card.green .card-desc { color: #15803d; }
.summary-card.green .count { color: #166534; }
.summary-card.green .bg-icon { color: #bbf7d0; }

/* Red */
.summary-card.red { background-color: #fef2f2; border-color: #fecaca; }
.summary-card.red .card-title { color: #991b1b; }
.summary-card.red .card-desc { color: #b91c1c; }
.summary-card.red .count { color: #991b1b; }
.summary-card.red .bg-icon { color: #fecaca; }

/* 내부 텍스트 스타일 */
.card-header {
  display: flex;
  align-items: center;
  gap: 6px;
  margin-bottom: 4px;
}

.card-title {
  font-weight: 700;
  font-size: 15px;
}

.card-desc {
  font-size: 13px;
  margin: 0;
  margin-bottom: auto; /* 상단 고정 */
}

.card-bottom {
  margin-top: 12px;
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.count {
  font-size: 20px;
  font-weight: 700;
}

/* 상세 정보 (긴급 2건 등) */
.sub-info {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 13px;
  color: #c2410c;
  font-weight: 500;
}

.dot {
  width: 6px;
  height: 6px;
  border-radius: 50%;
  display: inline-block;
}
.dot.red { background-color: #ef4444; }
.dot.orange { background-color: #f97316; }

/* 배경 아이콘 (우측 하단) */
.bg-icon {
  position: absolute;
  right: 15px;
  bottom: 15px;
  font-size: 40px;
  opacity: 0.8;
  pointer-events: none; /* 클릭 방지 */
  /* 실제 이미지 아이콘 대신 텍스트 이모지로 대체했습니다. 
     필요시 SVG나 이미지 태그로 교체하세요. */
}

/* 반응형 (모바일 등) */
@media (max-width: 1024px) {
  .summary-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}
@media (max-width: 600px) {
  .summary-grid {
    grid-template-columns: 1fr;
  }
}
</style>