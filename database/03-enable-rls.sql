-- 启用行级安全策略 (RLS)
-- 注意：由于我们使用自定义认证，需要特殊的RLS策略

-- 启用所有表的RLS
ALTER TABLE laboratories ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE reagents ENABLE ROW LEVEL SECURITY;
ALTER TABLE inventory ENABLE ROW LEVEL SECURITY;
ALTER TABLE purchase_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE approvals ENABLE ROW LEVEL SECURITY;
ALTER TABLE usage_records ENABLE ROW LEVEL SECURITY;

-- 由于我们使用自定义认证而不是Supabase Auth，需要创建宽松的策略
-- 在生产环境中，应该根据实际的认证机制调整这些策略

-- laboratories 表策略
CREATE POLICY "Allow all operations on laboratories" ON laboratories FOR ALL USING (true);

-- users 表策略
CREATE POLICY "Allow all operations on users" ON users FOR ALL USING (true);

-- reagents 表策略
CREATE POLICY "Allow all operations on reagents" ON reagents FOR ALL USING (true);

-- inventory 表策略
CREATE POLICY "Allow all operations on inventory" ON inventory FOR ALL USING (true);

-- purchase_requests 表策略
CREATE POLICY "Allow all operations on purchase_requests" ON purchase_requests FOR ALL USING (true);

-- approvals 表策略
CREATE POLICY "Allow all operations on approvals" ON approvals FOR ALL USING (true);

-- usage_records 表策略
CREATE POLICY "Allow all operations on usage_records" ON usage_records FOR ALL USING (true);

-- 注意：在生产环境中，应该实现更严格的RLS策略，例如：
-- 1. 用户只能查看和修改自己的记录
-- 2. 管理员可以查看所有记录
-- 3. 导师可以查看本实验室的记录
-- 4. 学生只能查看自己的记录和公共信息

-- 示例：更严格的用户表策略（注释掉，供参考）
/*
-- 删除宽松策略
DROP POLICY "Allow all operations on users" ON users;

-- 创建严格策略
CREATE POLICY "Users can view their own record" ON users
  FOR SELECT USING (id = current_setting('app.current_user_id')::uuid);

CREATE POLICY "Users can update their own record" ON users
  FOR UPDATE USING (id = current_setting('app.current_user_id')::uuid);

CREATE POLICY "Admins can view all users" ON users
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM users 
      WHERE id = current_setting('app.current_user_id')::uuid 
      AND role = 'admin'
    )
  );
*/

SELECT 'RLS policies created successfully' as status;
