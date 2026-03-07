local ADDON_NAME, NS = ...
if GetLocale() ~= "koKR" then return end

local IS_KOREAN_LOCALE = true
NS.FONT_NAME = "2002"
NS.FONT_PATH = "Interface\\AddOns\\EllesmereUI_KRPatch\\2002.ttf"

local KO_EXACT = {
    ["General"] = "일반",
    ["Quick Setup"] = "빠른 설정",
    ["Fonts & Colors"] = "폰트 및 색상",
    ["Enabled Addons"] = "활성 애드온",
    ["Profiles"] = "프로필",
    ["Global Settings"] = "전체 설정",
    ["Unlock Mode"] = "잠금 해제 모드",
    ["Action Bars"] = "액션 바",
    ["Nameplates"] = "이름표",
    ["Unit Frames"] = "유닛 프레임",
    ["Raid Frames"] = "공대 프레임",
    ["Resource Bars"] = "자원 바",
    ["Cooldown Manager"] = "쿨다운 관리자",
    ["AuraBuff Reminders"] = "오라/버프 알림",
    ["Cursor"] = "커서",
    ["Basics"] = "기본 기능",
    ["Party Mode"] = "파티 모드",
    ["Install"] = "설치",
    ["Coming Soon"] = "준비 중",
    ["Coming soon"] = "준비 중",
    ["Search..."] = "검색...",
    ["Open EllesmereUI"] = "EllesmereUI 열기",
    ["Cancel"] = "취소",
    ["Confirm"] = "확인",
    ["OK"] = "확인",
    ["Okay"] = "확인",
    ["Dismiss"] = "닫기",
    ["Done"] = "완료",
    ["Save"] = "저장",
    ["Close"] = "닫기",
    ["Exit"] = "나가기",
    ["Delete"] = "삭제",
    ["Apply to All"] = "모두 적용",
    ["Information"] = "정보",
    ["Enter Name"] = "이름 입력",
    ["Enter name..."] = "이름 입력...",
    ["Extra"] = "추가",
    ["Are you sure?"] = "계속하시겠습니까?",
    ["Click to Show"] = "클릭하여 표시",
    ["Reposition freely with"] = "자유롭게 위치 조정:",
    ["All EUI Addons:"] = "모든 EUI 애드온:",
    ["Color Picker"] = "색상 선택기",
    ["New"] = "새 색상",
    ["Prev"] = "이전",
    ["Hex#"] = "16진수#",
    ["Unlock Mode is not available."] = "잠금 해제 모드를 사용할 수 없습니다.",
    ["Cannot open options in combat"] = "전투 중에는 설정을 열 수 없습니다",
    ["Cannot open options during combat."] = "전투 중에는 설정을 열 수 없습니다.",
    ["This addon is not currently installed or enabled."] = "이 애드온은 현재 설치되어 있지 않거나 활성화되어 있지 않습니다.",
    ["This addon is not currently installed or enabled"] = "이 애드온은 현재 설치되어 있지 않거나 활성화되어 있지 않습니다",
    ["Press Ctrl+C to copy, then Escape to close"] = "Ctrl+C로 복사하고 Esc로 닫으세요",
    ["General options for all EllesmereUI addons."] = "모든 EllesmereUI 애드온에 적용되는 일반 설정입니다.",
    ["Configure visuals and behavior for your action bars."] = "액션 바의 외형과 동작을 설정합니다.",
    ["Custom nameplate design and behavior."] = "이름표의 외형과 동작을 설정합니다.",
    ["Configure unit frame appearance and behavior."] = "유닛 프레임의 외형과 동작을 설정합니다.",
    ["Custom party and raid unit frames."] = "파티 및 공대 유닛 프레임을 설정합니다.",
    ["Custom class resource, health, and mana bar display."] = "클래스 자원, 생명력, 마나 바 표시를 설정합니다.",
    ["CDM bar customization, action bar glows, and buff bars."] = "CDM 바, 액션 바 반짝임, 버프 바를 설정합니다.",
    ["AuraBuff Reminders: Raid Buffs, Auras, and Consumables."] = "오라/버프 알림: 공격대 버프, 오라, 소모품을 설정합니다.",
    ["Add a custom texture to your mouse cursor with GCD and cast bar rings."] = "마우스 커서에 사용자 지정 텍스처와 GCD/시전 바 링을 적용합니다.",
    ["Customize your minimap, friends list, bags, and minimap skin."] = "미니맵, 친구 목록, 가방, 미니맵 스킨을 설정합니다.",
    ["This option requires you to enable "] = "이 옵션을 사용하려면 ",
    [" in the Global Settings -> Enabled Addons tab"] = " 전체 설정 -> 활성 애드온 탭에서 활성화해야 합니다",
    ["This option requires "] = "이 옵션을 사용하려면 ",
    [" to be enabled"] = " 활성화가 필요합니다",
    ["Font changed. A UI reload is needed to apply the new font."] = "폰트가 변경되었습니다. 새 폰트를 적용하려면 UI를 다시 불러와야 합니다.",
    ["Combat text font changes require a logout to character select to take effect. This is a WoW engine limitation."] = "전투 텍스트 폰트 변경은 캐릭터 선택 화면까지 로그아웃해야 적용됩니다. 이는 WoW 엔진의 제한입니다.",
    ["3D portraits may cause a slight loss in performance efficiency. Do you want to enable them?"] = "3D 초상화는 성능 효율이 약간 떨어질 수 있습니다. 활성화하시겠습니까?",
    ["Custom active state animations may cause a slight loss in performance efficiency. Do you want to enable it?"] = "사용자 지정 활성 상태 애니메이션은 성능 효율이 약간 떨어질 수 있습니다. 활성화하시겠습니까?",
    ["Custom proc glow may cause a slight loss in performance efficiency. Do you want to enable it?"] = "사용자 지정 발동 반짝임은 성능 효율이 약간 떨어질 수 있습니다. 활성화하시겠습니까?",
    ["Custom shapes always use Shape Glow. Change your bar shape to None or Cropped to pick a different glow."] = "사용자 지정 형태는 항상 도형 반짝임을 사용합니다. 다른 반짝임을 사용하려면 바 모양을 없음 또는 잘림으로 바꾸세요.",
    ["Custom shapes always use Shape Glow — change your bar shape to None or Cropped to pick a different glow"] = "사용자 지정 형태는 항상 도형 반짝임을 사용합니다. 다른 반짝임을 사용하려면 바 모양을 없음 또는 잘림으로 바꾸세요.",
    ["Displays a spoiler tag over guild chat in the communities window that you can click to hide"] = "커뮤니티 창의 길드 채팅 위에 클릭해서 숨길 수 있는 가림 표시를 보여줍니다.",
    ["Displays secondary stat percentages (Crit, Haste, Mastery, Vers) at the top left of the screen."] = "화면 좌측 상단에 2차 스탯(치명타, 가속, 특화, 유연성) 퍼센트를 표시합니다.",
    ["Automatically repair all gear when visiting a repair vendor."] = "수리 가능한 상인을 방문하면 모든 장비를 자동으로 수리합니다.",
    ["Automatically sell all junk items when visiting a vendor."] = "상인을 방문하면 모든 잡템을 자동으로 판매합니다.",
    ["Flashes a warning on screen when any equipped item drops below the configured durability threshold. Only triggers out of combat."] = "착용 장비 내구도가 설정한 기준 이하로 내려가면 화면에 경고를 표시합니다. 전투 중에는 작동하지 않습니다.",
    ["Adds a subtle background color tint based on the unit's role (Tank/Healer/DPS). Helps quickly identify roles at a glance."] = "유닛 역할(탱커/힐러/DPS)에 따라 배경 색조를 은은하게 입힙니다. 한눈에 역할을 구분하기 쉽습니다.",
    ["Adjusts the vertical spacing between stacked nameplates. 100% = default, lower = tighter, higher = more spread."] = "겹쳐진 이름표 사이의 세로 간격을 조정합니다. 100%는 기본값이며, 낮을수록 촘촘하고 높을수록 넓어집니다.",
    ["Colors enemy nameplates for quest mobs you still need to kill."] = "아직 처치해야 하는 퀘스트 몹의 적 이름표 색상을 변경합니다.",
    ["Bar Interactions are the light effects that happen when you hover/press a spell, your cooldown swipe line, aura active border glow, etc"] = "바 상호작용은 주문에 마우스를 올리거나 누를 때, 쿨다운 스와이프 선, 오라 활성 테두리 반짝임 등에 표시되는 빛 효과입니다.",
    ["Click elements to scroll to and highlight their options"] = "요소를 클릭하면 해당 옵션으로 이동하고 강조 표시합니다",
    ["Disabled while Class Color is enabled"] = "직업 색상이 활성화되어 있으면 사용할 수 없습니다",
    ["Disabled while Class Colors is enabled"] = "직업 색상이 활성화되어 있으면 사용할 수 없습니다",
    ["Disabled when Enemy Name is centered on the health bar due to overlapping text"] = "적 이름이 생명력 바 중앙에 있으면 텍스트가 겹쳐 비활성화됩니다",
    ["Activate Party Mode"] = "파티 모드 활성화",
    ["Deactivate Party Mode"] = "파티 모드 비활성화",
    ["Auras, Buffs & Consumables"] = "오라, 버프 및 소모품",
    ["Top Left"] = "좌상단",
    ["Top Right"] = "우상단",
    ["Bottom Left"] = "좌하단",
    ["Bottom Right"] = "우하단",
    ["Left to Right"] = "왼쪽에서 오른쪽",
    ["Right to Left"] = "오른쪽에서 왼쪽",
    ["Bottom to Top"] = "아래에서 위",
    ["Top"] = "상단",
    ["Bottom"] = "하단",
    ["Left"] = "왼쪽",
    ["Right"] = "오른쪽",
    ["Center"] = "중앙",
    ["Always"] = "항상",
    ["Auto"] = "자동",
    ["None"] = "없음",
    ["Default"] = "기본값",
    ["Blizzard Default"] = "블리자드 기본값",
    ["Classic (Blizzard)"] = "클래식 (블리자드)",
    ["Faction (Auto)"] = "진영 자동",
    ["Dark"] = "어둠",
    ["Class Colored"] = "직업 색상",
    ["Custom Color"] = "사용자 색상",
    ["Player"] = "플레이어",
    ["Target"] = "대상",
    ["Focus"] = "주시",
    ["Pet"] = "펫",
    ["Boss"] = "보스",
    ["Friendly"] = "아군",
    ["Enemy"] = "적",
    ["Enemies"] = "적",
    ["Party"] = "파티",
    ["Raid"] = "공격대",
    ["Health Bar"] = "생명력 바",
    ["Power Bar"] = "자원 바",
    ["Cast Bar"] = "시전 바",
    ["Text Bar"] = "텍스트 바",
    ["Class Resource"] = "클래스 자원",
    ["Class Resource Bar"] = "클래스 자원 바",
    ["Class Colors"] = "직업 색상",
    ["Class Color"] = "직업 색상",
    ["Class Icon"] = "직업 아이콘",
    ["Role Tint"] = "역할 틴트",
    ["Quest Mob Color"] = "퀘스트 몹 색상",
    ["Enemy Name"] = "적 이름",
    ["Enemy Name Text"] = "적 이름 텍스트",
    ["Target of Target"] = "대상의 대상",
    ["Focus Target"] = "주시 대상",
    ["Focus Target / Target of Target"] = "주시 대상 / 대상의 대상",
    ["Boss Frames"] = "보스 프레임",
    ["Pet Frame"] = "펫 프레임",
    ["Player Cast Bar"] = "플레이어 시전 바",
    ["Combat Indicator"] = "전투 표시",
    ["Global Font"] = "전체 폰트",
    ["Action Button Glow"] = "액션 버튼 반짝임",
    ["3D Portrait"] = "3D 초상화",
    ["3D Portraits"] = "3D 초상화",
    ["2D Portrait"] = "2D 초상화",
    ["FPS Counter"] = "FPS 카운터",
    ["Friends List"] = "친구 목록",
    ["Minimap"] = "미니맵",
    ["Bags"] = "가방",
    ["Power Word: Fortitude"] = "신의 권능: 인내",
    ["Arcane Intellect"] = "비전 지능",
    ["Battle Shout"] = "전투의 외침",
    ["Devotion Aura"] = "헌신의 오라",
    ["Augment Rune"] = "증강 룬",
    ["Energy"] = "기력",
    ["Fury"] = "격노",
    ["Chi"] = "기",
    ["Essence"] = "정수",
    ["Combo Points"] = "연계 점수",
    ["Arcane Charges"] = "비전 충전물",
    ["Soul Shards"] = "영혼의 조각",
    ["Runes"] = "룬",
    ["APPEARANCE"] = "외형",
    ["LAYOUT"] = "배치",
    ["TEXT"] = "텍스트",
    ["VISIBILITY"] = "표시",
    ["ICON SETTINGS"] = "아이콘 설정",
    ["SELECTED BAR"] = "선택한 바",
    ["ICONS"] = "아이콘",
    ["FRAME SIZE & LAYOUT"] = "프레임 크기 및 배치",
    ["BORDER & BACKGROUND"] = "테두리 및 배경",
    ["BUFFS & DEBUFFS"] = "버프 및 디버프",
    ["Scale"] = "배율",
    ["Width"] = "너비",
    ["Height"] = "높이",
    ["Size"] = "크기",
    ["Spacing"] = "간격",
    ["Padding"] = "여백",
    ["Position"] = "위치",
    ["Texture"] = "텍스처",
    ["Opacity"] = "투명도",
    ["Font"] = "폰트",
    ["Preview"] = "미리보기",
    ["Mode"] = "모드",
    ["Style"] = "스타일",
    ["Type"] = "유형",
    ["Text"] = "텍스트",
    ["Color"] = "색상",
    ["Offset"] = "오프셋",
    ["X-Offset"] = "X 오프셋",
    ["Y-Offset"] = "Y 오프셋",
    ["Enabled"] = "활성",
    ["Disabled"] = "비활성",
    ["Other"] = "기타",
    ["Secondary Stats"] = "2차 스탯",
    ["Aura"] = "오라",
    ["Buff"] = "버프",
    ["Debuff"] = "디버프",
    ["Top"] = "상단",
    ["Bottom"] = "하단",
    ["Left"] = "왼쪽",
    ["Right"] = "오른쪽",
    ["Location"] = "위치",
    ["Custom"] = "사용자 지정",
    ["Shape"] = "형태",
    ["Show Local MS"] = "로컬 지연시간 표시",
    ["Show World MS"] = "월드 지연시간 표시",
    ["Repair %"] = "수리 %",
    ["Show Tertiary Stats"] = "3차 스탯 표시",
    ["Tertiary Label Color"] = "3차 스탯 라벨 색상",
    ["Show Pet/Periodic Damage"] = "펫/주기 피해 표시",
    ["GCD Circle"] = "글로벌 쿨다운 원",
    ["Cast Bar Circle"] = "시전 바 원",
    ["Action Bar 1 (Main)"] = "액션 바 1 (메인)",
    ["Action Bar 2"] = "액션 바 2",
    ["Action Bar 3"] = "액션 바 3",
    ["Action Bar 4"] = "액션 바 4",
    ["Action Bar 5"] = "액션 바 5",
    ["Action Bar 6"] = "액션 바 6",
    ["Action Bar 7"] = "액션 바 7",
    ["Action Bar 8"] = "액션 바 8",
    ["Stance Bar"] = "태세 바",
    ["Pet Bar"] = "펫 바",
    ["Micro Menu Bar"] = "마이크로 메뉴 바",
    ["Bag Bar"] = "가방 바",
    ["XP Bar"] = "경험치 바",
    ["Reputation Bar"] = "평판 바",
    ["Extra Abilities (Special Action)"] = "추가 능력 (특수 액션)",
    ["Encounter Bar"] = "인카운터 바",
    ["Save & Exit"] = "저장 후 나가기",
    ["Exit Without Saving"] = "저장하지 않고 나가기",
    ["Unsaved Changes"] = "저장되지 않은 변경 사항",
    ["You have unsaved position changes.\nWhat would you like to do?"] = "저장되지 않은 위치 변경이 있습니다.\n어떻게 하시겠습니까?",
    ["This is where you can control the settings of Unlock Mode.\n\nElement repositioning supports dragging,\narrow keys, and shift arrow keys.\nSnapping is based on closest element.\nSnap to a specific element via the cogwheel icon."] = "여기서 잠금 해제 모드 설정을 조정할 수 있습니다.\n\n요소 위치는 드래그, 화살표 키,\nShift+화살표 키로 조정할 수 있습니다.\n스냅은 가장 가까운 요소를 기준으로 동작합니다.\n톱니바퀴 아이콘으로 특정 요소에 맞출 수 있습니다.",
    ["Cannot enter Unlock Mode during combat."] = "전투 중에는 잠금 해제 모드에 들어갈 수 없습니다.",
    ["This feature requires Snap to Elements to be enabled"] = "이 기능을 사용하려면 요소 맞춤을 활성화해야 합니다",
    ["Snap to Elements is disabled"] = "요소 맞춤이 비활성화되어 있습니다",
    ["Minimum scale reached"] = "최소 배율에 도달했습니다",
    ["Maximum scale reached"] = "최대 배율에 도달했습니다",
    ["Grid Lines\nBright"] = "격자선\n밝게",
    ["Grid Lines\nDimmed"] = "격자선\n어둡게",
    ["Grid Lines\nDisabled"] = "격자선\n비활성",
    ["Weapon"] = "무기",
    ["Flask"] = "영약",
    ["Food"] = "음식",
    ["Choose Zones"] = "지역 선택",
    ["Select Dungeon/Raid"] = "던전/공격대 선택",
    ["The Voidspire"] = "공허첨탑",
    ["Magister's Terrace"] = "마법학자의 정원",
    ["Maisara Caverns"] = "마이사라 동굴",
    ["Nexus-Point Xenas"] = "공결탑 제나스",
    ["Windrunner Spire"] = "윈드러너 첨탑",
    ["Algeth'ar Academy"] = "알게타르 대학",
    ["Seat of the Triumvirate"] = "삼두정의 권좌",
    ["Skyreach"] = "하늘탑",
    ["Pit of Saron"] = "사론의 구덩이",
    ["Class Talent"] = "직업 특성",
    ["Spec Talent"] = "전문화 특성",
    ["Add Reminder"] = "알림 추가",
    ["No talent reminders configured"] = "설정된 특성 알림이 없습니다",
    ["Show 'Not Needed' Reminder"] = "'필요 없음' 알림 표시",
    ["Inky Black Potion - Zone IDs"] = "먹물 검은 물약 - 지역 ID",
    ["Enter map zone IDs separated by commas.\nThe potion reminder will only show in these zones."] = "쉼표로 구분된 지도 지역 ID를 입력하세요.\n물약 알림은 이 지역에서만 표시됩니다.",
    ["e.g. 2248, 2339"] = "예: 2248, 2339",
    ["Add Current Zone"] = "현재 지역 추가",
    ["ACTIVE REMINDERS"] = "활성 알림",
    ["Active Reminders"] = "활성 알림",
    ["Left click a button to edit an existing glow, right click to add a new glow"] = "좌클릭으로 기존 반짝임을 편집하고, 우클릭으로 새 반짝임을 추가합니다",
    ["No buffs assigned. Right click a button in the preview to assign buffs."] = "할당된 버프가 없습니다. 미리보기에서 버튼을 우클릭해 버프를 할당하세요.",
    ["No Bars - Click to Add"] = "바 없음 - 클릭하여 추가",
    ["Select a bar"] = "바 선택",
    ["+ Add New Bar"] = "+ 새 바 추가",
    ["Click to assign a buff"] = "클릭해서 버프 할당",
    ["Use the dropdown above to add a new bar"] = "위 드롭다운을 사용해 새 바를 추가하세요",
    ["Remove Spell"] = "주문 제거",
    ["Assigned Buff"] = "할당된 버프",
    ["Glow Type"] = "반짝임 유형",
    ["Threshold Coloring"] = "임계값 색상 처리",
    ["Only Color At/Above Threshold"] = "임계값 이상에서만 색상 적용",
    ["Resource Count"] = "자원 수",
    ["Class Resource Anchor"] = "클래스 자원 앵커",
    ["Growth"] = "성장 방향",
    ["Power Text"] = "자원 텍스트",
    ["Power Bar Anchor"] = "자원 바 앵커",
    ["Position Settings"] = "위치 설정",
    ["Power Bar Text Settings"] = "자원 바 텍스트 설정",
    ["Target/Focus Cast Bar"] = "대상/주시 시전 바",
    ["Show Icon"] = "아이콘 표시",
    ["Detached Position Offsets"] = "분리 위치 오프셋",
    ["BTB Left Text Settings"] = "BTB 왼쪽 텍스트 설정",
    ["BTB Right Text Settings"] = "BTB 오른쪽 텍스트 설정",
    ["BTB Center Text Settings"] = "BTB 중앙 텍스트 설정",
    ["Class Resource Position"] = "클래스 자원 위치",
    ["Buff Settings"] = "버프 설정",
    ["Debuff Settings"] = "디버프 설정",
    ["Show Own Only"] = "내 것만 표시",
    ["Preview Frame:"] = "미리보기 프레임:",
    ["Click to Sync Different Values"] = "클릭하여 다른 값을 동기화",
    ["Spell Not Tracked"] = "추적되지 않은 주문",
    ["This spell is not currently tracked in any of your CDM bars. Add it to a CDM bar first, or enable it in Blizzard's Cooldown Manager."] = "이 주문은 현재 어떤 CDM 바에서도 추적되지 않습니다. 먼저 CDM 바에 추가하거나 블리자드 쿨다운 관리자에서 활성화하세요.",
    ["This spell is not currently tracked in any of your CDM bars. Add it to a CDM bar first."] = "이 주문은 현재 어떤 CDM 바에서도 추적되지 않습니다. 먼저 CDM 바에 추가하세요.",
    ["Remove Buff Assignment"] = "버프 할당 제거",
    ["Remove this buff from this button's glow assignments?"] = "이 버튼의 반짝임 할당에서 이 버프를 제거하시겠습니까?",
    ["Delete Bar"] = "바 삭제",
    ["Name Text Settings"] = "이름 텍스트 설정",
    ["Duration Settings"] = "지속시간 설정",
    ["Icon Settings"] = "아이콘 설정",
    ["Gradient Settings"] = "그라데이션 설정",
    ["Enable Gradient"] = "그라데이션 활성화",
    ["Gradient Direction"] = "그라데이션 방향",
    ["Border Settings"] = "테두리 설정",
    ["Visibility Options"] = "표시 옵션",
    ["Hide in Housing"] = "하우징에서 숨김",
    ["Bar Background"] = "바 배경",
    ["Background"] = "배경",
    ["Background Color"] = "배경 색상",
    ["Anchor Settings"] = "앵커 설정",
    ["Growth Direction"] = "성장 방향",
    ["Grow Centered"] = "중앙 기준 성장",
    ["Animation Options"] = "애니메이션 옵션",
    ["Class Colored Animation"] = "직업 색상 애니메이션",
    ["Border Options"] = "테두리 옵션",
    ["Class Colored Border"] = "직업 색상 테두리",
    ["Duration Text Settings"] = "지속시간 텍스트 설정",
    ["Stack Count Settings"] = "중첩 수 설정",
    ["Spell Not Displayed"] = "표시되지 않는 주문",
    ["This spell is not currently displayed in your Blizzard Cooldown Manager. Enable it there to get full cooldown, charge, and active state tracking."] = "이 주문은 현재 블리자드 쿨다운 관리자에 표시되지 않습니다. 그곳에서 활성화해야 전체 쿨다운, 충전, 활성 상태 추적이 가능합니다.",
    ["Action Bar"] = "액션 바",
    ["Bar"] = "바",
    ["Unknown"] = "알 수 없음",
    ["Disabled"] = "비활성",
    ["Assign Preset to Specs"] = "전문화에 프리셋 할당",
    ["Check All"] = "모두 선택",
    ["Uncheck All"] = "모두 해제",
    ["Default Profile (for non-assigned specs)"] = "기본 프로필 (할당되지 않은 전문화용)",
    ["(default)"] = "(기본값)",
    ["(default - inactive)"] = "(기본값 - 비활성)",
    ["(inactive)"] = "(비활성)",
    ["(spec active)"] = "(전문화 활성)",
    ["Add New"] = "새로 추가",
    ["Assign to Spec"] = "전문화에 할당",
    ["Set as Default"] = "기본값으로 설정",
    ["Delete Preset"] = "프리셋 삭제",
    ["Rename Preset"] = "프리셋 이름 변경",
    ["Custom Preset Exists"] = "사용자 프리셋이 이미 있습니다",
    ["You already have a Custom preset. What would you like to do with your current changes?"] = "이미 사용자 프리셋이 있습니다. 현재 변경 사항을 어떻게 처리하시겠습니까?",
    ["New Preset"] = "새 프리셋",
    ["Enter a name for your new preset:"] = "새 프리셋 이름을 입력하세요:",
    ["Name Your Preset"] = "프리셋 이름 지정",
    ["Please name your custom preset before assigning specs:"] = "전문화를 할당하기 전에 사용자 프리셋 이름을 지정하세요:",
    ["Save & Continue"] = "저장 후 계속",
    ["Select which specs you want"] = "어떤 전문화에",
    ["to be assigned to"] = "할당할지 선택하세요",
    ["Out of Date"] = "버전이 오래됨",
    ["Incompatible Addon Detected"] = "호환되지 않는 애드온 감지됨",
    ["Party Mode addon is not loaded."] = "Party Mode 애드온이 로드되지 않았습니다.",
    ["Toggle On/Off Keybind"] = "켜기/끄기 단축키",
    ["Press a key..."] = "키를 누르세요...",
    ["Not Bound"] = "미설정",
    ["Brightness"] = "밝기",
    ["More Information"] = "추가 정보",
    ["FPS & Graphics Optimization"] = "FPS 및 그래픽 최적화",
    ["Reload Required"] = "재시작 필요",
    ["Logout Required"] = "로그아웃 필요",
    ["Toggling an addon requires a UI reload to take effect."] = "애드온 토글 변경을 적용하려면 UI를 다시 불러와야 합니다.",
    ["Modern Icons requires a UI reload to apply."] = "Modern Icons를 적용하려면 UI를 다시 불러와야 합니다.",
    ["Reset ALL EUI Addon Settings"] = "모든 EUI 애드온 설정 초기화",
    ["Reset ALL Settings"] = "모든 설정 초기화",
    ["Are you sure you want to reset ALL EUI addon settings to their defaults? This will reload your UI."] = "모든 EUI 애드온 설정을 기본값으로 초기화하시겠습니까? UI가 다시 불러와집니다.",
    ["This resets every EUI addon, not just the current one."] = "현재 애드온만이 아니라 모든 EUI 애드온이 초기화됩니다.",
    ["Reset All & Reload"] = "모두 초기화 후 리로드",
    ["Low Durability"] = "낮은 내구도",
    ["Low Durability (Preview)"] = "낮은 내구도 (미리보기)",
    ["Preview Bar:"] = "미리보기 바:",
    ["Friendly Nameplate Settings"] = "아군 이름표 설정",
    ["Spell Name"] = "주문 이름",
    ["Distance"] = "거리",
    ["Show Health Percent"] = "생명력 퍼센트 표시",
    ["Name Only Settings"] = "이름만 표시 설정",
    ["Pixel Glow Settings"] = "픽셀 반짝임 설정",
    ["Lines"] = "선 개수",
    ["Thickness"] = "두께",
    ["Speed"] = "속도",
    ["Spell Icon Settings"] = "주문 아이콘 설정",
    ["Aura Duration Settings"] = "오라 지속시간 설정",
    ["Aura Stacks Settings"] = "오라 중첩 설정",
    ["Spell Name Settings"] = "주문 이름 설정",
    ["Spell Target Settings"] = "주문 대상 설정",
    ["Focus Texture Settings"] = "주시 텍스처 설정",
    ["Row Settings"] = "행 설정",
    ["Bar Background Settings"] = "바 배경 설정",
    ["Keybind Text Settings"] = "단축키 텍스트 설정",
    ["Charges Text Settings"] = "충전 수 텍스트 설정",
    ["Pushed Border Settings"] = "누름 테두리 설정",
    ["Highlight Border Settings"] = "강조 테두리 설정",
    ["Custom Proc Glow Settings"] = "사용자 발동 반짝임 설정",
    ["Frame Display Options"] = "프레임 표시 옵션",
    ["Portrait Position Offsets"] = "초상화 위치 오프셋",
    ["Shape Border Settings"] = "형태 테두리 설정",
    ["Center Text Settings"] = "중앙 텍스트 설정",
    ["Left Text Settings"] = "왼쪽 텍스트 설정",
    ["Right Text Settings"] = "오른쪽 텍스트 설정",
    ["Health Text"] = "생명력 텍스트",
    ["Health Bar Anchor"] = "생명력 바 앵커",
    ["Cast Bar Position"] = "시전 바 위치",
    ["Timer Settings"] = "타이머 설정",
    ["Cast Bar Settings"] = "시전 바 설정",
    ["Cursor Circle"] = "커서 원형 표시",
    ["Friend groups are managed by right-clicking friends in the Blizzard Friends List. Groups are stored locally in your saved variables (not in friend notes).\n\nOpen the Friends List (default: O key) to manage groups."] = "친구 그룹은 블리자드 친구 목록에서 친구를 우클릭하여 관리합니다. 그룹 정보는 친구 메모가 아니라 로컬 저장 변수에 저장됩니다.\n\n그룹을 관리하려면 친구 목록(기본 단축키: O)을 여세요.",
    ["Select a talent..."] = "특성을 선택하세요...",
    ["Low Durability Warning"] = "낮은 내구도 경고",
    ["FPS Counter Settings"] = "FPS 카운터 설정",
    ["Durability Settings"] = "내구도 설정",
    ["Damage Text Settings"] = "피해 텍스트 설정",
    ["Minimap & Chat"] = "미니맵 및 채팅",
    ["Fill Color"] = "채움 색상",
    ["Gradient End Color"] = "그라데이션 끝 색상",
    ["Main Color"] = "주 색상",
    ["Show Hash Line on Target at Percent"] = "대상 체력 퍼센트 기준선 표시",
    ["Show Lua Errors In Chat"] = "채팅에 Lua 오류 표시",
    ["This option is not available for custom shapes"] = "이 옵션은 사용자 지정 형태에서 사용할 수 없습니다.",
    ["Required:"] = "필수:",
    ["(seconds)"] = "(초)",
    ["(minutes)"] = "(분)",
    ["(world)"] = "(월드)",
    ["(local)"] = "(로컬)",
    ["(Percent)"] = "(퍼센트)",
    ["(one per slot)"] = "(슬롯당 1개)",
    ["Disco lights overlay for celebrations."] = "축하 상황에서 디스코 조명 오버레이를 표시합니다.",
    ["ACTION BARS"] = "액션 바",
    ["ADDITIONAL SETTINGS"] = "추가 설정",
    ["BAR DISPLAY"] = "바 표시",
    ["BAR GLOWS"] = "바 반짝임",
    ["BARS"] = "바",
    ["BEACON REMINDERS"] = "비콘 알림",
    ["CAST BAR"] = "시전 바",
    ["CELEBRATION TRIGGERS"] = "축하 트리거",
    ["CLASS COLORS"] = "직업 색상",
    ["CLASS RESOURCE"] = "클래스 자원",
    ["CLASS RESOURCE BAR"] = "클래스 자원 바",
    ["COMBAT"] = "전투",
    ["CONSUMABLES"] = "소모품",
    ["CORE POSITIONS"] = "핵심 위치",
    ["CORE TEXT POSITIONS"] = "핵심 텍스트 위치",
    ["CURSOR CIRCLE"] = "커서 원형 표시",
    ["DEVELOPER"] = "개발자",
    ["DISPLAY"] = "표시",
    ["ENABLED ADDONS"] = "활성 애드온",
    ["EXTRAS"] = "추가 기능",
    ["FLOATING COMBAT TEXT"] = "전투 문자",
    ["FONTS"] = "폰트",
    ["GENERAL"] = "일반",
    ["GENERAL TEXT"] = "일반 텍스트",
    ["HEALTH BAR"] = "생명력 바",
    ["NAMEPLATES"] = "이름표",
    ["PARTY MODE"] = "파티 모드",
    ["PLAYER CAST BAR"] = "플레이어 시전 바",
    ["PORTRAIT"] = "초상화",
    ["POSITIONING"] = "위치 조정",
    ["POWER BAR"] = "자원 바",
    ["POWER COLORS"] = "자원 색상",
    ["RESET"] = "초기화",
    ["STYLE"] = "스타일",
    ["TEXT"] = "텍스트",
    ["TEXT BAR"] = "텍스트 바",
    ["UNIT FRAMES"] = "유닛 프레임",
    ["Randomly"] = "무작위",
    ["Timed Keystone"] = "시간 내 쐐기 완료",
    ["Mythic Boss Kill"] = "신화 보스 처치",
    ["Rated Arena Win"] = "평점 투기장 승리",
    ["Rated BG Win"] = "평점 전장 승리",
    ["Heroic Boss Kill"] = "영웅 보스 처치",
    ["Normal Boss Kill"] = "일반 보스 처치",
    ["Raid Finder Boss Kill"] = "공찾 보스 처치",
    ["Mythic 0 Completion"] = "신화 0단 완료",
    ["Auto Celebration Duration"] = "자동 축하 지속시간",
    ["Random Celebrations Minimum Cooldown"] = "무작위 축하 최소 재사용 대기시간",
    ["Display In:"] = "표시 위치:",
    ["Occurrences:"] = "횟수:",
    ["Addon: "] = "애드온: ",
    ["Auto"] = "자동",
    ["None"] = "없음",
    ["Anchored To"] = "앵커 대상",
    ["Snap to: Auto"] = "맞춤 대상: 자동",
    ["Snap to: None"] = "맞춤 대상: 없음",
    ["Snap to: Select Element"] = "맞춤 대상: 요소 선택",
    ["Snap to: All Elements"] = "맞춤 대상: 모든 요소",
    ["Above Health Bar"] = "생명력 바 위",
    ["Auras, Buffs & Consumables"] = "오라, 버프 및 소모품",
    ["Preferred Click to Buff"] = "선호 클릭 버프",
    ["Weapon Enhancement"] = "무기 강화",
    ["Make Friendly Nameplates Name Only"] = "아군 이름표를 이름만 표시",
    ["Scale Nameplate On Cast"] = "시전 중 이름표 크기 조정",
    ["Nameplate Distance from Enemy"] = "적과 이름표 거리",
    ["Stacked Nameplate Spacing"] = "겹침 이름표 간격",
    ["Enemy Types"] = "적 유형",
    ["Spell Casters"] = "시전자",
    ["Mini-Bosses"] = "미니 보스",
    ["Enemies"] = "적",
    ["Has Aggro"] = "어그로 보유",
    ["Near Aggro"] = "어그로 근접",
    ["Losing Aggro"] = "어그로 상실 중",
    ["No Aggro"] = "어그로 없음",
    ["Non-Tank Threat"] = "비탱커 위협",
    ["Tank Threat"] = "탱커 위협",
    ["Interruptible Cast"] = "차단 가능 시전",
    ["Interrupt on CD"] = "차단기 쿨다운 중",
    ["Enemy Name"] = "적 이름",
    ["Health Percent"] = "생명력 퍼센트",
    ["Health Number"] = "생명력 수치",
    ["Raid Marker"] = "징표",
    ["Elite/Rare Indicator"] = "정예/희귀 표시",
    ["CCs"] = "군중 제어",
    ["Augment Rune"] = "증강 룬",
    ["Global Font"] = "전체 폰트",
    ["Window Scale"] = "창 배율",
    ["UI Scale"] = "UI 배율",
    ["Max Camera Distance"] = "최대 카메라 거리",
    ["Increase Game Image Quality"] = "게임 화면 품질 향상",
    ["Guild Chat Privacy Cover"] = "길드 채팅 프라이버시 가리개",
    ["Disable Right Click Enemies"] = "우클릭 적 대상지정 비활성화",
    ["Cast Actions on Key Down"] = "키를 누를 때 주문 시전",
    ["Lag Tolerance"] = "지연 허용치",
    ["Secondary Stat Display"] = "2차 스탯 표시",
    ["Show Friendly Player Nameplates"] = "아군 플레이어 이름표 표시",
    ["Show Friendly NPC Nameplates"] = "아군 NPC 이름표 표시",
    ["Show Enemy Pet Nameplates"] = "적 펫 이름표 표시",
    ["Show All Your Player Debuffs"] = "내 모든 디버프 표시",
    ["Show Specials Outside Instances"] = "인스턴스 밖에서도 특수 표시",
    ["Show Buffs Outside Instances"] = "인스턴스 밖에서도 버프 표시",
    ["Show Auras Outside Instances"] = "인스턴스 밖에서도 오라 표시",
    ["Show Tick at Kick Ready Spot"] = "차단 준비 지점 틱 표시",
    ["Show Special \"Has Aggro\" Color"] = "\"어그로 보유\" 특수 색상 표시",
    ["Adjusts the vertical spacing between stacked nameplates. 100% = default, lower = tighter, higher = more spread."] = "겹침 이름표 사이의 세로 간격을 조정합니다. 100%는 기본값이며, 낮을수록 촘촘하고 높을수록 넓어집니다.",
    ["Affects global settings extras like durability warning and show FPS counter"] = "낮은 내구도 경고, FPS 표시 같은 전체 설정 추가 기능에 영향을 줍니다.",
    ["Attach to Cast Bar"] = "시전 바에 부착",
    ["Automatically repair all gear when visiting a repair vendor."] = "수리 가능한 상인을 방문하면 모든 장비를 자동으로 수리합니다.",
    ["Automatically sell all junk items when visiting a vendor."] = "상인을 방문하면 모든 잡동사니 아이템을 자동으로 판매합니다.",
    ["Class Colored is enabled in Spell Target Settings"] = "주문 대상 설정에서 직업 색상이 활성화되어 있습니다.",
    ["Colors enemy nameplates for quest mobs you still need to kill."] = "아직 처치해야 하는 퀘스트 몹의 적 이름표에 색상을 적용합니다.",
    ["Custom shapes always use Shape Glow â€” change your bar shape to None or Cropped to pick a different glow"] = "사용자 지정 형태는 항상 형태 반짝임을 사용합니다. 다른 반짝임을 선택하려면 바 형태를 없음 또는 잘림으로 변경하세요.",
    ["Custom shapes always use Shape Glow. Change your bar shape to None or Cropped to pick a different glow."] = "사용자 지정 형태는 항상 형태 반짝임을 사용합니다. 다른 반짝임을 선택하려면 바 형태를 없음 또는 잘림으로 변경하세요.",
    ["Disable Dark Theme first"] = "먼저 어두운 테마를 비활성화하세요.",
    ["Disable Global Font"] = "전체 폰트 비활성화",
    ["Disabled while Class Color is enabled"] = "직업 색상이 활성화되어 있는 동안 사용할 수 없습니다.",
    ["Disabled while Class Colors is enabled"] = "직업 색상이 활성화되어 있는 동안 사용할 수 없습니다.",
    ["Disables the default behavior of right clicking to target enemies."] = "우클릭으로 적을 대상으로 지정하는 기본 동작을 비활성화합니다.",
    ["Displays a spoiler tag over guild chat in the communities window that you can click to hide"] = "커뮤니티 창의 길드 채팅 위에 클릭해서 숨길 수 있는 스포일러 태그를 표시합니다.",
    ["Displays secondary stat percentages (Crit, Haste, Mastery, Vers) at the top left of the screen."] = "화면 왼쪽 상단에 2차 스탯 비율(치명, 가속, 특화, 유연)을 표시합니다.",
    ["Empty Bar Color"] = "빈 바 색상",
    ["Enable the Global Font toggle to use this setting"] = "이 설정을 사용하려면 전체 폰트 토글을 활성화하세요.",
    ["Enable this to display a reminder to untalent\nout of this when it is not needed\n(all other dungeons/raids not selected)."] = "이 옵션을 켜면 필요하지 않을 때\n(선택되지 않은 다른 모든 던전/공격대)\n이 특성을 빼라는 알림을 표시합니다.",
    ["Enables sharpening to improve image clarity. Especially noticeable at lower render scales."] = "선명도를 높여 화면 선명도를 개선합니다. 낮은 렌더 배율에서 특히 눈에 띕니다.",
    ["Flashes a warning on screen when any equipped item drops below the configured durability threshold. Only triggers out of combat."] = "착용한 아이템 중 하나라도 설정한 내구도 임계값 아래로 떨어지면 화면에 경고를 표시합니다. 비전투 중에만 동작합니다.",
    ["Hide friendly player health bars and instead only see their names.\n\nRequires 'Simplified Friendly Nameplates' to be disabled in Blizzard's Nameplate settings (Esc > Options > Nameplates)."] = "아군 플레이어 생명력 바를 숨기고 이름만 표시합니다.\n\n블리자드 이름표 설정(Esc > 설정 > 이름표)에서 '단순화된 아군 이름표'를 꺼야 합니다.",
    ["Increases the cast bar height on your focus target's nameplate. 100% = normal height."] = "주시 대상 이름표의 시전 바 높이를 늘립니다. 100%는 기본 높이입니다.",
    ["Keybinds respond on key down instead of key up. This helps make your abilities feel more responsive."] = "키를 뗄 때가 아니라 누를 때 단축키가 반응합니다. 기술 반응성을 높이는 데 도움이 됩니다.",
    ["Left-click to set a keybind.\nRight-click to unbind."] = "좌클릭으로 단축키를 지정하고,\n우클릭으로 해제합니다.",
    ["Only available when Portrait Mode is Detached"] = "초상화 모드가 분리됨일 때만 사용할 수 있습니다.",
    ["Optimizes your graphics settings for maximum FPS and visual clarity."] = "최대 FPS와 시각적 선명도를 위해 그래픽 설정을 최적화합니다.",
    ["Portrait Mode is set to None"] = "초상화 모드가 없음으로 설정되어 있습니다.",
    ["Preview durability warning"] = "내구도 경고 미리보기",
    ["Requires Name Only mode"] = "이름만 표시 모드가 필요합니다.",
    ["Requires Name Only setting to be disabled"] = "이름만 표시 설정이 비활성화되어 있어야 합니다.",
    ["Reset to default"] = "기본값으로 초기화",
    ["Scales enemy nameplates while they are casting. 100% = no change."] = "적이 시전하는 동안 이름표 크기를 조정합니다. 100%는 변경 없음입니다.",
    ["Set Anchored To first"] = "먼저 앵커 대상을 설정하세요.",
    ["Show button backgrounds even if a spell is not assigned to that slot."] = "해당 슬롯에 주문이 없어도 버튼 배경을 표시합니다.",
    ["Show/Hide on Preview"] = "미리보기에서 표시/숨김",
    ["Shows a small white tick mark on the cast bar at the point where the cast will be when your interrupt comes off cooldown."] = "차단 기술의 재사용 대기시간이 끝날 시점의 위치에 시전 바 흰색 틱을 표시합니다.",
    ["Shows a special color for non caster/mini-boss enemies when you have aggro on them."] = "시전자/미니보스가 아닌 적에게 어그로가 있을 때 특수 색상을 표시합니다.",
    ["The overlay that appears on the icon when you hover your mouse over a spell button"] = "주문 버튼 위에 마우스를 올렸을 때 아이콘에 나타나는 오버레이입니다.",
    ["The overlay that appears on the icon when you press and hold a spell button"] = "주문 버튼을 누르고 있을 때 아이콘에 나타나는 오버레이입니다.",
    ["This is the Spell Queue Window, it helps with making sure you can't queue up too many spells at once which makes the game feel laggy. Recommended settings are generally ~150 for melee and ~300 for casters. Higher if you have high local ping."] = "이것은 주문 대기열 창으로, 한 번에 너무 많은 주문을 대기열에 넣어 게임이 느리게 느껴지는 것을 방지하는 데 도움이 됩니다. 일반적으로 권장 설정은 근접은 약 150, 시전자는 약 300입니다. 로컬 핑이 높다면 더 높게 설정하세요.",
    ["This is the full overlay that swipes from right to left on the icon during its cast duration"] = "시전 지속시간 동안 아이콘 위를 오른쪽에서 왼쪽으로 쓸어가는 전체 오버레이입니다.",
    ["This option is not supported for this bar type"] = "이 옵션은 이 바 유형에서 지원되지 않습니다.",
    ["This option is only available for the Custom Color Theme"] = "이 옵션은 사용자 지정 색상 테마에서만 사용할 수 있습니다.",
    ["This option requires Pixel Glow to be the selected glow type"] = "이 옵션을 사용하려면 반짝임 유형이 픽셀 반짝임이어야 합니다.",
    ["This option requires a custom glow to be selected"] = "이 옵션을 사용하려면 사용자 지정 반짝임을 선택해야 합니다.",
    ["This option requires a non-custom shaped action bar"] = "이 옵션을 사용하려면 사용자 지정 형태가 아닌 액션 바가 필요합니다.",
    ["This option requires a detached position to be active."] = "이 옵션을 사용하려면 분리된 위치가 활성화되어 있어야 합니다.",
    ["This option requires a text selection other than none."] = "이 옵션을 사용하려면 없음 이외의 텍스트 선택이 필요합니다.",
    ["This option requires a text to be assigned"] = "이 옵션을 사용하려면 텍스트가 할당되어 있어야 합니다.",
    ["This option requires an aura or indicator to be assigned"] = "이 옵션을 사용하려면 오라 또는 표시기가 할당되어 있어야 합니다.",
    ["Not available for Mouse Cursor anchor"] = "마우스 커서 앵커에서는 사용할 수 없습니다.",
    ["Border color is controlled by class color"] = "테두리 색상은 직업 색상에 의해 제어됩니다.",
    ["This will display ALL of your debuffs on enemy nameplates, rather than only the important ones."] = "중요한 디버프만이 아니라 내 모든 디버프를 적 이름표에 표시합니다.",
    ["Toggle between horizontal and vertical bar layout."] = "가로 바 배치와 세로 바 배치 사이를 전환합니다.",
    ["Toggle visibility of enemy pet nameplates."] = "적 펫 이름표 표시를 전환합니다.",
    ["WARNING: This feature requires you to re-log or restart WoW to take effect."] = "경고: 이 기능을 적용하려면 재접속하거나 WoW를 다시 시작해야 합니다.",
}

local KO_EXACT_EXTRA = {
    ["Colors"] = "색상",
    ["Multi Bar Edit"] = "다중 바 편집",
    ["Single Bar Edit"] = "개별 바 편집",
    ["Multi Frame Edit"] = "다중 프레임 편집",
    ["Single Frame Edit"] = "개별 프레임 편집",
    ["Mini Frame Edit"] = "미니 프레임 편집",
    ["Bar Glows"] = "바 반짝임",
    ["Buff Bars"] = "버프 바",
    ["CDM Bars"] = "CDM 바",
    ["Talent Reminders"] = "특성 알림",
    ["Minimap Skin"] = "미니맵 스킨",
    ["Class, Power and Health Bars"] = "클래스/자원/생명력 바",
    ["Active Animation"] = "활성 애니메이션",
    ["Active State Animation"] = "활성 상태 애니메이션",
    ["Active Theme"] = "활성 테마",
    ["Always Show Buttons"] = "버튼 항상 표시",
    ["Anchor Position"] = "앵커 위치",
    ["Anchor Settings"] = "앵커 설정",
    ["Anchored To"] = "앵커 대상",
    ["Animation Options"] = "애니메이션 옵션",
    ["Art Style"] = "아트 스타일",
    ["Auto Repair"] = "자동 수리",
    ["Auto Sell Junk"] = "잡템 자동 판매",
    ["Bar Background"] = "바 배경",
    ["Bar Interactions Color"] = "바 상호작용 색상",
    ["Border"] = "테두리",
    ["Border Style"] = "테두리 스타일",
    ["Buff Duration"] = "버프 지속시간",
    ["Buff Name"] = "버프 이름",
    ["Button Spacing"] = "버튼 간격",
    ["Cast Bar Height"] = "시전 바 높이",
    ["Cast Color"] = "시전 색상",
    ["Center Text"] = "중앙 텍스트",
    ["Charges Text"] = "충전 수 텍스트",
    ["Class"] = "직업",
    ["Class Colored"] = "직업 색상",
    ["Class Colored Bar Interactions"] = "직업 색상 바 상호작용",
    ["Class Colored Fill"] = "직업 색상 채움",
    ["Class Colored Glow"] = "직업 색상 반짝임",
    ["Class Colored Icon Border"] = "직업 색상 아이콘 테두리",
    ["Class Icon Settings"] = "직업 아이콘 설정",
    ["Click Through"] = "클릭 무시",
    ["Damage Text Settings"] = "피해 텍스트 설정",
    ["Dark Mode"] = "어두운 모드",
    ["Dark Theme"] = "어두운 테마",
    ["Detached Position Offsets"] = "분리 위치 오프셋",
    ["Display In:"] = "표시 위치:",
    ["Duration Size"] = "지속시간 크기",
    ["Duration Timer"] = "지속시간 타이머",
    ["Enemy Types"] = "적 유형",
    ["Fill Color"] = "채움 색상",
    ["Focus Cast Height"] = "주시 시전 높이",
    ["Focus Preview"] = "주시 미리보기",
    ["Focus Texture"] = "주시 텍스처",
    ["Frame Display Options"] = "프레임 표시 옵션",
    ["Frame Scale"] = "프레임 배율",
    ["Glow Type"] = "반짝임 유형",
    ["Hash Line Location"] = "기준선 위치",
    ["Health Bar Anchor"] = "생명력 바 앵커",
    ["Health Bar Height"] = "생명력 바 높이",
    ["Health Bar Width"] = "생명력 바 너비",
    ["Health Colored Fill"] = "생명력 색상 채움",
    ["Health Text"] = "생명력 텍스트",
    ["Highlight Type"] = "강조 유형",
    ["Icon Scale"] = "아이콘 배율",
    ["Icon Spacing"] = "아이콘 간격",
    ["Icon Zoom"] = "아이콘 확대",
    ["Interrupt on CD"] = "차단기 쿨다운 중",
    ["Keybind Text"] = "단축키 텍스트",
    ["Layout Settings"] = "배치 설정",
    ["Left Text"] = "왼쪽 텍스트",
    ["Main Color"] = "주 색상",
    ["Pixel Glow Settings"] = "픽셀 반짝임 설정",
    ["Power Bar Anchor"] = "자원 바 앵커",
    ["Power Text"] = "자원 텍스트",
    ["Pushed Type"] = "누름 유형",
    ["Resource Text"] = "자원 텍스트",
    ["Right Text"] = "오른쪽 텍스트",
    ["Shape Border"] = "형태 테두리",
    ["Show Absorbs on Frame"] = "프레임에 흡수량 표시",
    ["Show Buffs on Frame"] = "프레임에 버프 표시",
    ["Show Damage Text"] = "피해 텍스트 표시",
    ["Show Healing Text"] = "치유 텍스트 표시",
    ["Show Portrait"] = "초상화 표시",
    ["Show Power Bar"] = "자원 바 표시",
    ["Show Spark"] = "반짝이 표시",
    ["Show Text"] = "텍스트 표시",
    ["Spell Icon"] = "주문 아이콘",
    ["Spell Target"] = "주문 대상",
    ["Stack Count"] = "중첩 수",
    ["Target Debuffs Location"] = "대상 디버프 위치",
    ["Target Glow Style"] = "대상 반짝임 스타일",
    ["Text Settings"] = "텍스트 설정",
    ["Threshold Color"] = "임계값 색상",
    ["Threshold Count"] = "임계값 개수",
    ["Top Text"] = "상단 텍스트",
    ["Weapon Enhancement"] = "무기 강화",
    ["Last Used"] = "마지막 사용",
    ["Mythic Only"] = "신화만",
    ["Heroic and Mythic"] = "영웅 및 신화",
    ["All Instanced Content"] = "모든 인스턴스 콘텐츠",
    ["Fortitude"] = "인내",
    ["Intellect"] = "지능",
    ["Shout"] = "외침",
    ["Poison"] = "독",
    ["Shield"] = "보호막",
    ["Weapon Enchant"] = "무기 강화",
    ["CURSOR"] = "커서",
    ["GLOBAL COOLDOWN"] = "글로벌 쿨다운",
    ["THEME"] = "테마",
    ["CLOCK"] = "시계",
    ["ZOOM"] = "확대/축소",
    ["FRIENDS LIST"] = "친구 목록",
    ["FRIEND GROUPS"] = "친구 그룹",
    ["FILTERS"] = "필터",
    ["AUTOMATION"] = "자동화",
    ["OTHER NAMEPLATES"] = "기타 이름표",
    ["ENEMY NAMEPLATE SPACING"] = "적 이름표 간격",
    ["ENEMY COLORS"] = "적 색상",
    ["THREAT COLORS (INSTANCES ONLY)"] = "위협 수준 색상 (인스턴스 전용)",
    ["OTHER COLORS"] = "기타 색상",
    ["RAID BUFFS"] = "공격대 버프",
    ["AURAS"] = "오라",
    ["ROGUE POISONS"] = "도적 독",
    ["PALADIN RITES"] = "성기사 축복",
    ["SHAMAN IMBUES & SHIELDS"] = "주술사 무기 강화 및 보호막",
    ["NAME TEXT"] = "이름 텍스트",
    ["HEALTH TEXT"] = "생명력 텍스트",
    ["HEALTH COLORS"] = "생명력 색상",
    ["HIGHLIGHTS & EFFECTS"] = "강조 및 효과",
    ["ROLE TINT"] = "역할 색조",
    ["LAYOUT & SORTING"] = "배치 및 정렬",
    ["RANGE & FADING"] = "거리 및 투명도",
    ["Cursor Trail"] = "커서 궤적",
    ["Ring Texture"] = "링 텍스처",
    ["Only Show in Instances"] = "인스턴스에서만 표시",
    ["Attach to Cursor"] = "커서에 부착",
    ["Attach Important Buffs to Cursor"] = "중요 버프를 커서에 부착",
    ["Popup Title"] = "팝업 제목",
    ["Row Label"] = "행 라벨",
    ["Swatch 1"] = "색상 견본 1",
    ["Swatch 2"] = "색상 견본 2",
    ["General Extras Font"] = "일반 추가 기능 폰트",
    ["Action Bars Font"] = "액션 바 폰트",
    ["Nameplates Font"] = "이름표 폰트",
    ["Unit Frames Font"] = "유닛 프레임 폰트",
    ["Raid Frames Font"] = "공대 프레임 폰트",
    ["Resource Bars Font"] = "자원 바 폰트",
    ["AuraBuff Font"] = "오라/버프 폰트",
    ["CDM Font"] = "CDM 폰트",
    ["Combat Text Font"] = "전투 문자 폰트",
    ["Combat Text Size"] = "전투 문자 크기",
    ["Reload UI"] = "UI 리로드",
    ["Reset to Defaults"] = "기본값으로 초기화",
    ["Show Minimap Button"] = "미니맵 버튼 표시",
    ["Play Sound on Lua Error"] = "Lua 오류 시 소리 재생",
    ["Suppress Lua Errors"] = "Lua 오류 숨김",
    ["Show Spell ID on Tooltip"] = "툴팁에 주문 ID 표시",
    ["Preview durability warning"] = "내구도 경고 미리보기",
    ["Show/Hide on Preview"] = "미리보기에서 표시/숨김",
    ["Health Value"] = "생명력 수치",
    ["Health Value | Health %"] = "생명력 수치 | 생명력 %",
    ["Toggle EllesmereUI"] = "EllesmereUI 열기/닫기",
    ["Enter Unlock Mode"] = "잠금 해제 모드 진입",
    ["Hide Minimap Button"] = "미니맵 버튼 숨기기",
    ["Left-click:"] = "좌클릭:",
    ["Right-click:"] = "우클릭:",
    ["Middle-click:"] = "휠클릭:",
    ["Install by searching for "] = "다음 이름으로 검색하여 설치: ",
    ["Experience"] = "경험치",
    ["Interrupted"] = "차단됨",
    ["Ellesmere Unit Frames setting changed. Reload UI to apply?"] = "Ellesmere 유닛 프레임 설정이 변경되었습니다. 적용하려면 UI를 리로드할까요?",
    ["|cff0cd29fEllesmereUI|r"] = "|cff0cd29fEllesmereUI|r",
    ["|cff0cd29dLeft-click:|r |cffE0E0E0Toggle EllesmereUI|r"] = "|cff0cd29d좌클릭:|r |cffE0E0E0EllesmereUI 열기/닫기|r",
    ["|cff0cd29dRight-click:|r |cffE0E0E0Enter Unlock Mode|r"] = "|cff0cd29d우클릭:|r |cffE0E0E0잠금 해제 모드 진입|r",
    ["|cff0cd29dMiddle-click:|r |cffE0E0E0Hide Minimap Button|r"] = "|cff0cd29d휠클릭:|r |cffE0E0E0미니맵 버튼 숨기기|r",
    ["Arial"] = "Arial",
    ["Arial Bold"] = "Arial Bold",
    ["Arial Narrow"] = "Arial Narrow",
    ["Avant Garde"] = "Avant Garde",
    ["Changa"] = "Changa",
    ["Cinzel Decorative"] = "Cinzel Decorative",
    ["Exo"] = "Exo",
    ["Expressway"] = "Expressway",
    ["Fira Sans Bold"] = "Fira Sans Bold",
    ["Fira Sans Light"] = "Fira Sans Light",
    ["Fira Sans Medium"] = "Fira Sans Medium",
    ["Friz Quadrata"] = "Friz Quadrata",
    ["Future X Black"] = "Future X Black",
    ["Gotham Narrow"] = "Gotham Narrow",
    ["Gotham Narrow Ultra"] = "Gotham Narrow Ultra",
    ["Homespun"] = "Homespun",
    ["Morpheus"] = "Morpheus",
    ["Poppins"] = "Poppins",
    ["Russo One"] = "Russo One",
    ["Skurri"] = "Skurri",
    ["Ubuntu"] = "Ubuntu",
}

for source, target in pairs(KO_EXACT_EXTRA) do
    KO_EXACT[source] = target
end

local KO_TERMS = {
    ["Action Bars"] = "액션 바",
    ["Action Bar"] = "액션 바",
    ["Resource Bars"] = "자원 바",
    ["Resource Bar"] = "자원 바",
    ["Unit Frames"] = "유닛 프레임",
    ["Unit Frame"] = "유닛 프레임",
    ["Raid Frames"] = "공대 프레임",
    ["Raid Frame"] = "공대 프레임",
    ["Nameplates"] = "이름표",
    ["Nameplate"] = "이름표",
    ["Cooldown Manager"] = "쿨다운 관리자",
    ["AuraBuff Reminders"] = "오라/버프 알림",
    ["Global Settings"] = "전체 설정",
    ["Quick Setup"] = "빠른 설정",
    ["Fonts & Colors"] = "폰트 및 색상",
    ["Enabled Addons"] = "활성 애드온",
    ["Party Mode"] = "파티 모드",
    ["Unlock Mode"] = "잠금 해제 모드",
    ["Snap to:"] = "맞춤 대상:",
    ["Snap Target:"] = "맞춤 대상:",
    ["Snap Target"] = "맞춤 대상",
    ["Select Element"] = "요소 선택",
    ["All Elements"] = "모든 요소",
    ["Dark Overlays"] = "어두운 오버레이",
    ["Cursor Light"] = "커서 조명",
    ["Snap to Elements"] = "요소 맞춤",
    ["Hover Top Bar"] = "상단 바 표시",
    ["Cursor Lite"] = "커서",
    ["Buff Bar"] = "버프 바",
    ["Local MS"] = "로컬 지연시간",
    ["World MS"] = "월드 지연시간",
    ["Tertiary Stats"] = "3차 스탯",
    ["Enabled"] = "활성",
    ["Disabled"] = "비활성",
    ["Layout"] = "배치",
    ["Spell"] = "주문",
    ["Glow"] = "반짝임",
    ["Gradient"] = "그라데이션",
    ["Direction"] = "방향",
    ["Background"] = "배경",
    ["Anchor"] = "앵커",
    ["Animation"] = "애니메이션",
    ["Visibility"] = "표시",
    ["Duration"] = "지속시간",
    ["Timer"] = "타이머",
    ["Stack"] = "중첩",
    ["Count"] = "개수",
    ["Threshold"] = "임계값",
    ["Growth"] = "성장",
    ["Housing"] = "하우징",
    ["Zone"] = "지역",
    ["Zones"] = "지역",
    ["Talent"] = "특성",
    ["Preset"] = "프리셋",
    ["Profile"] = "프로필",
    ["Reminder"] = "알림",
    ["Reminders"] = "알림",
    ["Sync"] = "동기화",
    ["Button"] = "버튼",
    ["Buttons"] = "버튼",
    ["Assigned"] = "할당된",
    ["Icon"] = "아이콘",
    ["Power"] = "자원",
    ["Current"] = "현재",
    ["Active"] = "활성",
    ["Name"] = "이름",
    ["Percent"] = "퍼센트",
    ["Texture"] = "텍스처",
    ["Keybind"] = "단축키",
    ["Charges"] = "충전 수",
    ["Friendly"] = "아군",
    ["Cast"] = "시전",
    ["Aura"] = "오라",
    ["Buff"] = "버프",
    ["Debuff"] = "디버프",
    ["Top"] = "상단",
    ["Bottom"] = "하단",
    ["Left"] = "왼쪽",
    ["Right"] = "오른쪽",
    ["Location"] = "위치",
    ["Custom"] = "사용자 지정",
    ["Shape"] = "형태",
    ["Bars"] = "바",
    ["Blizzard"] = "블리자드",
    ["Casting"] = "시전",
    ["Proc"] = "발동",
    ["Interactions"] = "상호작용",
    ["Health Bar"] = "생명력 바",
    ["Power Bar"] = "자원 바",
    ["Cast Bar"] = "시전 바",
    ["Text Bar"] = "텍스트 바",
    ["Class Resource Bar"] = "클래스 자원 바",
    ["Class Resource"] = "클래스 자원",
    ["Class Colors"] = "직업 색상",
    ["Class Color"] = "직업 색상",
    ["Class Icon"] = "직업 아이콘",
    ["Role Tint"] = "역할 틴트",
    ["Quest Mob"] = "퀘스트 몹",
    ["Enemy Name Text"] = "적 이름 텍스트",
    ["Enemy Name"] = "적 이름",
    ["Target of Target"] = "대상의 대상",
    ["Focus Target"] = "주시 대상",
    ["Boss Frames"] = "보스 프레임",
    ["Boss Frame"] = "보스 프레임",
    ["Pet Frame"] = "펫 프레임",
    ["Player Cast Bar"] = "플레이어 시전 바",
    ["Combat Indicator"] = "전투 표시",
    ["Bar Animations"] = "바 애니메이션",
    ["Bar Visibility"] = "바 표시",
    ["Bar Layout"] = "바 배치",
    ["Bar Texture"] = "바 텍스처",
    ["Bar Spacing"] = "바 간격",
    ["Bar Scale"] = "바 배율",
    ["Bar Opacity"] = "바 투명도",
    ["Background Color"] = "배경 색상",
    ["Border Color"] = "테두리 색상",
    ["Border Size"] = "테두리 크기",
    ["Font Size"] = "폰트 크기",
    ["Frame Width"] = "프레임 너비",
    ["Frame Height"] = "프레임 높이",
    ["Frame Scale"] = "프레임 배율",
    ["Frame Spacing"] = "프레임 간격",
    ["Column Spacing"] = "열 간격",
    ["Column Growth"] = "열 성장 방향",
    ["Top Left"] = "좌상단",
    ["Top Right"] = "우상단",
    ["Bottom Left"] = "좌하단",
    ["Bottom Right"] = "우하단",
    ["Left to Right"] = "왼쪽에서 오른쪽",
    ["Right to Left"] = "오른쪽에서 왼쪽",
    ["Bottom to Top"] = "아래에서 위",
    ["General"] = "일반",
    ["Display"] = "표시",
    ["Combat"] = "전투",
    ["Extras"] = "추가 기능",
    ["Fonts"] = "폰트",
    ["Developer"] = "개발자",
    ["Reset"] = "초기화",
    ["Portrait"] = "초상화",
    ["Consumables"] = "소모품",
    ["Auras"] = "오라",
    ["Buffs"] = "버프",
    ["Enemy"] = "적",
    ["Player"] = "플레이어",
    ["NPC"] = "NPC",
    ["Boss"] = "보스",
    ["Pet"] = "펫",
    ["Focus"] = "주시",
    ["Target"] = "대상",
    ["Number"] = "수치",
    ["Theme"] = "테마",
    ["Dark"] = "어두운",
    ["Light"] = "빛",
    ["Repair"] = "수리",
    ["Junk"] = "잡동사니",
    ["Cooldown"] = "쿨다운",
    ["Rows"] = "행",
    ["Row"] = "행",
    ["Enemy Name"] = "적 이름",
    ["Health Percent"] = "생명력 퍼센트",
    ["Health Number"] = "생명력 수치",
    ["Raid Marker"] = "징표",
    ["Elite/Rare Indicator"] = "정예/희귀 표시",
    ["Celebration Trigger"] = "축하 트리거",
    ["Celebration Triggers"] = "축하 트리거",
    ["Auto Celebration"] = "자동 축하",
    ["Friendly Player Nameplates"] = "아군 플레이어 이름표",
    ["Friendly NPC Nameplates"] = "아군 NPC 이름표",
    ["Enemy Pet Nameplates"] = "적 펫 이름표",
    ["Player Debuffs"] = "내 디버프",
    ["Name Only"] = "이름만",
    ["Hash Line"] = "기준선",
    ["Focus Cast"] = "주시 시전",
    ["Mini-Bosses"] = "미니 보스",
    ["Spell Casters"] = "시전자",
    ["Non-Tank Threat"] = "비탱커 위협",
    ["Tank Threat"] = "탱커 위협",
    ["Has Aggro"] = "어그로 보유",
    ["Near Aggro"] = "어그로 근접",
    ["Losing Aggro"] = "어그로 상실 중",
    ["No Aggro"] = "어그로 없음",
    ["Raid Finder"] = "공찾",
    ["Keystone"] = "쐐기",
    ["Mythic"] = "신화",
    ["Heroic"] = "영웅",
    ["Normal"] = "일반",
    ["Arena"] = "투기장",
    ["Quest Mob"] = "퀘스트 몹",
}

local KO_TERMS_EXTRA = {
    ["Tooltip"] = "툴팁",
    ["Preview"] = "미리보기",
    ["Frame"] = "프레임",
    ["Frames"] = "프레임",
    ["Button"] = "버튼",
    ["Buttons"] = "버튼",
    ["Orientation"] = "방향",
    ["Vertical"] = "세로",
    ["Horizontal"] = "가로",
    ["Cursor"] = "커서",
    ["Trail"] = "궤적",
    ["Ring"] = "링",
    ["Spark"] = "반짝이",
    ["Popup"] = "팝업",
    ["Label"] = "라벨",
    ["Swatch"] = "색상 견본",
    ["Spell ID"] = "주문 ID",
    ["Lua Error"] = "Lua 오류",
    ["Lua Errors"] = "Lua 오류",
    ["Minimap Button"] = "미니맵 버튼",
    ["Health Value"] = "생명력 수치",
}

for source, target in pairs(KO_TERMS_EXTRA) do
    KO_TERMS[source] = target
end

local KO_ADDON_LABELS = {
    ["EllesmereUI"] = "코어",
    ["EllesmereUIActionBars"] = "액션 바",
    ["EllesmereUIUnitFrames"] = "유닛 프레임",
    ["EllesmereUINameplates"] = "이름표",
    ["EllesmereUIRaidFrames"] = "공대 프레임",
    ["EllesmereUIResourceBars"] = "자원 바",
    ["EllesmereUIAuraBuffReminders"] = "오라/버프 알림",
    ["EllesmereUICooldownManager"] = "쿨다운 관리자",
    ["EllesmereUICursor"] = "커서",
    ["EllesmereUIBasics"] = "기본 기능",
    ["EllesmereUIPartyMode"] = "파티 모드",
    ["ActionBars"] = "액션 바",
    ["UnitFrames"] = "유닛 프레임",
    ["Nameplates"] = "이름표",
    ["RaidFrames"] = "공대 프레임",
    ["ResourceBars"] = "자원 바",
    ["AuraBuffReminders"] = "오라/버프 알림",
    ["CooldownManager"] = "쿨다운 관리자",
    ["PartyMode"] = "파티 모드",
    ["Basics"] = "기본 기능",
    ["Cursor"] = "커서",
}

local dynamicGameNameMap = {}
local dynamicGameNameMapReady = false

local koTermOrder
local localizedTextCache = {}

local function EscapeLuaPattern(text)
    return (text:gsub("([%%%^%$%(%)%.%[%]%*%+%-%?])", "%%%1"))
end

local function BuildKoTermOrder()
    if koTermOrder then return end
    koTermOrder = {}
    for source, target in pairs(KO_TERMS) do
        koTermOrder[#koTermOrder + 1] = {
            pattern = EscapeLuaPattern(source),
            source = source,
            target = target,
        }
    end
    table.sort(koTermOrder, function(a, b)
        return #a.source > #b.source
    end)
end

local function LocalizePhrase(text)
    if type(text) ~= "string" or text == "" then return text end
    if KO_EXACT[text] then return KO_EXACT[text] end
    BuildKoTermOrder()
    local localized = text
    for i = 1, #koTermOrder do
        local entry = koTermOrder[i]
        localized = localized:gsub(entry.pattern, entry.target)
    end
    if localized == text and text == text:upper() and text:find("%u") then
        local titleish = text:lower():gsub("(%a)([%w']*)", function(first, rest)
            return first:upper() .. rest
        end)
        if KO_EXACT[titleish] then
            return KO_EXACT[titleish]
        end
        localized = titleish
        for i = 1, #koTermOrder do
            local entry = koTermOrder[i]
            localized = localized:gsub(entry.pattern, entry.target)
        end
    end
    return localized
end

local function TrimText(text)
    return (text:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function LocalizeAddonToken(token)
    token = TrimText(token or "")
    return KO_ADDON_LABELS[token] or LocalizePhrase(token)
end

local function LocalizeAddonList(list)
    if type(list) ~= "string" or list == "" then return list end
    local localized = {}
    for token in list:gmatch("[^,]+") do
        localized[#localized + 1] = LocalizeAddonToken(token)
    end
    if #localized > 0 then
        return table.concat(localized, ", ")
    end
    return list
end

local function GetLocalizedSpellName(spellID)
    if not spellID then return nil end
    if C_Spell and C_Spell.GetSpellName then
        local name = C_Spell.GetSpellName(spellID)
        if type(name) == "string" and name ~= "" then
            return name
        end
    end
    if GetSpellInfo then
        local name = GetSpellInfo(spellID)
        if type(name) == "string" and name ~= "" then
            return name
        end
    end
end

local function GetLocalizedItemName(itemID)
    if not itemID then return nil end
    local name
    if C_Item and C_Item.GetItemNameByID then
        local ok, result = pcall(C_Item.GetItemNameByID, itemID)
        if ok and type(result) == "string" and result ~= "" then
            name = result
        end
    end
    if (not name or name == "") and GetItemInfo then
        local result = GetItemInfo(itemID)
        if type(result) == "string" and result ~= "" then
            name = result
        end
    end
    return name
end

local function RegisterDynamicGameName(englishName, localizedName)
    if type(englishName) ~= "string" or englishName == "" then return end
    if type(localizedName) ~= "string" or localizedName == "" then return end
    dynamicGameNameMap[englishName] = localizedName
end

local function RegisterSpellEntryNames(entries)
    if type(entries) ~= "table" then return end
    for i = 1, #entries do
        local entry = entries[i]
        if type(entry) == "table" and type(entry.name) == "string" then
            local localizedName = GetLocalizedSpellName(entry.castSpell)
            if not localizedName and type(entry.buffIDs) == "table" then
                localizedName = GetLocalizedSpellName(entry.buffIDs[1])
            end
            local originalName = entry._euiKROriginalName or entry.name
            RegisterDynamicGameName(originalName, localizedName)
            if entry.name ~= originalName then
                RegisterDynamicGameName(entry.name, localizedName)
            end
        end
    end
end

local function RegisterItemEntryNames(entries)
    if type(entries) ~= "table" then return end
    for i = 1, #entries do
        local entry = entries[i]
        if type(entry) == "table" and type(entry.name) == "string" then
            local itemID = entry.itemID
            if not itemID and type(entry.items) == "table" then
                itemID = entry.items[1]
            end
            local localizedName = GetLocalizedItemName(itemID)
            local originalName = entry._euiKROriginalName or entry.name
            RegisterDynamicGameName(originalName, localizedName)
            if entry.name ~= originalName then
                RegisterDynamicGameName(entry.name, localizedName)
            end
        end
    end
end

local function RegisterWeaponEnchantChoiceNames(choices, items)
    local itemNameMap = {}
    if type(items) == "table" then
        for i = 1, #items do
            local entry = items[i]
            if type(entry) == "table" and type(entry.name) == "string" and entry.itemID then
                local localizedName = GetLocalizedItemName(entry.itemID)
                if localizedName and localizedName ~= "" then
                    itemNameMap[entry.name] = localizedName
                    if type(entry._euiKROriginalName) == "string" and entry._euiKROriginalName ~= "" then
                        itemNameMap[entry._euiKROriginalName] = localizedName
                    end
                end
            end
        end
    end
    if type(choices) ~= "table" then return end
    for i = 1, #choices do
        local choice = choices[i]
        if type(choice) == "table" and type(choice.name) == "string" then
            local originalName = choice._euiKROriginalName or choice.name
            local localizedName = itemNameMap[choice.name] or itemNameMap[originalName]
            RegisterDynamicGameName(originalName, localizedName)
            if choice.name ~= originalName then
                RegisterDynamicGameName(choice.name, localizedName)
            end
        end
    end
end

local dynamicGameNameSourceStamp = 0

local function GetDynamicGameNameSourceStamp()
    local stamp = 0
    local sources = {
        _G._EABR_RAID_BUFFS,
        _G._EABR_AURAS,
        _G._EABR_ROGUE_POISONS,
        _G._EABR_PALADIN_RITES,
        _G._EABR_SHAMAN_IMBUES,
        _G._EABR_SHAMAN_SHIELDS,
        _G._EABR_FLASK_ITEMS,
        _G._EABR_FOOD_ITEMS,
        _G._EABR_WEAPON_ENCHANT_ITEMS,
        _G._EABR_WEAPON_ENCHANT_CHOICES,
    }
    for i = 1, #sources do
        local entries = sources[i]
        if type(entries) == "table" then
            stamp = stamp + #entries
        end
    end
    return stamp
end

local function BuildDynamicGameNameMap(force)
    local sourceStamp = GetDynamicGameNameSourceStamp()
    if not force and dynamicGameNameMapReady and dynamicGameNameSourceStamp == sourceStamp then
        return
    end
    dynamicGameNameMap = {}
    RegisterSpellEntryNames(_G._EABR_RAID_BUFFS)
    RegisterSpellEntryNames(_G._EABR_AURAS)
    RegisterSpellEntryNames(_G._EABR_ROGUE_POISONS)
    RegisterSpellEntryNames(_G._EABR_PALADIN_RITES)
    RegisterSpellEntryNames(_G._EABR_SHAMAN_IMBUES)
    RegisterSpellEntryNames(_G._EABR_SHAMAN_SHIELDS)
    RegisterItemEntryNames(_G._EABR_FLASK_ITEMS)
    RegisterItemEntryNames(_G._EABR_FOOD_ITEMS)
    RegisterItemEntryNames(_G._EABR_WEAPON_ENCHANT_ITEMS)
    RegisterWeaponEnchantChoiceNames(_G._EABR_WEAPON_ENCHANT_CHOICES, _G._EABR_WEAPON_ENCHANT_ITEMS)
    dynamicGameNameSourceStamp = sourceStamp
    dynamicGameNameMapReady = (sourceStamp > 0)
end

local function ResolveDynamicGameName(text)
    local sourceStamp = GetDynamicGameNameSourceStamp()
    if not dynamicGameNameMapReady or dynamicGameNameSourceStamp ~= sourceStamp then
        BuildDynamicGameNameMap(true)
    elseif text and sourceStamp > 0 and not dynamicGameNameMap[text] then
        BuildDynamicGameNameMap(true)
    end
    return dynamicGameNameMap[text]
end

local function TranslateKoreanText(text)
    if not IS_KOREAN_LOCALE or type(text) ~= "string" or text == "" then
        return text
    end
    local cached = localizedTextCache[text]
    if cached then
        return cached
    end
    local localized = KO_EXACT[text]
    if not localized then
        localized = ResolveDynamicGameName(text)
    end
    if not localized then
        local capture = (not text:find(" is set to None$") and not text:find(" is off$")) and text:match("^Enable (.+)$")
        if capture then
            localized = LocalizePhrase(capture) .. " 활성화"
        end
    end
    if not localized then
        local capture = text:match("^Disable (.+)$")
        if capture then
            localized = LocalizePhrase(capture) .. " 비활성화"
        end
    end
    if not localized then
        local capture = text:match("^Show (.+)$")
        if capture then
            localized = LocalizePhrase(capture) .. " 표시"
        end
    end
    if not localized then
        local capture = text:match("^Hide (.+)$")
        if capture then
            localized = LocalizePhrase(capture) .. " 숨김"
        end
    end
    if not localized then
        local capture = text:match("^Always Show (.+)$")
        if capture then
            localized = "항상 " .. LocalizePhrase(capture) .. " 표시"
        end
    end
    if not localized then
        local capture = text:match("^Use (.+)$")
        if capture then
            localized = LocalizePhrase(capture) .. " 사용"
        end
    end
    if not localized then
        local capture = text:match("^Add New (.+)$")
        if capture then
            localized = "새 " .. LocalizePhrase(capture) .. " 추가"
        end
    end
    if not localized then
        local capture = text:match("^Add (.+)$")
        if capture then
            localized = LocalizePhrase(capture) .. " 추가"
        end
    end
    if not localized then
        local capture = text:match("^Delete (.+)$")
        if capture then
            localized = LocalizePhrase(capture) .. " 삭제"
        end
    end
    if not localized then
        local capture = text:match("^Reset (.+)$")
        if capture then
            localized = LocalizePhrase(capture) .. " 초기화"
        end
    end
    if not localized then
        local capture = text:match("^Apply (.+) to all Bars$")
        if capture then
            localized = "모든 바에 " .. LocalizePhrase(capture) .. " 적용"
        end
    end
    if not localized then
        local capture = text:match("^(.+) Settings$")
        if capture then
            localized = LocalizePhrase(capture) .. " 설정"
        end
    end
    if not localized then
        local capture = text:match("^(.+) Color$")
        if capture then
            localized = LocalizePhrase(capture) .. " 색상"
        end
    end
    if not localized then
        local capture = text:match("^(.+) Size$")
        if capture then
            localized = LocalizePhrase(capture) .. " 크기"
        end
    end
    if not localized then
        local capture = text:match("^(.+) Width$")
        if capture then
            localized = LocalizePhrase(capture) .. " 너비"
        end
    end
    if not localized then
        local capture = text:match("^(.+) Height$")
        if capture then
            localized = LocalizePhrase(capture) .. " 높이"
        end
    end
    if not localized then
        local capture = text:match("^(.+) Scale$")
        if capture then
            localized = LocalizePhrase(capture) .. " 배율"
        end
    end
    if not localized then
        local capture = text:match("^(.+) Spacing$")
        if capture then
            localized = LocalizePhrase(capture) .. " 간격"
        end
    end
    if not localized then
        local capture = text:match("^(.+) Padding$")
        if capture then
            localized = LocalizePhrase(capture) .. " 여백"
        end
    end
    if not localized then
        local capture = text:match("^(.+) Position$")
        if capture then
            localized = LocalizePhrase(capture) .. " 위치"
        end
    end
    if not localized then
        local capture = text:match("^(.+) Location$")
        if capture then
            localized = LocalizePhrase(capture) .. " 위치"
        end
    end
    if not localized then
        local capture = text:match("^(.+) Texture$")
        if capture then
            localized = LocalizePhrase(capture) .. " 텍스처"
        end
    end
    if not localized then
        local capture = text:match("^(.+) Opacity$")
        if capture then
            localized = LocalizePhrase(capture) .. " 투명도"
        end
    end
    if not localized then
        local capture = text:match("^(.+) Duration$")
        if capture then
            localized = LocalizePhrase(capture) .. " 지속시간"
        end
    end
    if not localized then
        local capture = text:match("^(.+) Font$")
        if capture then
            localized = LocalizePhrase(capture) .. " 폰트"
        end
    end
    if not localized then
        local capture = text:match("^Number of (.+)$")
        if capture then
            localized = LocalizePhrase(capture) .. " 개수"
        end
    end
    if not localized then
        local capture = text:match("^(.+) Preview$")
        if capture then
            localized = LocalizePhrase(capture) .. " 미리보기"
        end
    end
    if not localized then
        local capture = text:match("^(.+) Mode$")
        if capture then
            localized = LocalizePhrase(capture) .. " 모드"
        end
    end
    if not localized then
        local capture = text:match("^(.+) Style$")
        if capture then
            localized = LocalizePhrase(capture) .. " 스타일"
        end
    end
    if not localized then
        local capture = text:match("^(.+) Type$")
        if capture then
            localized = LocalizePhrase(capture) .. " 유형"
        end
    end
    if not localized then
        local capture = text:match("^(.+) Text$")
        if capture then
            localized = LocalizePhrase(capture) .. " 텍스트"
        end
    end
    if not localized then
        local capture = text:match("^Enable (.+) is set to None$")
        if capture then
            localized = LocalizePhrase(capture) .. "이(가) 없음으로 설정되어 있습니다"
        end
    end
    if not localized then
        local capture = text:match("^Enable (.+) is off$")
        if capture then
            localized = LocalizePhrase(capture) .. "이(가) 꺼져 있습니다"
        end
    end
    if not localized then
        local capture = text:match("^(.+) is set to None$")
        if capture then
            localized = LocalizePhrase(capture) .. "이(가) 없음으로 설정되어 있습니다"
        end
    end
    if not localized then
        local capture = text:match("^(.+) is off$")
        if capture then
            localized = LocalizePhrase(capture) .. "이(가) 꺼져 있습니다"
        end
    end
    if not localized then
        local capture = text:match("^Disabled while (.+) is enabled$")
        if capture then
            localized = LocalizePhrase(capture) .. "이(가) 활성화되어 있어 사용할 수 없습니다"
        end
    end
    if not localized then
        local capture = (
            not text:find("^This option requires at least one ")
            and not text:find("^This option requires the ")
            and not text:find("^This option requires a .+ other than None to be enabled$")
            and not text:find("^This option requires you to enable ")
        ) and text:match("^This option requires (.+) to be enabled$")
        if capture then
            localized = "이 옵션을 사용하려면 " .. LocalizePhrase(capture) .. " 활성화가 필요합니다"
        end
    end
    if not localized then
        local capture = text:match("^This option requires at least one (.+) to be enabled$")
        if capture then
            localized = "이 옵션을 사용하려면 적어도 하나의 " .. LocalizePhrase(capture) .. "가 필요합니다"
        end
    end
    if not localized then
        local capture = text:match("^This option requires the (.+) trigger to be enabled$")
        if capture then
            localized = "이 옵션을 사용하려면 " .. LocalizePhrase(capture) .. " 트리거가 필요합니다"
        end
    end
    if not localized then
        local capture = text:match("^This option requires a (.+) other than None to be enabled$")
        if capture then
            localized = "이 옵션을 사용하려면 " .. LocalizePhrase(capture) .. "이(가) 없음 이외로 설정되어야 합니다"
        end
    end
    if not localized then
        local capture = text:match("^This option requires you to enable (.+) in the Global Settings %-%> Enabled Addons tab$")
        if capture then
            localized = "이 옵션을 사용하려면 전체 설정 -> 활성 애드온 탭에서 " .. LocalizePhrase(capture) .. "를 활성화해야 합니다"
        end
    end
    if not localized then
        local capture = text:match("^ACTION BAR (.+)$")
        if capture then
            localized = "액션 바 " .. capture
        end
    end
    if not localized then
        local barNum, btnNum = text:match("^ACTION BAR (%d+) BUTTON (%d+) BUFF ASSIGNMENTS$")
        if barNum and btnNum then
            localized = "액션 바 " .. barNum .. " 버튼 " .. btnNum .. " 버프 할당"
        end
    end
    if not localized then
        local capture = text:match('^Delete "(.+)"%?$')
        if capture then
            localized = '"' .. capture .. '" 삭제하시겠습니까?'
        end
    end
    if not localized then
        local capture = text:match('^Are you sure you want to delete "(.+)"%?$')
        if capture then
            localized = '"' .. capture .. '" 삭제하시겠습니까?'
        end
    end
    if not localized then
        local capture = text:match('^Enter a new name for "(.+)":$')
        if capture then
            localized = '"' .. capture .. '"의 새 이름을 입력하세요:'
        end
    end
    if not localized then
        local capture = text:match("^Select which specs you want (.+) to be assigned to$")
        if capture then
            localized = "어떤 전문화에 " .. capture .. "를 할당할지 선택하세요"
        end
    end
    if not localized then
        local capture = text:match("^Buff Bar: (.+)$")
        if capture then
            localized = "버프 바: " .. capture
        end
    end
    if not localized then
        local capture = text:match("^CDM: (.+)$")
        if capture then
            localized = "CDM: " .. capture
        end
    end
    if not localized then
        local capture = text:match("^Bar (%d+)$")
        if capture then
            localized = "바 " .. capture
        end
    end
    if not localized then
        local capture = text:match("^Spell (%d+)$")
        if capture then
            localized = "주문 " .. capture
        end
    end
    if not localized then
        local capture = text:match("^(.+) %(Raid%)$")
        if capture then
            localized = LocalizePhrase(capture) .. " (공격대)"
        end
    end
    if not localized then
        local version = text:match("^v([%w%.%-]+) loaded%. Type |cff0cd29f/eui|r for settings, and |cff0cd29f/unlock|r for Unlock Mode%.$")
        if version then
            localized = "v" .. version .. " 로드됨. 설정은 |cff0cd29f/eui|r, 잠금 해제 모드는 |cff0cd29f/unlock|r"
        end
    end
    if not localized then
        local count = text:match("^Sold (%d+) junk items?%.$")
        if count then
            localized = "잡템 " .. count .. "개를 판매했습니다."
        end
    end
    if not localized then
        local gold, silver, suffix = text:match("^Repaired all items for (%d+)g (%d+)s%.(.*)$")
        if gold and silver then
            suffix = suffix or ""
            if suffix == " (guild bank)" then
                suffix = " (길드 은행)"
            end
            localized = "모든 아이템을 " .. gold .. "골드 " .. silver .. "실버에 수리했습니다." .. suffix
        end
    end
    if not localized then
        local list = text:match("^The following EllesmereUI addons are out of date%. Please update so all addons are the same version:%s*\n\n(.+)$")
        if list then
            localized = "다음 EllesmereUI 애드온의 버전이 오래되었습니다. 모든 애드온을 같은 버전으로 업데이트하세요:\n\n" .. LocalizeAddonList(list)
        end
    end
    if not localized then
        local otherAddon, addonList = text:match("^(.+) is not compatible with EllesmereUI (.+)%. Running both at the same time may cause errors or unexpected behavior%.%s*\n\nPlease disable one of them%.$")
        if otherAddon and addonList then
            localized = otherAddon .. " 애드온은 EllesmereUI " .. LocalizeAddonList(addonList) .. "와(과) 호환되지 않습니다. 함께 실행하면 오류나 예기치 않은 동작이 발생할 수 있습니다.\n\n둘 중 하나를 비활성화하세요."
        end
    end
    if not localized then
        local addonName = text:match("^Install by searching for |cff%x%x%x%x%x%x(.+)|r in your favorite WoW Addon manager: Curseforge, WoWup or Wago$")
        if addonName then
            localized = "|cff0cd29d설치 방법:|r 즐겨 사용하는 WoW 애드온 관리자(Curseforge, WoWUp, Wago)에서 |cff0cd29f" .. addonName .. "|r 을(를) 검색하세요."
        end
    end
    if not localized then
        local addonName = text:match("^Install by searching for |cffffffff(.+)|r in your favorite WoW Addon manager: Curseforge, WoWup or Wago$")
        if addonName then
            localized = "|cff0cd29d설치 방법:|r 즐겨 사용하는 WoW 애드온 관리자(Curseforge, WoWUp, Wago)에서 |cffffffff" .. addonName .. "|r 을(를) 검색하세요."
        end
    end
    if not localized then
        local cpuText = text:match("^CPU Usage: |cffffffff(.+)|r$")
        if cpuText then
            localized = "CPU 사용량: |cffffffff" .. cpuText .. "|r"
        end
    end
    if not localized then
        local memText = text:match("^Memory Usage: |cffffffff(.+)|r$")
        if memText then
            localized = "메모리 사용량: |cffffffff" .. memText .. "|r"
        end
    end
    if not localized then
        local prefix, body = text:match("^(|c%x%x%x%x%x%x%x%x.-|r)%s*(.+)$")
        if prefix and body then
            local translatedBody = TranslateKoreanText(body)
            if translatedBody ~= body then
                localized = prefix .. " " .. translatedBody
            end
        end
    end
    if not localized then
        localized = LocalizePhrase(text)
    end
    localizedTextCache[text] = localized or text
    return localized or text
end

function NS.Translate(text)
    return TranslateKoreanText(text)
end

function NS.GetLocalizedSpellName(spellID)
    return GetLocalizedSpellName(spellID)
end

function NS.GetLocalizedItemName(itemID)
    return GetLocalizedItemName(itemID)
end

function NS.InvalidateDynamicGameNameMap()
    dynamicGameNameMapReady = false
    dynamicGameNameSourceStamp = 0
    localizedTextCache = {}
end

local function LocalizeTextObject(obj)
    if not IS_KOREAN_LOCALE or not obj or not obj.GetText or not obj.SetText then return end
    if obj._euiSkipLocalize then return end
    if obj.GetObjectType and obj:GetObjectType() == "EditBox" then return end

    local ok = pcall(function()
        local currentText = obj:GetText()
        if type(currentText) ~= "string" or currentText == "" then return end
        local original = obj._euiOriginalText
        if type(original) ~= "string" or original == "" then
            original = currentText
            obj._euiOriginalText = original
        elseif currentText ~= original and currentText ~= NS.Translate(original) then
            original = currentText
            obj._euiOriginalText = original
        end
        local localized = NS.Translate(original)
        if localized and localized ~= currentText then
            obj:SetText(localized)
        end
    end)

    if not ok then
        obj._euiSkipLocalize = true
    end
end

function NS.LocalizeFrameTexts(root)
    if not IS_KOREAN_LOCALE or not root then return end
    local queue = { root }
    local seen = { [root] = true }
    local index = 1

    while queue[index] do
        local current = queue[index]
        index = index + 1

        LocalizeTextObject(current)

        if current.GetRegions then
            local regions = { current:GetRegions() }
            for i = 1, #regions do
                LocalizeTextObject(regions[i])
            end
        end

        if current.GetChildren then
            local children = { current:GetChildren() }
            for i = 1, #children do
                local child = children[i]
                if child and not seen[child] then
                    seen[child] = true
                    queue[#queue + 1] = child
                end
            end
        end
    end
end

function NS.LocalizeTooltip(tooltip)
    if not IS_KOREAN_LOCALE or not tooltip or not tooltip.GetName then return end
    local baseName = tooltip:GetName()
    if type(baseName) ~= "string" or baseName == "" then return end
    local numLines = tooltip.NumLines and tooltip:NumLines() or 0
    for i = 1, numLines do
        LocalizeTextObject(_G[baseName .. "TextLeft" .. i])
        LocalizeTextObject(_G[baseName .. "TextRight" .. i])
    end
end
