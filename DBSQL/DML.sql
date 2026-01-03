-- 1. 외래 키 제약 조건 검사 비활성화 (순서 상관없이 삭제하기 위해 필수)
SET FOREIGN_KEY_CHECKS = 0;

-- ==========================================
-- 수급자 관련
-- ==========================================
TRUNCATE TABLE cost_of_beneficiary_record;
TRUNCATE TABLE beneficiary_count;
TRUNCATE TABLE care_service_count;
TRUNCATE TABLE notice_expiration;
TRUNCATE TABLE expiration_of_care_level;
TRUNCATE TABLE invoice;
TRUNCATE TABLE tag_of_beneficiary;
TRUNCATE TABLE emergency;
TRUNCATE TABLE beneficiary_schedule;
TRUNCATE TABLE application_form;
TRUNCATE TABLE riskOfMember;
TRUNCATE TABLE beneficiary_care_level;
TRUNCATE TABLE cost_of_beneficiary;
TRUNCATE TABLE guardian;
TRUNCATE TABLE contract;
TRUNCATE TABLE m_form_category;
TRUNCATE TABLE m_care_level;
TRUNCATE TABLE beneficiary;

-- ==========================================
-- 요양사 관련
-- ==========================================
TRUNCATE TABLE care_logs;
TRUNCATE TABLE counseling_logs;
TRUNCATE TABLE basic_evaluations;
TRUNCATE TABLE visit_schedule;
TRUNCATE TABLE todo_for_care_worker;
TRUNCATE TABLE tag_of_care_worker;
TRUNCATE TABLE care_worker_certificate;
TRUNCATE TABLE education;
TRUNCATE TABLE care_worker_service_type;
TRUNCATE TABLE matching;
TRUNCATE TABLE care_worker;
TRUNCATE TABLE m_service_type;
TRUNCATE TABLE m_personal_type;
TRUNCATE TABLE eval_templates;

-- ==========================================
-- 직원 관련
-- ==========================================
TRUNCATE TABLE assignment_history;
TRUNCATE TABLE authorities_of_employee;
TRUNCATE TABLE employee;
TRUNCATE TABLE m_status;
TRUNCATE TABLE m_job;
TRUNCATE TABLE m_authorities;
TRUNCATE TABLE m_department;
TRUNCATE TABLE certificate;
TRUNCATE TABLE employee_career;

-- ==========================================
-- 알람 관련
-- ==========================================
TRUNCATE TABLE notification_log;
TRUNCATE TABLE notification_rule;
TRUNCATE TABLE notification_template;
TRUNCATE TABLE notification_event_type;
TRUNCATE TABLE notification_channel_type;

-- ==========================================
-- 용품 관련
-- ==========================================
TRUNCATE TABLE contract_status;
TRUNCATE TABLE rental_contract;
TRUNCATE TABLE rental_product_status;
TRUNCATE TABLE rental_product;
TRUNCATE TABLE m_location_status;
TRUNCATE TABLE care_product;
TRUNCATE TABLE m_care_product;
TRUNCATE TABLE m_product_status;
TRUNCATE TABLE product_category;
TRUNCATE TABLE product_tasks;
TRUNCATE TABLE product_tasks_for_worker;
TRUNCATE TABLE product_history;

-- ==========================================
-- AI + 태그 + 위험요소 관련
-- ==========================================
TRUNCATE TABLE ai_care;
TRUNCATE TABLE personal_tag;
TRUNCATE TABLE m_risk_level;
TRUNCATE TABLE m_risk_factor;

-- ==========================================
-- 결제 및 기타 상담 관련
-- ==========================================
TRUNCATE TABLE electronic_payment_process;
TRUNCATE TABLE electronic_payment;
TRUNCATE TABLE electronic_payment_category;
TRUNCATE TABLE beneficiary_significant;
TRUNCATE TABLE m_significant_category;
TRUNCATE TABLE m_significant;
TRUNCATE TABLE potential_customer;
TRUNCATE TABLE potential_stage;
TRUNCATE TABLE counsel_history;
TRUNCATE TABLE m_reservation_channel;
TRUNCATE TABLE m_counsel_category;
TRUNCATE TABLE counsel_history;

-- 2. 외래 키 제약 조건 검사 다시 활성화 (필수)
SET FOREIGN_KEY_CHECKS = 1;


/* [파트 1] 기초 마스터 데이터
 - 다른 테이블들이 참조하는 기준 정보들입니다.
 - 외래키 의존성이 거의 없어 가장 먼저 실행되어야 합니다.
*/

-- 1. 장기요양등급
INSERT INTO m_care_level (id, level, validity, monthly_limit) VALUES
                                                                  (1, '1등급', 60, 2300000),
                                                                  (2, '2등급', 48, 2080000),
                                                                  (3, '3등급', 48, 1480000),
                                                                  (4, '4등급', 48, 1370000),
                                                                  (5, '5등급', 24, 1170000),
                                                                  (6, '인지지원등급', 24, 650000);

-- 2. 서류 카테고리
INSERT INTO m_form_category (id, name) VALUES
                                           (1, '의사소견서'),
                                           (2, '장기요양인정 신청/갱신/변경서'),
                                           (3, '장기요양인정조사표'),
                                           (4, '장기요양인정서'),
                                           (5, '장기요양급여 제공 계획서'),
                                           (6, '장기요양급여 제공기록지(방문요양)'),
                                           (7, '장기요양급여 제공기록지(방문목욕)'),
                                           (8, '장기요양급여 제공기록지(방문간호)'),
                                           (9, '건강보험(중증치매 등)산정특례 신청서');

-- 3. 예약/상담/특이사항 관련 카테고리
INSERT INTO m_reservation_channel (name) VALUES ('전화'), ('방문'), ('블로그'), ('지인 추천'), ('SNS');
INSERT INTO m_counsel_category (name) VALUES ('가입'), ('렌탈'), ('문의'), ('컴플레인'), ('해지');
INSERT INTO m_significant_category (name) VALUES ('렌탈성사도움'), ('문의해결도움'), ('컴플레인해결도움'), ('해지상담도움');

-- 4. 특이사항 상세 (FK: m_significant_category)
-- ID는 자동증가(Auto Increment)를 따르되 순서대로 입력합니다.
INSERT INTO m_significant (name, significant_category_id) VALUES
                                                              ('렌탈금액민감', 1), ('보호자결정의존', 1), ('보편상품신뢰', 1), ('거동불편', 1), ('목욕불편', 1),
                                                              ('문자소통형', 2), ('정기연락중시형', 2),
                                                              ('요양보호사고정선호', 3), ('성격민감도높음', 3), ('금액민감도높음', 3), ('금액부담', 4);

-- 5. 직무/부서/상태/권한
-- 초기 데이터 + DML에 등장하는 추가 데이터 매핑
INSERT INTO m_job (name) VALUES
                             ('센터장'), ('관리자'), ('사원'), ('영업상담'), ('요양보호사');

INSERT INTO m_department (dept_name) VALUES
                                         ('영업팀'), ('자재팀');

INSERT INTO m_status (field) VALUES
                                 ('재직'), ('휴직'), ('퇴사');

INSERT INTO m_authorities (name) VALUES
                                     ('ROLE_CAREGIVER'), ('ROLE_EMPLOYEE'), ('ROLE_CONSULTANT'), ('ROLE_TEAM_LEAD'), ('ROLE_CENTER_MANAGER'), ('ROLE_SALES_TEAM'), ('ROLE_MATERIAL_TEAM');

-- 6. 위험도/태그/서비스 유형
INSERT INTO m_risk_level (level, score) VALUES
                                            (1, '10점 미만'), (2, '10점~15점미만'), (3, '15점이상');

INSERT INTO m_risk_factor (name, score) VALUES
                                            ('낙상', 5), ('욕창', 10), ('치매', 20), ('고혈압', 5), ('당뇨', 5),
                                            ('뇌졸증', 15), ('거동불편', 3), ('공격성', 10), ('몽유병', 10);

INSERT INTO personal_tag (tag) VALUES
                                   ('말벗'), ('산책'), ('음악'), ('종교'), ('운동'), ('영화'), ('게임'), ('서예'), ('요리');

INSERT INTO m_service_type (name, money) VALUES
                                             ('방문요양', 33000), ('방문목욕', 76000), ('방문간호', 50000);

-- 개인 일정 유형 마스터 데이터
INSERT INTO m_personal_type (name, description) VALUES
                                                    ('점심', '점심 식사 시간'),
                                                    ('휴식', '휴식 시간'),
                                                    ('휴가', '연차/휴가'),
                                                    ('병원', '병원 방문'),
                                                    ('교육', '교육/연수'),
                                                    ('회의', '회의/미팅'),
                                                    ('개인용무', '개인 업무'),
                                                    ('기타', '기타 일정');


-- 7. 계약/물류 상태
INSERT INTO contract_status (name) VALUES
                                       ('접수'), ('유지'), ('종료');

INSERT INTO m_location_status (name) VALUES
                                         ('창고'), ('배송중'), ('대여중'), ('회수중'), ('수리중'),
                                         ('센터'), ('출고'), ('수급자'), ('AS센터'), ('회수'); -- ID 6~10 추가

INSERT INTO m_product_status (name) VALUES
                                        ('보관'), ('대여'), ('폐기'),('AS');

INSERT INTO rental_product_status (name) VALUES
                                             ('렌탈'), ('회수접수'), ('회수완료');

INSERT INTO product_category (id, name, parent_id) VALUES
                                                       ('C001', '침상용품', NULL),
                                                       ('C002', '이동보조', NULL),
                                                       ('C003', '위생용품', NULL),
                                                       ('C004', '안전용품', NULL),
                                                       ('C005', '재활운동기기', NULL),
                                                       ('C006', '생활보조용품', NULL);

-- 8. 알람 관련 마스터
INSERT INTO notification_channel_type (code, name, description) VALUES
                                                                    ('WEB_PUSH', '웹 알림', '웹 알림'),
                                                                    ('SMS', '문자 메시지', '핸드폰 문자(SMS) 전송'),
                                                                    ('EMAIL', '이메일', '이메일로 알림 발송');

INSERT INTO notification_event_type (code, name, description) VALUES
                                                                  ('CERT_EXPIRE', '자격증 만료 예정', '요양보호사 자격증이 만료되기 전에 알려주는 이벤트'),
                                                                  ('RECIPIENT_BIRTHDAY','수급자 생일 알림', '수급자의 생일을 직원에게 알림'),
                                                                  ('VISIT_REMINDER', '방문 일정 알림', '요양보호사의 오늘 방문 일정을 알려줌'),
                                                                  ('DOCUMENT_MISSING', '서류 미제출 알림', '필수 서류가 제출되지 않았을 때 발생하는 이벤트'),
                                                                  ('CONTRACT_EXPIRE', '서비스 계약 만료', '수급자의 서비스 계약 만료가 다가옴'),
                                                                  ('EMERGENCY_REPORT', '응급 상황 보고', '수급자에게 응급 상황 발생 시 직원에게 알림'),
                                                                  ('CARELOG_SUBMIT', '요양일지 제출 요청', '요양보호사에게 일지 제출 요청'),
                                                                  ('NEW_ASSIGNMENT', '새 배정 안내', '새로운 수급자가 요양보호사에게 배정됨'),
                                                                  ('PAYROLL_NOTICE', '급여 안내', '직원에게 급여 지급 사실을 알림'),
                                                                  ('SYSTEM_ANNOUNCE', '시스템 공지', '관리자 공지사항'),
                                                                  ('CARE_LEVEL_EXPIRE', '장기요양등급 만료 예정', '장기요양등급 만료 60/30/15일 전에 알림');

-- 9. 자격증 및 서비스 금액
INSERT INTO certificate (certificate_name, organization, edu_cycle_years) VALUES
                                                                              ('요양보호사 자격증', '보건복지부', 3),
                                                                              ('치매전문교육 이수증', '국립치매센터', 2),
                                                                              ('노인돌봄 전문교육 이수증', '한국사회복지사협회', 2),
                                                                              ('장기요양 실무교육 수료증', '국민건강보험공단', 1),
                                                                              ('응급처치 및 심폐소생술 자격증', '대한적십자사', 2),
                                                                              ('감염관리·위생 안전교육 이수증', '질병관리청', 1);

INSERT INTO care_service_count (id, m_care_level_id, name, money) VALUES
                                                                      (1, 1, '방문요양', 33000), (2, 1, '방문간호', 50000), (3, 1, '방문목욕', 76000),
                                                                      (4, 2, '방문요양', 33000), (5, 2, '방문간호', 50000), (6, 2, '방문목욕', 76000),
                                                                      (7, 3, '방문요양', 33000), (8, 3, '방문간호', 50000), (9, 3, '방문목욕', 76000),
                                                                      (10,4, '방문요양', 33000), (11,4, '방문간호', 50000), (12,4, '방문목욕', 76000),
                                                                      (13,5, '방문요양', 33000), (14,5, '방문간호', 50000), (15,5, '방문목욕', 76000),
                                                                      (16,6, '방문요양', 33000), (17,6, '방문간호', 50000), (18,6, '방문목욕', 76000);

-- 10. 용품 마스터
INSERT INTO m_care_product
(id, name, explanation, category_cd, amount, rental_amount, created_at, updated_at)
VALUES

-- ===============================
-- 침상용품 (C001)
-- ===============================
('EM001', '전동침대', '3모터 전동침대', 'C001', 800000, 35000, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('EM003', '에어매트', '욕창방지 에어매트', 'C001', 400000, 28000, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('EM006', '욕창방지 쿠션', '메모리폼 욕창방지 쿠션', 'C001', 80000, 10000, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('EM009', '전동침대 프리미엄', '5모터 프리미엄 전동침대', 'C001', 1200000, 50000, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('EM010', '수동침대', '기본형 수동 침대', 'C001', 450000, 20000, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('EM011', '침대 난간', '낙상 방지 침대 난간', 'C001', 90000, 9000, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('EM012', '방수 매트리스', '방수 커버 포함 매트리스', 'C001', 150000, 12000, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('EM013', '욕창방지 패드', '젤 타입 욕창방지 패드', 'C001', 60000, 7000, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('EM036', '라텍스 매트리스', '압력 분산 라텍스 매트리스', 'C001', 300000, 20000, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('EM037', '침대 테이블', '회전형 침대 테이블', 'C001', 85000, 9000, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('EM038', '베개 세트', '경추 보호 베개 세트', 'C001', 60000, 7000, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),

-- ===============================
-- 이동보조 (C002)
-- ===============================
('EM002', '휠체어', '경량 알루미늄 휠체어', 'C002', 500000, 25000, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('EM004', '보행보조기', '4발 보행보조기', 'C002', 150000, 18000, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('EM005', '이동식 리프트', '전동 이동식 리프트', 'C002', 1200000, 45000, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('EM014', '전동휠체어', '조이스틱 전동휠체어', 'C002', 2500000, 90000, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('EM015', '실내용 워커', '접이식 실내용 워커', 'C002', 130000, 15000, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('EM016', '지팡이', '미끄럼방지 지팡이', 'C002', 30000, 5000, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('EM017', '계단 리프트', '계단 설치형 리프트', 'C002', 5000000, 180000, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('EM018', '이동용 보드', '침대-휠체어 이동 보드', 'C002', 70000, 8000, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('EM039', '실외용 워커', '대형 바퀴 실외용 워커', 'C002', 220000, 20000, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('EM040', '휠체어 방석', '장시간 착석용 방석', 'C002', 70000, 8000, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('EM041', '전동 스쿠터', '고령자용 전동 이동 스쿠터', 'C002', 2800000, 95000, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),

-- ===============================
-- 위생용품 (C003)
-- ===============================
('EM007', '목욕의자', '높이조절 목욕의자', 'C003', 120000, 15000, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('EM019', '이동식 변기', '침실용 이동식 변기', 'C003', 110000, 14000, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('EM020', '목욕 침대', '욕실용 이동식 목욕 침대', 'C003', 900000, 40000, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('EM021', '샤워 휠체어', '방수 샤워 휠체어', 'C003', 350000, 25000, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('EM022', '배변 패드', '흡수력 강화 배변 패드', 'C003', 40000, 6000, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('EM023', '세면 보조대', '침대 부착형 세면 보조대', 'C003', 80000, 9000, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('EM042', '침대용 세면 키트', '침상 세면 전용 키트', 'C003', 45000, 6000, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('EM043', '목욕 미끄럼 의자', '흡착형 욕실 의자', 'C003', 95000, 10000, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('EM044', '배변 훈련 변기', '재활용 배변 훈련 변기', 'C003', 80000, 9000, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),

-- ===============================
-- 안전용품 (C004)
-- ===============================
('EM008', '안전손잡이', '화장실 안전손잡이', 'C004', 50000, 8000, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('EM024', '미끄럼 방지 매트', '욕실용 미끄럼 방지 매트', 'C004', 30000, 4000, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('EM025', '침대 호출벨', '무선 호출벨 시스템', 'C004', 120000, 10000, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('EM026', '문턱 경사로', '휠체어용 문턱 경사로', 'C004', 60000, 7000, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('EM027', '야간 센서등', '움직임 감지 센서등', 'C004', 50000, 6000, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('EM028', '안전 매트', '낙상 방지 바닥 매트', 'C004', 90000, 9000, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('EM045', '침대 감지 센서', '이탈 감지 센서', 'C004', 200000, 15000, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('EM046', '욕실 안전 발판', '미끄럼 방지 발판', 'C004', 40000, 5000, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('EM047', '난간 쿠션', '충격 완화 난간 쿠션', 'C004', 30000, 4000, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),

-- ===============================
-- 재활운동기기 (C005)
-- ===============================
('EM029', '상지 재활 운동기', '팔 재활용 운동기', 'C005', 300000, 22000, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('EM030', '하지 재활 페달', '하체 재활 페달 운동기', 'C005', 200000, 18000, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('EM031', '악력 강화기', '손 근력 강화용', 'C005', 40000, 5000, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('EM032', '균형 훈련 보드', '재활 균형 훈련 보드', 'C005', 120000, 10000, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('EM048', '손가락 재활 볼', '손가락 스트레칭 볼', 'C005', 25000, 4000, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('EM049', '재활 스트레칭 밴드', '저강도 스트레칭 밴드', 'C005', 20000, 3000, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),

-- ===============================
-- 생활보조용품 (C006)
-- ===============================
('EM033', '침대 식탁', '높이 조절 침대 식탁', 'C006', 90000, 8000, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('EM034', '의자 보조 손잡이', '의자 기립 보조 손잡이', 'C006', 70000, 7000, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('EM035', '리모컨 홀더', '침대 고정형 리모컨 홀더', 'C006', 30000, 4000, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('EM050', '침대 수납 포켓', '사이드 수납 포켓', 'C006', 35000, 4000, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP());


-- 전자결재 마스터
INSERT INTO electronic_payment_category (name) VALUES
                                                   ('급여'), -- ID: 1
                                                   ('구매'), -- ID: 2
                                                   ('휴가'), -- ID: 3
                                                   ('출장'), -- ID: 4
                                                   ('기타'); -- ID: 5

/* [파트 2] 독립 주체 데이터
   - 잠재 고객 (FK 참조 없음)
   - 직원 (FK: m_job, m_department, m_status + Self Referencing manager_id)
   - 직원 테이블은 상급자(manager_id) 참조 무결성을 위해 계층 순서대로 입력합니다.
*/

-- -----------------------------------------------------------
-- 1. 잠재 고객 (Potential Customer)
-- -----------------------------------------------------------
-- 2) 70명(기존) + 30명(추가) = 총 100명 INSERT
INSERT INTO potential_customer
(id, name, phone, gender, birthdate, address, willingness, create_at, current_stage)
VALUES
    (37, '김영수', '010-1111-0001', 'M', '1942-01-15', '강남구 역삼1동', 'Y', NOW(), 4),
    (74, '이정자', '010-1111-0002', 'F', '1945-03-22', '서초구 서초1동', 'Y', NOW(), 4),
    (10, '박종원', '010-1111-0003', 'M', '1939-07-10', '송파구 잠실본동', 'Y', NOW(), 4),
    (47, '최미숙', '010-1111-0004', 'F', '1950-11-05', '관악구 청룡동', 'Y', NOW(), 4),
    (84, '정호석', '010-1111-0005', 'M', '1948-06-18', '노원구 상계3?4동', 'Y', NOW(), 4),
    (20, '오순자', '010-2222-0001', 'F', '1941-02-03', '도봉구 창1동', 'Y', NOW(), 4),
    (57, '한병철', '010-2222-0002', 'M', '1937-09-12', '강북구 수유1동', 'Y', NOW(), 4),
    (94, '서영희', '010-2222-0003', 'F', '1952-01-27', '은평구 응암1동', 'Y', NOW(), 4),
    (30, '신동호', '010-2222-0004', 'M', '1946-08-09', '마포구 망원1동', 'Y', NOW(), 4),
    (67, '조은자', '010-2222-0005', 'F', '1954-05-14', '용산구 한강로동', 'Y', NOW(), 4),
    (3, '윤재식', '010-3333-0001', 'M', '1940-12-01', '중랑구 면목본동', 'Y', NOW(), 4),
    (40, '배말순', '010-3333-0002', 'F', '1947-04-25', '동대문구 장안1동', 'Y', NOW(), 4),
    (77, '임성호', '010-3333-0003', 'M', '1938-10-30', '성북구 정릉1동', 'Y', NOW(), 4),
    (13, '권정임', '010-3333-0004', 'F', '1951-07-19', '성동구 금호1가동', 'Y', NOW(), 4),
    (50, '차동수', '010-3333-0005', 'M', '1944-09-08', '광진구 중곡1동', 'Y', NOW(), 4),
    (87, '홍금자', '010-4444-0001', 'F', '1956-02-11', '강서구 화곡본동', 'Y', NOW(), 4),
    (23, '문상철', '010-4444-0002', 'M', '1936-06-17', '양천구 신정1동', 'Y', NOW(), 4),
    (60, '남정희', '010-4444-0003', 'F', '1949-01-02', '구로구 개봉1동', 'Y', NOW(), 4),
    (97, '백영준', '010-4444-0004', 'M', '1943-08-26', '금천구 독산1동', 'Y', NOW(), 4),
    (33, '노순례', '010-4444-0005', 'F', '1957-11-29', '영등포구 대림1동', 'Y', NOW(), 4),
    (70, '강명자', '010-6000-0001', 'F', '1942-03-15', '서울시 강남구 압구정동', 'Y', NOW(), 4),
    (6, '고영식', '010-6000-0002', 'M', '1945-06-20', '서울시 서초구 잠원동', 'Y', NOW(), 4),
    (43, '권순자', '010-6000-0003', 'F', '1938-11-05', '서울시 송파구 방이동', 'Y', NOW(), 4),
    (80, '김철호', '010-6000-0004', 'M', '1950-01-25', '서울시 강동구 천호동', 'Y', NOW(), 4),
    (16, '나영희', '010-6000-0005', 'F', '1949-09-12', '서울시 마포구 성산동', 'Y', NOW(), 4),
    (53, '도진수', '010-6000-0006', 'M', '1940-05-08', '서울시 용산구 이촌동', 'Y', NOW(), 4),
    (90, '류정숙', '010-6000-0007', 'F', '1955-07-30', '서울시 성동구 성수동', 'Y', NOW(), 4),
    (26, '마동석', '010-6000-0008', 'M', '1937-12-11', '서울시 종로구 평창동', 'Y', NOW(), 4),
    (63, '박옥자', '010-6000-0009', 'F', '1943-02-18', '서울시 중구 신당동', 'Y', NOW(), 4),
    (99, '서상훈', '010-6000-0010', 'M', '1948-08-03', '서울시 광진구 자양동', 'Y', NOW(), 4),
    (35, '손미자', '010-6000-0011', 'F', '1941-04-22', '서울시 동대문구 전농동', 'Y', NOW(), 4),
    (72, '신동철', '010-6000-0012', 'M', '1952-10-15', '서울시 중랑구 묵동', 'Y', NOW(), 4),
    (8, '안경자', '010-6000-0013', 'F', '1939-01-07', '서울시 성북구 길음동', 'Y', NOW(), 4),
    (45, '양준호', '010-6000-0014', 'M', '1946-06-28', '서울시 강북구 미아동', 'Y', NOW(), 4),
    (82, '엄혜숙', '010-6000-0015', 'F', '1953-09-09', '서울시 도봉구 방학동', 'Y', NOW(), 4),
    (18, '오광수', '010-6000-0016', 'M', '1944-03-14', '서울시 노원구 중계동', 'Y', NOW(), 4),
    (55, '원정희', '010-6000-0017', 'F', '1947-11-20', '서울시 은평구 갈현동', 'Y', NOW(), 4),
    (92, '유병철', '010-6000-0018', 'M', '1950-05-02', '서울시 서대문구 연희동', 'Y', NOW(), 4),
    (28, '윤말순', '010-6000-0019', 'F', '1936-08-15', '서울시 양천구 신월동', 'Y', NOW(), 4),
    (65, '이재호', '010-6000-0020', 'M', '1949-01-30', '서울시 강서구 등촌동', 'Y', NOW(), 4),
    (1, '임숙자', '010-6000-0021', 'F', '1951-07-07', '서울시 구로구 오류동', 'Y', NOW(), 4),
    (38, '장석우', '010-6000-0022', 'M', '1942-04-12', '서울시 금천구 시흥동', 'Y', NOW(), 4),
    (75, '전영자', '010-6000-0023', 'F', '1954-12-05', '서울시 영등포구 당산동', 'Y', NOW(), 4),
    (11, '정길수', '010-6000-0024', 'M', '1938-10-22', '서울시 동작구 흑석동', 'Y', NOW(), 4),
    (48, '조현숙', '010-6000-0025', 'F', '1946-02-17', '서울시 관악구 봉천동', 'Y', NOW(), 4),
    (85, '주성민', '010-6000-0026', 'M', '1955-06-09', '서울시 강남구 청담동', 'Y', NOW(), 4),
    (21, '지순이', '010-6000-0027', 'F', '1940-09-28', '서울시 서초구 방배동', 'Y', NOW(), 4),
    (58, '진영수', '010-6000-0028', 'M', '1952-03-11', '서울시 송파구 문정동', 'Y', NOW(), 4),
    (95, '차명숙', '010-6000-0029', 'F', '1944-11-03', '서울시 강동구 명일동', 'Y', NOW(), 4),
    (31, '최민호', '010-6000-0030', 'M', '1937-05-19', '서울시 마포구 공덕동', 'Y', NOW(), 4),
    (68, '하경숙', '010-6000-0031', 'F', '1951-08-25', '서울시 용산구 한남동', 'Y', NOW(), 4),
    (4, '한상철', '010-6000-0032', 'M', '1945-01-14', '서울시 성동구 행당동', 'Y', NOW(), 4),
    (41, '허춘자', '010-6000-0033', 'F', '1939-07-06', '서울시 종로구 혜화동', 'Y', NOW(), 4),
    (78, '홍길동', '010-6000-0034', 'M', '1950-12-21', '서울시 중구 을지로동', 'Y', NOW(), 4),
    (14, '황금자', '010-6000-0035', 'F', '1948-04-09', '서울시 광진구 구의동', 'Y', NOW(), 4),
    (51, '강철수', '010-6000-0036', 'M', '1941-10-30', '서울시 동대문구 청량리동', 'Y', NOW(), 4),
    (88, '권영희', '010-6000-0037', 'F', '1954-02-12', '서울시 중랑구 신내동', 'Y', NOW(), 4),
    (24, '김동현', '010-6000-0038', 'M', '1938-06-05', '서울시 성북구 돈암동', 'Y', NOW(), 4),
    (61, '남정숙', '010-6000-0039', 'F', '1947-09-19', '서울시 강북구 번동', 'Y', NOW(), 4),
    (98, '박성훈', '010-6000-0040', 'M', '1953-03-24', '서울시 도봉구 창동', 'Y', NOW(), 4),
    (34, '서미숙', '010-6000-0041', 'F', '1942-11-08', '서울시 노원구 하계동', 'Y', NOW(), 4),
    (71, '손재민', '010-6000-0042', 'M', '1949-05-17', '서울시 은평구 응암동', 'Y', NOW(), 4),
    (7, '송영자', '010-6000-0043', 'F', '1955-01-28', '서울시 서대문구 홍은동', 'Y', NOW(), 4),
    (44, '신우진', '010-6000-0044', 'M', '1940-08-11', '서울시 마포구 연남동', 'Y', NOW(), 4),
    (81, '안정자', '010-6000-0045', 'F', '1946-12-03', '서울시 양천구 목동', 'Y', NOW(), 4),
    (17, '양현수', '010-6000-0046', 'M', '1952-04-20', '서울시 강서구 가양동', 'Y', NOW(), 4),
    (54, '오옥분', '010-6000-0047', 'F', '1939-10-14', '서울시 구로구 구로동', 'Y', NOW(), 4),
    (91, '우상혁', '010-6000-0048', 'M', '1948-02-09', '서울시 금천구 가산동', 'Y', NOW(), 4),
    (27, '윤귀자', '010-6000-0049', 'F', '1951-07-22', '서울시 영등포구 여의도동', 'Y', NOW(), 4),
    (64, '이준영', '010-6000-0050', 'M', '1943-05-30', '서울시 동작구 노량진동', 'Y', NOW(), 4),

    (100, '김선우', '010-7000-0001', 'M', '1944-02-02', '서울시 강남구 대치동', 'Y', NOW(), 1),
    (36, '박정희', '010-7000-0002', 'F', '1948-06-16', '서울시 서초구 반포동', 'Y', NOW(), 2),
    (73, '이상민', '010-7000-0003', 'M', '1939-09-07', '서울시 송파구 가락동', 'Y', NOW(), 3),
    (9, '최은경', '010-7000-0004', 'F', '1952-01-19', '서울시 강동구 암사동', 'Y', NOW(), 1),
    (46, '정민수', '010-7000-0005', 'M', '1941-12-28', '서울시 마포구 상암동', 'Y', NOW(), 2),
    (83, '오정란', '010-7000-0006', 'F', '1947-05-11', '서울시 용산구 서빙고동', 'Y', NOW(), 4),
    (19, '한재훈', '010-7000-0007', 'M', '1936-03-03', '서울시 종로구 삼청동', 'Y', NOW(), 3),
    (56, '서지혜', '010-7000-0008', 'F', '1956-08-22', '서울시 중구 남대문로동', 'Y', NOW(), 1),
    (93, '신영호', '010-7000-0009', 'M', '1949-10-10', '서울시 성동구 옥수동', 'Y', NOW(), 2),
    (29, '조미경', '010-7000-0010', 'F', '1943-04-14', '서울시 광진구 능동', 'Y', NOW(), 2),
    (66, '윤성진', '010-7000-0011', 'M', '1950-07-01', '서울시 동대문구 이문동', 'Y', NOW(), 4),
    (2, '배정숙', '010-7000-0012', 'F', '1942-02-26', '서울시 중랑구 면목동', 'Y', NOW(), 1),
    (39, '임재성', '010-7000-0013', 'M', '1938-12-08', '서울시 성북구 월곡동', 'Y', NOW(), 3),
    (76, '권미자', '010-7000-0014', 'F', '1953-03-17', '서울시 강북구 우이동', 'Y', NOW(), 2),
    (12, '차영수', '010-7000-0015', 'M', '1946-11-23', '서울시 도봉구 쌍문동', 'Y', NOW(), 1),
    (49, '홍선영', '010-7000-0016', 'F', '1940-06-09', '서울시 노원구 공릉동', 'Y', NOW(), 3),
    (86, '문진호', '010-7000-0017', 'M', '1937-01-31', '서울시 은평구 불광동', 'Y', NOW(), 4),
    (22, '남영희', '010-7000-0018', 'F', '1955-09-05', '서울시 서대문구 북가좌동', 'Y', NOW(), 2),
    (59, '백승호', '010-7000-0019', 'M', '1945-04-20', '서울시 양천구 신정동', 'Y', NOW(), 1),
    (96, '노미선', '010-7000-0020', 'F', '1957-02-12', '서울시 강서구 마곡동', 'Y', NOW(), 3),
    (32, '강민호', '010-7000-0021', 'M', '1942-08-18', '서울시 구로구 신도림동', 'Y', NOW(), 2),
    (69, '고선자', '010-7000-0022', 'F', '1949-12-25', '서울시 금천구 독산동', 'Y', NOW(), 4),
    (5, '권성호', '010-7000-0023', 'M', '1952-06-06', '서울시 영등포구 신길동', 'Y', NOW(), 1),
    (42, '김지연', '010-7000-0024', 'F', '1941-01-08', '서울시 동작구 사당동', 'Y', NOW(), 2),
    (79, '나정훈', '010-7000-0025', 'M', '1948-03-29', '서울시 관악구 신림동', 'Y', NOW(), 3),
    (15, '도미정', '010-7000-0026', 'F', '1939-05-15', '서울시 서초구 양재동', 'Y', NOW(), 4),
    (52, '류성호', '010-7000-0027', 'M', '1936-10-27', '서울시 송파구 잠실동', 'Y', NOW(), 2),
    (89, '마은주', '010-7000-0028', 'F', '1954-07-13', '서울시 강남구 논현동', 'Y', NOW(), 1),
    (25, '박준수', '010-7000-0029', 'M', '1940-11-09', '서울시 마포구 합정동', 'Y', NOW(), 3),
    (62, '서정아', '010-7000-0030', 'F', '1947-04-03', '서울시 용산구 청파동', 'Y', NOW(), 2);

-- -----------------------------------------------------------
-- 2. 직원 (Employee) - 계층 구조 순서 입력 (관리자 -> 팀장 -> 팀원)
-- 암호는 암호화 했으며 모든 암호는 pwd123 으로 통일 함
-- -----------------------------------------------------------

INSERT INTO employee (name, pw, birth, gender, address, email, phone, hire_date, dept_code, job_code, manager_id, status_id)
VALUES
    -- [ID: 1] 최상위 관리자 (센터장) - 80년생 남성
    ('김철수', '$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS', '1980-01-01', 'M', '서울특별시 강남구 역삼동', 'cs.kim@example.com', '010-1000-0001', '2024-01-01', NULL, 1, NULL, 1),

    -- [ID: 2] 영업팀장 - 85년생 남성
    ('박진호', '$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS', '1985-02-01', 'M', '서울특별시 서초구 방배동', 'jh.park@example.com', '010-1000-0002', '2024-01-01', 1, 2, 1, 1),

    -- [ID: 3] 자재팀장 - 86년생 여성
    ('이수진', '$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS', '1986-03-01', 'F', '서울특별시 송파구 잠실동', 'sj.lee@example.com', '010-1000-0003', '2024-01-01', 2, 2, 1, 1),

    -- [ID: 4~8] 자재팀 직원 (90년생)
    ('김민수', '$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS', '1990-01-01', 'M', '서울특별시 강동구 천호동', 'ms.kim@example.com', '010-2000-0001', '2024-01-01', 2, 2, 3, 1),
    ('이지영', '$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS', '1990-02-01', 'F', '서울특별시 영등포구 여의도동', 'jy.lee@example.com', '010-2000-0002', '2024-01-01', 2, 2, 3, 1),
    ('박준영', '$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS', '1990-03-01', 'M', '서울특별시 마포구 합정동', 'jy.park@example.com', '010-2000-0003', '2024-01-01', 2, 2, 3, 1),
    ('최현주', '$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS', '1990-04-01', 'F', '서울특별시 용산구 이태원동', 'hj.choi@example.com', '010-2000-0004', '2024-01-01', 2, 2, 3, 1),
    ('정우성', '$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS', '1990-05-01', 'M', '서울특별시 성동구 성수동', 'ws.jung@example.com', '010-2000-0005', '2024-01-01', 2, 2, 3, 1),

    -- [ID: 9~13] 영업팀 직원 (91년생)
    ('김도훈', '$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS', '1991-01-01', 'M', '서울특별시 강북구 미아동', 'dh.kim@example.com', '010-3000-0001', '2024-01-01', 1, 4, 2, 1),
    ('이미란', '$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS', '1991-02-01', 'F', '서울특별시 은평구 불광동', 'mr.lee@example.com', '010-3000-0002', '2024-01-01', 1, 4, 2, 1),
    ('박성훈', '$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS', '1991-03-01', 'M', '서울특별시 동대문구 장안동', 'sh.park@example.com', '010-3000-0003', '2024-01-01', 1, 4, 2, 1),
    ('최윤정', '$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS', '1991-04-01', 'F', '서울특별시 중랑구 상봉동', 'yj.choi@example.com', '010-3000-0004', '2024-01-01', 1, 4, 2, 1),
    ('정민재', '$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS', '1991-05-01', 'M', '서울특별시 성북구 돈암동', 'mj.jung@example.com', '010-3000-0005', '2024-01-01', 1, 4, 2, 1),

    -- [ID: 14~35] 요양보호사 (80~82년생 여성)
    ('김혜진','$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS','1980-01-01','F','강남구 논현1동','hj.kim@example.com','010-4000-0001','2024-01-01',1,5,2,1),
    ('이경미','$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS','1980-02-01','F','강남구 삼성1동','km.lee@example.com','010-4000-0002','2024-01-01',1,5,2,1),
    ('박소영','$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS','1980-03-01','F','송파구 가락본동','sy.park@example.com','010-4000-0003','2024-01-01',1,5,2,1),
    ('최은희','$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS','1980-04-01','F','송파구 문정1동','eh.choi@example.com','010-4000-0004','2024-01-01',1,5,2,1),
    ('정미경','$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS','1980-05-01','F','서초구 반포본동','mk.jung@example.com','010-4000-0005','2024-01-01',1,5,2,1),
    ('강지현','$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS','1980-06-01','F','서초구 잠원동','jh.kang@example.com','010-4000-0006','2024-01-01',1,5,2,1),
    ('오수정','$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS','1980-07-01','F','강동구 길동','sj.oh@example.com','010-4000-0007','2024-01-01',1,5,2,1),
    ('윤희수','$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS','1980-08-01','F','강동구 둔촌1동','hs.yoon@example.com','010-4000-0008','2024-01-01',1,5,2,1),
    ('서유진','$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS','1980-09-01','F','영등포구 당산1동','yj.seo@example.com','010-4000-0009','2024-01-01',1,5,2,1),
    ('문정숙','$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS','1980-10-01','F','영등포구 도림동','js.moon@example.com','010-4000-0010','2024-01-01',1,5,2,1),
    ('유선영','$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS','1980-11-01','F','마포구 상암동','sy.yoo@example.com','010-4000-0011','2024-01-01',1,5,2,1),
    ('배지영','$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS','1980-12-01','F','마포구 성산1동','jy.bae@example.com','010-4000-0012','2024-01-01',1,5,2,1),
    ('신혜림','$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS','1981-01-01','F','용산구 한남동','hl.shin@example.com','010-4000-0013','2024-01-01',1,5,2,1),
    ('황미나','$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS','1981-02-01','F','용산구 청파동','mn.hwang@example.com','010-4000-0014','2024-01-01',1,5,2,1),
    ('곽수진','$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS','1981-03-01','F','성동구 금호1가동','sj.kwak@example.com','010-4000-0015','2024-01-01',1,5,2,1),
    ('정은주','$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS','1981-04-01','F','성동구 행당1동','ej.jung@example.com','010-4000-0016','2024-01-01',1,5,2,1),
    ('서미연','$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS','1981-05-01','F','동작구 사당1동','my.seo@example.com','010-4000-0017','2024-01-01',1,5,2,1),
    ('최지수','$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS','1981-06-01','F','동작구 상도1동','js.choi@example.com','010-4000-0018','2024-01-01',1,5,2,1),
    ('홍주연','$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS','1981-07-01','F','관악구 신림동','jy.hong@example.com','010-4000-0019','2024-01-01',1,5,2,1),
    ('김나영','$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS','1981-08-01','F','관악구 청룡동','ny.kim@example.com','010-4000-0020','2024-01-01',1,5,2,1),
    ('박혜수','$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS','1981-09-01','F','강서구 화곡본동','hs.park@example.com','010-4000-0021','2024-01-01',1,5,2,1),
    ('조현주','$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS','1981-10-01','F','강서구 등촌1동','hj.cho@example.com','010-4000-0022','2024-01-01',1,5,2,1),
    ('유민정','$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS','1981-11-01','F','구로구 구로1동','mj.yoo@example.com','010-4000-0023','2024-01-01',1,5,2,1),
    ('임수연','$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS','1981-12-01','F','구로구 고척1동','sy.lim@example.com','010-4000-0024','2024-01-01',1,5,2,1),
    ('차은영','$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS','1982-01-01','F','금천구 가산동','ey.cha@example.com','010-4000-0025','2024-01-01',1,5,2,1),
    ('백지은','$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS','1982-02-01','F','금천구 독산1동','je.baek@example.com','010-4000-0026','2024-01-01',1,5,2,1),
    ('송민경','$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS','1982-03-01','F','중구 신당동','mk.song@example.com','010-4000-0027','2024-01-01',1,5,2,1),
    ('심혜정','$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS','1982-04-01','F','중구 필동','hj.shim@example.com','010-4000-0028','2024-01-01',1,5,2,1),
    ('권지영','$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS','1982-05-01','F','종로구 삼청동','jy.kwon@example.com','010-4000-0029','2024-01-01',1,5,2,1),
    ('고현숙','$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS','1982-06-01','F','종로구 혜화동','hs.ko@example.com','010-4000-0030','2024-01-01',1,5,2,1),
    ('은정화','$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS','1982-07-01','F','노원구 상계3?4동','jh.eun@example.com','010-4000-0031','2024-01-01',1,5,2,1),
    ('윤서영','$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS','1982-08-01','F','도봉구 쌍문1동','sy.yoon2@example.com','010-4000-0032','2024-01-01',1,5,2,1),
    ('계승희','$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS','1982-09-01','F','강북구 수유1동','sh.kye@example.com','010-4000-0033','2024-01-01',1,5,2,1),
    ('맹주희','$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS','1982-10-01','F','서대문구 남가좌1동','jh.maeng@example.com','010-4000-0034','2024-01-01',1,5,2,1),
    ('류민아','$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS','1982-11-01','F','양천구 목1동','ma.ryu@example.com','010-4000-0035','2024-01-01',1,5,2,1),

    -- 1~10 (강남/서초/송파/강동/광진)
    ('김미경', '$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS', '1975-01-01', 'F', '서울시 강남구 역삼동', 'mk.kim@example.com', '010-5000-0001', '2024-02-01', 1, 5, 2, 1),
    ('이은주', '$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS', '1976-02-02', 'F', '서울시 강남구 논현동', 'ej.lee@example.com', '010-5000-0002', '2024-02-01', 1, 5, 2, 1),
    ('박성자', '$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS', '1972-03-03', 'F', '서울시 서초구 방배동', 'sj.park@example.com', '010-5000-0003', '2024-02-01', 1, 5, 2, 1),
    ('최현숙', '$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS', '1968-04-04', 'F', '서울시 서초구 서초동', 'hs.choi@example.com', '010-5000-0004', '2024-02-01', 1, 5, 2, 1),
    ('정영희', '$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS', '1970-05-05', 'F', '서울시 송파구 잠실동', 'yh.jung@example.com', '010-5000-0005', '2024-02-01', 1, 5, 2, 1),
    ('강수진', '$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS', '1979-06-06', 'F', '서울시 송파구 가락동', 'sj.kang@example.com', '010-5000-0006', '2024-02-01', 1, 5, 2, 1),
    ('조미숙', '$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS', '1981-07-07', 'F', '서울시 강동구 천호동', 'ms.cho@example.com', '010-5000-0007', '2024-02-01', 1, 5, 2, 1),
    ('윤정숙', '$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS', '1973-08-08', 'F', '서울시 강동구 명일동', 'js.yoon@example.com', '010-5000-0008', '2024-02-01', 1, 5, 2, 1),
    ('장혜진', '$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS', '1974-09-09', 'F', '서울시 광진구 자양동', 'hj.jang@example.com', '010-5000-0009', '2024-02-01', 1, 5, 2, 1),
    ('임소정', '$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS', '1971-10-10', 'F', '서울시 광진구 구의동', 'sj.lim@example.com', '010-5000-0010', '2024-02-01', 1, 5, 2, 1),

-- 11~20 (성동/중랑/동대문/성북/강북)
    ('한미영', '$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS', '1975-01-11', 'F', '서울시 성동구 성수동', 'my.han@example.com', '010-5000-0011', '2024-02-01', 1, 5, 2, 1),
    ('오경희', '$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS', '1976-02-12', 'F', '서울시 성동구 옥수동', 'kh.oh@example.com', '010-5000-0012', '2024-02-01', 1, 5, 2, 1),
    ('서지현', '$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS', '1972-03-13', 'F', '서울시 중랑구 면목동', 'jh.seo@example.com', '010-5000-0013', '2024-02-01', 1, 5, 2, 1),
    ('신혜경', '$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS', '1968-04-14', 'F', '서울시 중랑구 상봉동', 'hk.shin@example.com', '010-5000-0014', '2024-02-01', 1, 5, 2, 1),
    ('권영자', '$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS', '1970-05-15', 'F', '서울시 동대문구 장안동', 'yj.kwon@example.com', '010-5000-0015', '2024-02-01', 1, 5, 2, 1),
    ('황보라', '$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS', '1979-06-16', 'F', '서울시 동대문구 청량리동', 'br.hwang@example.com', '010-5000-0016', '2024-02-01', 1, 5, 2, 1),
    ('안미정', '$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS', '1981-07-17', 'F', '서울시 성북구 돈암동', 'mj.ahn@example.com', '010-5000-0017', '2024-02-01', 1, 5, 2, 1),
    ('송현주', '$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS', '1973-08-18', 'F', '서울시 성북구 정릉동', 'hj.song@example.com', '010-5000-0018', '2024-02-01', 1, 5, 2, 1),
    ('전수경', '$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS', '1974-09-19', 'F', '서울시 강북구 미아동', 'sk.jeon@example.com', '010-5000-0019', '2024-02-01', 1, 5, 2, 1),
    ('홍지은', '$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS', '1971-10-20', 'F', '서울시 강북구 수유동', 'je.hong@example.com', '010-5000-0020', '2024-02-01', 1, 5, 2, 1),

-- 21~30 (도봉/노원/은평/서대문/마포)
    ('고은아', '$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS', '1975-01-21', 'F', '서울시 도봉구 창동', 'ea.ko@example.com', '010-5000-0021', '2024-02-01', 1, 5, 2, 1),
    ('문정임', '$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS', '1976-02-22', 'F', '서울시 도봉구 쌍문동', 'ji.moon@example.com', '010-5000-0022', '2024-02-01', 1, 5, 2, 1),
    ('양희정', '$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS', '1972-03-23', 'F', '서울시 노원구 상계동', 'hj.yang@example.com', '010-5000-0023', '2024-02-01', 1, 5, 2, 1),
    ('손미나', '$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS', '1968-04-24', 'F', '서울시 노원구 중계동', 'mn.son@example.com', '010-5000-0024', '2024-02-01', 1, 5, 2, 1),
    ('배지혜', '$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS', '1970-05-25', 'F', '서울시 은평구 불광동', 'jh.bae@example.com', '010-5000-0025', '2024-02-01', 1, 5, 2, 1),
    ('조현정', '$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS', '1979-06-26', 'F', '서울시 은평구 녹번동', 'hj.cho2@example.com', '010-5000-0026', '2024-02-01', 1, 5, 2, 1),
    ('백수미', '$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS', '1981-07-27', 'F', '서울시 서대문구 홍제동', 'sm.baek@example.com', '010-5000-0027', '2024-02-01', 1, 5, 2, 1),
    ('허영란', '$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS', '1973-08-28', 'F', '서울시 서대문구 연희동', 'yr.heo@example.com', '010-5000-0028', '2024-02-01', 1, 5, 2, 1),
    ('유경아', '$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS', '1974-09-29', 'F', '서울시 마포구 합정동', 'ka.yoo@example.com', '010-5000-0029', '2024-02-01', 1, 5, 2, 1),
    ('남정미', '$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS', '1971-10-30', 'F', '서울시 마포구 공덕동', 'jm.nam@example.com', '010-5000-0030', '2024-02-01', 1, 5, 2, 1),

-- 31~40 (양천/강서/구로/금천/영등포)
    ('심은경', '$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS', '1975-01-31', 'F', '서울시 양천구 목동', 'ek.shim@example.com', '010-5000-0031', '2024-02-01', 1, 5, 2, 1),
    ('노현정', '$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS', '1976-02-28', 'F', '서울시 양천구 신정동', 'hj.noh@example.com', '010-5000-0032', '2024-02-01', 1, 5, 2, 1),
    ('하수진', '$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS', '1972-03-31', 'F', '서울시 강서구 화곡동', 'sj.ha@example.com', '010-5000-0033', '2024-02-01', 1, 5, 2, 1),
    ('곽미연', '$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS', '1968-04-30', 'F', '서울시 강서구 마곡동', 'my.kwak@example.com', '010-5000-0034', '2024-02-01', 1, 5, 2, 1),
    ('성지현', '$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS', '1970-05-31', 'F', '서울시 구로구 구로동', 'jh.sung@example.com', '010-5000-0035', '2024-02-01', 1, 5, 2, 1),
    ('차은주', '$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS', '1979-06-30', 'F', '서울시 구로구 신도림동', 'ej.cha@example.com', '010-5000-0036', '2024-02-01', 1, 5, 2, 1),
    ('주영미', '$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS', '1981-07-31', 'F', '서울시 금천구 가산동', 'ym.joo@example.com', '010-5000-0037', '2024-02-01', 1, 5, 2, 1),
    ('우정희', '$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS', '1973-08-31', 'F', '서울시 금천구 독산동', 'jh.woo@example.com', '010-5000-0038', '2024-02-01', 1, 5, 2, 1),
    ('구민지', '$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS', '1974-09-30', 'F', '서울시 영등포구 여의도동', 'mj.koo@example.com', '010-5000-0039', '2024-02-01', 1, 5, 2, 1),
    ('신영애', '$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS', '1971-10-31', 'F', '서울시 영등포구 문래동', 'ya.shin@example.com', '010-5000-0040', '2024-02-01', 1, 5, 2, 1),

-- 41~50 (동작/관악/용산/종로/중구)
    ('나혜영', '$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS', '1975-01-31', 'F', '서울시 동작구 노량진동', 'hy.na@example.com', '010-5000-0041', '2024-02-01', 1, 5, 2, 1),
    ('진소라', '$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS', '1976-02-28', 'F', '서울시 동작구 사당동', 'sr.jin@example.com', '010-5000-0042', '2024-02-01', 1, 5, 2, 1),
    ('지은희', '$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS', '1972-03-31', 'F', '서울시 관악구 신림동', 'eh.ji@example.com', '010-5000-0043', '2024-02-01', 1, 5, 2, 1),
    ('엄미자', '$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS', '1968-04-30', 'F', '서울시 관악구 봉천동', 'mj.eom@example.com', '010-5000-0044', '2024-02-01', 1, 5, 2, 1),
    ('원정숙', '$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS', '1970-05-31', 'F', '서울시 용산구 이태원동', 'js.won@example.com', '010-5000-0045', '2024-02-01', 1, 5, 2, 1),
    ('방수련', '$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS', '1979-06-30', 'F', '서울시 용산구 한남동', 'sr.bang@example.com', '010-5000-0046', '2024-02-01', 1, 5, 2, 1),
    ('천지혜', '$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS', '1981-07-31', 'F', '서울시 종로구 평창동', 'jh.chun@example.com', '010-5000-0047', '2024-02-01', 1, 5, 2, 1),
    ('류경미', '$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS', '1973-08-31', 'F', '서울시 종로구 혜화동', 'km.ryu@example.com', '010-5000-0048', '2024-02-01', 1, 5, 2, 1),
    ('고영미', '$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS', '1974-09-30', 'F', '서울시 중구 명동', 'ym.ko@example.com', '010-5000-0049', '2024-02-01', 1, 5, 2, 1),
    ('이수정', '$2a$10$Zd8/G4.o2ksF14yiZ38we.unBnNNrGAeNxhYABqa9qV5ZD8ctncOS', '1971-10-31', 'F', '서울시 중구 신당동', 'sj.lee2@example.com', '010-5000-0050', '2024-02-01', 1, 5, 2, 1);


-- -----------------------------------------------------------
-- 3. 직원 근무 이력 (Employee Career)
-- -----------------------------------------------------------
INSERT INTO employee_career
(employee_id, company_name, work_period, task)
SELECT
    e.id AS employee_id,
    c.company_name,
    c.work_period,
    c.task
FROM employee e
         JOIN (
    -- 최대 3개의 근무 이력 후보
    SELECT 1 AS seq,
           ELT(FLOOR(1 + RAND()*10),
               '행복요양병원',
               '사랑재활요양병원',
               '늘봄요양병원',
               '은혜요양병원',
               '푸른요양병원',
               '중앙요양병원',
               '미래요양병원',
               '참사랑요양병원',
               '효드림요양병원',
               '희망요양병원'
           ) AS company_name,
           CONCAT(
                   DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL (36 + FLOOR(RAND()*60)) MONTH), '%Y.%m'),
                   ' ~ ',
                   DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL (12 + FLOOR(RAND()*24)) MONTH), '%Y.%m')
           ) AS work_period,
           ELT(FLOOR(1 + RAND()*8),
               '입원 환자 일상생활 지원 및 케어',
               '식사·위생·배변 보조 업무',
               '환자 이동 및 체위 변경 지원',
               '낙상 예방 및 안전 관리',
               '기초 건강 상태 관찰 및 보고',
               '간호사 및 의료진 보조 업무',
               '요양 기록지 작성 및 관리',
               '보호자 상담 및 응대 지원'
           ) AS task

    UNION ALL

    SELECT 2,
           ELT(FLOOR(1 + RAND()*10),
               '한마음요양원',
               '늘사랑요양원',
               '효마을요양원',
               '은빛요양원',
               '사랑채요양원',
               '정다운요양원',
               '희망케어요양원',
               '온누리요양원',
               '푸른마을요양원',
               '행복동행요양원'
           ),
           CONCAT(
                   DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL (18 + FLOOR(RAND()*36)) MONTH), '%Y.%m'),
                   ' ~ ',
                   DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL (6 + FLOOR(RAND()*12)) MONTH), '%Y.%m')
           ),
           ELT(FLOOR(1 + RAND()*8),
               '어르신 생활 전반 케어',
               '개인 위생 관리 및 목욕 지원',
               '식사 보조 및 투약 확인',
               '정서 지원 및 말벗 서비스',
               '프로그램 활동 보조',
               '생활 공간 정리 및 청결 유지',
               '요양일지 작성',
               '응급 상황 발생 시 초기 대응'
           )

    UNION ALL

    SELECT 3,
           ELT(FLOOR(1 + RAND()*10),
               '새봄재가요양센터',
               '행복재가요양센터',
               '늘함께재가센터',
               '참사랑재가요양센터',
               '온케어요양센터',
               '희망재가복지센터',
               '사랑손재가센터',
               '동행재가요양센터',
               '효나눔재가센터',
               '한결재가요양센터'
           ),
           CONCAT(
                   DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL (6 + FLOOR(RAND()*18)) MONTH), '%Y.%m'),
                   ' ~ ',
                   DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL FLOOR(RAND()*6) MONTH), '%Y.%m')
           ),
           ELT(FLOOR(1 + RAND()*8),
               '방문요양 서비스 제공',
               '가정 내 일상생활 지원',
               '어르신 정서 관리 및 상담',
               '방문 일정 관리',
               '서비스 제공 기록 작성',
               '보호자와 서비스 내용 공유',
               '수급자 상태 변화 보고',
               '장기요양 기준 준수 관리'
           )
) c
-- 직원마다 0~3개 중 랜덤 개수만 삽입
WHERE c.seq <= FLOOR(RAND()*4);

/* [파트 3] 종속 주체 및 관계 데이터
   - 수급자 (FK: potential_customer, m_risk_level)
   - 요양보호사 (FK: employee)
   - 보호자, 등급이력, 위험요소, 태그 등 (FK: beneficiary, care_worker)
   - 직원 권한 (FK: employee, m_authorities)
*/

-- -----------------------------------------------------------
-- 1. 수급자 (Beneficiary) - ID 1~20 생성
-- -----------------------------------------------------------
-- beneficiary: potential_customer_id를 위에서 섞인 ID에 맞춰서 재매핑 INSERT
INSERT INTO beneficiary
(name, gender, birthdate, address, phone, out_of_poket_ratio, status, potential_customer_id, risk_id)
VALUES
    ('김영수', 'M', '1942-01-15', '강남구 역삼1동', '010-1111-0001', 0.20, 1, 37, 3),
    ('이정자', 'F', '1945-03-22', '서초구 서초1동', '010-1111-0002', 0.15, 1, 74, 3),
    ('박종원', 'M', '1939-07-10', '송파구 잠실본동', '010-1111-0003', 0.30, 0, 10, 3),
    ('최미숙', 'F', '1950-11-05', '관악구 청룡동', '010-1111-0004', 0.10, 1, 47, 2),
    ('정호석', 'M', '1948-06-18', '노원구 상계3?4동', '010-1111-0005', 0.25, 0, 84, 1),
    ('오순자', 'F', '1941-02-03', '도봉구 창1동', '010-2222-1001', 0.20, 1, 20, 1),
    ('한병철', 'M', '1937-09-12', '강북구 수유1동', '010-2222-1002', 0.35, 1, 57, 3),
    ('서영희', 'F', '1952-01-27', '은평구 응암1동', '010-2222-1003', 0.10, 1, 94, 2),
    ('신동호', 'M', '1946-08-09', '마포구 망원1동', '010-2222-1004', 0.18, 1, 30, 3),
    ('조은자', 'F', '1954-05-14', '용산구 한강로동', '010-2222-1005', 0.22, 0, 67, 1),
    ('윤재식', 'M', '1940-12-01', '중랑구 면목본동', '010-3333-0001', 0.27, 1, 3, 2),
    ('배말순', 'F', '1947-04-25', '동대문구 장안1동', '010-3333-0002', 0.19, 1, 40, 3),
    ('임성호', 'M', '1938-10-30', '성북구 정릉1동', '010-3333-0003', 0.32, 1, 77, 3),
    ('권정임', 'F', '1951-07-19', '성동구 금호1가동', '010-3333-0004', 0.14, 1, 13, 3),
    ('차동수', 'M', '1944-09-08', '광진구 중곡1동', '010-3333-0005', 0.28, 1, 50, 1),
    ('홍금자', 'F', '1956-02-11', '강서구 화곡본동', '010-4444-0001', 0.12, 1, 87, 2),
    ('문상철', 'M', '1936-06-17', '양천구 신정1동', '010-4444-0002', 0.40, 1, 23, 3),
    ('남정희', 'F', '1949-01-02', '구로구 개봉1동', '010-4444-0003', 0.20, 1, 60, 3),
    ('백영준', 'M', '1943-08-26', '금천구 독산1동', '010-4444-0004', 0.24, 0, 97, 3),
    ('노순례', 'F', '1957-11-29', '영등포구 대림1동', '010-4444-0005', 0.10, 0, 33, 3),
    ('강명자', 'F', '1942-03-15', '강남구 압구정동', '010-6000-0001', 0.15, 1, 70, 2),
    ('고영식', 'M', '1945-06-20', '서초구 잠원동', '010-6000-0002', 0.20, 1, 6, 3),
    ('권순자', 'F', '1938-11-05', '송파구 방이동', '010-6000-0003', 0.15, 1, 43, 3),
    ('김철호', 'M', '1950-01-25', '강동구 천호동', '010-6000-0004', 0.25, 0, 80, 1),
    ('나영희', 'F', '1949-09-12', '마포구 성산동', '010-6000-0005', 0.15, 1, 16, 2),
    ('도진수', 'M', '1940-05-08', '용산구 이촌동', '010-6000-0006', 0.20, 1, 53, 3),
    ('류정숙', 'F', '1955-07-30', '성동구 성수동', '010-6000-0007', 0.15, 1, 90, 3),
    ('마동석', 'M', '1937-12-11', '종로구 평창동', '010-6000-0008', 0.30, 0, 26, 3),
    ('박옥자', 'F', '1943-02-18', '중구 신당동', '010-6000-0009', 0.15, 1, 63, 3),
    ('서상훈', 'M', '1948-08-03', '광진구 자양동', '010-6000-0010', 0.20, 1, 99, 3),
    ('손미자', 'F', '1941-04-22', '동대문구 전농동', '010-6000-0011', 0.15, 1, 35, 2),
    ('신동철', 'M', '1952-10-15', '중랑구 묵동', '010-6000-0012', 0.20, 1, 72, 3),
    ('안경자', 'F', '1939-01-07', '성북구 길음동', '010-6000-0013', 0.15, 1, 8, 3),
    ('양준호', 'M', '1946-06-28', '강북구 미아동', '010-6000-0014', 0.25, 1, 45, 3),
    ('엄혜숙', 'F', '1953-09-09', '도봉구 방학동', '010-6000-0015', 0.15, 1, 82, 2),
    ('오광수', 'M', '1944-03-14', '노원구 중계동', '010-6000-0016', 0.20, 0, 18, 3),
    ('원정희', 'F', '1947-11-20', '은평구 갈현동', '010-6000-0017', 0.15, 1, 55, 3),
    ('유병철', 'M', '1950-05-02', '서대문구 연희동', '010-6000-0018', 0.20, 1, 92, 2),
    ('윤말순', 'F', '1936-08-15', '양천구 신월동', '010-6000-0019', 0.15, 1, 28, 3),
    ('이재호', 'M', '1949-01-30', '강서구 등촌동', '010-6000-0020', 0.20, 1, 65, 3),
    ('임숙자', 'F', '1951-07-07', '구로구 오류동', '010-6000-0021', 0.15, 1, 1, 3),
    ('장석우', 'M', '1942-04-12', '금천구 시흥동', '010-6000-0022', 0.20, 1, 38, 3),
    ('전영자', 'F', '1954-12-05', '영등포구 당산동', '010-6000-0023', 0.15, 1, 75, 3),
    ('정길수', 'M', '1938-10-22', '동작구 흑석동', '010-6000-0024', 0.25, 1, 11, 3),
    ('조현숙', 'F', '1946-02-17', '관악구 봉천동', '010-6000-0025', 0.15, 1, 48, 3),
    ('주성민', 'M', '1955-06-09', '강남구 청담동', '010-6000-0026', 0.20, 1, 85, 2),
    ('지순이', 'F', '1940-09-28', '서초구 방배동', '010-6000-0027', 0.15, 1, 21, 3),
    ('진영수', 'M', '1952-03-11', '송파구 문정동', '010-6000-0028', 0.20, 0, 58, 3),
    ('차명숙', 'F', '1944-11-03', '강동구 명일동', '010-6000-0029', 0.15, 1, 95, 3),
    ('최민호', 'M', '1937-05-19', '마포구 공덕동', '010-6000-0030', 0.20, 1, 31, 3),
    ('하경숙', 'F', '1951-08-25', '용산구 한남동', '010-6000-0031', 0.15, 1, 68, 2),
    ('한상철', 'M', '1945-01-14', '성동구 행당동', '010-6000-0032', 0.20, 1, 4, 3),
    ('허춘자', 'F', '1939-07-06', '종로구 혜화동', '010-6000-0033', 0.15, 1, 41, 3),
    ('홍길동', 'M', '1950-12-21', '중구 을지로동', '010-6000-0034', 0.25, 1, 78, 2),
    ('황금자', 'F', '1948-04-09', '광진구 구의동', '010-6000-0035', 0.15, 1, 14, 3),
    ('강철수', 'M', '1941-10-30', '동대문구 청량리동', '010-6000-0036', 0.20, 0, 51, 1),
    ('권영희', 'F', '1954-02-12', '중랑구 신내동', '010-6000-0037', 0.15, 1, 88, 3),
    ('김동현', 'M', '1938-06-05', '성북구 돈암동', '010-6000-0038', 0.20, 1, 24, 3),
    ('남정숙', 'F', '1947-09-19', '강북구 번동', '010-6000-0039', 0.15, 1, 61, 3),
    ('박성훈', 'M', '1953-03-24', '도봉구 창동', '010-6000-0040', 0.20, 1, 98, 3),
    ('서미숙', 'F', '1942-11-08', '노원구 하계동', '010-6000-0041', 0.15, 1, 34, 3),
    ('손재민', 'M', '1949-05-17', '은평구 응암동', '010-6000-0042', 0.20, 1, 71, 3),
    ('송영자', 'F', '1955-01-28', '서대문구 홍은동', '010-6000-0043', 0.15, 1, 7, 2),
    ('신우진', 'M', '1940-08-11', '마포구 연남동', '010-6000-0044', 0.20, 1, 44, 3),
    ('안정자', 'F', '1946-12-03', '양천구 목동', '010-6000-0045', 0.15, 1, 81, 3),
    ('양현수', 'M', '1952-04-20', '강서구 가양동', '010-6000-0046', 0.25, 0, 17, 3),
    ('오옥분', 'F', '1939-10-14', '구로구 구로동', '010-6000-0047', 0.15, 1, 54, 1),
    ('우상혁', 'M', '1948-02-09', '금천구 가산동', '010-6000-0048', 0.20, 1, 91, 3),
    ('윤귀자', 'F', '1951-07-22', '영등포구 여의도동', '010-6000-0049', 0.15, 1, 27, 3),
    ('이준영', 'M', '1943-05-30', '동작구 노량진동', '010-6000-0050', 0.20, 1, 64, 3);


-- -----------------------------------------------------------
-- 2. 요양보호사 (Care Worker) - ID 1~10 생성
-- -----------------------------------------------------------
INSERT INTO care_worker (employee_id)
SELECT id
FROM employee
WHERE job_code = 5;

-- -----------------------------------------------------------
-- 3. 보호자 (Guardian)
-- -----------------------------------------------------------
INSERT INTO guardian (name, phone, relation, is_primary, beneficiary_id) VALUES
                                                                             ('김지훈', '010-2222-0001', '아들', 'Y', 1),
                                                                             ('박지수', '010-2222-0002', '딸', 'Y', 2),
                                                                             ('이민우', '010-2222-0003', '아들', 'Y', 3),
                                                                             ('정세연', '010-2222-0005', '딸', 'Y', 5),
                                                                             ('오준호', '010-2222-0006', '아들', 'Y', 6),
                                                                             ('한소민', '010-2222-0007', '손녀', 'Y', 7),
                                                                             ('문채원', '010-2222-0009', '딸', 'Y', 9),
                                                                             ('유지훈', '010-2222-0010', '아들', 'Y', 10),
                                                                             ('배수빈', '010-2222-0012', '아들', 'Y', 12),
                                                                             ('신하늘', '010-2222-0013', '딸', 'Y', 13),
                                                                             ('노지훈', '010-2222-0014', '아들', 'Y', 14),
                                                                             ('권유나', '010-2222-0015', '손녀', 'Y', 15),
                                                                             ('조민서', '010-2222-0017', '딸', 'Y', 17),
                                                                             ('설민호', '010-2222-0019', '친구', 'N', 19),
                                                                             ('김도현', '010-2222-0021', '아들', 'Y', 21),
                                                                             ('이준호', '010-2222-0023', '아들', 'Y', 23),
                                                                             ('최은지', '010-2222-0024', '딸', 'Y', 24),
                                                                             ('정우진', '010-2222-0025', '아들', 'Y', 25),
                                                                             ('오수현', '010-2222-0026', '딸', 'Y', 26),
                                                                             ('한지민', '010-2222-0027', '손녀', 'Y', 27),
                                                                             ('장하은', '010-2222-0031', '딸', 'Y', 31),
                                                                             ('배준서', '010-2222-0032', '아들', 'Y', 32),
                                                                             ('권민서', '010-2222-0035', '손녀', 'Y', 35),
                                                                             ('임지훈', '010-2222-0036', '아들', 'Y', 36),
                                                                             ('조아린', '010-2222-0037', '딸', 'Y', 37),
                                                                             ('양수빈', '010-2222-0040', '딸', 'Y', 40),
                                                                             ('김태윤', '010-2222-0041', '아들', 'Y', 41),
                                                                             ('박지안', '010-2222-0042', '딸', 'Y', 42),
                                                                             ('이도윤', '010-2222-0043', '아들', 'Y', 43),
                                                                             ('최다은', '010-2222-0044', '딸', 'Y', 44),
                                                                             ('한시우', '010-2222-0047', '손자', 'Y', 47),
                                                                             ('유채원', '010-2222-0050', '딸', 'Y', 50),
                                                                             ('장도경', '010-2222-0051', '아들', 'Y', 51),
                                                                             ('배예나', '010-2222-0052', '딸', 'Y', 52),
                                                                             ('신민재', '010-2222-0053', '아들', 'Y', 53),
                                                                             ('노수아', '010-2222-0054', '딸', 'Y', 54),
                                                                             ('권태호', '010-2222-0055', '아들', 'Y', 55),
                                                                             ('하윤서', '010-2222-0058', '딸', 'Y', 58),
                                                                             ('설준혁', '010-2222-0059', '아들', 'Y', 59),
                                                                             ('양나은', '010-2222-0060', '딸', 'Y', 60),
                                                                             ('김민규', '010-2222-0061', '아들', 'Y', 61),
                                                                             ('박서우', '010-2222-0062', '딸', 'Y', 62),
                                                                             ('이하준', '010-2222-0063', '아들', 'Y', 63),
                                                                             ('최유진', '010-2222-0064', '딸', 'Y', 64),
                                                                             ('정도훈', '010-2222-0065', '아들', 'Y', 65),
                                                                             ('오나연', '010-2222-0066', '딸', 'Y', 66),
                                                                             ('한준우', '010-2222-0067', '손자', 'Y', 67),
                                                                             ('서윤아', '010-2222-0068', '손녀', 'Y', 68),
                                                                             ('문지호', '010-2222-0069', '아들', 'Y', 69),
                                                                             ('유하린', '010-2222-0070', '딸', 'Y', 70);


-- -----------------------------------------------------------
-- 4. 수급자 상세 정보 (등급, 위험요소, 태그, 특이사항)
-- -----------------------------------------------------------

-- 수급자별 장기요양등급 이력
INSERT INTO beneficiary_care_level (start_date, end_date, number, renewal, beneficiary_id) VALUES
                                                                                               ('2021-01-30','2026-01-30','L0000000001','Y',1),
                                                                                               ('2022-01-20','2026-01-20','L0000000002','N',2),
                                                                                               ('2022-02-10','2026-02-10','L0000000003','Y',3),
                                                                                               ('2022-02-04','2026-02-04','L0000000004','N',4),
                                                                                               ('2024-01-25','2026-01-25','L0000000005','Y',5),
                                                                                               ('2024-02-06','2026-02-06','L0000000006','N',6),
                                                                                               ('2021-02-07','2026-02-07','L0000000007','Y',7),
                                                                                               ('2022-02-08','2026-02-08','L0000000008','N',8),
                                                                                               ('2022-02-09','2026-02-09','L0000000009','Y',9),
                                                                                               ('2022-02-20','2026-02-20','L0000000010','N',10),
                                                                                               ('2024-01-11','2026-01-11','L0000000011','Y',11),
                                                                                               ('2024-01-12','2026-01-12','L0000000012','N',12),
                                                                                               ('2021-01-13','2026-01-13','L0000000013','Y',13),
                                                                                               ('2022-01-14','2026-01-14','L0000000014','N',14),
                                                                                               ('2022-02-15','2026-02-15','L0000000015','Y',15),
                                                                                               ('2022-01-16','2026-01-16','L0000000016','N',16),
                                                                                               ('2024-01-17','2026-01-17','L0000000017','Y',17),
                                                                                               ('2024-01-18','2026-02-18','L0000000018','N',18),
                                                                                               ('2021-03-19','2026-03-19','L0000000019','Y',19),
                                                                                               ('2022-03-20','2026-03-20','L0000000020','N',20),

                                                                                               ('2025-01-21','2029-01-21','L0000000021','Y',21),
                                                                                               ('2025-01-22','2029-01-22','L0000000022','N',22),
                                                                                               ('2025-01-23','2027-01-23','L0000000023','Y',23),
                                                                                               ('2025-01-24','2027-01-24','L0000000024','N',24),
                                                                                               ('2025-01-25','2030-01-25','L0000000025','Y',25),
                                                                                               ('2025-01-26','2029-01-26','L0000000026','N',26),
                                                                                               ('2025-01-27','2029-01-27','L0000000027','Y',27),
                                                                                               ('2025-01-28','2029-01-28','L0000000028','N',28),
                                                                                               ('2025-01-29','2027-01-29','L0000000029','Y',29),
                                                                                               ('2025-01-30','2027-01-30','L0000000030','N',30),
                                                                                               ('2025-01-31','2030-01-31','L0000000031','Y',31),
                                                                                               ('2025-02-01','2029-02-01','L0000000032','N',32),
                                                                                               ('2025-02-02','2029-02-02','L0000000033','Y',33),
                                                                                               ('2025-02-03','2029-02-03','L0000000034','N',34),
                                                                                               ('2025-02-04','2027-02-04','L0000000035','Y',35),
                                                                                               ('2025-02-05','2027-02-05','L0000000036','N',36),
                                                                                               ('2025-02-06','2030-02-06','L0000000037','Y',37),
                                                                                               ('2025-02-07','2029-02-07','L0000000038','N',38),
                                                                                               ('2025-02-08','2029-02-08','L0000000039','Y',39),
                                                                                               ('2025-02-09','2029-02-09','L0000000040','N',40),
                                                                                               ('2025-02-10','2027-02-10','L0000000041','Y',41),
                                                                                               ('2025-02-11','2027-02-11','L0000000042','N',42),
                                                                                               ('2025-02-12','2030-02-12','L0000000043','Y',43),
                                                                                               ('2025-02-13','2029-02-13','L0000000044','N',44),
                                                                                               ('2025-02-14','2029-02-14','L0000000045','Y',45),
                                                                                               ('2025-02-15','2029-02-15','L0000000046','N',46),
                                                                                               ('2025-02-16','2027-02-16','L0000000047','Y',47),
                                                                                               ('2025-02-17','2027-02-17','L0000000048','N',48),
                                                                                               ('2025-02-18','2030-02-18','L0000000049','Y',49),
                                                                                               ('2025-02-19','2029-02-19','L0000000050','N',50),
                                                                                               ('2025-02-20','2029-02-20','L0000000051','Y',51),
                                                                                               ('2025-02-21','2029-02-21','L0000000052','N',52),
                                                                                               ('2025-02-22','2027-02-22','L0000000053','Y',53),
                                                                                               ('2025-02-23','2027-02-23','L0000000054','N',54),
                                                                                               ('2025-02-24','2030-02-24','L0000000055','Y',55),
                                                                                               ('2025-02-25','2029-02-25','L0000000056','N',56),
                                                                                               ('2025-02-26','2029-02-26','L0000000057','Y',57),
                                                                                               ('2025-02-27','2029-02-27','L0000000058','N',58),
                                                                                               ('2025-02-28','2027-02-28','L0000000059','Y',59),
                                                                                               ('2025-03-01','2027-03-01','L0000000060','N',60),
                                                                                               ('2025-03-02','2030-03-02','L0000000061','Y',61),
                                                                                               ('2025-03-03','2029-03-03','L0000000062','N',62),
                                                                                               ('2025-03-04','2029-03-04','L0000000063','Y',63),
                                                                                               ('2025-03-05','2029-03-05','L0000000064','N',64),
                                                                                               ('2025-03-06','2027-03-06','L0000000065','Y',65),
                                                                                               ('2025-03-07','2027-03-07','L0000000066','N',66),
                                                                                               ('2025-03-08','2030-03-08','L0000000067','Y',67),
                                                                                               ('2025-03-09','2029-03-09','L0000000068','N',68),
                                                                                               ('2025-03-10','2029-03-10','L0000000069','Y',69),
                                                                                               ('2025-03-11','2029-03-11','L0000000070','N',70);



-- 수급자별 위험요소 (RiskOfMember)
INSERT INTO riskOfMember (beneficiary_id, risk_id) VALUES
                                                       (1,1),(1,3),(1,6),
                                                       (2,1),(2,2),
                                                       (3,3),(3,1),(3,8),
                                                       (4,9),
                                                       (5,5),
                                                       (6,5),(6,7),
                                                       (7,1),(7,3),
                                                       (8,2),
                                                       (9,3),(9,6),
                                                       (10,1),
                                                       (11,2),
                                                       (12,3),
                                                       (13,1),(13,2),
                                                       (14,3),
                                                       (15,5),
                                                       (16,2),
                                                       (17,1),(17,2),
                                                       (18,1),(18,2),
                                                       (19,6),
                                                       (20,2),(20,3),
                                                       (21,4),(21,1),
                                                       (22,3),(22,4),(22,5),
                                                       (23,1),(23,6),
                                                       (24,7),(24,1),
                                                       (25,4),(25,5),
                                                       (26,1),(26,3),(26,9),
                                                       (27,2),(27,5),
                                                       (28,8),(28,3),
                                                       (29,4),(29,6),
                                                       (30,1),(30,2),
                                                       (31,5),(31,4),(31,7),
                                                       (32,3),(32,6),
                                                       (33,2),(33,9),
                                                       (34,4),(34,6),(34,1),
                                                       (35,5),(35,4),
                                                       (36,1),(36,8),
                                                       (37,2),(37,6),(37,7),
                                                       (38,4),(38,5),
                                                       (39,3),(39,1),(39,7),
                                                       (40,6),(40,4),
                                                       (41,2),(41,5),
                                                       (42,1),(42,9),
                                                       (43,4),(43,5),(43,6),
                                                       (44,3),(44,7),
                                                       (45,2),(45,8),
                                                       (46,1),(46,4),
                                                       (47,6),(47,5),(47,7),
                                                       (48,4),(48,9),
                                                       (49,3),(49,1),
                                                       (50,5),(50,4),(50,6),
                                                       (51,2),(51,7),
                                                       (52,1),(52,3),
                                                       (53,6),(53,8),
                                                       (54,4),(54,5),
                                                       (55,3),(55,2),(55,9),
                                                       (56,1),(56,7),
                                                       (57,4),(57,6),
                                                       (58,2),(58,3),(58,5),
                                                       (59,6),(59,7),
                                                       (60,1),(60,4),(60,5),
                                                       (61,3),(61,8),
                                                       (62,2),(62,6),
                                                       (63,4),(63,5),(63,7),
                                                       (64,3),(64,1),
                                                       (65,2),(65,9),
                                                       (66,6),(66,4),
                                                       (67,5),(67,7),
                                                       (68,1),(68,3),(68,6),
                                                       (69,2),(69,4),
                                                       (70,6),(70,8),(70,5);


-- 수급자 태그 (Tag of Beneficiary)
INSERT INTO tag_of_beneficiary (beneficiary_id, tag_id) VALUES
                                                            (1, 1),(1, 2), (2, 2), (3, 3),(3, 5), (4, 1), (5, 4),
                                                            (6, 2),(6, 3), (7, 5), (8, 1),(8, 4), (9, 3), (10,2),
                                                            (10,5),(11,1), (12,2), (13,3), (14,4), (15,5),(16,1),
                                                            (16,2), (17,3), (18,4), (19,2),(19,5), (20,1),(21, 6),
                                                            (21, 9),(22, 7),(23, 8),(23, 3),(24, 1),(24, 5),(25, 2),
                                                            (26, 4),(26, 6),(27, 9),(28, 3),(28, 7),(29, 5),(30, 6),
                                                            (30, 2),(31, 1),(32, 8),(32, 9),(33, 2),(33, 5),(34, 3),
                                                            (35, 4),(35, 1),(36, 7),(37, 6),(37, 9),(38, 5),(39, 2),
                                                            (39, 8),(40, 3),(40, 6),(41, 1),(41, 9),(42, 4),(43, 7),
                                                            (43, 5),(44, 6),(45, 2),(45, 3),(46, 8),(47, 9),(47, 1),
                                                            (48, 5),(48, 6),(49, 7),(50, 3),(50, 4),(51, 2),(52, 1),
                                                            (52, 8),(53, 6),(53, 7),(54, 9),(55, 5),(55, 2),(56, 3),
                                                            (57, 4),(57, 6),(58, 7),(58, 9),(59, 1),(60, 8),(60, 2),
                                                            (61, 6),(62, 5),(62, 3),(63, 9),(63, 4),(64, 7),(65, 1),
                                                            (65, 2),(66, 6),(66, 8),(67, 3),(68, 4),(68, 9),(69, 7),
                                                            (69, 5),(70, 2),(70, 6);



-- 수급자 특이사항 (Beneficiary Significant)
INSERT INTO beneficiary_significant (beneficiary_id, significant_id) VALUES
                                                                         (1, 1), (1, 6), (2, 2), (3, 7), (3, 8), (4, 1), (5, 9), (5, 10), (6, 3), (7, 4),
                                                                         (8, 5), (9, 6), (10, 1), (11, 7), (12, 8), (13, 9), (14, 10), (15, 2), (16, 3), (17, 4);

-- 수급자 금액산정 (Beneficiary Count)
INSERT INTO beneficiary_count (beneficiary_care_level_id, m_care_level_id) VALUES
                                                                               (1, 1), (2, 2), (3, 3), (4, 4), (5, 5),
                                                                               (6, 6), (7, 1), (8, 2), (9, 3), (10,4),
                                                                               (11,5), (12,6), (13,1), (14,2), (15,3),
                                                                               (16,4), (17,5), (18,6), (19,1), (20,2),
                                                                               (21,3), (22,4), (23,5), (24,6), (25,1),
                                                                               (26,2), (27,3), (28,4), (29,5), (30,6),
                                                                               (31,1), (32,2), (33,3), (34,4), (35,5),
                                                                               (36,6), (37,1), (38,2), (39,3), (40,4),
                                                                               (41,5), (42,6), (43,1), (44,2), (45,3),
                                                                               (46,4), (47,5), (48,6), (49,1), (50,2),
                                                                               (51,3), (52,4), (53,5), (54,6), (55,1),
                                                                               (56,2), (57,3), (58,4), (59,5), (60,6),
                                                                               (61,1), (62,2), (63,3), (64,4), (65,5),
                                                                               (66,6), (67,1), (68,2), (69,3), (70,4);


-- -----------------------------------------------------------
-- 5. 직원 권한 및 요양보호사 상세 (Authorities, Certificate, Education)
-- -----------------------------------------------------------

-- 직원별 권한 (Authorities of Employee)
-- 순서 변경: (authority_code, employee_id) -> (employee_id, authority_code)

-- 1. 센터장 (ID 1)
INSERT INTO authorities_of_employee (employee_id, authority_code) VALUES (1, 5), (1, 2);

-- 2. 영업팀장 (ID 2)
INSERT INTO authorities_of_employee (employee_id, authority_code) VALUES (2, 4), (2, 6), (2, 2);

-- 3. 자재팀장 (ID 3)
INSERT INTO authorities_of_employee (employee_id, authority_code) VALUES (3, 4), (3, 7), (3, 2);

-- 4. 자재팀원 (ID 4~8)
INSERT INTO authorities_of_employee (employee_id, authority_code) VALUES
                                                                      (4, 7), (4, 2),
                                                                      (5, 7), (5, 2),
                                                                      (6, 7), (6, 2),
                                                                      (7, 7), (7, 2),
                                                                      (8, 7), (8, 2);

-- 5. 영업팀원 (ID 9~13)
INSERT INTO authorities_of_employee (employee_id, authority_code) VALUES
                                                                      (9, 6), (9, 2),
                                                                      (10, 6), (10, 2),
                                                                      (11, 6), (11, 2),
                                                                      (12, 6), (12, 2),
                                                                      (13, 6), (13, 2);

-- 6. 요양보호사 (ID 14~23만 예시 등록)
INSERT INTO authorities_of_employee (employee_id, authority_code) VALUES
                                                                      (14, 1), (14, 2),
                                                                      (15, 1), (15, 2),
                                                                      (16, 1), (16, 2),
                                                                      (17, 1), (17, 2),
                                                                      (18, 1), (18, 2),
                                                                      (19, 1), (19, 2),
                                                                      (20, 1), (20, 2),
                                                                      (21, 1), (21, 2),
                                                                      (22, 1), (22, 2),
                                                                      (23, 1), (23, 2);


-- 요양보호사 자격증 (Care Worker Certificate)
INSERT INTO care_worker_certificate
(care_worker_id, certificate_id, license_no, issue_date, expire_date, status)
SELECT
    cw.id AS care_worker_id,
    c.id  AS certificate_id,
    CONCAT('CW', LPAD(cw.id, 4, '0'), '-LIC-', LPAD(c.id, 3, '0')) AS license_no,
    DATE_SUB(CURDATE(), INTERVAL (300 + FLOOR(RAND()*1500)) DAY) AS issue_date,
    DATE_ADD(
            DATE_SUB(CURDATE(), INTERVAL (300 + FLOOR(RAND()*1500)) DAY),
            INTERVAL c.edu_cycle_years YEAR
    ) AS expire_date,
    2 AS status
FROM care_worker cw
         JOIN certificate c ON c.certificate_name = '요양보호사 자격증'
         LEFT JOIN care_worker_certificate cwc
                   ON cwc.care_worker_id = cw.id AND cwc.certificate_id = c.id
WHERE cwc.id IS NULL;

-- 2) 추가 자격증: 사람마다 다르게 / 여러 개 (2~6)
INSERT INTO care_worker_certificate
(care_worker_id, certificate_id, license_no, issue_date, expire_date, status)
SELECT
    cw.id AS care_worker_id,
    c.id  AS certificate_id,
    CONCAT('CW', LPAD(cw.id, 4, '0'), '-LIC-', LPAD(c.id, 3, '0')) AS license_no,
    DATE_SUB(CURDATE(), INTERVAL (30 + FLOOR(RAND()*900)) DAY) AS issue_date,
    DATE_ADD(
            DATE_SUB(CURDATE(), INTERVAL (30 + FLOOR(RAND()*900)) DAY),
            INTERVAL c.edu_cycle_years YEAR
    ) AS expire_date,
    2 AS status
FROM care_worker cw
         JOIN certificate c
              ON c.certificate_name IN (
                                        '치매전문교육 이수증',
                                        '노인돌봄 전문교육 이수증',
                                        '장기요양 실무교육 수료증',
                                        '응급처치 및 심폐소생술',
                                        '감염관리·위생 안전교육'
                  )
         LEFT JOIN care_worker_certificate cwc
                   ON cwc.care_worker_id = cw.id AND cwc.certificate_id = c.id
WHERE cwc.id IS NULL
  AND (
    -- 확률 조절(원하는 만큼 바꿔도 됨)
    (c.certificate_name IN ('치매전문교육 이수증','노인돌봄 전문교육 이수증','응급처치 및 심폐소생술') AND RAND() < 0.55)
        OR
    (c.certificate_name IN ('장기요양 실무교육 수료증','감염관리·위생 안전교육') AND RAND() < 0.40)
    );

-- 요양보호사 교육 이력 (Education)
INSERT INTO education
(care_worker_certificate_id, edu_name, institution, edu_date, next_edu_date, is_overdue, status)
SELECT
    cwc.id AS care_worker_certificate_id,
    c.certificate_name AS edu_name,
    c.organization     AS institution,
    DATE_ADD(cwc.issue_date, INTERVAL FLOOR(RAND()*20) DAY) AS edu_date,
    DATE_ADD(
            DATE_ADD(cwc.issue_date, INTERVAL FLOOR(RAND()*20) DAY),
            INTERVAL c.edu_cycle_years YEAR
    ) AS next_edu_date,
    CASE
        WHEN DATE_ADD(
                     DATE_ADD(cwc.issue_date, INTERVAL FLOOR(RAND()*20) DAY),
                     INTERVAL c.edu_cycle_years YEAR
             ) < CURDATE() THEN TRUE
        ELSE FALSE
        END AS is_overdue,
    2 AS status
FROM care_worker_certificate cwc
         JOIN certificate c ON c.id = cwc.certificate_id
         LEFT JOIN education e ON e.care_worker_certificate_id = cwc.id
WHERE e.id IS NULL;





-- 요양보호사 태그 및 서비스 유형
INSERT INTO tag_of_care_worker (care_worker_id, tag_id) VALUES
                                                            (1,1),(2,2),(3,3),(4,4),(5,5),(6,6),(7,7),(8,8),(9,9),(10,1);

-- 2-1) 방문요양은 100% 배정
INSERT INTO care_worker_service_type (m_service_type_id, care_worker_id)
SELECT mst.id, cw.id
FROM care_worker cw
         JOIN m_service_type mst ON mst.name = '방문요양'
         LEFT JOIN care_worker_service_type cwst
                   ON cwst.care_worker_id = cw.id AND cwst.m_service_type_id = mst.id
WHERE cwst.care_worker_id IS NULL;

-- 2-2) 방문간호/방문목욕은 일부만 추가 배정
INSERT INTO care_worker_service_type (m_service_type_id, care_worker_id)
SELECT mst.id, cw.id
FROM care_worker cw
         JOIN m_service_type mst ON mst.name IN ('방문간호','방문목욕')
         LEFT JOIN care_worker_service_type cwst
                   ON cwst.care_worker_id = cw.id AND cwst.m_service_type_id = mst.id
WHERE cwst.care_worker_id IS NULL
  AND (
    (mst.name='방문간호' AND RAND() < 0.30)
        OR
    (mst.name='방문목욕' AND RAND() < 0.25)
    );

/* [파트 4] 계약 및 물류/매칭 프로세스
   - 계약서 (FK: beneficiary, contract_status)
   - 서류 양식 (FK: beneficiary, m_form_category)
   - 매칭 (FK: beneficiary, care_worker) *중요: ID 매핑 수정됨
   - 용품 재고 (FK: m_care_product, m_location_status)
   - 렌탈 계약 및 상세 (FK: beneficiary, employee, care_product)
*/

-- -----------------------------------------------------------
-- 1. 수급자 계약 정보 (Contract)
-- -----------------------------------------------------------
INSERT INTO contract (id, beneficiary_id, start_date, end_date, file_path, contract_status) VALUES
                                                                                                (1, 1, '2024-01-01', NULL,         '/files/contract/1.pdf',  '진행중'),
                                                                                                (2, 2, '2024-01-05', NULL,         '/files/contract/2.pdf',  '진행중'),
                                                                                                (3, 3, '2023-07-01', '2025-06-30', '/files/contract/3.pdf',  '만료'),
                                                                                                (4, 4, '2024-02-01', NULL,         '/files/contract/4.pdf',  '진행중'),
                                                                                                (5, 5, '2023-10-01', '2024-09-30', '/files/contract/5.pdf',  '해지'),
                                                                                                (6, 6, '2024-01-10', NULL,         '/files/contract/6.pdf',  '진행중'),
                                                                                                (7, 7, '2024-01-15', NULL,         '/files/contract/7.pdf',  '진행중'),
                                                                                                (8, 8, '2023-12-01', '2025-11-30', '/files/contract/8.pdf',  '진행중'),
                                                                                                (9, 9, '2024-01-20', NULL,         '/files/contract/9.pdf',  '진행중'),
                                                                                                (10,10,'2023-06-01', '2024-05-31', '/files/contract/10.pdf', '만료'),
                                                                                                (11,11,'2024-02-01', NULL,         '/files/contract/11.pdf', '진행중'),
                                                                                                (12,12,'2024-02-05', NULL,         '/files/contract/12.pdf', '진행중'),
                                                                                                (13,13,'2023-09-01', '2025-08-31', '/files/contract/13.pdf', '진행중'),
                                                                                                (14,14,'2024-01-01', NULL,         '/files/contract/14.pdf', '진행중'),
                                                                                                (15,15,'2023-11-01', '2025-10-31', '/files/contract/15.pdf', '진행중'),
                                                                                                (16,16,'2024-01-10', NULL,         '/files/contract/16.pdf', '진행중'),
                                                                                                (17,17,'2023-05-01', '2025-04-30', '/files/contract/17.pdf', '진행중'),
                                                                                                (18,18,'2024-02-10', NULL,         '/files/contract/18.pdf', '진행중'),
                                                                                                (19,19,'2023-08-01', '2024-07-31', '/files/contract/19.pdf', '해지'),
                                                                                                (20,20,'2024-01-25', '2025-01-31', '/files/contract/20.pdf', '해지');

-- -----------------------------------------------------------
-- 2. 신청 서류 (Application Form)
-- -----------------------------------------------------------
INSERT INTO application_form
(id, mime_type, file_path, created_at, original_file_name, re_file_name, form_category_id,size)
VALUES
    (1,  'PDF', '/img/beneficiary/template_doctor_opinion.pdf','2025-01-05 11:00:00',
     '의사소견서(양식).pdf',          'template_doctor_opinion.pdf', 1,'119KB'),
    (2,  'PDF', '/img/beneficiary/template_apply_ltc.pdf',     '2025-01-05 11:30:00',
     '장기요양인정 신청,갱신,변경서(양식).pdf','template_apply_ltc.pdf', 2,'128KB'),
    (3,  'PDF', '/img/beneficiary/template_survey_ltc.pdf',    '2025-01-06 09:40:00',
     '장기요양인정조사표(양식).pdf',  'template_survey_ltc.pdf',     3,'123KB'),
    (4,  'PDF', '/img/beneficiary/template_cert_ltc.pdf',      '2025-01-06 10:00:00',
     '장기요양인정서(양식).pdf',      'template_cert_ltc.pdf',       4,'51KB'),
    (5,  'PDF', '/img/beneficiary/template_plan_ltc.pdf',      '2025-01-07 14:10:00',
     '장기요양급여 제공 계획서(양식).pdf','template_plan_ltc.pdf',   5,'70KB'),
    (6,  'PDF', '/img/beneficiary/template_record_visit.pdf',  '2025-01-08 15:00:00',
     '제공기록지(방문요양, 양식).pdf', 'template_record_visit.pdf',  6,'89KB'),
    (7, 'PDF', '/img/beneficiary/template_record_bath.pdf',   '2025-01-09 10:20:00',
     '제공기록지(방문목욕, 양식).pdf', 'template_record_bath.pdf',  7,'75KB'),
    (8, 'PDF', '/img/beneficiary/template_record_nurse.pdf',  '2025-01-09 10:40:00',
     '제공기록지(방문간호, 양식).pdf', 'template_record_nurse.pdf', 8,'64KB'),
    (9, 'PDF', '/img/beneficiary/template_healty.pdf',  '2025-01-09 10:50:00',
     '건강보험(중증치매 등)산정특례 신청서(양식).pdf', 'template_healty.pdf', 9,'149KB');
-- -----------------------------------------------------------
-- 3. 요양보호사 매칭 (Matching)
-- -----------------------------------------------------------
-- [중요] beneficiary_id는 1~20, care_worker_id는 1~10을 사용합니다.
INSERT INTO matching
(start_date, status, beneficiary_id, care_worker_id)
SELECT
    DATE_SUB(CURDATE(), INTERVAL FLOOR(RAND()*30) DAY),
    'Y',
    bs.beneficiary_id,
    cwst.care_worker_id
FROM beneficiary_schedule bs
         JOIN care_worker_service_type cwst
              ON cwst.m_service_type_id = bs.service_type_id
         JOIN care_worker cw
              ON cw.id = cwst.care_worker_id;


-- -----------------------------------------------------------
-- 4. 용품 재고 관리 (Care Product)
-- -----------------------------------------------------------
-- location_status: 1(창고), 2(배송중), 3(대여중), 4(회수중), 5(수리중) 등
INSERT INTO care_product
(id, product_cd, amount, rental_amount, product_status, m_location_status_cd, last_id, bought_date)
VALUES

-- =========================================================
-- C001 침상용품
--   EM001, EM003, EM006, EM009, EM010, EM011, EM012, EM013, EM036, EM037, EM038
-- =========================================================
('EM001-001', 'EM001', 800000.00, 35000.00, 2, 3, 1, '2024-01-15'),  -- [기존]
('EM001-002', 'EM001', 800000.00, 35000.00, 2, 3, 2, '2024-02-10'),  -- [기존]
('EM001-003', 'EM001', 800000.00, 35000.00, 1, 1, 3, '2024-03-05'),  -- [기존]
('EM001-004', 'EM001', 800000.00, 35000.00, 2, 8, 4, '2024-05-12'),
('EM001-005', 'EM001', 800000.00, 35000.00, 4, 9, 5, '2024-07-03'),
('EM003-001', 'EM003', 400000.00, 28000.00, 2, 3, 1, '2024-02-15'),  -- [기존]
('EM003-002', 'EM003', 400000.00, 28000.00, 2, 8, 2, '2024-06-03'),
('EM006-001', 'EM006', 80000.00, 10000.00, 2, 8, 1, '2024-01-28'),
('EM009-001', 'EM009', 1200000.00, 50000.00, 1, 6, 1, '2024-04-05'),
('EM009-002', 'EM009', 1200000.00, 50000.00, 2, 8, 2, '2024-08-19'),
('EM010-001', 'EM010', 450000.00, 20000.00, 1, 1, 1, '2024-03-22'),
('EM010-002', 'EM010', 450000.00, 20000.00, 2, 3, 2, '2024-09-07'),
('EM011-001', 'EM011', 90000.00, 9000.00, 1, 1, 1, '2024-02-11'),
('EM012-001', 'EM012', 150000.00, 12000.00, 2, 8, 1, '2024-06-26'),
('EM013-001', 'EM013', 60000.00, 7000.00, 1, 6, 1, '2024-07-10'),
('EM036-001', 'EM036', 300000.00, 20000.00, 2, 3, 1, '2024-10-02'),
('EM037-001', 'EM037', 85000.00, 9000.00, 1, 1, 1, '2024-08-03'),
('EM038-001', 'EM038', 60000.00, 7000.00, 3, 10, 1, '2024-11-15'),

-- =========================================================
-- C002 이동보조
--   EM002, EM004, EM005, EM014, EM015, EM016, EM017, EM018, EM039, EM040, EM041
-- =========================================================
('EM002-001', 'EM002', 500000.00, 25000.00, 2, 3, 1, '2024-01-20'),  -- [기존]
('EM002-002', 'EM002', 500000.00, 25000.00, 3, 4, 2, '2024-04-01'),  -- [기존]
('EM002-003', 'EM002', 500000.00, 25000.00, 2, 8, 3, '2024-05-05'),
('EM004-001', 'EM004', 150000.00, 18000.00, 2, 3, 1, '2024-03-10'),  -- [기존]
('EM004-002', 'EM004', 150000.00, 18000.00, 1, 1, 2, '2024-05-21'),
('EM005-001', 'EM005', 1200000.00, 45000.00, 2, 8, 1, '2024-03-17'),
('EM014-001', 'EM014', 2500000.00, 90000.00, 2, 8, 1, '2024-04-03'),
('EM015-001', 'EM015', 130000.00, 15000.00, 1, 1, 1, '2024-05-08'),
('EM016-001', 'EM016', 30000.00, 5000.00, 2, 3, 1, '2024-06-14'),
('EM017-001', 'EM017', 5000000.00, 180000.00, 1, 6, 1, '2024-09-01'),
('EM018-001', 'EM018', 70000.00, 8000.00, 2, 8, 1, '2024-07-21'),
('EM039-001', 'EM039', 220000.00, 20000.00, 1, 6, 1, '2024-10-11'),
('EM040-001', 'EM040', 70000.00, 8000.00, 4, 5, 1, '2024-10-11'),
('EM041-001', 'EM041', 2800000.00, 95000.00, 2, 8, 1, '2024-11-06'),

-- =========================================================
-- C003 위생용품
--   EM007, EM019, EM020, EM021, EM022, EM023, EM042, EM043, EM044
-- =========================================================
('EM007-001', 'EM007', 120000.00, 15000.00, 1, 6, 1, '2024-02-22'),
('EM019-001', 'EM019', 110000.00, 14000.00, 2, 3, 1, '2024-03-12'),
('EM020-001', 'EM020', 900000.00, 40000.00, 1, 6, 1, '2024-06-08'),
('EM021-001', 'EM021', 350000.00, 25000.00, 2, 8, 1, '2024-08-04'),
('EM022-001', 'EM022', 40000.00, 6000.00, 1, 1, 1, '2024-02-25'),
('EM023-001', 'EM023', 80000.00, 9000.00, 2, 8, 1, '2024-05-30'),
('EM042-001', 'EM042', 45000.00, 6000.00, 1, 6, 1, '2024-09-18'),
('EM043-001', 'EM043', 95000.00, 10000.00, 4, 9, 1, '2024-10-25'),
('EM044-001', 'EM044', 80000.00, 9000.00, 2, 3, 1, '2024-12-03'),

-- =========================================================
-- C004 안전용품
--   EM008, EM024, EM025, EM026, EM027, EM028, EM045, EM046, EM047
-- =========================================================
('EM008-001', 'EM008', 50000.00, 8000.00, 1, 1, 1, '2024-01-05'),
('EM008-002', 'EM008', 50000.00, 8000.00, 2, 8, 2, '2024-02-14'),
('EM024-001', 'EM024', 30000.00, 4000.00, 1, 1, 1, '2024-02-09'),
('EM025-001', 'EM025', 120000.00, 10000.00, 2, 8, 1, '2024-09-20'),
('EM026-001', 'EM026', 60000.00, 7000.00, 1, 6, 1, '2024-08-29'),
('EM027-001', 'EM027', 50000.00, 6000.00, 2, 3, 1, '2024-10-08'),
('EM028-001', 'EM028', 90000.00, 9000.00, 3, 10, 1, '2024-11-22'),
('EM045-001', 'EM045', 200000.00, 15000.00, 1, 6, 1, '2024-11-05'),
('EM046-001', 'EM046', 40000.00, 5000.00, 1, 1, 1, '2024-12-02'),
('EM047-001', 'EM047', 30000.00, 4000.00, 2, 8, 1, '2024-12-20'),

-- =========================================================
-- C005 재활운동기기
--   EM029, EM030, EM031, EM032, EM048, EM049
-- =========================================================
('EM029-001', 'EM029', 300000.00, 22000.00, 1, 6, 1, '2024-07-06'),
('EM030-001', 'EM030', 200000.00, 18000.00, 2, 3, 1, '2024-09-09'),
('EM031-001', 'EM031', 40000.00, 5000.00, 1, 1, 1, '2024-05-19'),
('EM032-001', 'EM032', 120000.00, 10000.00, 2, 8, 1, '2024-10-01'),
('EM048-001', 'EM048', 25000.00, 4000.00, 1, 6, 1, '2024-11-11'),
('EM049-001', 'EM049', 20000.00, 3000.00, 3, 10, 1, '2024-12-12'),

-- =========================================================
-- C006 생활보조용품
--   EM033, EM034, EM035, EM050
-- =========================================================
('EM033-001', 'EM033', 90000.00, 8000.00, 2, 8, 1, '2024-06-01'),
('EM034-001', 'EM034', 70000.00, 7000.00, 1, 1, 1, '2024-07-22'),
('EM035-001', 'EM035', 30000.00, 4000.00, 2, 3, 1, '2024-10-14'),
('EM050-001', 'EM050', 35000.00, 4000.00, 1, 6, 1, '2024-12-28');


-- -----------------------------------------------------------
-- 5. 렌탈 계약 및 상세 (Rental Contract)
-- -----------------------------------------------------------
-- emp_id: 자재팀장(3) 또는 자재팀원(4)으로 매핑
INSERT INTO rental_contract (beneficiary_id, emp_id, product_cd, contract_status_cd,term_month,wanted_date, start_date,expected_date) VALUES
                      (1, 3, 'EM001', 2, 11, '2024-02-01', '2024-02-01', '2026-01-31'),
                      (2, 3, 'EM002', 2, 10, '2024-02-01', '2024-02-01', '2025-12-31'),
                      (2, 3, 'EM002', 2, 3, '2025-12-02', '2025-12-02', '2026-01-31'),
                      (3, 4, 'EM003', 1, 9, '2024-04-01', '2024-04-01', '2026-01-31'),
                      (4, 4, 'EM004', 2, 12, '2025-11-01', '2025-11-02', '2026-11-01');

-- 렌탈 상세 (어떤 개별 상품이 나갔는지)
INSERT INTO rental_product (rental_contract_cd, rental_status_id, product_id,start_date, end_date) VALUES
                       (2, 3, 'EM002-001','2024-02-01', '2025-11-15'),
                       (2, 1, 'EM002-002','2025-11-16', null),
                       (1, 1, 'EM001-001','2024-02-01', null),
                       (4, 1, 'EM003-001','2024-04-01', null),
                       (5, 1, 'EM004-001','2025-11-02', null);

-- 물류 작업 (입출고 예정)
INSERT INTO product_tasks (status, expected_date, is_confirmed, product_id, employee_id, created_at) VALUES
                                                                                                         (1, '2024-02-01', 'Y', 'EM001-001', 4, '2024-01-31 10:00:00'),
                                                                                                         (0, '2024-04-15', 'N', 'EM002-002', 4, '2024-04-10 14:00:00');

-- 요양보호사 물류 작업 (회수 등)
-- care_worker_id: 1~10
INSERT INTO product_tasks_for_worker (status, expected_date, is_confirmed, completed_at, created_at, product_id, care_worker_id, beneficiary_id) VALUES
                                                                                                                                                     (0, '2024-06-03', 'N', NULL, NOW(), 'EM001-001', 1, 3),
                                                                                                                                                     (1, '2024-06-07', 'Y', '2024-06-07 14:00:00', NOW(), 'EM004-001', 1, 4);

-- 요양보호사 할 일 (ToDo)
INSERT INTO todo_for_care_worker
(todo, todo_date, type, clear_st, create_at, beneficiary_id, care_worker_id)
SELECT
    CASE
        WHEN RAND() < 0.2 THEN '혈압 체크 및 기록'
        WHEN RAND() < 0.4 THEN '식사(수분) 섭취량 확인'
        WHEN RAND() < 0.6 THEN '복약 여부 확인'
        WHEN RAND() < 0.8 THEN '침상 정리 및 체위 변경'
        ELSE '보호자 요청사항 확인'
        END AS todo,
    DATE(NOW() + INTERVAL FLOOR(RAND()*14) DAY) AS todo_date,
    CASE
        WHEN RAND() < 0.5 THEN 'VISIT'
        ELSE 'ETC'
        END AS type,
    CASE WHEN RAND() < 0.25 THEN 1 ELSE 0 END AS clear_st,
    NOW() AS create_at,
    m.beneficiary_id,
    m.care_worker_id
FROM matching m
         JOIN (
    SELECT 1 n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5
) x
WHERE m.status='Y';

-- -----------------------------------------------------------
-- 1. 수급자 서비스 일정 (Beneficiary Schedule)
-- -----------------------------------------------------------
-- 기존 파트 4에서 2건만 들어갔다면, 중복 방지를 위해 삭제 후 다시 넣거나 없는 ID만 넣어야 합니다.
-- 안전하게 전체를 다시 정의합니다. (ID 1, 2가 이미 있다면 무시되거나 에러가 날 수 있으므로 제외하거나 수정 필요)
-- 여기서는 ID 3번부터 이어가거나, 전체를 제공합니다. (충돌 시 기존 데이터 삭제 권장)

INSERT INTO beneficiary_schedule
(day, start_time, end_time, beneficiary_id, service_type_id)
SELECT
    FLOOR(1 + RAND()*7) AS day,           -- 요일
    '09:00:00',
    '10:00:00',
    b.id,
    FLOOR(1 + RAND()*3) AS service_type_id
FROM beneficiary b
         JOIN (
    SELECT 1 n UNION ALL SELECT 2
) x;

-- -----------------------------------------------------------
-- 2. 월별 서비스 금액 누계 (Cost of Beneficiary)
-- -----------------------------------------------------------
INSERT INTO cost_of_beneficiary
(monthly_amount, month, beneficiary_id)
SELECT
    SUM(cbr.calculated_amount),
    DATE_FORMAT(NOW(), '%Y-%m'),
    cbr.beneficiary_id
FROM cost_of_beneficiary_record cbr
GROUP BY cbr.beneficiary_id;

-- -----------------------------------------------------------
-- 3. 응급 알람 (Emergency)
-- -----------------------------------------------------------
INSERT INTO emergency (id, emergency_st, action_st, emergency_time, action_time, beneficiary_id) VALUES
                                                                                                     (1, 'Y', 'Y', '2025-01-05 08:30:00', '2025-01-05 09:00:00', 1),
                                                                                                     (2, 'Y', 'Y', '2025-01-10 21:10:00', '2025-01-10 21:40:00', 2),
                                                                                                     (3, 'Y', 'N', '2025-01-12 07:20:00', NULL, 3),
                                                                                                     (4, 'N', 'N', '2025-01-15 00:00:00', '2025-01-15 00:00:00', 4),
                                                                                                     (5, 'Y', 'Y', '2025-01-18 16:00:00', '2025-01-18 16:30:00', 5),
                                                                                                     (6, 'N', 'N', '2025-01-20 00:00:00', '2025-01-20 00:00:00', 6),
                                                                                                     (7, 'Y', 'Y', '2025-01-22 11:11:00', '2025-01-22 11:40:00', 7),
                                                                                                     (8, 'Y', 'Y', '2025-01-23 19:30:00', '2025-01-23 19:50:00', 8),
                                                                                                     (9, 'N', 'N', '2025-01-24 00:00:00', '2025-01-24 00:00:00', 9),
                                                                                                     (10,'Y', 'Y', '2025-01-25 05:45:00', '2025-01-25 06:00:00', 10),
                                                                                                     (11,'N', 'N', '2025-02-01 00:00:00', '2025-02-01 00:00:00', 11),
                                                                                                     (12,'Y', 'Y', '2025-02-03 14:00:00', '2025-02-03 14:20:00', 12),
                                                                                                     (13,'Y', 'Y', '2025-02-05 10:30:00', '2025-02-05 10:55:00', 13),
                                                                                                     (14,'N', 'N', '2025-02-06 00:00:00', '2025-02-06 00:00:00', 14),
                                                                                                     (15,'Y', 'Y', '2025-02-08 18:40:00', '2025-02-08 19:05:00', 15),
                                                                                                     (16,'N', 'N', '2025-02-10 00:00:00', '2025-02-10 00:00:00', 16),
                                                                                                     (17,'Y', 'Y', '2025-02-12 09:10:00', '2025-02-12 09:30:00', 17),
                                                                                                     (18,'N', 'N', '2025-02-13 00:00:00', '2025-02-13 00:00:00', 18),
                                                                                                     (19,'Y', 'Y', '2025-02-15 22:00:00', '2025-02-15 22:25:00', 19),
                                                                                                     (20,'N', 'N', '2025-02-16 00:00:00', NULL, 20);

-- -----------------------------------------------------------
-- 4. 요양등급 만료 임박 구간 (Expiration of Care Level)
-- -----------------------------------------------------------
INSERT INTO expiration_of_care_level (outbound_status, extends_status, beneficiary_id, emp_id) VALUES
                                                                                                   (  'Y', 'Y',  1, 1),
                                                                                                   ( 'Y', 'Y',  2, 1),
                                                                                                   ( 'N', 'N',  3, 1),
                                                                                                   ( 'Y', 'Y',  4, 2),
                                                                                                   ( 'N', 'Y',  5, 2),
                                                                                                   ( 'Y', 'Y',  6, 1),
                                                                                                   ( 'Y', 'Y',  7, 2),
                                                                                                   ( 'Y', 'Y',  8, 3),
                                                                                                   ( 'Y', 'N',  9, 1),
                                                                                                   ( 'Y', 'Y',  10, 1),
                                                                                                   ( 'N', 'N', 11, 3),
                                                                                                   ( 'N', 'Y', 12, 1),
                                                                                                   ( 'N', 'Y', 13, 2),
                                                                                                   ( 'N', 'Y', 14, 3),
                                                                                                   ( 'N', 'N', 15, 1),
                                                                                                   ( 'N', 'N', 16, 1),
                                                                                                   ( 'N', 'Y', 17, 1),
                                                                                                   ( 'N', 'N', 18, 1),
                                                                                                   ( 'N', 'Y', 19, 1),
                                                                                                   ( 'N', 'Y', 20, 1);


UPDATE expiration_of_care_level e
    JOIN (
        SELECT beneficiary_id, MAX(end_date) AS end_date
        FROM beneficiary_care_level
        GROUP BY beneficiary_id
    ) bcl
    ON bcl.beneficiary_id = e.beneficiary_id
SET e.expired_section =
        CASE
            WHEN DATEDIFF(bcl.end_date, CURDATE()) <= 45 THEN 3
            WHEN DATEDIFF(bcl.end_date, CURDATE()) <= 60 THEN 2
            WHEN DATEDIFF(bcl.end_date, CURDATE()) <= 90 THEN 1
            ELSE NULL
            END
WHERE bcl.end_date IS NOT NULL;


-- -----------------------------------------------------------
-- 5. 만료 알림 (Notice Expiration)
-- -----------------------------------------------------------
-- expiration_id는 위 테이블(expiration_of_care_level)의 ID를 참조합니다.
INSERT INTO notice_expiration (notice_date, memo, expiration_id, emp_id) VALUES
                                                                             ('2025-12-30 10:00:00', '45일 전 1차 안내(전화)',               1, 1),
                                                                             ('2026-01-01 10:00:00', '45일 전 2차 안내(문자)',               1, 1),
                                                                             ('2025-12-29 09:30:00', '45일 전 안내, 보호자 통화 완료',       2, 1),
                                                                             ('2026-01-01 09:30:00', '45일 전 안내, 수급자 직접 통화',         2, 1),
                                                                             ('2026-01-01 15:00:00', '45일 전 안내, 연장 신청 예정',         4, 2),
                                                                             ('2025-12-30 14:10:00', '45일 전 안내, 수급자 직접 통화',       6, 1),
                                                                             ('2026-01-01 14:10:00', '45일 전 안내, 상태 양호',             6, 1),
                                                                             ('2025-11-02 09:00:00', '90일 전 안내, 연락 불가(번호 변경 추정)', 7, 2),
                                                                             ('2025-11-27 13:30:00', '90일 전 안내, 연장 의사 있음',         8, 3),
                                                                             ('2025-12-27 13:30:00', '60일 전 안내, 서류 접수 완료',         8, 3),
                                                                             ('2025-09-29 10:40:00', '90일 전 안내, 방문상담 예정',          9, 1),
                                                                             ('2025-11-29 10:40:00', '60일 전 안내, 일정 확정',             9, 1),
                                                                             ('2025-12-29 10:40:00', '60일 전 안내, 일정 확정',             10, 1),
                                                                             ('2026-01-01 15:40:00', '60일 전 안내, 일정 확정',             10, 1);



/* [파트 5] 업무 로그, 알림 및 정산
   - 방문 일정 (FK: beneficiary, care_worker, m_service_type)
   - 요양 일지 (FK: visit_schedule, employee, beneficiary) *직원ID 14~23 사용
   - 상담 일지 (FK: employee, beneficiary)
   - 알림/AI (FK: employee, beneficiary)
   - 전자결재 (FK: employee)
   - 청구서/영업상태 (FK: beneficiary, potential_customer)
*/

-- -----------------------------------------------------------
-- 1. 방문 일정 (Visit Schedule)
-- -----------------------------------------------------------
-- 방문 완료
-- DONE 방문 (과거 30~90일, 매칭 1건당 10회)
INSERT INTO visit_schedule
(
    start_dt, end_dt, visit_status,
    rfid_start_time, rfid_end_time,
    is_log_written, note,
    service_type_id, care_worker_id, beneficiary_id
)
SELECT
    s.start_dt,
    DATE_ADD(s.start_dt, INTERVAL 1 HOUR) AS end_dt,
    'DONE',

    -- 실제 RFID 시간 (시작 ±10분)
    DATE_ADD(s.start_dt, INTERVAL FLOOR(RAND()*600) SECOND),
    DATE_ADD(s.start_dt, INTERVAL (3600 - FLOOR(RAND()*600)) SECOND),

    0,
    CASE
        WHEN RAND()<0.05 THEN '어르신 컨디션 저하'
        WHEN RAND()<0.05 THEN '보행 시 부축 필요'
        WHEN RAND()<0.05 THEN '혈압 수치 변동'
        ELSE NULL
        END,

    s.service_type_id,
    s.care_worker_id,
    s.beneficiary_id
FROM (
         SELECT
             -- 과거 30~90일 + 랜덤 시간대(09~16시쯤)
             (DATE_SUB(CURDATE(), INTERVAL (30 + FLOOR(RAND()*60)) DAY)
                 + INTERVAL (9 + FLOOR(RAND()*8)) HOUR
                 ) AS start_dt,

             bs.service_type_id,
             m.care_worker_id,
             m.beneficiary_id
         FROM matching m
                  JOIN beneficiary_schedule bs
                       ON bs.beneficiary_id = m.beneficiary_id
                  JOIN care_worker_service_type cwst
                       ON cwst.care_worker_id = m.care_worker_id
                           AND cwst.m_service_type_id = bs.service_type_id
                  JOIN (
             SELECT 1 n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5
             UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10
         ) x
         WHERE m.status='Y'
     ) s
         LEFT JOIN visit_schedule vs
                   ON vs.care_worker_id = s.care_worker_id
                       AND vs.beneficiary_id = s.beneficiary_id
                       AND vs.start_dt = s.start_dt
WHERE vs.vs_id IS NULL
ORDER BY RAND()
LIMIT 500;

-- 방문 예정 (향후 0~30일, 매칭 1건당 20회)
INSERT INTO visit_schedule
(start_dt, end_dt, visit_status, is_log_written, service_type_id, care_worker_id, beneficiary_id)
SELECT
    s.start_dt,
    DATE_ADD(s.start_dt, INTERVAL 1 HOUR) AS end_dt,
    'SCHEDULED',
    0,
    s.service_type_id,
    s.care_worker_id,
    s.beneficiary_id
FROM (
         SELECT
             (CURDATE()
                 + INTERVAL FLOOR(RAND()*30) DAY
                 + INTERVAL (9 + FLOOR(RAND()*10)) HOUR
                 ) AS start_dt,

             bs.service_type_id,
             m.care_worker_id,
             m.beneficiary_id
         FROM matching m
                  JOIN beneficiary_schedule bs
                       ON bs.beneficiary_id = m.beneficiary_id
                  JOIN care_worker_service_type cwst
                       ON cwst.care_worker_id = m.care_worker_id
                           AND cwst.m_service_type_id = bs.service_type_id
                  JOIN (
             SELECT 1 n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5
             UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10
             UNION ALL SELECT 11 UNION ALL SELECT 12 UNION ALL SELECT 13 UNION ALL SELECT 14 UNION ALL SELECT 15
             UNION ALL SELECT 16 UNION ALL SELECT 17 UNION ALL SELECT 18 UNION ALL SELECT 19 UNION ALL SELECT 20
         ) x
         WHERE m.status='Y'
     ) s
         LEFT JOIN visit_schedule vs
                   ON vs.care_worker_id = s.care_worker_id
                       AND vs.beneficiary_id = s.beneficiary_id
                       AND vs.start_dt = s.start_dt
WHERE vs.vs_id IS NULL
ORDER BY RAND()
LIMIT 500;


-- 개인 일정 샘플 데이터
-- care_worker_id = 1 (테스트용)
INSERT INTO personal_schedule (care_worker_id, start_dt, end_dt, schedule_status, title, personal_type_id, custom_type, location, notes)
VALUES
    -- 이번 주 개인 일정
    (1, CURRENT_DATE + INTERVAL 12 HOUR, CURRENT_DATE + INTERVAL 13 HOUR, 'SCHEDULED', '점심 약속', 1, NULL, '강남역 근처 식당', '팀 미팅 겸 점심'),
    (1, CURRENT_DATE + INTERVAL 1 DAY + INTERVAL 10 HOUR, CURRENT_DATE + INTERVAL 1 DAY + INTERVAL 11 HOUR, 'SCHEDULED', '병원 방문', 4, NULL, '서울대병원', '정기검진'),
    (1, CURRENT_DATE + INTERVAL 2 DAY + INTERVAL 14 HOUR, CURRENT_DATE + INTERVAL 2 DAY + INTERVAL 16 HOUR, 'SCHEDULED', '교육 연수', 5, NULL, '요양보호사 교육센터', '직무 교육 참석'),
    (1, CURRENT_DATE + INTERVAL 3 DAY + INTERVAL 18 HOUR, CURRENT_DATE + INTERVAL 3 DAY + INTERVAL 19 HOUR, 'SCHEDULED', '저녁 약속', 8, '가족 모임', '홍대 카페', '친구 만남'),
    (1, CURRENT_DATE - INTERVAL 1 DAY + INTERVAL 13 HOUR, CURRENT_DATE - INTERVAL 1 DAY + INTERVAL 14 HOUR, 'DONE', '월간 회의', 6, NULL, '본사 회의실', '월간 회의'),

    -- 다음 주 개인 일정
    (1, CURRENT_DATE + INTERVAL 7 DAY + INTERVAL 9 HOUR, CURRENT_DATE + INTERVAL 7 DAY + INTERVAL 10 HOUR, 'SCHEDULED', '운동', 2, NULL, '헬스장', '아침 운동'),
    (1, CURRENT_DATE + INTERVAL 8 DAY + INTERVAL 15 HOUR, CURRENT_DATE + INTERVAL 8 DAY + INTERVAL 16 HOUR + INTERVAL 30 MINUTE, 'SCHEDULED', '슈퍼비전', 5, NULL, '센터장실', '사례 슈퍼비전'),

    -- 다른 요양 보호사
    (2, CURRENT_DATE + INTERVAL 11 HOUR + INTERVAL 30 MINUTE, CURRENT_DATE + INTERVAL 12 HOUR + INTERVAL 30 MINUTE, 'SCHEDULED', '점심시간', 1, NULL, NULL, NULL),
    (3, CURRENT_DATE + INTERVAL 1 DAY + INTERVAL 16 HOUR, CURRENT_DATE + INTERVAL 1 DAY + INTERVAL 17 HOUR, 'SCHEDULED', '개인 상담', 7, NULL, '상담실', '심리 상담');

-- -----------------------------------------------------------
-- 2. 요양 일지 (Care Logs)
-- -----------------------------------------------------------
INSERT INTO care_logs
(
    vs_id, service_date, start_time, end_time, service_type,
    created_at, updated_at, is_deleted,
    special_note, care_worker_id, beneficiary_id,
    is_draft
)
SELECT
    vs.vs_id,
    DATE(vs.start_dt),
    TIME(vs.start_dt),
    TIME(vs.end_dt),
    CASE vs.service_type_id
        WHEN 1 THEN 'CARE'   -- 방문요양
        WHEN 2 THEN 'NURSE'  -- 방문간호
        WHEN 3 THEN 'BATH'   -- 방문목욕
        ELSE 'CARE'
        END,
    NOW(), NOW(), 0,
    vs.note,
    vs.care_worker_id,
    vs.beneficiary_id,
    FALSE
FROM visit_schedule vs
         LEFT JOIN care_logs cl
                   ON cl.vs_id = vs.vs_id
WHERE vs.visit_status='DONE'
  AND vs.is_log_written = 0
  AND cl.log_id IS NULL;

UPDATE visit_schedule vs
    JOIN care_logs cl ON cl.vs_id = vs.vs_id
SET vs.is_log_written = 1
WHERE vs.visit_status='DONE'
  AND vs.is_log_written = 0;


-- -----------------------------------------------------------
-- 3. 상담 일지 (Counseling Logs)
-- -----------------------------------------------------------
INSERT INTO counseling_logs
(
    counseling_date, counseling_type, satisfaction,
    visit_purpose, attendees,
    discussion_content, agreement_content,
    next_visit_date,
    counselor_sign_url, guardian_sign_url,
    created_at, care_worker_id, beneficiary_id, is_draft
)
SELECT
    DATE(vs.start_dt) AS counseling_date,
    '정기',
    CASE
        WHEN RAND()<0.2 THEN '불만족'
        WHEN RAND()<0.6 THEN '보통'
        ELSE '만족'
        END,

    '정기 서비스 점검 및 생활/건강 상태 확인',
    '요양보호사 / 수급자',

    CASE
        WHEN RAND()<0.3 THEN '식사량 감소 및 수면 상태 변화 관찰'
        WHEN RAND()<0.6 THEN '거동 시 불안정, 낙상 주의 필요'
        ELSE '정서적 교류 및 말벗 서비스 필요'
        END,

    '현재 상태 유지, 특이사항 발생 시 보호자 공유',
    DATE(vs.start_dt + INTERVAL 30 DAY),

    'https://dummy.local/sign/counselor.png',
    'https://dummy.local/sign/guardian.png',
    NOW(),
    vs.care_worker_id,
    vs.beneficiary_id,
    0
FROM visit_schedule vs
         LEFT JOIN counseling_logs cl
                   ON cl.beneficiary_id = vs.beneficiary_id
                       AND DATE_FORMAT(cl.counseling_date,'%Y-%m')
                          = DATE_FORMAT(vs.start_dt,'%Y-%m')
WHERE vs.visit_status='DONE'
  AND cl.counseling_id IS NULL
GROUP BY
    vs.beneficiary_id,
    DATE_FORMAT(vs.start_dt,'%Y-%m');

-- -----------------------------------------------------------
-- 4. 알림 및 AI Care (Notification & AI)
-- -----------------------------------------------------------
-- 알림 템플릿/규칙/로그
INSERT INTO notification_template (title, content, template_type, created_at, is_active, created_by, severity, target_type_id) VALUES
                                                                                                                                   ('자격증 만료 예정 안내', '귀하의 자격증이 만료됩니다.', 'CERT_EXPIRE', CURDATE(), 1, 1, 2, 1),
                                                                                                                                   ('긴급: 방문 일정 변경', '오늘 오후 3시 방문 일정이 오후 5시로 변경되었습니다.', 'SCHEDULE_CHANGE', CURDATE(), 1, 1, 1, 3),
                                                                                                                                   ('긴급: 수급자 상태 확인 요청', '김영희 수급자님의 건강 상태 확인이 필요합니다.', 'HEALTH_CHECK', CURDATE(), 1, 1, 1, 3),
                                                                                                                                   ('긴급: 요양일지 미작성', '어제 방문한 요양일지가 아직 작성되지 않았습니다.', 'CARE_LOG_REMINDER', CURDATE(), 1, 1, 1, 3),
                                                                                                                                   ('보수교육 이수 안내', '요양보호사 보수교육 이수 기간입니다. 기한 내에 교육을 완료해주세요.', 'EDU_REQUIRED', CURDATE(), 1, 1, 2, 1),
                                                                                                                                   ('전자결재 승인 요청', '결재 대기 중인 전자결재 문서가 있습니다. 확인 후 승인 또는 반려를 진행해주세요.', 'ELECTRONIC_PAYMENT_APPROVAL',CURDATE(), 1, 1, 2, 1),
                                                                                                                                   ('전자결재 승인 완료', '요청하신 전자결재 문서가 최종 승인되었습니다.', 'ELECTRONIC_PAYMENT_APPROVED', CURDATE(), 1, 1, 2, 2),
                                                                                                                                   ('전자결재 반려 안내', '요청하신 전자결재 문서가 반려되었습니다. 반려 사유를 확인해주세요.', 'ELECTRONIC_PAYMENT_REJECTED', CURDATE(), 1, 1, 1, 2);

INSERT INTO notification_rule (template_id, channel_type_id, offset_days, is_active, created_at, created_by, target_type) VALUES
                                                                                                                              (1, 1, 7, 1, CURDATE(), 1, 'EMPLOYEE'),
                                                                                                                              (2, 1, 0, 1, CURDATE(), 1, 'EMPLOYEE'),
                                                                                                                              (3, 2, 0, 1, CURDATE(), 1, 'EMPLOYEE'),
                                                                                                                              (4, 3, 0, 1, CURDATE(), 1, 'EMPLOYEE'),
                                                                                                                              (5, 1, 14,1, CURDATE(), 1, 'EMPLOYEE');

# INSERT INTO notification_log (rule_id, template_id, receiver_id, receiver_type, sent_at, status, read_at) VALUES;

-- AI Care (FK 없음, id는 beneficiary_id와 논리적 연결)
INSERT INTO ai_care (ai_id, ai_content, ai_month, ai_create_at, beneficiary_id, ai_last_log_id, ai_logs_count, ai_last_service_date,ai_input_tokens,ai_output_tokens,ai_total_tokens) VALUES
                                                                                                                                                                                          (1, '4월 건강 상태 양호, 산책 활동 증가함', '2025-12', NOW(), 1,1,1,'2025-12-20',10,20,30),
                                                                                                                                                                                          (2, '수면 패턴 불규칙, 야간 케어 필요', '2025-11', NOW(), 2,2,2,'2025-11-15',15,40,55);

-- -----------------------------------------------------------
-- 5. 전자결재 및 청구서 (Payment & Invoice)
-- -----------------------------------------------------------
SET @base_time := NOW();

INSERT INTO electronic_payment
(
    employee_id,
    electronic_payment_category_id,
    title,
    content,
    status,
    priority,
    amount,
    start_date,
    end_date,
    created_at
)
SELECT
    CASE
        WHEN n % 3 = 0 THEN 14 + (n % 37)
        WHEN n % 3 = 1 THEN 4 + (n % 5)
        ELSE 9 + (n % 5)
        END,
    (n % 4) + 1,
    CONCAT(
            CASE (n % 4) + 1
                WHEN 1 THEN '급여 결재 '
                WHEN 2 THEN '구매 결재 '
                WHEN 3 THEN '휴가 신청 '
                ELSE '출장 신청 '
                END, n
    ),
    CONCAT('전자결재 더미 문서 내용 ', n),
    CASE
        WHEN n % 12 = 0 THEN 2
        WHEN n % 4  = 0 THEN 1
        ELSE 0
        END,
    IF(n % 10 = 0, 0, 1),
    CASE
        WHEN (n % 4) + 1 = 1 THEN 20000000 + (n * 50000)
        WHEN (n % 4) + 1 = 2 THEN 500000 + (n * 15000)
        ELSE NULL
        END,
    CASE
        WHEN (n % 4) + 1 IN (3,4) THEN DATE_ADD(CURDATE(), INTERVAL (n % 30) DAY)
        ELSE NULL
        END,
    CASE
        WHEN (n % 4) + 1 IN (3,4) THEN DATE_ADD(CURDATE(), INTERVAL (n % 30) + 1 DAY)
        ELSE NULL
        END,
    /* ✅ base_time "이후"로 찍기 */
    DATE_ADD(@base_time, INTERVAL n SECOND)
FROM (
         SELECT (a.d + b.d*10) + 1 AS n
         FROM
             (SELECT 0 d UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
              UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) a
                 CROSS JOIN
             (SELECT 0 d UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
              UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) b
         WHERE (a.d + b.d*10) + 1 <= 100
     ) seq;


INSERT INTO electronic_payment_process
(
    electronic_payment_id,
    employee_id,
    step_order,
    status,
    comment,
    processed_at
)
SELECT
    ep.id,
    CASE
        WHEN ep.employee_id BETWEEN 4 AND 8 THEN 3
        ELSE 2
        END,
    1,
    CASE
        WHEN ep.status = 1 THEN 1
        WHEN ep.status = 2 THEN 2
        ELSE 0
        END,
    CASE
        WHEN ep.status = 1 THEN '검토 승인'
        WHEN ep.status = 2 THEN '반려 처리'
        ELSE NULL
        END,
    CASE
        WHEN ep.status IN (1,2) THEN NOW()
        ELSE NULL
        END
FROM electronic_payment ep
WHERE ep.created_at >= @base_time
ORDER BY ep.id
LIMIT 100;

INSERT INTO electronic_payment_process
(
    electronic_payment_id,
    employee_id,
    step_order,
    status,
    comment,
    processed_at
)
SELECT
    ep.id,
    1,
    2,
    CASE WHEN ep.status = 1 THEN 1 ELSE 0 END,
    CASE WHEN ep.status = 1 THEN '최종 승인' ELSE NULL END,
    CASE WHEN ep.status = 1 THEN NOW() ELSE NULL END
FROM electronic_payment ep
WHERE ep.created_at >= @base_time
  AND ep.status <> 2
  AND (ep.id % 2) = 0
ORDER BY ep.id
LIMIT 50;

-- 청구서 (Invoice)
INSERT INTO invoice (beneficiary_id, bill, period_start, period_end, is_sent, total_count, own_count, payment_status, billing_month) VALUES
                                                                                                                                         (1, '2025년 1월 청구서', '2025-01-01', '2025-01-31', '전송', 20, 4, '미납', '2025-01'),
                                                                                                                                         (2, '2025년 1월 청구서', '2025-01-01', '2025-01-31', '전송', 18, 3, '완납', '2025-01'),
                                                                                                                                         (3, '2025년 1월 청구서', '2025-01-01', '2025-01-31', '지불됨', 16, 2, '완납', '2025-01'),
                                                                                                                                         (4, '2025년 1월 청구서', '2025-01-01', '2025-01-31', '초안', 15, 3, '미납', '2025-01');

-- -----------------------------------------------------------
-- 6. 영업/상담 이력 (CRM) - 테스트 데이터를 위한 날짜 다양화
-- -----------------------------------------------------------

-- 1) 잠재고객 단계 이력 (Potential Stage)
-- ID 1: 1단계 진행 중
-- ID 2: 2단계 진행 중
-- ID 3: 이탈 (가입 의사 없음)
INSERT INTO potential_stage
(stage, process_status, process_time, month, html_code, potential_customer_id)
VALUES
    (1, 'P', NOW(), NOW(), '<div class="step1">전화상담 완료</div>', 1),
    (2, 'P', NOW(), NOW(), '<div class="step2">서류 접수중</div>', 2),
    (1, 'F', DATE_SUB(NOW(), INTERVAL 10 DAY), NOW(), '<div class="step1 error">실패</div>', 3);
-- 2) 상담 이력 (Counsel History)
--  잠재고객 상담
INSERT INTO counsel_history
(
    consult_date,
    summary,
    detail,
    guardian_st,
    follow_up,
    follow_up_necessary,
    churn,
    churn_reason,
    m_reservation_channel_id,
    potential_id,
    beneficiary_id,
    counsel_category_id,
    counselor_id
)
SELECT
    DATE_SUB(NOW(), INTERVAL seq.n DAY)                       AS consult_date,
    NULL                                                      AS summary,
    CONCAT('잠재고객 상담 ', seq.n)                            AS detail,
    0                                                         AS guardian_st,
    CASE WHEN seq.n % 4 = 0
             THEN CONCAT('잠재고객 후속 상담 예정 (', seq.n, ')')
         ELSE NULL END                                        AS follow_up,
    CASE WHEN seq.n % 4 = 0 THEN 'Y' ELSE 'N' END             AS follow_up_necessary,
    CASE WHEN seq.n % 10 = 0 THEN 'Y' ELSE 'N' END            AS churn,
    CASE WHEN seq.n % 10 = 0
             THEN '비용 부담으로 계약 진행 중단'
         ELSE NULL END                                        AS churn_reason,
    (seq.n % 4) + 1                                           AS m_reservation_channel_id,
    (seq.n % 100) + 1                                         AS potential_id,   -- 1~100
    NULL                                                      AS beneficiary_id,
    (seq.n % 5) + 1                                           AS counsel_category_id,
    (seq.n % 5) + 9                                           AS counselor_id    -- ⭐ 상담사만
FROM (
         SELECT (a.i + b.i * 10) AS n
         FROM
             (SELECT 0 i UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
              UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) a
                 CROSS JOIN
             (SELECT 0 i UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
              UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) b
     ) seq
LIMIT 100;


--  기존 수급자 본인 상담
INSERT INTO counsel_history
(
    consult_date,
    summary,
    detail,
    guardian_st,
    follow_up,
    follow_up_necessary,
    churn,
    churn_reason,
    m_reservation_channel_id,
    potential_id,
    beneficiary_id,
    counsel_category_id,
    counselor_id
)
SELECT
    DATE_SUB(NOW(), INTERVAL seq.n DAY)        AS consult_date,
    NULL                                       AS summary,
    CONCAT('기존 수급자 본인 상담 ', seq.n)     AS detail,
    0                                          AS guardian_st,
    NULL                                       AS follow_up,
    'N'                                        AS follow_up_necessary,
    'N'                                        AS churn,
    NULL                                       AS churn_reason,
    (seq.n % 4) + 1                            AS m_reservation_channel_id,
    NULL                                       AS potential_id,
    (seq.n % 50) + 1                           AS beneficiary_id,
    (seq.n % 5) + 1                            AS counsel_category_id,
    (seq.n % 5) + 9                            AS counselor_id   -- ⭐ 상담사만
FROM (
         SELECT (a.i + b.i * 10) AS n
         FROM
             (SELECT 0 i UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
              UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) a
                 CROSS JOIN
             (SELECT 0 i UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
              UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) b
     ) seq
LIMIT 100;


-- 기존 수급자 보호자 상담 100건
INSERT INTO counsel_history
(
    consult_date,
    summary,
    detail,
    guardian_st,
    follow_up,
    follow_up_necessary,
    churn,
    churn_reason,
    m_reservation_channel_id,
    potential_id,
    beneficiary_id,
    counsel_category_id,
    counselor_id
)
SELECT
    DATE_SUB(NOW(), INTERVAL seq.n DAY)           AS consult_date,
    NULL                                          AS summary,
    CONCAT('기존 수급자 보호자 상담 ', seq.n)      AS detail,
    1                                             AS guardian_st,
    '보호자 요청 사항 재확인 후 재연락 예정'        AS follow_up,
    'Y'                                           AS follow_up_necessary,
    CASE WHEN seq.n % 8 = 0 THEN 'Y' ELSE 'N' END  AS churn,
    CASE WHEN seq.n % 8 = 0
             THEN '보호자 요청으로 서비스 종료'
         ELSE NULL END                             AS churn_reason,
    (seq.n % 4) + 1                               AS m_reservation_channel_id,
    NULL                                          AS potential_id,
    (seq.n % 50) + 1                              AS beneficiary_id,
    (seq.n % 5) + 1                               AS counsel_category_id,
    (seq.n % 5) + 9                               AS counselor_id   -- ⭐ 상담사만
FROM (
         SELECT (a.i + b.i * 10) AS n
         FROM
             (SELECT 0 i UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
              UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) a
                 CROSS JOIN
             (SELECT 0 i UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
              UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) b
     ) seq
LIMIT 100;

-- ========================================================
-- [중요] 데이터 동기화 (Data Synchronization)
-- 상담 이력(counsel_history)과 단계 이력(potential_stage)을 기반으로
-- 고객 테이블(beneficiary, potential_customer)의 최신 정보를 업데이트합니다.
-- 이 쿼리는 모든 INSERT가 끝난 후 마지막에 실행되어야 합니다.
-- ========================================================

-- 1. 수급자(Beneficiary)의 last_counsel_date 동기화
UPDATE beneficiary b
    JOIN (
        SELECT beneficiary_id, MAX(consult_date) as max_date
        FROM counsel_history
        WHERE beneficiary_id IS NOT NULL
        GROUP BY beneficiary_id
    ) ch ON b.id = ch.beneficiary_id
SET b.last_counsel_date = ch.max_date
WHERE b.id > 0;

-- 2. 잠재고객(Potential Customer)의 last_counsel_date 동기화
UPDATE potential_customer p
    JOIN (
        SELECT potential_id, MAX(consult_date) as max_date
        FROM counsel_history
        WHERE potential_id IS NOT NULL
        GROUP BY potential_id
    ) ch ON p.id = ch.potential_id
SET p.last_counsel_date = ch.max_date
WHERE p.id > 0;

-- 3. 잠재고객(Potential Customer)의 current_stage 동기화
-- potential_stage 테이블에서 가장 높은 단계를 가져와서 설정
UPDATE potential_customer p
    JOIN (
        SELECT potential_customer_id, MAX(stage) as max_stage
        FROM potential_stage
        GROUP BY potential_customer_id
    ) ps ON p.id = ps.potential_customer_id
SET p.current_stage = ps.max_stage
WHERE p.id > 0;

-- 4. current_stage가 NULL인 잠재고객 기본값(1) 처리
UPDATE potential_customer
SET current_stage = 1
WHERE current_stage IS NULL
  AND id > 0;

/* [파트 6] 평가 템플릿 및 결과 데이터 (JSON 포함)
   - 평가 템플릿 (eval_templates): 낙상, 욕창, 인지, 욕구사정 양식 정의
   - 기초 평가 결과 (basic_evaluations): 수급자별 평가 결과 (JSON 저장)
   - FK 참조: beneficiary(id2), employee(id3)
*/

-- -----------------------------------------------------------
-- 1. 평가 템플릿 (Evaluation Templates)
-- -----------------------------------------------------------

-- -----------------------------------------------------------
-- 1. 평가 서식 (Evaluation Templates)
-- -----------------------------------------------------------
INSERT INTO eval_templates (template_id, eval_type, version, name, description, template_json, total_score, is_active) VALUES
-- 1-1. 낙상위험도 평가 (FALL)
(1, 'FALL', 1, '낙상위험도 평가지', '연 1회 낙상위험도 평가 (연령, 정신상태, 낙상병력, 활동, 보행, 균형, 약물/질병 변화 포함)',
 '{
   "title": "낙상위험도 평가",
   "code": "FALL",
   "columns": [
     { "score": 4, "label": "4점" }, { "score": 3, "label": "3점" },
     { "score": 2, "label": "2점" }, { "score": 1, "label": "1점" }, { "score": 0, "label": "0점" }
   ],
   "items": [
     {
       "code": "age", "label": "연령",
       "choices": [ { "score": 3, "label": "80세 이상" }, { "score": 2, "label": "70~79세" }, { "score": 1, "label": "60~69세" }, { "score": 0, "label": "60세 미만" } ]
     },
     {
       "code": "mental_status", "label": "정신상태",
       "choices": [ { "score": 4, "label": "혼란스러움/정신장애" }, { "score": 2, "label": "때때로 혼란스러움/생활환경 장애" }, { "score": 0, "label": "해당없음" } ]
     },
     {
       "code": "stool", "label": "배변",
       "choices": [ { "score": 4, "label": "소변, 대변 실금" }, { "score": 3, "label": "조절능력 있지만 도움필요" }, { "score": 1, "label": "유치도뇨관/인공항문" }, { "score": 0, "label": "해당없음" } ]
     },
     {
       "code": "fall_history", "label": "낙상경험",
       "choices": [ { "score": 4, "label": "이미 세 번 이상 넘어짐" }, { "score": 2, "label": "이미 한 번 또는 두 번 넘어짐" }, { "score": 0, "label": "해당없음" } ]
     },
     {
       "code": "activity", "label": "활동",
       "choices": [ { "score": 4, "label": "전적으로 도움을 받음" }, { "score": 3, "label": "자리에서 일어나 앉기 도움" }, { "score": 1, "label": "자립/세면대,화장실이동" }, { "score": 0, "label": "완전 자립" } ]
     },
     {
       "code": "balance", "label": "걸음걸이 및 균형",
       "choices": [ { "score": 4, "label": "평균적/불안정서 있을 때와 걸을 때 균형을 거의 유지하지 못함" }, { "score": 3, "label": "일어서거나, 걸을 때 기립성 반영/혈압조절 문제" }, { "score": 2, "label": "보행장애/보조도구나 도움으로 걷기" }, { "score": 0, "label": "해당없음" } ]
     },
     {
       "code": "recent", "label": "지난 7일간 약복용이나 계획된 약물",
       "choices": [ { "score": 4, "label": "3개 또는 그 이상의 약 복용" }, { "score": 3, "label": "두 가지 약 복용" }, { "score": 2, "label": "한 가지 약 복용" }, { "score": 0, "label": "해당없음" } ]
     }
   ],
   "grading": {
     "ranges": [
       { "min": 0,  "max": 4,  "label": "낙상 위험 낮음" },
       { "min": 5,  "max": 10, "label": "낙상 위험 높음" },
       { "min": 11, "max": 999, "label": "낙상 위험 매우 높음" }
     ],
     "comment_field": true
   }
 }', 28, 1),

-- 1-2. 욕창위험도 평가 (BEDSORE)
(2, 'BEDSORE', 1, '욕창위험도 평가지 (Braden)', '연 1회 욕창위험도 평가 (감각인지, 습기, 활동성, 움직임, 영양상태, 마찰력/전단력)',
 '{
   "title": "욕창위험도 평가",
   "code": "BEDSORE",
   "columns": [ { "score": 1, "label": "1점" }, { "score": 2, "label": "2점" }, { "score": 3, "label": "3점" }, { "score": 4, "label": "4점" } ],
   "items": [
     { "code": "sensory", "label": "감각인지", "choices": [ { "score": 1, "label": "완전 제한" }, { "score": 2, "label": "매우 제한" }, { "score": 3, "label": "약간 제한" }, { "score": 4, "label": "손상 없음" } ] },
     { "code": "moisture", "label": "습기", "choices": [ { "score": 1, "label": "계속 축축함" }, { "score": 2, "label": "자주 축축함" }, { "score": 3, "label": "가끔 축축함" }, { "score": 4, "label": "거의 없음" } ] },
     { "code": "activity", "label": "활동성", "choices": [ { "score": 1, "label": "침상안정" }, { "score": 2, "label": "의자안정" }, { "score": 3, "label": "가끔 보행" }, { "score": 4, "label": "자주 보행" } ] },
     { "code": "mobility", "label": "움직임", "choices": [ { "score": 1, "label": "완전 부동" }, { "score": 2, "label": "매우 제한" }, { "score": 3, "label": "약간 제한" }, { "score": 4, "label": "제한 없음" } ] },
     { "code": "nutrition", "label": "영양상태", "choices": [ { "score": 1, "label": "매우 불량" }, { "score": 2, "label": "약간 불량" }, { "score": 3, "label": "양호" }, { "score": 4, "label": "매우 양호" } ] },
     { "code": "friction", "label": "마찰력과 전단력", "choices": [ { "score": 1, "label": "문제 있음" }, { "score": 2, "label": "잠재적 문제" }, { "score": 3, "label": "문제 없음" } ] }
   ],
   "grading": {
     "ranges": [
       { "min": 19, "max": 23, "label": "낮음(위험 없음)" },
       { "min": 13, "max": 18, "label": "중간(약간~중도 위험)" },
       { "min": 0, "max": 12, "label": "매우 높음(위험 매우 높음)" }
     ],
     "comment_field": true
   }
 }', 23, 1),

-- 1-3. 인지기능 평가 (COGNITIVE)
(3, 'COGNITIVE', 1, '인지기능 평가 (CIST)', '연 1회 인지기능 평가, 학력 보정 기준을 포함한 CIST 기반 평가',
 '{
   "title": "인지기능 평가",
   "code": "COGNITIVE",
   "max_score": 30,
   "education_levels": [
     { "code": "NO_EDU_READ", "label": "무학(글자 모름)", "cutoff": 14 },
     { "code": "NO_EDU", "label": "무학(글자 앎)", "cutoff": 18 },
     { "code": "ELEMENTARY", "label": "초등학교 졸업", "cutoff": 22 },
     { "code": "MIDDLE_HIGH", "label": "중·고등학교 졸업", "cutoff": 24 },
     { "code": "COLLEGE", "label": "대학교 졸업 이상", "cutoff": 26 }
   ],
   "sections": [
     {
       "code": "A", "title": "지남력 (Orientation)", "max_score": 5,
       "items": [
         { "code": "A1", "question": "올해는 몇 년입니까?", "score": 1 },
         { "code": "A2", "question": "지금은 몇 월입니까?", "score": 1 },
         { "code": "A3", "question": "오늘은 며칠입니까?", "score": 1 },
         { "code": "A4", "question": "오늘은 무슨 요일입니까?", "score": 1 },
         { "code": "A5", "question": "여기는 어디입니까?", "score": 1 }
       ]
     },
     {
       "code": "B", "title": "기억력 - 등록", "max_score": 0,
       "items": [ { "code": "B1", "instruction": "비행기, 연필, 소나무를 따라 말하게 한다", "note": "점수 없음" } ]
     },
     {
       "code": "C", "title": "주의력 (Attention)", "max_score": 3,
       "items": [
         { "code": "C1", "question": "숫자 바로 따라 말하기 (3자리)", "score": 1 },
         { "code": "C2", "question": "숫자 거꾸로 말하기 (3자리)", "score": 1 },
         { "code": "C3", "question": "숫자 거꾸로 말하기 (4자리)", "score": 1 }
       ]
     },
     {
       "code": "D", "title": "시공간 기능 (Visuospatial)", "max_score": 2,
       "items": [
         {
           "code": "D1", "question": "도형 따라 그리기",
           "choices": [ { "score": 2, "label": "두 도형 정확, 교차 정확" }, { "score": 1, "label": "형태 맞으나 교차 오류" }, { "score": 0, "label": "형태 다름" } ]
         }
       ]
     },
     {
       "code": "E", "title": "집행 기능 (Executive Function)", "max_score": 6,
       "items": [
         {
           "code": "E1", "question": "동물 이름 말하기 (1분)",
           "auto_score_rule": [ { "min": 0, "max": 5, "score": 0 }, { "min": 6, "max": 8, "score": 1 }, { "min": 9, "max": 11, "score": 2 }, { "min": 12, "max": 99, "score": 3 } ]
         },
         {
           "code": "E2", "question": "선로 잇기 검사",
           "choices": [ { "score": 3, "label": "실수 없이 시간 내 완료" }, { "score": 2, "label": "스스로 수정하여 완료" }, { "score": 1, "label": "시간 초과/도움 필요" }, { "score": 0, "label": "실패" } ]
         }
       ]
     },
     {
       "code": "F", "title": "기억력 - 회상 (Memory Recall)", "max_score": 10,
       "items": [
         { "code": "F1", "word": "비행기", "choices": [ { "score": 2, "label": "자발 회상" }, { "score": 1, "label": "힌트 회상" }, { "score": 0, "label": "실패" } ] },
         { "code": "F2", "word": "연필", "choices": [ { "score": 2, "label": "자발 회상" }, { "score": 1, "label": "힌트 회상" }, { "score": 0, "label": "실패" } ] },
         { "code": "F3", "word": "소나무", "choices": [ { "score": 2, "label": "자발 회상" }, { "score": 1, "label": "힌트 회상" }, { "score": 0, "label": "실패" } ] },
         { "convert_rule": { "base_total": 6, "converted_total": 10 } }
       ]
     },
     {
       "code": "G", "title": "언어 기능 (Language)", "max_score": 4,
       "items": [
         {
           "code": "G1", "question": "상황 파악 질문",
           "choices": [ { "score": 4, "label": "모두 정답" }, { "score": 3, "label": "부분 정답" }, { "score": 2, "label": "약간 이해" }, { "score": 1, "label": "이해 어려움" }, { "score": 0, "label": "전혀 이해 못함" } ]
         }
       ]
     }
   ],
   "grading": {
     "rule": "education_cutoff",
     "description": "선택된 학력 기준 점수 미만일 경우 인지저하 의심"
   }
 }', 30, 1),

-- 1-4. 욕구사정 평가 (NEEDS)
(4, 'NEEDS', 1, '욕구사정 평가', '신체상태, 질병, 인지·의사소통, 가족환경, 자원활용, 주관적 욕구 등 욕구사정 종합평가',
 '{
   "title": "욕구사정 평가",
   "code": "NEEDS",
   "sections": [
     {
       "code": "1", "title": "일반 상태",
       "items": [
         { "code": "weight", "label": "체중", "type": "number", "unit": "kg" },
         { "code": "height", "label": "키", "type": "number", "unit": "cm" },
         { "code": "nutrition_status", "label": "영양상태", "type": "radio", "choices": ["양호", "적당", "부족", "매우 나쁨"] },
         { "code": "diet_type", "label": "식사형태", "type": "checkbox", "choices": ["일반식", "다진식", "죽식", "미음", "유동식", "연하식", "기타"], "hasTextWhen": ["기타"] },
         { "code": "therapeutic_diet", "label": "치료식이", "type": "checkbox", "choices": ["당뇨식", "저염식", "고단백식", "체중조절식"] },
         { "code": "eating_problem", "label": "식사 시 문제점", "type": "checkbox", "choices": ["양호", "저작곤란", "소화불량", "오심·구토", "연하곤란", "기타"], "hasTextWhen": ["기타"] },
         { "code": "oral_status", "label": "구강상태", "type": "radio", "choices": ["양호", "청결불량", "치아 약함", "틀니", "전존 치아 없음", "기타"], "hasTextWhen": ["기타"] },
         { "code": "urination_status", "label": "배설 양상 - 소변상태", "type": "checkbox", "choices": ["양호", "요실금", "배뇨곤란", "기타"], "hasTextWhen": ["기타"] },
         { "code": "defecation_status", "label": "대변상태", "type": "checkbox", "choices": ["양호", "지속적인 설사", "변비", "기타"], "hasTextWhen": ["기타"] },
         { "code": "diaper_use", "label": "기저귀 여부", "type": "checkbox", "choices": ["기저귀"] }
       ]
     },
     {
       "code": "2", "title": "주요 질병상태",
       "items": [
         { "code": "past_history", "label": "과거 병력", "type": "text" },
         { "code": "current_diagnosis", "label": "현 진단명", "type": "text" },
         { "code": "chronic_disease", "label": "만성질환", "type": "checkbox", "choices": ["당뇨", "고혈압", "만성호흡기질환", "암", "기타"], "hasTextWhen": ["기타"] },
         { "code": "circulatory", "label": "순환기계", "type": "checkbox", "choices": ["뇌경색", "뇌출혈", "협심증", "심근경색증", "기타"], "hasTextWhen": ["기타"] },
         { "code": "neurologic", "label": "신경계", "type": "checkbox", "choices": ["치매", "파킨슨병", "간질", "기타"], "hasTextWhen": ["기타"] },
         { "code": "musculoskeletal", "label": "근골격계", "type": "checkbox", "choices": ["관절염", "요통, 좌골통", "골절 등 후유증", "기타"], "hasTextWhen": ["기타"] },
         { "code": "mental_behavior", "label": "정신·행동장애", "type": "checkbox", "choices": ["중풍", "우울증", "수면장애", "정신질환", "기타"], "hasTextWhen": ["기타"] },
         { "code": "respiratory", "label": "호흡기계", "type": "checkbox", "choices": ["호흡곤란", "결핵", "기타"], "hasTextWhen": ["기타"] },
         { "code": "renal", "label": "만성 신장질환", "type": "checkbox", "choices": ["만성신부전증", "보막투석", "혈액투석", "기타"], "hasTextWhen": ["기타"] },
         { "code": "other_disease", "label": "기타 질환", "type": "checkbox", "choices": ["알레르기", "기타"], "subItems": [ { "code": "allergy_food", "label": "식품", "type": "text", "showWhen": "알레르기" } ], "hasTextWhen": ["기타"] }
       ]
     },
     {
       "code": "3", "title": "신체 상태 (일상생활동작 수행능력)",
       "items": [
         { "code": "adl", "label": "ADL", "type": "table_radio", "rows": ["옷 벗고 입기", "세수하기", "양치질하기", "식사하기", "목욕하기", "체위변경", "일어나 앉기", "옮겨 앉기", "화장실 사용하기", "몸단장하기"], "columns": ["완전자립", "부분도움", "완전도움"] }
       ]
     },
     {
       "code": "4", "title": "인지 상태",
       "items": [
         { "code": "behavior", "label": "행동 증상", "type": "checkbox", "choices": ["망상 (남을 의심하거나, 위험을 느낌)", "환각 (헛것을 보거나 환청을 듣는다.)", "배회 (의미 없이 걷는다.)", "반복적인 행동 (의미 없는 행동을 한다.)", "부적절한 행동 (불결행위 및 숨기는 행동을 한다.)", "폭력적 행동 (주변인에게 폭력적인 행동을 보인다.)", "우울 (슬프거나 처져있고 때로는 운다.)", "불안 (서성이거나, 안절부절 못한다.)"] }
       ]
     },
     {
       "code": "5", "title": "의사소통",
       "items": [
         { "code": "hearing", "label": "청력상태", "type": "radio", "choices": ["정상(보청기 포함)", "가까운 곳 대화 가능", "큰소리만 들음", "소리에 거의 반응 없음", "들리는지 판단 불능"] },
         { "code": "communication", "label": "의사소통", "type": "radio", "choices": ["모두 이해·표현 가능", "대부분 이해하고 의사표현 가능", "가끔 이해하고 의사표현 가능", "거의 이해하지 못하고 의사전달 불가능"] },
         { "code": "speech", "label": "발음능력", "type": "radio", "choices": ["정확함", "옹얼거림", "간혹 왜곡", "전혀 안 됨"] }
       ]
     },
     {
       "code": "6", "title": "가족 및 환경상태",
       "items": [
         { "code": "living_with", "label": "동거인", "type": "checkbox", "choices": ["독거", "배우자", "부모", "자녀", "자부/사위", "손자녀", "친척", "친구/이웃", "기타"], "hasTextWhen": ["기타"] },
         { "code": "children", "label": "자녀수", "type": "compound", "fields": [ { "code": "has_children", "label": "유무", "type": "radio", "choices": ["무", "유"] }, { "code": "son_count", "label": "아들 수", "type": "number", "showWhen": { "has_children": "유" } }, { "code": "daughter_count", "label": "딸 수", "type": "number", "showWhen": { "has_children": "유" } } ] },
         { "code": "main_supporter", "label": "주수발자", "type": "radio", "choices": ["무", "유"] },
         { "code": "supporter_relation", "label": "관계", "type": "radio", "choices": ["배우자", "자녀", "자부", "사위", "형제자매", "친척", "기타"], "hasTextWhen": ["기타"], "showWhen": { "main_supporter": "유" } },
         { "code": "economic", "label": "경제 상태", "type": "radio", "choices": ["안정", "불안정", "연금생활", "기초생활수급", "의료급여"] },
         { "code": "care_burden", "label": "수발 부담", "type": "radio", "choices": ["전혀 부담되지 않음", "아주 가끔 부담됨", "가끔 부담됨", "자주 부담됨", "항상 부담됨"] },
         { "code": "housing", "label": "거주 환경", "type": "radio", "choices": ["아파트", "단독주택", "연립주택", "다세대주택", "기타"], "hasTextWhen": ["기타"] }
       ]
     },
     {
       "code": "7", "title": "자원 이용",
       "items": [
         { "code": "medical_institution", "label": "진료 병원", "type": "compound", "fields": [ { "code": "hospital_name", "label": "병원명(진료과)", "type": "text" }, { "code": "regular_visit", "label": "정기진료", "type": "radio", "choices": ["무", "유"] }, { "code": "hospital_phone", "label": "전화번호", "type": "text", "showWhen": { "regular_visit": "유" } } ] },
         { "code": "religion", "label": "종교활동", "type": "radio", "choices": ["천주교", "기독교", "불교", "기타"], "hasTextWhen": ["기타"] },
         { "code": "community_service", "label": "지역사회 자원", "type": "checkbox", "choices": ["노인맞춤돌봄서비스", "노인돌봄기본서비스", "노인돌봄종합서비스", "단기가사서비스", "독거노인사회관계활성화", "초기독거노인자립지원", "가사간병", "재가복지", "급식및도시락배달", "보건소사업", "개인간병인", "산업재해간병인", "치매안심센터", "복지관(다음희망)", "노인정", "이동서비스", "종교단체", "이미용", "주거개선사업", "기타"], "hasTextWhen": ["기타"] }
       ]
     },
     {
       "code": "8", "title": "주관적 욕구",
       "items": [ { "code": "subjective_need", "label": "수급자 또는 보호자가 희망하는 개별 욕구", "type": "textarea" } ]
     },
     {
       "code": "9", "title": "총평",
       "items": [ { "code": "summary", "label": "종합 소견", "type": "textarea" } ]
     },
     {
       "code": "10", "title": "간호평가",
       "items": [
         { "code": "respiration", "label": "호흡", "type": "checkbox", "choices": ["기관지 절개관 간호", "흡인", "산소요법", "기타"], "hasTextWhen": ["기타"] },
         { "code": "nutrition_nursing", "label": "영양", "type": "checkbox", "choices": ["경관영양", "기타"], "hasTextWhen": ["기타"] },
         { "code": "elimination_nursing", "label": "배설", "type": "checkbox", "choices": ["투석간호", "유치도뇨관", "단순 도뇨", "방광루", "요루", "장루간호"] },
         { "code": "wound", "label": "상처", "type": "checkbox", "choices": ["상처간호", "당뇨발간호", "기타"], "hasTextWhen": ["상처간호", "기타"], "textLabel": { "상처간호": "부위" } },
         { "code": "bedsore_stage", "label": "욕창 단계", "type": "radio", "choices": ["1단계", "2단계", "3단계", "4단계"] },
         { "code": "bedsore_site", "label": "욕창 부위", "type": "checkbox", "choices": ["머리", "등", "어깨", "팔꿈치", "엉덩이", "뒤꿈치", "기타"], "hasTextWhen": ["기타"] },
         { "code": "bedsore_prevention", "label": "욕창 방지 도구", "type": "text" },
         { "code": "pain_cancer_site", "label": "통증 - 암 발생 부위", "type": "checkbox", "choices": ["폐", "위", "대장", "간", "전립선", "유방", "담낭 및 기타담도", "기타"], "hasTextWhen": ["기타"] },
         { "code": "pain_general_site", "label": "일반 통증 부위", "type": "checkbox", "choices": ["머리", "상지", "하지", "허리", "등", "복부", "기타"], "hasTextWhen": ["기타"] }
       ]
     }
   ]
 }', NULL, 1);


-- -----------------------------------------------------------
-- 2. 기초 평가 결과 (Basic Evaluations)
-- -----------------------------------------------------------
-- template_id 1: 낙상 (FALL)
-- template_id 2: 욕창 (BEDSORE)
-- template_id 3: 인지 (COGNITIVE)

INSERT INTO basic_evaluations
(eval_type, template_id, eval_date, eval_data, special_note, created_at, beneficiary_id, care_worker_id, is_draft)
SELECT
    et.eval_type,
    et.template_id,
    DATE(vs.start_dt) AS eval_date,
    JSON_OBJECT(
            'total', FLOOR(RAND()*et.total_score),
            'items', JSON_ARRAY(
                    JSON_OBJECT('no',1,'score',FLOOR(RAND()*6)),
                    JSON_OBJECT('no',2,'score',FLOOR(RAND()*6)),
                    JSON_OBJECT('no',3,'score',FLOOR(RAND()*6))
                     )
    ) AS eval_data,
    CASE
        WHEN RAND() < 0.05 THEN '최근 컨디션 저하 관찰'
        WHEN RAND() < 0.05 THEN '낙상 위험 주의 필요'
        ELSE NULL
        END AS special_note,
    NOW() AS created_at,
    vs.beneficiary_id,
    vs.care_worker_id,
    CASE WHEN RAND() < 0.1 THEN 1 ELSE 0 END AS is_draft
FROM visit_schedule vs
         JOIN (
    SELECT template_id, eval_type, total_score
    FROM eval_templates
    WHERE is_active=1
) et
WHERE RAND() < 0.6;  -- 방문 중 60%만 평가 생성(너무 과도 방지)



/* [추가 데이터] 배정 이력 (Assignment History)
   - 요양보호사(id2)와 수급자(id3) 간의 매칭 변경 이력을 기록합니다.
   - matching 테이블에 있는 현재 데이터와, 과거에 종료된 데이터를 포함합니다.
*/

INSERT INTO assignment_history (start_date, end_date, status, reason, created_at, id2, id3) VALUES
-- 1. 수급자 1번 (현재 요양보호사 1번 배정 중, 과거에 2번이 담당했음)
('2023-01-01', '2023-12-31', '종료', '요양보호사 개인 사정', '2023-01-01 09:00:00', 2, 1),
('2024-01-01', NULL,         '배정', '정기 배정',           '2024-01-01 09:00:00', 1, 1),

-- 2. 수급자 2번 (현재 요양보호사 2번 배정 중)
('2024-04-15', NULL,         '배정', '신규 계약 배정',      '2024-04-15 10:00:00', 2, 2),

-- 3. 수급자 3번 (요양보호사 3번 배정 후 종료됨)
('2023-07-01', '2023-09-30', '종료', '수급자 입원',         '2023-07-01 09:00:00', 3, 3),
('2023-10-01', '2024-03-31', '종료', '계약 만료',           '2023-10-01 09:00:00', 3, 3),

-- 4. 수급자 4번 (요양보호사 4번 -> 보호자 요청으로 중단)
('2024-02-01', '2024-02-20', '중단', '보호자 요청(불만족)', '2024-02-01 14:00:00', 4, 4),

-- 5. 수급자 5번 (요양보호사 5번 -> 단기 종료)
('2024-01-10', '2024-02-05', '종료', '수급자 거주지 이전',  '2024-01-10 11:00:00', 5, 5),

-- 6. 수급자 6번 (장기 근속 배정)
('2023-06-01', NULL,         '배정', '장기 근속 유지',      '2023-06-01 09:00:00', 6, 6),

-- 7. 수급자 7번 (단기 대체 근무 이력)
('2024-01-01', '2024-01-31', '종료', '기존 요양사 휴가 대체', '2024-01-01 09:00:00', 8, 7),
('2024-05-01', '2024-05-31', '종료', '단기 서비스 제공',      '2024-05-01 09:00:00', 7, 7),

-- 8. 수급자 8번 (현재 진행 중)
('2024-03-01', NULL,         '배정', '정기 배정',           '2024-03-01 10:00:00', 8, 8),

-- 9. 수급자 9번 (품질 이슈로 교체 이력)
('2023-12-01', '2024-01-19', '종료', '요양보호사 변경 요청',  '2023-12-01 09:00:00', 10, 9),
('2024-01-20', '2024-03-10', '종료', '서비스 만족도 문제',    '2024-01-20 13:00:00', 9, 9),

-- 10. 수급자 10번 (대기 상태였다가 배정)
('2024-06-01', NULL,         '배정', '신규 배정',           '2024-06-01 09:00:00', 10, 10),

-- 11. 기타 과거 이력 (다양한 케이스)
('2023-05-01', '2023-12-31', '종료', '계약 종료',           '2023-05-01 09:00:00', 5, 11),
('2024-01-01', '2024-02-28', '종료', '수급자 건강 악화',      '2024-01-01 09:00:00', 6, 12),
('2023-09-01', NULL,         '배정', '가족 요양',           '2023-09-01 09:00:00', 7, 13),
('2024-01-01', NULL,         '배정', '주간 보호 병행',      '2024-01-01 09:00:00', 8, 14),
('2023-11-01', '2024-01-31', '종료', '동절기 단기',         '2023-11-01 09:00:00', 9, 15);


-- 월별 서비스유형별 금액 누계 이력(방문일정 테이블 기준)
-- 분 단위로 계산 후 시간 환산 * 단가
-- `rfid_start_time`, `rfid_end_time`가 NULL이면 “아직 출근/퇴근 태그 전”이므로 집계/리스트에서 제외(금액도 아직 확정되지 않은 건으로 취급)
-- => “실제 태그 완료된 건만 보여줌”
INSERT INTO cost_of_beneficiary_record
(visit_schedule_id, beneficiary_id, service_type_id, calculated_amount)
SELECT
    vs.vs_id,
    vs.beneficiary_id,
    vs.service_type_id,
    CASE vs.service_type_id
        WHEN 1 THEN 33000
        WHEN 2 THEN 50000
        WHEN 3 THEN 76000
        END
FROM visit_schedule vs
LIMIT 150;


INSERT INTO product_history
(product_id, product_name, start_date, end_date, status, content, employee_id, employee_name, beneficiary_id, beneficiary_name)
VALUES
-- 1. [EM001-001 전동침대] 사이클: 구매 -> 렌탈
('EM001-001', '전동침대', '2024-01-15 09:00:00', NULL, 'PURCHASED', '신규 장비 제조사 구매 입고', 4, '김자재1', NULL, NULL),
('EM001-001', '전동침대', '2024-02-01 10:00:00', '2025-01-31 23:59:59', 'RENTAL', '장기 요양 렌탈 계약 (12개월)', 4, '김자재1', 1, '김영수'),

-- 2. [EM002-001 휠체어] 사이클: 구매 -> 렌탈 -> 수리
('EM002-001', '휠체어', '2024-01-20 09:00:00', NULL, 'PURCHASED', '신규 장비 제조사 구매 입고', 5, '이자재2', NULL, NULL),
('EM002-001', '휠체어', '2024-03-10 11:00:00', '2024-06-10 11:00:00', 'RENTAL', '단기 렌탈 계약 (3개월)', 5, '이자재2', 2, '이정자'),
('EM002-001', '휠체어', '2024-06-12 14:00:00', '2024-06-15 18:00:00', 'REPAIR', '반납 후 브레이크 점검 및 수리', 5, '이자재2', NULL, NULL),

-- 3. [EM003-001 에어매트] 사이클: 구매 -> 폐기
('EM003-001', '에어매트', '2023-05-01 09:00:00', NULL, 'PURCHASED', '이월 상품 구매', 4, '김자재1', NULL, NULL),
('EM003-001', '에어매트', '2024-12-20 15:30:00', NULL, 'DISCARD', '내구 연한 초과 및 파손으로 인한 폐기', 4, '김자재1', NULL, NULL),

-- 4. [EM004-001 보행보조기] 사이클: 구매 (현재 보관 중)
('EM004-001', '보행보조기', '2024-12-01 09:00:00', NULL, 'PURCHASED', '신규 모델 입고', 5, '이자재2', NULL, NULL),

-- 5. [EM001-002 전동침대] 사이클: 구매 -> 렌탈 (진행 중)
('EM001-002', '전동침대', '2024-06-01 09:00:00', NULL, 'PURCHASED', '추가 물량 확보', 4, '김자재1', NULL, NULL),
('EM001-002', '전동침대', '2024-07-01 10:00:00', '2025-06-30 23:59:59', 'RENTAL', '신규 수급자 렌탈 계약', 5, '이자재2', 3, '박종원');

INSERT INTO beneficiary_history
(join_date, terminate_date, beneficiary_id)
SELECT
    NOW() - INTERVAL FLOOR(RAND()*180) DAY,
    NULL,
    b.id
FROM beneficiary b;