# 如何添加新 Realm 补丁

> 以添加 `"MyServer"` 为例

---

## 一、下拉框添加选项

编辑 `DXE_Options/Options.lua`，在 `Realm` 的 `values` 表中加一行：

```lua
values = {
    Apollo   = "Apollo",
    JRG      = "JRG",
    Hongxi   = "Hongxi",
    Test     = "Test (Dev)",
    MyServer = "MyServer",   -- ← 新增
},
```

---

## 二、创建补丁文件（每个副本模块一个）

以 `DXE_Bastion` 为例，创建 `DXE_Bastion/Data_Bastion_MyServer.lua`：

```lua
-- Data_Bastion_MyServer.lua
local L, SN, ST = DXE.L, DXE.SN, DXE.ST
local realm = "MyServer"

DXE:RegisterRealmPatch(realm, "halfus", {
})

DXE:RegisterRealmPatch(realm, "valther", {
})

DXE:RegisterRealmPatch(realm, "ascendcouncil", {
})

DXE:RegisterRealmPatch(realm, "chogall", {
})

DXE:RegisterRealmPatch(realm, "sinestra", {
})

DXE:RegisterRealmPatch(realm, "bottrash", {
})
```

`realm` 变量值与下拉框中的 key 一致。`"halfus"` 等必须与 `Encounters.lua` 中各 `data.key` 一致。空 `{}` = 无差异。

> 文件不再需要 Realm 守卫。切换 Realm 后补丁自动生效，无需 `/reload`。

---

## 三、TOC 引入新文件

编辑 `DXE_Bastion/DXE_Bastion.toc`，加到 `Encounters.lua` **之前**：

```
Locales.lua
Data_Bastion_Apollo.lua
Data_Bastion_JRG.lua
Data_Bastion_Test.lua
Data_Bastion_MyServer.lua   ← 新增
Encounters.lua
```

---

## 四、对其他副本模块重复二、三

**识别副本模块**：目录名符合 `DXE_{副本名}` 且包含 `Encounters.lua` 文件即为副本模块。

```
DXE_Firelands/          ← 副本模块 ✅
├── Encounters.lua
│   ...

DXE_Loader/             ← 加载器，非副本模块 ❌
DXE_Options/            ← 设置面板，非副本模块 ❌
```

对每个副本模块，逐一创建 `Data_{副本名}_{Realm}.lua` 并更新对应的 `.toc` 文件。

---

## 五、如何构建补丁

### 5.1 文件头声明

补丁文件声明 `L`、`SN`、`ST` 等快捷变量及 `realm`，无需 Realm 守卫：

```lua
local L, SN, ST = DXE.L, DXE.SN, DXE.ST
local realm = "MyServer"
```

`RegisterRealmPatch` 的第一个参数 `realm` 决定了补丁在哪个 Realm 生效。

### 5.2 字段覆盖（默认行为）

有差异时在对应 `{}` 中写入字段：

```lua
DXE:RegisterRealmPatch(realm, "halfus", {
    alerts = {
        enragecd = { time = 420 },
    },
})
```

**规则**：

| 场景 | 写法 | 结果 |
|------|------|------|
| 覆盖单个字段 | `{ time = 14 }` | 只改 time，其余不动 |
| 替换整个数组 | `scan = { 1, 2, 3 }` | 整表替换 |
| 新增一个 key | `{ newalert = { ... } }` | 字典内新增 |
| 删除一个 key | `{ obsolete = false }` | 删除该 key |
| 不写的 BOSS | 不调用 `RegisterRealmPatch` | 零改动 |

### 5.3 强制整表替换（DXE.Replace）

默认行为下，字典型字段（如 `alerts`）是递归合并。如果希望**整个字典替换**而非合并，用 `DXE.Replace`：

```lua
local realm = "MyServer"

DXE:RegisterRealmPatch(realm, "halfus", {
    alerts = DXE.Replace({
        enragecd = {
            varname = L.alert["Berserk CD"],
            type = "dropdown",
            text = L.alert["Berserk"],
            time = 999,
            flashtime = 10,
            color1 = "RED",
            icon = ST[12317],
        },
    }),
})
```

⚠️ `DXE.Replace` 会**丢弃目标中未提及的全部字段**。上面例子中 `halfus` 除 `enragecd` 外所有告警都会被删除。同时被替换的告警必须写全字段（`type`、`text`、`icon` 等），否则告警无法正常显示。

一般场景下**不需要**使用 `DXE.Replace`，默认的合并行为已够用。
