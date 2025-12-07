// MongoDB 初始化脚本
// 用于创建应用数据库和用户
// 此脚本需要在 MongoDB 启动后手动执行

// 切换到应用数据库
db = db.getSiblingDB('bantu_crm');

// 创建应用用户
db.createUser({
  user: 'bantu_mongo_user',
  pwd: 'bantu_mongo_user_password_2024',
  roles: [
    {
      role: 'readWrite',
      db: 'bantu_crm'
    }
  ]
});

// 验证用户创建
print('User created successfully');
db.getUsers();

