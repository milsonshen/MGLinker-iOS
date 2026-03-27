#!/bin/bash

# MG Linker iOS 构建脚本
# 用于构建和打包 .ipa 文件（用于巨魔安装）

set -e

# 配置
PROJECT_NAME="MGLinker"
SCHEME="MGLinker"
CONFIGURATION="Release"
BUILD_DIR="./build"
ARCHIVE_PATH="${BUILD_DIR}/${PROJECT_NAME}.xcarchive"
EXPORT_PATH="${BUILD_DIR}/${PROJECT_NAME}"
EXPORT_OPTIONS_PLIST="${BUILD_DIR}/ExportOptions.plist"

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}开始构建 MG Linker iOS...${NC}"

# 清理构建目录
echo -e "${YELLOW}清理构建目录...${NC}"
rm -rf "${BUILD_DIR}"
mkdir -p "${BUILD_DIR}"

# 创建 ExportOptions.plist
echo -e "${YELLOW}创建 ExportOptions.plist...${NC}"
cat > "${EXPORT_OPTIONS_PLIST}" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>ad-hoc</string>
    <key>teamID</key>
    <string></string>
    <key>uploadSymbols</key>
    <false/>
    <key>compileBitcode</key>
    <false/>
    <key>provisioningProfiles</key>
    <dict>
        <key>com.mglinker.app</key>
        <string>MG Linker</string>
    </dict>
    <key>signingStyle</key>
    <string>manual</string>
    <key>signingCertificate</key>
    <string>Apple Development</string>
</dict>
</plist>
EOF

# 构建项目
echo -e "${YELLOW}构建项目...${NC}"
xcodebuild clean archive \
    -project "${PROJECT_NAME}.xcodeproj" \
    -scheme "${SCHEME}" \
    -configuration "${CONFIGURATION}" \
    -archivePath "${ARCHIVE_PATH}" \
    -destination 'generic/platform=iOS' \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO

# 导出 IPA
echo -e "${YELLOW}导出 IPA...${NC}"
xcodebuild -exportArchive \
    -archivePath "${ARCHIVE_PATH}" \
    -exportPath "${EXPORT_PATH}" \
    -exportOptionsPlist "${EXPORT_OPTIONS_PLIST}"

# 检查 IPA 是否生成
IPA_PATH="${EXPORT_PATH}/${PROJECT_NAME}.ipa"
if [ -f "${IPA_PATH}" ]; then
    echo -e "${GREEN}构建成功！${NC}"
    echo -e "${GREEN}IPA 文件位置: ${IPA_PATH}${NC}"
    
    # 重命名为 .tipa（巨魔格式）
    TIPA_PATH="${EXPORT_PATH}/${PROJECT_NAME}.tipa"
    cp "${IPA_PATH}" "${TIPA_PATH}"
    echo -e "${GREEN}TIPA 文件位置: ${TIPA_PATH}${NC}"
    
    # 显示文件大小
    FILE_SIZE=$(du -h "${TIPA_PATH}" | cut -f1)
    echo -e "${GREEN}文件大小: ${FILE_SIZE}${NC}"
    
    echo -e "${YELLOW}安装说明：${NC}"
    echo -e "1. 将 ${TIPA_PATH} 传输到您的 iOS 设备"
    echo -e "2. 使用巨魔（TrollStore）打开并安装"
    echo -e "3. 首次打开应用时，请授予必要的权限"
else
    echo -e "${RED}构建失败！请检查错误信息。${NC}"
    exit 1
fi

echo -e "${GREEN}构建完成！${NC}"