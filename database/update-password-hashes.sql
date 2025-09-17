-- 更新密码哈希为带盐值的格式
-- 注意：这个脚本将所有演示用户的密码更新为使用盐值的SHA256哈希

-- 如果您想使用带盐值的哈希（SHA256(password + 'lab_reagent_salt')），请执行以下更新：

-- 更新演示用户的密码哈希
UPDATE users SET password_hash = 'c9f3bd241194b2622023c98205a45cd6e93ada03971b8ddf55c6a73f333ba9b2' 
WHERE username IN ('admin', 'teacher', 'teacher2', 'student', 'student2', 'student3');

-- 验证更新结果
SELECT 
  username,
  name,
  password_hash,
  '密码: 123456 (带盐值哈希)' as password_info
FROM users 
WHERE username IN ('admin', 'teacher', 'teacher2', 'student', 'student2', 'student3')
ORDER BY role, username;

-- 说明：
-- 新的哈希值 'c9f3bd241194b2622023c98205a45cd6e93ada03971b8ddf55c6a73f333ba9b2' 
-- 对应 SHA256('123456' + 'lab_reagent_salt')

-- 如果您想保持当前的简单SHA256格式，则不需要执行此脚本
-- 当前的简单格式：SHA256('123456') = '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92'
