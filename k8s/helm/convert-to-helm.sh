#!/bin/bash

# 将现有 YAML 文件转换为 Helm 模板的辅助脚本
# 使用方法: ./convert-to-helm.sh <service-name> <yaml-file>

set -e

if [ $# -lt 2 ]; then
    echo "用法: $0 <service-name> <yaml-file>"
    echo "示例: $0 redis redis-secret.yaml"
    exit 1
fi

SERVICE_NAME=$1
YAML_FILE=$2
CHART_DIR="bantu-crm/templates"
TEMP_FILE=$(mktemp)

echo "转换 $YAML_FILE 为 Helm 模板..."

# 读取 YAML 文件
if [ ! -f "$YAML_FILE" ]; then
    echo "❌ 错误: 文件不存在: $YAML_FILE"
    exit 1
fi

# 创建模板文件
OUTPUT_FILE="$CHART_DIR/${SERVICE_NAME}-$(basename $YAML_FILE .yaml).yaml"

# 添加 Helm 条件判断
echo "{{- if .Values.${SERVICE_NAME}.enabled }}" > "$OUTPUT_FILE"

# 转换 YAML，添加 Helm 模板变量
cat "$YAML_FILE" | sed \
    -e "s/namespace: default/namespace: {{ .Values.global.namespace }}/g" \
    -e "s/name: ${SERVICE_NAME}-secret/name: ${SERVICE_NAME}-secret/g" \
    -e "s/name: ${SERVICE_NAME}-config/name: ${SERVICE_NAME}-config/g" \
    -e "s/name: ${SERVICE_NAME}-pv/name: ${SERVICE_NAME}-pv/g" \
    -e "s/name: ${SERVICE_NAME}-pvc/name: ${SERVICE_NAME}-pvc/g" \
    -e "s/name: ${SERVICE_NAME}/name: ${SERVICE_NAME}/g" \
    -e "s/app: ${SERVICE_NAME}/app: ${SERVICE_NAME}\n    chart: {{ include \"bantu-crm.chart\" . }}\n    release: {{ .Release.Name }}/g" \
    >> "$OUTPUT_FILE"

# 添加结束标签
echo "{{- end }}" >> "$OUTPUT_FILE"

echo "✅ 已创建模板: $OUTPUT_FILE"
echo ""
echo "⚠️  注意: 请手动检查并更新以下内容:"
echo "  1. 镜像标签: image: {{ .Values.${SERVICE_NAME}.image.repository }}:{{ .Values.${SERVICE_NAME}.image.tag }}"
echo "  2. 资源限制: {{- toYaml .Values.${SERVICE_NAME}.resources | nindent 10 }}"
echo "  3. 存储大小: {{ .Values.${SERVICE_NAME}.persistence.size }}"
echo "  4. 密码和密钥: 使用 .Values.${SERVICE_NAME}.secrets.*"
echo ""

