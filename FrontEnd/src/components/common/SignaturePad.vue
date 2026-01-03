<script setup>
import { ref, onMounted, nextTick } from 'vue';

const props = defineProps({
  title: {
    type: String,
    default: '서명'
  }
});

const emit = defineEmits(['close', 'save']);

const canvasRef = ref(null);
const isDrawing = ref(false);
const lastPoint = ref({ x: 0, y: 0 });

const resetCanvas = () => {
  const canvas = canvasRef.value;
  if (!canvas) return;
  const ctx = canvas.getContext("2d");
  ctx.fillStyle = "#fff";
  ctx.fillRect(0, 0, canvas.width, canvas.height);
  
  ctx.strokeStyle = "#1f2937";
  ctx.lineWidth = 2;
  ctx.lineCap = "round";
};

const pointerPos = (event) => {
  const canvas = canvasRef.value;
  if (!canvas) return { x: 0, y: 0 };
  const rect = canvas.getBoundingClientRect();
  const clientX = event.clientX ?? event.touches?.[0]?.clientX;
  const clientY = event.clientY ?? event.touches?.[0]?.clientY;
  return { x: clientX - rect.left, y: clientY - rect.top };
};

const startDraw = (event) => { 
  event.preventDefault(); 
  isDrawing.value = true; 
  lastPoint.value = pointerPos(event); 
};

const draw = (event) => { 
  if (!isDrawing.value) return; 
  event.preventDefault(); 
  const canvas = canvasRef.value; 
  const ctx = canvas.getContext("2d"); 
  const { x, y } = pointerPos(event); 
  ctx.beginPath(); 
  ctx.moveTo(lastPoint.value.x, lastPoint.value.y); 
  ctx.lineTo(x, y); 
  ctx.stroke(); 
  lastPoint.value = { x, y }; 
};

const endDraw = () => { 
  isDrawing.value = false; 
};

const handleSave = () => {
  const canvas = canvasRef.value;
  const dataUrl = canvas.toDataURL("image/png");
  emit('save', dataUrl);
};

onMounted(() => {
  nextTick(() => {
    resetCanvas();
  });
});
</script>

<template>
  <div class="modal-overlay">
    <div class="modal-content signature-modal">
      <div class="modal-header">
        <h3>{{ title }}</h3>
        <button class="modal-close-btn" @click="$emit('close')">×</button>
      </div>
      <div class="modal-body">
        <div class="signature-pad">
          <p class="signature-instruction">패드 위에 정자로 서명해 주세요.</p>
          <canvas
            ref="canvasRef"
            class="signature-canvas"
            width="500"
            height="200"
            @pointerdown="startDraw"
            @pointermove="draw"
            @pointerup="endDraw"
            @pointerleave="endDraw"
          ></canvas>
        </div>
      </div>
      <div class="modal-footer">
        <button class="btn-cancel" @click="$emit('close')">취소</button>
        <button class="btn-save" @click="handleSave">서명 저장</button>
      </div>
    </div>
  </div>
</template>

<style scoped>
.modal-overlay {
  position: fixed; inset: 0; background: rgba(0, 0, 0, 0.45);
  display: flex; align-items: center; justify-content: center;
  padding: 1rem; z-index: 3000;
}

.modal-content.signature-modal {
  width: min(600px, 95%); background: white; border-radius: 0.75rem;
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.18); overflow: hidden;
  border: 1px solid #e5e7eb; display: flex; flex-direction: column;
}

.modal-header {
  display: flex; justify-content: space-between; align-items: center;
  padding: 1.25rem 1.5rem; border-bottom: 1px solid #e5e7eb;
  background: linear-gradient(135deg, #f3e8ff 0%, #e9d5ff 100%);
}
.modal-header h3 { margin: 0; font-size: 1.25rem; font-weight: 800; color: #581c87; }
.modal-close-btn {
  border: none; background: white; width: 32px; height: 32px; border-radius: 50%;
  font-size: 1.25rem; color: #6b7280; cursor: pointer; box-shadow: 0 1px 3px rgba(0,0,0,0.1);
}

.modal-body { padding: 1.5rem; }
.signature-instruction { text-align: center; color: #6b7280; margin-bottom: 10px; font-size: 0.9rem; }
.signature-canvas { 
  width: 100%; border: 2px solid #e5e7eb; border-radius: 0.5rem; cursor: crosshair; touch-action: none; 
}

.modal-footer {
  display: flex; justify-content: flex-end; gap: 0.5rem;
  padding: 1rem 1.25rem; border-top: 1px solid #e5e7eb; background: #f9fafb;
}

.btn-cancel { padding: 0.6rem 1.2rem; border-radius: 0.5rem; background: white; border: 1px solid #d1d5db; cursor: pointer; }
.btn-save { padding: 0.6rem 1.2rem; border-radius: 0.5rem; background: #8b5cf6; color: white; border: none; cursor: pointer; }
</style>
