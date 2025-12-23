<template>
  <div class="modal-overlay" @click.self="$emit('close')">
    <div class="modal-container">
      
      <div class="modal-header">
        <div class="header-title">
          <span class="icon">📄</span> 
          <span>결재 요청</span>
        </div>
        <button class="close-btn" @click="$emit('close')">✕</button>
      </div>

      <div class="modal-body">
        
        <section class="form-section">
          <h3 class="section-title">기본 정보</h3>
          
          <div class="form-group">
            <label>제목 <span class="required">*</span></label>
            <input type="text" placeholder="결재 문서 제목을 입력하세요" class="form-input" />
          </div>

          <div class="form-row">
            <div class="form-group half">
              <label>유형 <span class="required">*</span></label>
              <select class="form-select">
                <option>급여</option>
                <option>구매</option>
                <option>휴가</option>
              </select>
            </div>
            <div class="form-group half">
              <label>우선순위 <span class="required">*</span></label>
              <select class="form-select">
                <option>보통</option>
                <option>긴급</option>
                <option>낮음</option>
              </select>
            </div>
          </div>

          <div class="form-group">
            <label>금액</label>
            <div class="input-with-icon">
              <span class="currency-icon">₩</span>
              <input type="number" placeholder="금액을 입력하세요" class="form-input padding-left" />
            </div>
          </div>

          <div class="form-group">
            <label>내용</label>
            <textarea placeholder="결재 요청 사유 및 상세 내용을 입력하세요" class="form-textarea"></textarea>
          </div>
        </section>

        <section class="form-section">
          <h3 class="section-title success-color">첨부 파일</h3>
          <div class="file-upload-box">
            <div class="upload-content">
              <div class="upload-icon">⬆️</div>
              <p>
                <span class="highlight">파일 선택</span> 또는 드래그하여 업로드
              </p>
              <span class="sub-text">PDF, Excel, Word 파일 지원</span>
            </div>
          </div>
        </section>

        <section class="form-section">
          <div class="section-header">
            <h3 class="section-title success-color">승인자 지정 <span class="required">*</span></h3>
            <button class="btn-add-approver">+ 승인자 추가</button>
          </div>
          <div class="empty-approver-box">
            승인자를 추가해주세요
          </div>
        </section>

      </div>

      <div class="modal-footer">
        <button class="btn btn-cancel" @click="$emit('close')">취소</button>
        <button class="btn btn-submit">📄 결재 요청</button>
      </div>

    </div>
  </div>
</template>

<script setup>
defineEmits(['close']);
</script>

<style scoped>
/* 오버레이 */
.modal-overlay {
  position: fixed; top: 0; left: 0; width: 100%; height: 100%;
  background: rgba(0, 0, 0, 0.4);
  z-index: 1000;
  display: flex; justify-content: center; align-items: center;
}

/* 모달 컨테이너 */
.modal-container {
  background: white;
  width: 600px;
  max-height: 90vh; /* 화면 꽉 차지 않게 */
  border-radius: 12px;
  display: flex; flex-direction: column;
  box-shadow: 0 10px 25px rgba(0,0,0,0.15);
  overflow: hidden;
}

/* 헤더 */
.modal-header {
  background-color: #4ade80; /* 녹색 배경 */
  color: white;
  padding: 16px 24px;
  display: flex; justify-content: space-between; align-items: center;
}
.header-title { font-size: 18px; font-weight: 600; display: flex; align-items: center; gap: 8px; }
.close-btn { background: none; border: none; color: white; font-size: 20px; cursor: pointer; }

/* 바디 */
.modal-body {
  padding: 24px;
  overflow-y: auto;
  flex: 1;
}

/* 폼 스타일 공통 */
.form-section { margin-bottom: 24px; }
.section-title { font-size: 16px; font-weight: 600; color: #1a5928; margin-bottom: 12px; display: block; }
.success-color { color: #1a5928; }
.required { color: #ef4444; margin-left: 2px; }

.form-group { margin-bottom: 16px; display: flex; flex-direction: column; gap: 6px; }
.form-group label { font-size: 14px; font-weight: 600; color: #333; }

.form-input, .form-select, .form-textarea {
  border: 1px solid #e2e8f0;
  border-radius: 6px;
  padding: 10px 12px;
  font-size: 14px;
  outline: none;
  width: 100%; box-sizing: border-box;
}
.form-input:focus, .form-select:focus, .form-textarea:focus {
  border-color: #4ade80;
}

.form-textarea { height: 100px; resize: none; }

/* 한 줄에 두 개 배치 */
.form-row { display: flex; gap: 16px; }
.half { flex: 1; }

/* 금액 입력창 아이콘 */
.input-with-icon { position: relative; }
.currency-icon { position: absolute; left: 12px; top: 50%; transform: translateY(-50%); color: #888; font-size: 14px; }
.padding-left { padding-left: 30px; }

/* 첨부 파일 박스 (점선) */
.file-upload-box {
  border: 2px dashed #e2e8f0;
  border-radius: 8px;
  padding: 30px;
  text-align: center;
  background-color: #fafafa;
  cursor: pointer;
  transition: all 0.2s;
}
.file-upload-box:hover { border-color: #4ade80; background-color: #f0fdf4; }
.upload-icon { font-size: 24px; margin-bottom: 8px; color: #94a3b8; }
.highlight { color: #22c55e; font-weight: 600; text-decoration: underline; }
.sub-text { display: block; margin-top: 4px; font-size: 12px; color: #94a3b8; }

/* 승인자 섹션 */
.section-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 10px; }
.btn-add-approver {
  background-color: #4ade80; color: white; border: none;
  padding: 6px 12px; border-radius: 6px; font-size: 13px; font-weight: 600; cursor: pointer;
}
.btn-add-approver:hover { background-color: #22c55e; }

.empty-approver-box {
  background-color: #f8f9fa; border: 1px solid #e2e8f0; border-radius: 6px;
  padding: 24px; text-align: center; color: #64748b; font-size: 14px;
}

/* 푸터 */
.modal-footer {
  padding: 16px 24px;
  border-top: 1px solid #e2e8f0;
  display: flex; gap: 12px;
}
.btn {
  flex: 1; padding: 12px; border-radius: 8px; font-weight: 600; cursor: pointer; font-size: 15px;
}
.btn-cancel { background: white; border: 1px solid #e2e8f0; color: #64748b; }
.btn-cancel:hover { background: #f1f5f9; }
.btn-submit { background: #4ade80; border: none; color: white; }
.btn-submit:hover { background: #22c55e; }
</style>