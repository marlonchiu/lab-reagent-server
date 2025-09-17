-- 清空数据库表
-- 注意：这将删除所有现有数据，请确保已备份重要数据

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

-- 清理完成
SELECT 'Database cleanup completed' as status;
