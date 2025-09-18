// 专门用于搜索关键词的空值检查
export const isValidEmpty = (keyword: string | null) => {
  // null, undefined 直接返回 false
  if (keyword === null || keyword === undefined) return true;

  // 转换为字符串并去除首尾空格
  const trimmed = String(keyword).trim();

  // 检查是否为有效的搜索关键词
  return trimmed !== '' && trimmed !== 'null' && trimmed !== 'undefined' && trimmed !== 'NaN';
};
