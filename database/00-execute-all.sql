-- 完整数据库初始化脚本（UUID修复版）
-- 实验室试剂管理系统
-- 执行顺序：清空 -> 创建结构 -> 启用RLS -> 插入基础数据 -> 插入示例数据

-- ============================================================================
-- 第1步：清空数据库表
-- ============================================================================

-- 删除所有表（按依赖关系顺序）
DROP TABLE IF EXISTS usage_records CASCADE;
DROP TABLE IF EXISTS approvals CASCADE;
DROP TABLE IF EXISTS purchase_requests CASCADE;
DROP TABLE IF EXISTS inventory CASCADE;
DROP TABLE IF EXISTS reagents CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS laboratories CASCADE;

-- 删除可能存在的类型
DROP TYPE IF EXISTS user_role CASCADE;
DROP TYPE IF EXISTS request_status CASCADE;
DROP TYPE IF EXISTS approval_status CASCADE;

-- 删除可能存在的函数
DROP FUNCTION IF EXISTS update_updated_at_column() CASCADE;

SELECT '✅ Step 1: Database cleanup completed' as status;

-- ============================================================================
-- 第2步：创建数据库结构
-- ============================================================================

-- 创建枚举类型
CREATE TYPE user_role AS ENUM ('student', 'teacher', 'admin');
CREATE TYPE request_status AS ENUM ('pending', 'approved', 'rejected', 'completed');
CREATE TYPE approval_status AS ENUM ('pending', 'approved', 'rejected');

-- 创建更新时间触发器函数
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 1. 实验室表
CREATE TABLE laboratories (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  description TEXT,
  location VARCHAR(200),
  contact_person VARCHAR(50),
  contact_phone VARCHAR(20),
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. 用户表（使用用户名+密码认证）
CREATE TABLE users (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  username VARCHAR(50) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  email VARCHAR(100),
  name VARCHAR(50) NOT NULL,
  role user_role NOT NULL,
  laboratory_id UUID REFERENCES laboratories(id),
  student_id VARCHAR(20),
  phone VARCHAR(20),
  avatar_url TEXT,
  is_active BOOLEAN DEFAULT true,
  last_login_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. 试剂表
CREATE TABLE reagents (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  cas_number VARCHAR(50),
  molecular_formula VARCHAR(100),
  molecular_weight DECIMAL(10,4),
  purity VARCHAR(20),
  manufacturer VARCHAR(100),
  supplier VARCHAR(100),
  category VARCHAR(50),
  hazard_level VARCHAR(20),
  storage_conditions TEXT,
  description TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. 库存表
CREATE TABLE inventory (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  reagent_id UUID NOT NULL REFERENCES reagents(id),
  laboratory_id UUID NOT NULL REFERENCES laboratories(id),
  batch_number VARCHAR(50),
  quantity DECIMAL(10,3) NOT NULL DEFAULT 0,
  unit VARCHAR(20) NOT NULL DEFAULT 'g',
  expiry_date DATE,
  purchase_date DATE,
  purchase_price DECIMAL(10,2),
  location VARCHAR(100),
  min_stock_level DECIMAL(10,3) DEFAULT 0,
  notes TEXT,
  created_by UUID REFERENCES users(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. 采购申请表
CREATE TABLE purchase_requests (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  reagent_id UUID NOT NULL REFERENCES reagents(id),
  applicant_id UUID NOT NULL REFERENCES users(id),
  laboratory_id UUID NOT NULL REFERENCES laboratories(id),
  quantity DECIMAL(10,3) NOT NULL,
  unit VARCHAR(20) NOT NULL DEFAULT 'g',
  urgency_level VARCHAR(20) DEFAULT 'normal',
  reason TEXT,
  estimated_cost DECIMAL(10,2),
  supplier_preference VARCHAR(100),
  status request_status DEFAULT 'pending',
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 6. 审批记录表
CREATE TABLE approvals (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  request_id UUID NOT NULL REFERENCES purchase_requests(id),
  approver_id UUID NOT NULL REFERENCES users(id),
  status approval_status NOT NULL,
  comments TEXT,
  approved_quantity DECIMAL(10,3),
  approved_cost DECIMAL(10,2),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 7. 使用记录表
CREATE TABLE usage_records (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  inventory_id UUID NOT NULL REFERENCES inventory(id),
  user_id UUID NOT NULL REFERENCES users(id),
  quantity_used DECIMAL(10,3) NOT NULL,
  unit VARCHAR(20) NOT NULL DEFAULT 'g',
  purpose TEXT,
  experiment_name VARCHAR(200),
  notes TEXT,
  used_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 创建索引
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_laboratory ON users(laboratory_id);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_reagents_name ON reagents(name);
CREATE INDEX idx_reagents_cas ON reagents(cas_number);
CREATE INDEX idx_inventory_reagent ON inventory(reagent_id);
CREATE INDEX idx_inventory_laboratory ON inventory(laboratory_id);
CREATE INDEX idx_purchase_requests_applicant ON purchase_requests(applicant_id);
CREATE INDEX idx_purchase_requests_status ON purchase_requests(status);
CREATE INDEX idx_approvals_request ON approvals(request_id);
CREATE INDEX idx_usage_records_inventory ON usage_records(inventory_id);
CREATE INDEX idx_usage_records_user ON usage_records(user_id);

-- 创建更新时间触发器
CREATE TRIGGER update_laboratories_updated_at BEFORE UPDATE ON laboratories FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_reagents_updated_at BEFORE UPDATE ON reagents FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_inventory_updated_at BEFORE UPDATE ON inventory FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_purchase_requests_updated_at BEFORE UPDATE ON purchase_requests FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

SELECT '✅ Step 2: Database schema created successfully' as status;

-- ============================================================================
-- 第3步：启用RLS并创建安全策略
-- ============================================================================

-- 启用所有表的RLS
ALTER TABLE laboratories ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE reagents ENABLE ROW LEVEL SECURITY;
ALTER TABLE inventory ENABLE ROW LEVEL SECURITY;
ALTER TABLE purchase_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE approvals ENABLE ROW LEVEL SECURITY;
ALTER TABLE usage_records ENABLE ROW LEVEL SECURITY;

-- 创建宽松的策略（适用于自定义认证系统）
CREATE POLICY "Allow all operations on laboratories" ON laboratories FOR ALL USING (true);
CREATE POLICY "Allow all operations on users" ON users FOR ALL USING (true);
CREATE POLICY "Allow all operations on reagents" ON reagents FOR ALL USING (true);
CREATE POLICY "Allow all operations on inventory" ON inventory FOR ALL USING (true);
CREATE POLICY "Allow all operations on purchase_requests" ON purchase_requests FOR ALL USING (true);
CREATE POLICY "Allow all operations on approvals" ON approvals FOR ALL USING (true);
CREATE POLICY "Allow all operations on usage_records" ON usage_records FOR ALL USING (true);

SELECT '✅ Step 3: RLS policies created successfully' as status;

-- ============================================================================
-- 第4步：插入基础数据
-- ============================================================================

-- 插入实验室数据
INSERT INTO laboratories (id, name, description, location, contact_person, contact_phone) VALUES
('550e8400-e29b-41d4-a716-446655440001', '生物医学工程实验室', '主要从事生物医学工程相关研究', '科技楼3楼301室', '张教授', '13800138001'),
('550e8400-e29b-41d4-a716-446655440002', '化学分析实验室', '专业化学分析与检测实验室', '科技楼2楼201室', '李教授', '13800138002'),
('550e8400-e29b-41d4-a716-446655440003', '材料科学实验室', '材料合成与性能测试实验室', '科技楼4楼401室', '王教授', '13800138003');

-- 插入演示用户数据（密码：123456）
INSERT INTO users (id, username, password_hash, email, name, role, laboratory_id, student_id, phone) VALUES
('550e8400-e29b-41d4-a716-446655440011', 'admin', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'admin@lab.com', '系统管理员', 'admin', NULL, NULL, '13700137001'),
('550e8400-e29b-41d4-a716-446655440012', 'teacher', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'teacher@lab.com', '张教授', 'teacher', '550e8400-e29b-41d4-a716-446655440001', NULL, '13800138001'),
('550e8400-e29b-41d4-a716-446655440013', 'teacher2', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'teacher2@lab.com', '李教授', 'teacher', '550e8400-e29b-41d4-a716-446655440002', NULL, '13800138002'),
('550e8400-e29b-41d4-a716-446655440014', 'student', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'student@lab.com', '张同学', 'student', '550e8400-e29b-41d4-a716-446655440001', '2021001', '13900139001'),
('550e8400-e29b-41d4-a716-446655440015', 'student2', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'student2@lab.com', '李同学', 'student', '550e8400-e29b-41d4-a716-446655440001', '2021002', '13900139002'),
('550e8400-e29b-41d4-a716-446655440016', 'student3', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'student3@lab.com', '王同学', 'student', '550e8400-e29b-41d4-a716-446655440002', '2021003', '13900139003');

-- 插入试剂数据
INSERT INTO reagents (id, name, cas_number, molecular_formula, molecular_weight, purity, manufacturer, supplier, category, hazard_level, storage_conditions, description) VALUES
('550e8400-e29b-41d4-a716-446655440101', '乙醇', '64-17-5', 'C2H6O', 46.0684, '99.5%', '国药集团', '国药试剂', '有机溶剂', '易燃', '阴凉干燥处保存，远离火源', '分析纯乙醇，用于溶剂和清洗'),
('550e8400-e29b-41d4-a716-446655440102', '甲醇', '67-56-1', 'CH4O', 32.0419, '99.9%', '国药集团', '国药试剂', '有机溶剂', '有毒易燃', '阴凉干燥处保存，远离火源', '色谱纯甲醇，用于HPLC分析'),
('550e8400-e29b-41d4-a716-446655440103', '丙酮', '67-64-1', 'C3H6O', 58.0791, '99.5%', '西陇科学', '西陇试剂', '有机溶剂', '易燃', '阴凉干燥处保存，远离火源', '分析纯丙酮，用于清洗和萃取'),
('550e8400-e29b-41d4-a716-446655440104', '氯化钠', '7647-14-5', 'NaCl', 58.4428, '99.5%', '国药集团', '国药试剂', '无机盐', '无害', '干燥处保存', '分析纯氯化钠，用于配制缓冲液'),
('550e8400-e29b-41d4-a716-446655440105', '硫酸', '7664-93-9', 'H2SO4', 98.0785, '98%', '国药集团', '国药试剂', '无机酸', '强腐蚀性', '阴凉干燥处保存，防止泄漏', '浓硫酸，用于消解和分析'),
('550e8400-e29b-41d4-a716-446655440106', '氢氧化钠', '1310-73-2', 'NaOH', 39.9971, '96%', '西陇科学', '西陇试剂', '无机碱', '强腐蚀性', '密封保存，防潮', '分析纯氢氧化钠，用于调节pH'),
('550e8400-e29b-41d4-a716-446655440107', '葡萄糖', '50-99-7', 'C6H12O6', 180.1559, '99%', 'Sigma', 'Sigma-Aldrich', '生物试剂', '无害', '干燥处保存', 'D-葡萄糖，用于细胞培养'),
('550e8400-e29b-41d4-a716-446655440108', 'EDTA', '60-00-4', 'C10H16N2O8', 292.2426, '99%', 'Sigma', 'Sigma-Aldrich', '螯合剂', '低毒', '干燥处保存', '乙二胺四乙酸，用于螯合金属离子'),
('550e8400-e29b-41d4-a716-446655440109', '甲基橙', '547-58-0', 'C14H14N3NaO3S', 327.3336, '98%', '天津化学', '天津试剂', '指示剂', '低毒', '避光保存', 'pH指示剂，变色范围3.1-4.4'),
('550e8400-e29b-41d4-a716-446655440110', '酚酞', '77-09-8', 'C20H14O4', 318.3230, '98%', '天津化学', '天津试剂', '指示剂', '低毒', '避光保存', 'pH指示剂，变色范围8.2-10.0');

-- 插入库存数据
INSERT INTO inventory (id, reagent_id, laboratory_id, batch_number, quantity, unit, expiry_date, purchase_date, purchase_price, location, min_stock_level, created_by) VALUES
('550e8400-e29b-41d4-a716-446655440021', '550e8400-e29b-41d4-a716-446655440101', '550e8400-e29b-41d4-a716-446655440001', 'ET20240101', 1850.0, 'mL', '2025-12-31', '2024-01-15', 45.00, 'A1-01', 500.0, '550e8400-e29b-41d4-a716-446655440012'),
('550e8400-e29b-41d4-a716-446655440022', '550e8400-e29b-41d4-a716-446655440102', '550e8400-e29b-41d4-a716-446655440001', 'MT20240102', 920.0, 'mL', '2025-06-30', '2024-01-15', 85.00, 'A1-02', 200.0, '550e8400-e29b-41d4-a716-446655440012'),
('550e8400-e29b-41d4-a716-446655440023', '550e8400-e29b-41d4-a716-446655440104', '550e8400-e29b-41d4-a716-446655440001', 'NC20240103', 412.4, 'g', '2026-12-31', '2024-01-15', 25.00, 'A2-01', 100.0, '550e8400-e29b-41d4-a716-446655440012'),
('550e8400-e29b-41d4-a716-446655440024', '550e8400-e29b-41d4-a716-446655440107', '550e8400-e29b-41d4-a716-446655440001', 'GL20240104', 223.0, 'g', '2025-08-31', '2024-01-15', 120.00, 'B1-01', 50.0, '550e8400-e29b-41d4-a716-446655440012'),
('550e8400-e29b-41d4-a716-446655440025', '550e8400-e29b-41d4-a716-446655440108', '550e8400-e29b-41d4-a716-446655440001', 'ED20240105', 97.1, 'g', '2026-03-31', '2024-01-15', 180.00, 'B1-02', 20.0, '550e8400-e29b-41d4-a716-446655440012'),
('550e8400-e29b-41d4-a716-446655440026', '550e8400-e29b-41d4-a716-446655440103', '550e8400-e29b-41d4-a716-446655440002', 'AC20240201', 1300.0, 'mL', '2025-09-30', '2024-02-01', 55.00, 'C1-01', 300.0, '550e8400-e29b-41d4-a716-446655440013'),
('550e8400-e29b-41d4-a716-446655440027', '550e8400-e29b-41d4-a716-446655440105', '550e8400-e29b-41d4-a716-446655440002', 'SA20240202', 2400.0, 'mL', '2025-12-31', '2024-02-01', 95.00, 'C2-01', 500.0, '550e8400-e29b-41d4-a716-446655440013'),
('550e8400-e29b-41d4-a716-446655440028', '550e8400-e29b-41d4-a716-446655440106', '550e8400-e29b-41d4-a716-446655440002', 'SH20240203', 496.0, 'g', '2025-11-30', '2024-02-01', 35.00, 'C2-02', 100.0, '550e8400-e29b-41d4-a716-446655440013'),
('550e8400-e29b-41d4-a716-446655440029', '550e8400-e29b-41d4-a716-446655440109', '550e8400-e29b-41d4-a716-446655440002', 'MO20240204', 49.9, 'g', '2026-06-30', '2024-02-01', 65.00, 'D1-01', 10.0, '550e8400-e29b-41d4-a716-446655440013'),
('550e8400-e29b-41d4-a716-446655440030', '550e8400-e29b-41d4-a716-446655440110', '550e8400-e29b-41d4-a716-446655440002', 'PP20240205', 24.95, 'g', '2026-06-30', '2024-02-01', 45.00, 'D1-02', 5.0, '550e8400-e29b-41d4-a716-446655440013');

SELECT '✅ Step 4: Base data inserted successfully' as status;

-- ============================================================================
-- 第5步：插入示例业务数据
-- ============================================================================

-- 插入采购申请数据
INSERT INTO purchase_requests (id, reagent_id, applicant_id, laboratory_id, quantity, unit, urgency_level, reason, estimated_cost, supplier_preference, status, notes) VALUES
('550e8400-e29b-41d4-a716-446655440031', '550e8400-e29b-41d4-a716-446655440101', '550e8400-e29b-41d4-a716-446655440014', '550e8400-e29b-41d4-a716-446655440001', 1000.0, 'mL', 'normal', '实验需要大量乙醇作为溶剂', 35.00, '国药试剂', 'completed', '已采购并入库'),
('550e8400-e29b-41d4-a716-446655440032', '550e8400-e29b-41d4-a716-446655440107', '550e8400-e29b-41d4-a716-446655440015', '550e8400-e29b-41d4-a716-446655440001', 100.0, 'g', 'high', '细胞培养实验急需葡萄糖', 48.00, 'Sigma-Aldrich', 'completed', '紧急采购，已到货'),
('550e8400-e29b-41d4-a716-446655440033', '550e8400-e29b-41d4-a716-446655440102', '550e8400-e29b-41d4-a716-446655440014', '550e8400-e29b-41d4-a716-446655440001', 500.0, 'mL', 'normal', 'HPLC分析需要色谱纯甲醇', 85.00, '国药试剂', 'approved', '等待采购部门处理'),
('550e8400-e29b-41d4-a716-446655440034', '550e8400-e29b-41d4-a716-446655440105', '550e8400-e29b-41d4-a716-446655440016', '550e8400-e29b-41d4-a716-446655440002', 1000.0, 'mL', 'normal', '样品消解需要浓硫酸', 38.00, '国药试剂', 'approved', '已批准，等待采购'),
('550e8400-e29b-41d4-a716-446655440035', '550e8400-e29b-41d4-a716-446655440103', '550e8400-e29b-41d4-a716-446655440015', '550e8400-e29b-41d4-a716-446655440001', 200.0, 'mL', 'low', '清洗玻璃器皿需要丙酮', 22.00, '西陇试剂', 'pending', '等待导师审批'),
('550e8400-e29b-41d4-a716-446655440036', '550e8400-e29b-41d4-a716-446655440108', '550e8400-e29b-41d4-a716-446655440014', '550e8400-e29b-41d4-a716-446655440001', 50.0, 'g', 'normal', '金属离子螯合实验需要EDTA', 90.00, 'Sigma-Aldrich', 'pending', '新实验项目申请'),
('550e8400-e29b-41d4-a716-446655440037', '550e8400-e29b-41d4-a716-446655440106', '550e8400-e29b-41d4-a716-446655440016', '550e8400-e29b-41d4-a716-446655440002', 1000.0, 'g', 'low', '想要大量氢氧化钠做实验', 70.00, '西陇试剂', 'rejected', '申请量过大，已拒绝');

-- 插入审批记录数据
INSERT INTO approvals (id, request_id, approver_id, status, comments, approved_quantity, approved_cost) VALUES
('550e8400-e29b-41d4-a716-446655440041', '550e8400-e29b-41d4-a716-446655440031', '550e8400-e29b-41d4-a716-446655440012', 'approved', '实验需要合理，批准采购', 1000.0, 35.00),
('550e8400-e29b-41d4-a716-446655440042', '550e8400-e29b-41d4-a716-446655440032', '550e8400-e29b-41d4-a716-446655440012', 'approved', '紧急实验需要，优先采购', 100.0, 48.00),
('550e8400-e29b-41d4-a716-446655440043', '550e8400-e29b-41d4-a716-446655440033', '550e8400-e29b-41d4-a716-446655440012', 'approved', '色谱分析必需，批准采购', 500.0, 85.00),
('550e8400-e29b-41d4-a716-446655440044', '550e8400-e29b-41d4-a716-446655440034', '550e8400-e29b-41d4-a716-446655440013', 'approved', '样品处理需要，批准采购', 1000.0, 38.00),
('550e8400-e29b-41d4-a716-446655440045', '550e8400-e29b-41d4-a716-446655440037', '550e8400-e29b-41d4-a716-446655440013', 'rejected', '申请量过大，超出实验需要，建议减少用量后重新申请', NULL, NULL);

SELECT '✅ Step 5: Sample business data inserted successfully' as status;

-- ============================================================================
-- 数据库初始化完成
-- ============================================================================

-- 显示创建的用户账户信息
SELECT
  '🎉 数据库初始化完成！' as message,
  '以下是可用的演示账户：' as accounts_info;

SELECT
  username as 用户名,
  name as 姓名,
  role as 角色,
  email as 邮箱,
  '123456' as 密码,
  CASE
    WHEN role = 'admin' THEN '系统管理员，可管理所有数据'
    WHEN role = 'teacher' THEN '导师，可审批申请和管理实验室'
    WHEN role = 'student' THEN '学生，可申请试剂和记录使用'
  END as 权限说明
FROM users
WHERE username IN ('admin', 'teacher', 'student', 'teacher2', 'student2', 'student3')
ORDER BY
  CASE role
    WHEN 'admin' THEN 1
    WHEN 'teacher' THEN 2
    WHEN 'student' THEN 3
  END, username;

-- 显示数据统计
SELECT
  '📊 数据统计' as category,
  (SELECT count(*) FROM laboratories) as 实验室数量,
  (SELECT count(*) FROM users) as 用户数量,
  (SELECT count(*) FROM reagents) as 试剂种类,
  (SELECT count(*) FROM inventory) as 库存记录,
  (SELECT count(*) FROM purchase_requests) as 采购申请,
  (SELECT count(*) FROM approvals) as 审批记录;
