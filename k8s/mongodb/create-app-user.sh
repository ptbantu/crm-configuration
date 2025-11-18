#!/bin/bash
# MongoDB 应用用户创建脚本
# 部署后需要手动执行此脚本来创建应用用户

MONGO_POD=$(kubectl get pod -l app=mongodb -o jsonpath='{.items[0].metadata.name}')

if [ -z "$MONGO_POD" ]; then
    echo "❌ 错误: 找不到 MongoDB Pod"
    exit 1
fi

echo "📝 创建 MongoDB 应用用户..."
echo "Pod: $MONGO_POD"

kubectl exec -i $MONGO_POD -- mongosh -u bantu_mongo_admin -p bantu_mongo_password_2024 --authenticationDatabase admin <<EOF
use bantu_crm
var user = db.getUser("bantu_mongo_user");
if (!user) {
  db.createUser({
    user: "bantu_mongo_user",
    pwd: "bantu_mongo_user_password_2024",
    roles: [{ role: "readWrite", db: "bantu_crm" }]
  });
  print("✅ User bantu_mongo_user created successfully");
} else {
  print("ℹ️  User bantu_mongo_user already exists");
}
EOF

echo ""
echo "✅ 完成！"
echo "应用用户: bantu_mongo_user / bantu_mongo_user_password_2024"
echo "数据库: bantu_crm"

