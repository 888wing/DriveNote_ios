<?xml version="1.0" encoding="UTF-8"?>
<svg width="800" height="1200" viewBox="0 0 800 1200" xmlns="http://www.w3.org/2000/svg">
  <!-- 背景 -->
  <rect width="800" height="1200" fill="#f5f5f7"/>
  
  <!-- 標題 -->
  <text x="400" y="50" font-family="SF Pro Display, -apple-system, BlinkMacSystemFont, sans-serif" font-size="28" font-weight="700" text-anchor="middle" fill="#1d1d1f">DriveNote iOS UI設計概念</text>
  
  <!-- 儀表板視圖 -->
  <g transform="translate(60, 100)">
    <!-- iPhone框架 -->
    <rect x="0" y="0" width="300" height="620" rx="40" ry="40" fill="#1d1d1f"/>
    <rect x="10" y="10" width="280" height="600" rx="30" ry="30" fill="#f5f5f7"/>
    
    <!-- 狀態欄 -->
    <rect x="10" y="10" width="280" height="35" rx="30" ry="30" fill="#f5f5f7"/>
    <text x="25" y="32" font-family="SF Pro Text, -apple-system, BlinkMacSystemFont, sans-serif" font-size="14" font-weight="600" fill="#1d1d1f">9:41</text>
    <circle cx="270" cy="27" r="5" fill="#1d1d1f"/>
    <circle cx="255" cy="27" r="5" fill="#1d1d1f"/>
    <circle cx="240" cy="27" r="5" fill="#1d1d1f"/>
    
    <!-- 導航欄 -->
    <rect x="10" y="45" width="280" height="50" fill="#f5f5f7"/>
    <text x="25" y="75" font-family="SF Pro Display, -apple-system, BlinkMacSystemFont, sans-serif" font-size="20" font-weight="700" fill="#1d1d1f">儀表板</text>
    
    <!-- 收支摘要卡片 -->
    <rect x="25" y="105" width="250" height="130" rx="20" ry="20" fill="#ffffff" stroke="#e5e5ea" stroke-width="1"/>
    <rect x="25" y="105" width="250" height="130" rx="20" ry="20" fill="#ffffff" filter="drop-shadow(0px 4px 6px rgba(0, 0, 0, 0.05))"/>
    
    <text x="45" y="130" font-family="SF Pro Text, -apple-system, BlinkMacSystemFont, sans-serif" font-size="12" font-weight="400" fill="#8e8e93">本月總收入</text>
    <text x="230" y="130" font-family="SF Pro Text, -apple-system, BlinkMacSystemFont, sans-serif" font-size="12" font-weight="400" fill="#8e8e93" text-anchor="end">本月總支出</text>
    
    <text x="45" y="155" font-family="SF Pro Display, -apple-system, BlinkMacSystemFont, sans-serif" font-size="22" font-weight="700" fill="#30d158">£2,560</text>
    <text x="230" y="155" font-family="SF Pro Display, -apple-system, BlinkMacSystemFont, sans-serif" font-size="22" font-weight="700" fill="#ff9500" text-anchor="end">£1,180</text>
    
    <line x1="45" y1="170" x2="230" y2="170" stroke="#e5e5ea" stroke-width="1"/>
    
    <text x="45" y="195" font-family="SF Pro Text, -apple-system, BlinkMacSystemFont, sans-serif" font-size="12" font-weight="400" fill="#8e8e93">凈收入</text>
    <text x="45" y="220" font-family="SF Pro Display, -apple-system, BlinkMacSystemFont, sans-serif" font-size="22" font-weight="700" fill="#30d158">£1,380</text>
    
    <rect x="160" y="207" width="60" height="20" rx="10" ry="10" fill="#30d15833"/>
    <text x="190" y="221" font-family="SF Pro Text, -apple-system, BlinkMacSystemFont, sans-serif" font-size="11" font-weight="600" fill="#30d158" text-anchor="middle">+12%</text>
    
    <!-- 指標卡片 -->
    <rect x="25" y="245" width="120" height="100" rx="20" ry="20" fill="#ffffff" stroke="#e5e5ea" stroke-width="1"/>
    <rect x="25" y="245" width="120" height="100" rx="20" ry="20" fill="#ffffff" filter="drop-shadow(0px 4px 6px rgba(0, 0, 0, 0.05))"/>
    
    <text x="85" y="270" font-family="SF Pro Text, -apple-system, BlinkMacSystemFont, sans-serif" font-size="12" font-weight="400" fill="#8e8e93" text-anchor="middle">平均時薪</text>
    <text x="85" y="305" font-family="SF Pro Display, -apple-system, BlinkMacSystemFont, sans-serif" font-size="24" font-weight="700" fill="#0a84ff" text-anchor="middle">£18.50</text>
    <circle cx="85" cy="335" r="6" fill="#0a84ff33"/>
    <text x="85" y="339" font-family="SF Pro Text, -apple-system, BlinkMacSystemFont, sans-serif" font-size="10" font-weight="400" fill="#0a84ff" text-anchor="middle">£</text>
    
    <rect x="155" y="245" width="120" height="100" rx="20" ry="20" fill="#ffffff" stroke="#e5e5ea" stroke-width="1"/>
    <rect x="155" y="245" width="120" height="100" rx="20" ry="20" fill="#ffffff" filter="drop-shadow(0px 4px 6px rgba(0, 0, 0, 0.05))"/>
    
    <text x="215" y="270" font-family="SF Pro Text, -apple-system, BlinkMacSystemFont, sans-serif" font-size="12" font-weight="400" fill="#8e8e93" text-anchor="middle">每英里成本</text>
    <text x="215" y="305" font-family="SF Pro Display, -apple-system, BlinkMacSystemFont, sans-serif" font-size="24" font-weight="700" fill="#ff9500" text-anchor="middle">£0.42</text>
    <circle cx="215" cy="335" r="6" fill="#ff950033"/>
    <text x="215" y="339" font-family="SF Pro Text, -apple-system, BlinkMacSystemFont, sans-serif" font-size="10" font-weight="400" fill="#ff9500" text-anchor="middle">⛽</text>
    
    <!-- 圖表卡片 -->
    <rect x="25" y="355" width="250" height="160" rx="20" ry="20" fill="#ffffff" stroke="#e5e5ea" stroke-width="1"/>
    <rect x="25" y="355" width="250" height="160" rx="20" ry="20" fill="#ffffff" filter="drop-shadow(0px 4px 6px rgba(0, 0, 0, 0.05))"/>
    
    <text x="45" y="380" font-family="SF Pro Display, -apple-system, BlinkMacSystemFont, sans-serif" font-size="16" font-weight="600" fill="#1d1d1f">收支趨勢</text>
    <text x="230" y="380" font-family="SF Pro Text, -apple-system, BlinkMacSystemFont, sans-serif" font-size="12" font-weight="400" fill="#0a84ff" text-anchor="end">本月</text>
    
    <!-- 簡易圖表 -->
    <rect x="45" y="395" width="20" height="80" rx="4" ry="4" fill="#e5e5ea"/>
    <rect x="45" y="435" width="20" height="40" rx="4" ry="4" fill="#30d158"/>
    
    <rect x="75" y="395" width="20" height="80" rx="4" ry="4" fill="#e5e5ea"/>
    <rect x="75" y="425" width="20" height="50" rx="4" ry="4" fill="#30d158"/>
    
    <rect x="105" y="395" width="20" height="80" rx="4" ry="4" fill="#e5e5ea"/>
    <rect x="105" y="415" width="20" height="60" rx="4" ry="4" fill="#30d158"/>
    
    <rect x="135" y="395" width="20" height="80" rx="4" ry="4" fill="#e5e5ea"/>
    <rect x="135" y="405" width="20" height="70" rx="4" ry="4" fill="#30d158"/>
    
    <rect x="165" y="395" width="20" height="80" rx="4" ry="4" fill="#e5e5ea"/>
    <rect x="165" y="430" width="20" height="45" rx="4" ry="4" fill="#ff9500"/>
    
    <rect x="195" y="395" width="20" height="80" rx="4" ry="4" fill="#e5e5ea"/>
    <rect x="195" y="440" width="20" height="35" rx="4" ry="4" fill="#ff9500"/>
    
    <rect x="225" y="395" width="20" height="80" rx="4" ry="4" fill="#e5e5ea"/>
    <rect x="225" y="420" width="20" height="55" rx="4" ry="4" fill="#ff9500"/>
    
    <text x="55" y="490" font-family="SF Pro Text, -apple-system, BlinkMacSystemFont, sans-serif" font-size="10" font-weight="400" fill="#8e8e93" text-anchor="middle">一</text>
    <text x="85" y="490" font-family="SF Pro Text, -apple-system, BlinkMacSystemFont, sans-serif" font-size="10" font-weight="400" fill="#8e8e93" text-anchor="middle">二</text>
    <text x="115" y="490" font-family="SF Pro Text, -apple-system, BlinkMacSystemFont, sans-serif" font-size="10" font-weight="400" fill="#8e8e93" text-anchor="middle">三</text>
    <text x="145" y="490" font-family="SF Pro Text, -apple-system, BlinkMacSystemFont, sans-serif" font-size="10" font-weight="400" fill="#8e8e93" text-anchor="middle">四</text>
    <text x="175" y="490" font-family="SF Pro Text, -apple-system, BlinkMacSystemFont, sans-serif" font-size="10" font-weight="400" fill="#8e8e93" text-anchor="middle">五</text>
    <text x="205" y="490" font-family="SF Pro Text, -apple-system, BlinkMacSystemFont, sans-serif" font-size="10" font-weight="400" fill="#8e8e93" text-anchor="middle">六</text>
    <text x="235" y="490" font-family="SF Pro Text, -apple-system, BlinkMacSystemFont, sans-serif" font-size="10" font-weight="400" fill="#8e8e93" text-anchor="middle">日</text>
    
    <!-- Tab Bar -->
    <rect x="10" y="550" width="280" height="60" rx="0" ry="0" fill="#ffffff"/>
    <rect x="10" y="550" width="280" height="60" rx="0" ry="0" fill="#ffffff" filter="drop-shadow(0px -2px 6px rgba(0, 0, 0, 0.05))"/>
    
    <rect x="20" y="558" width="50" height="44" rx="10" ry="10" fill="#0a84ff1a"/>
    <text x="45" y="575" font-family="SF Symbols, -apple-system, BlinkMacSystemFont, sans-serif" font-size="20" text-anchor="middle" fill="#0a84ff">􀋗</text>
    <text x="45" y="595" font-family="SF Pro Text, -apple-system, BlinkMacSystemFont, sans-serif" font-size="9" font-weight="500" text-anchor="middle" fill="#0a84ff">儀表板</text>
    
    <text x="95" y="575" font-family="SF Symbols, -apple-system, BlinkMacSystemFont, sans-serif" font-size="20" text-anchor="middle" fill="#8e8e93">􀔀</text>
    <text x="95" y="595" font-family="SF Pro Text, -apple-system, BlinkMacSystemFont, sans-serif" font-size="9" font-weight="400" text-anchor="middle" fill="#8e8e93">支出</text>
    
    <text x="145" y="575" font-family="SF Symbols, -apple-system, BlinkMacSystemFont, sans-serif" font-size="20" text-anchor="middle" fill="#8e8e93">􀞋</text>
    <text x="145" y="595" font-family="SF Pro Text, -apple-system, BlinkMacSystemFont, sans-serif" font-size="9" font-weight="400" text-anchor="middle" fill="#8e8e93">里程</text>
    
    <text x="195" y="575" font-family="SF Symbols, -apple-system, BlinkMacSystemFont, sans-serif" font-size="20" text-anchor="middle" fill="#8e8e93">􀐫</text>
    <text x="195" y="595" font-family="SF Pro Text, -apple-system, BlinkMacSystemFont, sans-serif" font-size="9" font-weight="400" text-anchor="middle" fill="#8e8e93">工時</text>
    
    <text x="245" y="575" font-family="SF Symbols, -apple-system, BlinkMacSystemFont, sans-serif" font-size="20" text-anchor="middle" fill="#8e8e93">􀍩</text>
    <text x="245" y="595" font-family="SF Pro Text, -apple-system, BlinkMacSystemFont, sans-serif" font-size="9" font-weight="400" text-anchor="middle" fill="#8e8e93">更多</text>
  </g>
  
  <!-- 支出表單視圖 -->
  <g transform="translate(440, 100)">
    <!-- iPhone框架 -->
    <rect x="0" y="0" width="300" height="620" rx="40" ry="40" fill="#1d1d1f"/>
    <rect x="10" y="10" width="280" height="600" rx="30" ry="30" fill="#f5f5f7"/>
    
    <!-- 狀態欄 -->
    <rect x="10" y="10" width="280" height="35" rx="30" ry="30" fill="#f5f5f7"/>
    <text x="25" y="32" font-family="SF Pro Text, -apple-system, BlinkMacSystemFont, sans-serif" font-size="14" font-weight="600" fill="#1d1d1f">9:41</text>
    <circle cx="270" cy="27" r="5" fill="#1d1d1f"/>
    <circle cx="255" cy="27" r="5" fill="#1d1d1f"/>
    <circle cx="240" cy="27" r="5" fill="#1d1d1f"/>
    
    <!-- 導航欄 -->
    <rect x="10" y="45" width="280" height="50" fill="#f5f5f7"/>
    <text x="150" y="75" font-family="SF Pro Display, -apple-system, BlinkMacSystemFont, sans-serif" font-size="18" font-weight="600" fill="#1d1d1f" text-anchor="middle">添加支出</text>
    <text x="25" y="75" font-family="SF Symbols, -apple-system, BlinkMacSystemFont, sans-serif" font-size="18" font-weight="400" fill="#0a84ff">􀰪</text>
    
    <!-- 進度條 -->
    <rect x="25" y="105" width="250" height="4" rx="2" ry="2" fill="#e5e5ea"/>
    <rect x="25" y="105" width="83.3" height="4" rx="2" ry="2" fill="#0a84ff"/>
    
    <!-- 表單標題 -->
    <text x="25" y="135" font-family="SF Pro Display, -apple-system, BlinkMacSystemFont, sans-serif" font-size="22" font-weight="700" fill="#1d1d1f">基本信息</text>
    
    <!-- 類別選擇器 -->
    <text x="25" y="170" font-family="SF Pro Text, -apple-system, BlinkMacSystemFont, sans-serif" font-size="12" font-weight="400" fill="#8e8e93">支出類別</text>
    
    <rect x="25" y="180" width="60" height="80" rx="15" ry="15" fill="#0a84ff"/>
    <text x="55" y="225" font-family="SF Symbols, -apple-system, BlinkMacSystemFont, sans-serif" font-size="24" text-anchor="middle" fill="#ffffff">􀢋</text>
    <text x="55" y="250" font-family="SF Pro Text, -apple-system, BlinkMacSystemFont, sans-serif" font-size="11" font-weight="500" text-anchor="middle" fill="#0a84ff">燃料</text>
    
    <rect x="95" y="180" width="60" height="80" rx="15" ry="15" fill="#f2f2f7"/>
    <text x="125" y="225" font-family="SF Symbols, -apple-system, BlinkMacSystemFont, sans-serif" font-size="24" text-anchor="middle" fill="#1d1d1f">􁆰</text>
    <text x="125" y="250" font-family="SF Pro Text, -apple-system, BlinkMacSystemFont, sans-serif" font-size="11" font-weight="400" text-anchor="middle" fill="#1d1d1f">保險</text>
    
    <rect x="165" y="180" width="60" height="80" rx="15" ry="15" fill="#f2f2f7"/>
    <text x="195" y="225" font-family="SF Symbols, -apple-system, BlinkMacSystemFont, sans-serif" font-size="24" text-anchor="middle" fill="#1d1d1f">􀧖</text>
    <text x="195" y="250" font-family="SF Pro Text, -apple-system, BlinkMacSystemFont, sans-serif" font-size="11" font-weight="400" text-anchor="middle" fill="#1d1d1f">維修</text>
    
    <rect x="235" y="180" width="60" height="80" rx="15" ry="15" fill="#f2f2f7"/>
    <text x="265" y="225" font-family="SF Symbols, -apple-system, BlinkMacSystemFont, sans-serif" font-size="24" text-anchor="middle" fill="#1d1d1f">􀎸</text>
    <text x="265" y="250" font-family="SF Pro Text, -apple-system, BlinkMacSystemFont, sans-serif" font-size="11" font-weight="400" text-anchor="middle" fill="#1d1d1f">其他</text>
    
    <!-- 日期選擇器 -->
    <text x="25" y="290" font-family="SF Pro Text, -apple-system, BlinkMacSystemFont, sans-serif" font-size="12" font-weight="400" fill="#8e8e93">日期</text>
    
    <rect x="25" y="300" width="250" height="50" rx="12" ry="12" fill="#f2f2f7"/>
    <text x="50" y="330" font-family="SF Symbols, -apple-system, BlinkMacSystemFont, sans-serif" font-size="18" fill="#8e8e93">􀉉</text>
    <text x="75" y="330" font-family="SF Pro Text, -apple-system, BlinkMacSystemFont, sans-serif" font-size="16" font-weight="400" fill="#1d1d1f">2025年4月18日</text>
    
    <!-- 金額輸入 -->
    <text x="25" y="370" font-family="SF Pro Text, -apple-system, BlinkMacSystemFont, sans-serif" font-size="12" font-weight="400" fill="#8e8e93">金額</text>
    
    <rect x="25" y="380" width="250" height="50" rx="12" ry="12" fill="#f2f2f7"/>
    <text x="50" y="410" font-family="SF Symbols, -apple-system, BlinkMacSystemFont, sans-serif" font-size="18" fill="#8e8e93">􀐪</text>
    <text x="75" y="410" font-family="SF Pro Text, -apple-system, BlinkMacSystemFont, sans-serif" font-size="16" font-weight="400" fill="#1d1d1f">55.32</text>
    
    <!-- 底部按鈕 -->
    <rect x="10" y="550" width="280" height="60" fill="#f5f5f7"/>
    <rect x="10" y="550" width="280" height="1" fill="#e5e5ea"/>
    
    <rect x="150" y="560" width="120" height="40" rx="20" ry="20" fill="url(#gradient1)"/>
    <text x="210" y="584" font-family="SF Pro Text, -apple-system, BlinkMacSystemFont, sans-serif" font-size="15" font-weight="600" fill="#ffffff" text-anchor="middle">下一步 􀄯</text>
  </g>
  
  <!-- 里程記錄視圖 -->
  <g transform="translate(60, 770)">
    <!-- iPhone框架 -->
    <rect x="0" y="0" width="300" height="380" rx="40" ry="40" fill="#1d1d1f"/>
    <rect x="10" y="10" width="280" height="360" rx="30" ry="30" fill="#f5f5f7"/>
    
    <!-- 狀態欄 -->
    <rect x="10" y="10" width="280" height="35" rx="30" ry="30" fill="#f5f5f7"/>
    <text x="25" y="32" font-family="SF Pro Text, -apple-system, BlinkMacSystemFont, sans-serif" font-size="14" font-weight="600" fill="#1d1d1f">9:41</text>
    <circle cx="270" cy="27" r="5" fill="#1d1d1f"/>
    <circle cx="255" cy="27" r="5" fill="#1d1d1f"/>
    <circle cx="240" cy="27" r="5" fill="#1d1d1f"/>
    
    <!-- 導航欄 -->
    <rect x="10" y="45" width="280" height="50" fill="#f5f5f7"/>
    <text x="25" y="75" font-family="SF Pro Display, -apple-system, BlinkMacSystemFont, sans-serif" font-size="20" font-weight="700" fill="#1d1d1f">里程記錄</text>
    <text x="260" y="75" font-family="SF Pro Text, -apple-system, BlinkMacSystemFont, sans-serif" font-size="16" font-weight="600" fill="#0a84ff" text-anchor="end">新增</text>
    
    <!-- 列表項目 -->
    <rect x="25" y="105" width="250" height="75" rx="15" ry="15" fill="#ffffff" stroke="#e5e5ea" stroke-width="1"/>
    <rect x="25" y="105" width="250" height="75" rx="15" ry="15" fill="#ffffff" filter="drop-shadow(0px 2px 4px rgba(0, 0, 0, 0.05))"/>
    
    <text x="45" y="130" font-family="SF Pro Text, -apple-system, BlinkMacSystemFont, sans-serif" font-size="16" font-weight="600" fill="#1d1d1f">今日工作行程</text>
    <text x="200" y="130" font-family="SF Pro Text, -apple-system, BlinkMacSystemFont, sans-serif" font-size="16" font-weight="500" fill="#0a84ff" text-anchor="end">76.4英里</text>
    
    <text x="45" y="155" font-family="SF Pro Text, -apple-system, BlinkMacSystemFont, sans-serif" font-size="14" font-weight="400" fill="#8e8e93">2025年4月18日</text>
    <text x="220" y="155" font-family="SF Pro Text, -apple-system, BlinkMacSystemFont, sans-serif" font-size="14" font-weight="400" fill="#30d158" text-anchor="end">完全可抵稅</text>
    
    <rect x="25" y="190" width="250" height="75" rx="15" ry="15" fill="#ffffff" stroke="#e5e5ea" stroke-width="1"/>
    <rect x="25" y="190" width="250" height="75" rx="15" ry="15" fill="#ffffff" filter="drop-shadow(0px 2px 4px rgba(0, 0, 0, 0.05))"/>
    
    <text x="45" y="215" font-family="SF Pro Text, -apple-system, BlinkMacSystemFont, sans-serif" font-size="16" font-weight="600" fill="#1d1d1f">前往機場接客</text>
    <text x="200" y="215" font-family="SF Pro Text, -apple-system, BlinkMacSystemFont, sans-serif" font-size="16" font-weight="500" fill="#0a84ff" text-anchor="end">42.1英里</text>
    
    <text x="45" y="240" font-family="SF Pro Text, -apple-system, BlinkMacSystemFont, sans-serif" font-size="14" font-weight="400" fill="#8e8e93">2025年4月17日</text>
    <text x="220" y="240" font-family="SF Pro Text, -apple-system, BlinkMacSystemFont, sans-serif" font-size="14" font-weight="400" fill="#30d158" text-anchor="end">完全可抵稅</text>
    
    <rect x="25" y="275" width="250" height="75" rx="15" ry="15" fill="#ffffff" stroke="#e5e5ea" stroke-width="1"/>
    <rect x="25" y="275" width="250" height="75" rx="15" ry="15" fill="#ffffff" filter="drop-shadow(0px 2px 4px rgba(0, 0, 0, 0.05))"/>
    
    <text x="45" y="300" font-family="SF Pro Text, -apple-system, BlinkMacSystemFont, sans-serif" font-size="16" font-weight="600" fill="#1d1d1f">市中心接送</text>
    <text x="200" y="300" font-family="SF Pro Text, -apple-system, BlinkMacSystemFont, sans-serif" font-size="16" font-weight="500" fill="#0a84ff" text-anchor="end">38.9英里</text>
    
    <text x="45" y="325" font-family="SF Pro Text, -apple-system, BlinkMacSystemFont, sans-serif" font-size="14" font-weight="400" fill="#8e8e93">2025年4月16日</text>
    <text x="220" y="325" font-family="SF Pro Text, -apple-system, BlinkMacSystemFont, sans-serif" font-size="14" font-weight="400" fill="#30d158" text-anchor="end">完全可抵稅</text>
  </g>
  
  <!-- 工時記錄視圖 -->
  <g transform="translate(440, 770)">
    <!-- iPhone框架 -->
    <rect x="0" y="0" width="300" height="380" rx="40" ry="40" fill="#1d1d1f"/>
    <rect x="10" y="10" width="280" height="360" rx="30" ry="30" fill="#f5f5f7"/>
    
    <!-- 狀態欄 -->
    <rect x="10" y="10" width="280" height="35" rx="30" ry="30" fill="#f5f5f7"/>
    <text x="25" y="32" font-family="SF Pro Text, -apple-system, BlinkMacSystemFont, sans-serif" font-size="14" font-weight="600" fill="#1d1d1f">9:41</text>
    <circle cx="270" cy="27" r="5" fill="#1d1d1f"/>
    <circle cx="255" cy="27" r="5" fill="#1d1d1f"/>
    <circle cx="240" cy="27" r="5" fill="#1d1d1f"/>
    
    <!-- 導航欄 -->
    <rect x="10" y="45" width="280" height="50" fill="#f5f5f7"/>
    <text x="25" y="75" font-family="SF Pro Display, -apple-system, BlinkMacSystemFont, sans-serif" font-size="20" font-weight="700" fill="#1d1d1f">工時記錄</text>
    
    <!-- 計時器卡片 -->
    <rect x="25" y="105" width="250" height="140" rx="20" ry="20" fill="#ffffff" stroke="#e5e5ea" stroke-width="1"/>
    <rect x="25" y="105" width="250" height="140" rx="20" ry="20" fill="#ffffff" filter="drop-shadow(0px 4px 6px rgba(0, 0, 0, 0.05))"/>
    
    <text x="45" y="130" font-family="SF Pro Display, -apple-system, BlinkMacSystemFont, sans-serif" font-size="16" font-weight="600" fill="#1d1d1f">工作計時器</text>
    <text x="230" y="130" font-family="SF Pro Text, -apple-system, BlinkMacSystemFont, sans-serif" font-size="14" font-weight="400" fill="#8e8e93" text-anchor="end">今日</text>
    
    <circle cx="150" cy="175" r="40" fill="#30d15833"/>
    <circle cx="150" cy="175" r="36" fill="#ffffff"/>
    <text x="150" y="186" font-family="SF Symbols, -apple-system, BlinkMacSystemFont, sans-serif" font-size="36" text-anchor="middle" fill="#30d158">􀊄</text>
    
    <text x="150" y="230" font-family="SF Pro Display, -apple-system, BlinkMacSystemFont, sans-serif" font-size="16" font-weight="600" fill="#1d1d1f" text-anchor="middle">開始計時</text>
    
    <!-- 已記錄時數 -->
    <rect x="25" y="255" width="250" height="105" rx="20" ry="20" fill="#ffffff" stroke="#e5e5ea" stroke-width="1"/>
    <rect x="25" y="255" width="250" height="105" rx="20" ry="20" fill="#ffffff" filter="drop-shadow(0px 4px 6px rgba(0, 0, 0, 0.05))"/>
    
    <text x="45" y="280" font-family="SF Pro Display, -apple-system, BlinkMacSystemFont, sans-serif" font-size="16" font-weight="600" fill="#1d1d1f">本週工作時數</text>
    <text x="230" y="280" font-family="SF Pro Text, -apple-system, BlinkMacSystemFont, sans-serif" font-size="14" font-weight="600" fill="#0a84ff" text-anchor="end">查看全部</text>
    
    <text x="45" y="310" font-family="SF Pro Text, -apple-system, BlinkMacSystemFont, sans-serif" font-size="14" font-weight="400" fill="#8e8e93">總計工時</text>
    <text x="230" y="310" font-family="SF Pro Display, -apple-system, BlinkMacSystemFont, sans-serif" font-size="18" font-weight="600" fill="#1d1d1f" text-anchor="end">32.5小時</text>
    
    <text x="45" y="340" font-family="SF Pro Text, -apple-system, BlinkMacSystemFont, sans-serif" font-size="14" font-weight="400" fill="#8e8e93">預計收入</text>
    <text x="230" y="340" font-family="SF Pro Display, -apple-system, BlinkMacSystemFont, sans-serif" font-size="18" font-weight="600" fill="#30d158" text-anchor="end">£601.25</text>
  </g>
  
  <!-- 漸變色定義 -->
  <defs>
    <linearGradient id="gradient1" x1="0%" y1="0%" x2="100%" y2="0%">
      <stop offset="0%" stop-color="#0a84ff" />
      <stop offset="100%" stop-color="#0050c5" />
    </linearGradient>
  </defs>
</svg>