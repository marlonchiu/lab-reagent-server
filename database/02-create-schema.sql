-- 创建数据库结构
-- 实验室试剂管理系统

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

SELECT 'Database schema created successfully' as status;
