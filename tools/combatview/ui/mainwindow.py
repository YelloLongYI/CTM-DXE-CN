"""Main window for CombatView."""

from __future__ import annotations
import json
import logging
import os
import traceback
from pathlib import Path

from PySide6.QtWidgets import (
    QMainWindow, QWidget, QVBoxLayout, QHBoxLayout, QSplitter,
    QListWidget, QListWidgetItem, QLabel, QPushButton, QCheckBox,
    QFileDialog, QStatusBar, QGroupBox, QTextEdit, QMessageBox,
    QSlider, QApplication, QFrame,
    QTableWidget, QTableWidgetItem, QHeaderView, QScrollArea, QAbstractItemView,
    QMenu,
)
from PySide6.QtCore import Qt, QThread, Signal
from PySide6.QtGui import QFont, QColor

from models import Encounter, NPCUnit, SpellEvent, ParseResult
from parser import parse_log
from dxe_export import export_lua, export_json
from ui.timeline import TimelineView

log = logging.getLogger("combatview.ui")


class ParseWorker(QThread):
    finished = Signal(object)
    error = Signal(str)

    def __init__(self, text: str, npc_db: dict):
        super().__init__()
        self._text = text
        self._npc_db = npc_db

    def run(self) -> None:
        try:
            result = parse_log(self._text, self._npc_db)
            self.finished.emit(result)
        except Exception as e:
            log.error("ParseWorker failed: %s", e, exc_info=True)
            self.error.emit(str(e))


class MainWindow(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("CombatView — WOW Combat Log Analyzer")
        self.setMinimumSize(1200, 700)
        self.resize(1400, 850)

        self._result: ParseResult | None = None
        self._active_enc_index: int = -1
        self._npc_db: dict = {}
        self._user_npc: dict = {}
        self._config: dict = {}
        self._load_npc_db()
        self._load_user_npc()
        self._load_config()

        self.setAcceptDrops(True)

        self._setup_ui()
        self._setup_menubar()

    # ---- UI setup ----

    def _setup_ui(self) -> None:
        central = QWidget()
        self._central = central
        self.setCentralWidget(central)
        root = QVBoxLayout(central)
        root.setContentsMargins(6, 6, 6, 6)

        # toolbar
        toolbar = QHBoxLayout()
        btn_open = QPushButton("📂 打开日志")
        btn_open.clicked.connect(self._on_open)
        toolbar.addWidget(btn_open)
        self._btn_export_lua = QPushButton("📤 导出 Lua")
        self._btn_export_lua.clicked.connect(self._on_export_lua)
        self._btn_export_lua.setEnabled(False)
        toolbar.addWidget(self._btn_export_lua)
        self._btn_export_json = QPushButton("💾 导出 JSON")
        self._btn_export_json.clicked.connect(self._on_export_json)
        self._btn_export_json.setEnabled(False)
        toolbar.addWidget(self._btn_export_json)
        toolbar.addStretch()
        btn_timeline = QPushButton("📊 时间轴")
        btn_timeline.clicked.connect(self._on_show_timeline)
        toolbar.addWidget(btn_timeline)
        root.addLayout(toolbar)

        # main splitter
        splitter = QSplitter(Qt.Orientation.Horizontal)

        # -- left panel --
        left = QWidget()
        left_layout = QVBoxLayout(left)
        left_layout.setContentsMargins(0, 0, 0, 0)

        left_layout.addWidget(QLabel("📋 战斗列表"))
        self._enc_list = QListWidget()
        self._enc_list.currentRowChanged.connect(self._on_encounter_selected)
        left_layout.addWidget(self._enc_list)

        # NPC picker
        npc_group = QGroupBox("选择 NPC")
        self._npc_layout = QVBoxLayout(npc_group)
        self._chk_known_only = QCheckBox("只显示已分类 NPC (npc_db)")
        self._chk_known_only.setChecked(False)
        self._chk_known_only.stateChanged.connect(lambda: self._rebuild_npc_checkboxes())
        self._npc_layout.addWidget(self._chk_known_only)
        self._npc_checkboxes: dict[int, QCheckBox] = {}
        self._npc_scroll = QScrollArea()
        self._npc_scroll.setWidgetResizable(True)
        npc_inner = QWidget()
        self._npc_inner_layout = QVBoxLayout(npc_inner)
        self._npc_inner_layout.setContentsMargins(0, 0, 0, 0)
        self._npc_scroll.setWidget(npc_inner)
        self._npc_layout.addWidget(self._npc_scroll)
        left_layout.addWidget(npc_group)

        # event type picker
        evt_group = QGroupBox("选择事件类型")
        evt_group_layout = QVBoxLayout(evt_group)
        self._evt_checkboxes: dict[str, QCheckBox] = {}
        self._evt_scroll = QScrollArea()
        self._evt_scroll.setWidgetResizable(True)
        self._evt_scroll.setMaximumHeight(200)
        evt_inner = QWidget()
        self._evt_inner_layout = QVBoxLayout(evt_inner)
        self._evt_inner_layout.setContentsMargins(0, 0, 0, 0)
        self._evt_scroll.setWidget(evt_inner)
        evt_group_layout.addWidget(self._evt_scroll)
        btn_row = QHBoxLayout()
        btn_all = QPushButton("全选")
        btn_all.clicked.connect(self._on_select_all_events)
        btn_row.addWidget(btn_all)
        btn_none = QPushButton("全不选")
        btn_none.clicked.connect(self._on_select_none_events)
        btn_row.addWidget(btn_none)
        evt_group_layout.addLayout(btn_row)
        left_layout.addWidget(evt_group)

        # spell picker
        spell_group = QGroupBox("选择法术")
        spell_group_layout = QVBoxLayout(spell_group)
        self._spell_checkboxes: dict[str, QCheckBox] = {}
        self._spell_scroll = QScrollArea()
        self._spell_scroll.setWidgetResizable(True)
        self._spell_scroll.setMaximumHeight(200)
        spell_inner = QWidget()
        self._spell_inner_layout = QVBoxLayout(spell_inner)
        self._spell_inner_layout.setContentsMargins(0, 0, 0, 0)
        self._spell_scroll.setWidget(spell_inner)
        spell_group_layout.addWidget(self._spell_scroll)
        spell_btn_row = QHBoxLayout()
        btn_spell_all = QPushButton("全选")
        btn_spell_all.clicked.connect(self._on_select_all_spells)
        spell_btn_row.addWidget(btn_spell_all)
        btn_spell_none = QPushButton("全不选")
        btn_spell_none.clicked.connect(self._on_select_none_spells)
        spell_btn_row.addWidget(btn_spell_none)
        spell_group_layout.addLayout(spell_btn_row)
        left_layout.addWidget(spell_group)

        splitter.addWidget(left)

        # -- center panel: event table --
        center = QWidget()
        center_layout = QVBoxLayout(center)
        center_layout.setContentsMargins(0, 0, 0, 0)
        self._enc_label = QLabel("⏱ 选择一场战斗")
        self._enc_label.setFont(QFont("Consolas", 12))
        center_layout.addWidget(self._enc_label)

        self._table = QTableWidget()
        self._table.setColumnCount(5)
        self._table.setHorizontalHeaderLabels(["时间", "事件", "NPC", "法术", "目标"])
        self._table.setSelectionBehavior(QAbstractItemView.SelectionBehavior.SelectRows)
        self._table.setEditTriggers(QAbstractItemView.EditTrigger.NoEditTriggers)
        self._table.setAlternatingRowColors(True)
        self._table.setSortingEnabled(False)
        self._table.horizontalHeader().setStretchLastSection(True)
        self._table.horizontalHeader().setSectionResizeMode(0, QHeaderView.ResizeMode.Fixed)
        self._table.setColumnWidth(0, 100)
        self._table.horizontalHeader().setSectionResizeMode(1, QHeaderView.ResizeMode.Fixed)
        self._table.setColumnWidth(1, 200)
        self._table.horizontalHeader().setSectionResizeMode(2, QHeaderView.ResizeMode.Fixed)
        self._table.setColumnWidth(2, 180)
        self._table.horizontalHeader().setSectionResizeMode(3, QHeaderView.ResizeMode.Fixed)
        self._table.setColumnWidth(3, 180)
        self._table.verticalHeader().setVisible(False)
        self._table.itemClicked.connect(self._on_table_clicked)
        self._table.setContextMenuPolicy(Qt.ContextMenuPolicy.CustomContextMenu)
        self._table.customContextMenuRequested.connect(self._on_table_context_menu)
        center_layout.addWidget(self._table)
        splitter.addWidget(center)

        # -- right panel --
        right = QWidget()
        right_layout = QVBoxLayout(right)
        right_layout.setContentsMargins(0, 0, 0, 0)
        right_layout.addWidget(QLabel("🔍 事件详情"))
        self._detail = QTextEdit()
        self._detail.setReadOnly(True)
        self._detail.setFont(QFont("Consolas", 11))
        right_layout.addWidget(self._detail)
        splitter.addWidget(right)

        splitter.setSizes([240, 700, 260])
        root.addWidget(splitter)

        # status bar
        self._status = QStatusBar()
        self.setStatusBar(self._status)
        self._status.showMessage("就绪 — 打开 WoWCombatLog.txt 开始分析")

        # timeline window (separate)
        self._timeline_window: QMainWindow | None = None

    def _setup_menubar(self) -> None:
        mb = self.menuBar()
        file_menu = mb.addMenu("文件")
        act = file_menu.addAction("打开日志...")
        act.triggered.connect(self._on_open)

    # ---- NPC database ----

    def _load_npc_db(self) -> None:
        path = Path(__file__).resolve().parent.parent / "npc_db.json"
        try:
            with open(path, "r", encoding="utf-8") as f:
                self._npc_db = json.load(f)
        except Exception:
            self._npc_db = {}

    def _load_user_npc(self) -> None:
        try:
            path = Path.home() / ".combatview_npc.json"
            if path.exists():
                with open(path, "r", encoding="utf-8") as f:
                    self._user_npc = json.load(f)
        except Exception:
            self._user_npc = {}

    def _save_user_npc(self) -> None:
        try:
            path = Path.home() / ".combatview_npc.json"
            with open(path, "w", encoding="utf-8") as f:
                json.dump(self._user_npc, f, ensure_ascii=False, indent=2)
        except Exception:
            pass

    def _classify_npc(self, npc_id: int) -> str:
        if npc_id >= 1_000_000_000:
            return "player"
        if str(npc_id) in self._user_npc:
            return self._user_npc[str(npc_id)]["r"]
        entry = self._npc_db.get(str(npc_id))
        if entry:
            return entry.get("role", "unknown")
        return "unknown"

    def _get_boss_add_ids(self) -> set[int]:
        ids: set[int] = set()
        for nid, entry in self._npc_db.items():
            if entry.get("role") in ("boss", "add"):
                ids.add(int(nid))
        for nid, entry in self._user_npc.items():
            if entry.get("r") in ("boss", "add"):
                ids.add(int(nid))
        return ids

    def _load_config(self) -> None:
        path = Path(__file__).resolve().parent.parent / "config.json"
        try:
            with open(path, "r", encoding="utf-8") as f:
                self._config = json.load(f)
        except Exception:
            self._config = {}

    # ---- Slots ----

    def _on_open(self) -> None:
        path, _ = QFileDialog.getOpenFileName(
            self, "打开 WoWCombatLog.txt", "",
            "Text Files (*.txt *.log);;All Files (*)"
        )
        if path:
            self._load_file(path)

    def _on_parse_done(self, result: ParseResult | None) -> None:
        if result is None:
            QMessageBox.warning(self, "格式错误",
                                "无法识别日志格式。\n\n支持的格式:\n"
                                "1. Cataclysm Classic (4.4.2+) — 带年份、Creature-GUID\n"
                                "2. 原始 Cataclysm (4.3.4) — 无年份、0xF130 GUID")
            self._status.showMessage("解析失败 — 格式不匹配")
            return

        self._result = result
        self._apply_npc_classification()

        self._enc_list.clear()
        for enc in result.encounters:
            dur_str = f"{int(enc.duration // 60)}:{int(enc.duration % 60):02d}" if enc.duration else "?"
            item = QListWidgetItem(f"{enc.name}  [{dur_str}]")
            item.setData(Qt.ItemDataRole.UserRole, enc)
            self._enc_list.addItem(item)

        self._btn_export_lua.setEnabled(True)
        self._btn_export_json.setEnabled(True)
        self._status.showMessage(
            f"解析完成 — {len(result.encounters)} 场战斗, "
            f"{result.raw_lines} 行, {result.parse_time}s "
            f"(格式: {result.log_format})"
        )

        if self._enc_list.count() > 0:
            self._enc_list.setCurrentRow(0)

    def _apply_npc_classification(self) -> None:
        if not self._result:
            return
        for enc in self._result.encounters:
            for npc in enc.npcs.values():
                npc.role = self._classify_npc(npc.npc_id)

    def _on_parse_error(self, msg: str) -> None:
        log.error("Parse error: %s", msg)
        QMessageBox.critical(self, "解析错误",
                             f"{msg}\n\n详细日志: {Path(__file__).resolve().parent.parent / 'combatview.log'}")
        self._status.showMessage(f"解析失败: {msg}")

    def _on_encounter_selected(self, row: int) -> None:
        if not self._result or row < 0:
            return
        self._active_enc_index = row
        enc = self._result.encounters[row]
        self._enc_label.setText(
            f"⏱ {enc.name}  ({enc.duration:.1f}s)"
            if enc.duration else f"⏱ {enc.name}"
        )
        self._current_enc = enc
        self._build_npc_checkboxes(enc)
        self._build_event_type_checkboxes(enc)
        self._build_spell_checkboxes(enc)
        self._rebuild_table()

    def _build_npc_checkboxes(self, enc: Encounter) -> None:
        for cb in self._npc_checkboxes.values():
            cb.deleteLater()
        self._npc_checkboxes.clear()
        while self._npc_inner_layout.count():
            item = self._npc_inner_layout.takeAt(0)
            if item.widget():
                item.widget().deleteLater()

        known_only = self._chk_known_only.isChecked()
        role_order = {"boss": 0, "add": 1, "player": 2, "unknown": 3, "trash": 4}
        all_npcs = sorted(enc.npcs.values(), key=lambda n: role_order.get(n.role, 5))
        for npc in all_npcs:
            if known_only and npc.role not in ("boss", "add"):
                continue
            label = npc.name
            if npc.role == "player":
                label = f"👤 {npc.name}"
            cb = QCheckBox(label)
            cb.setChecked(npc.role in ("boss", "add"))
            if npc.role == "player":
                cb.stateChanged.connect(self._on_player_toggled)
            cb.stateChanged.connect(self._rebuild_table)
            self._npc_inner_layout.addWidget(cb)
            self._npc_checkboxes[npc.npc_id] = cb
        self._npc_inner_layout.addStretch()

    def _on_player_toggled(self) -> None:
        """When a player is checked, uncheck all event types if no NPC is checked."""
        any_player_checked = any(
            cb.isChecked() for nid, cb in self._npc_checkboxes.items()
            if nid >= 1_000_000_000
        )
        any_npc_checked = any(
            cb.isChecked() for nid, cb in self._npc_checkboxes.items()
            if nid < 1_000_000_000
        )
        if any_player_checked and not any_npc_checked:
            for cb in self._evt_checkboxes.values():
                cb.setChecked(False)

    def _rebuild_npc_checkboxes(self) -> None:
        if hasattr(self, "_current_enc") and self._current_enc:
            self._build_npc_checkboxes(self._current_enc)
            self._rebuild_table()

    def _build_event_type_checkboxes(self, enc: Encounter) -> None:
        for cb in self._evt_checkboxes.values():
            cb.deleteLater()
        self._evt_checkboxes.clear()
        while self._evt_inner_layout.count():
            item = self._evt_inner_layout.takeAt(0)
            if item.widget():
                item.widget().deleteLater()

        types = {}
        for ev in enc.events:
            if ev.src_npc_id:
                types[ev.event_type] = types.get(ev.event_type, 0) + 1
        hidden = set(self._config.get("hidden_event_types", []))
        for et, count in sorted(types.items()):
            cb = QCheckBox(f"{et} ({count})")
            cb.blockSignals(True)
            cb.setChecked(et not in hidden)
            cb.blockSignals(False)
            cb.stateChanged.connect(self._rebuild_table)
            self._evt_inner_layout.addWidget(cb)
            self._evt_checkboxes[et] = cb
        self._evt_inner_layout.addStretch()

    def _on_select_all_events(self) -> None:
        for cb in self._evt_checkboxes.values():
            cb.setChecked(True)

    def _on_select_none_events(self) -> None:
        for cb in self._evt_checkboxes.values():
            cb.setChecked(False)

    def _build_spell_checkboxes(self, enc: Encounter) -> None:
        for cb in self._spell_checkboxes.values():
            cb.deleteLater()
        self._spell_checkboxes.clear()
        while self._spell_inner_layout.count():
            item = self._spell_inner_layout.takeAt(0)
            if item.widget():
                item.widget().deleteLater()

        spells: dict[str, int] = {}
        for ev in enc.events:
            if ev.src_npc_id and ev.spell_name:
                spells[ev.spell_name] = spells.get(ev.spell_name, 0) + 1
        for name, count in sorted(spells.items(), key=lambda x: -x[1]):
            cb = QCheckBox(f"{name} ({count})")
            cb.setChecked(True)
            cb.stateChanged.connect(self._rebuild_table)
            self._spell_inner_layout.addWidget(cb)
            self._spell_checkboxes[name] = cb
        self._spell_inner_layout.addStretch()

    def _on_select_all_spells(self) -> None:
        for cb in self._spell_checkboxes.values():
            cb.setChecked(True)

    def _on_select_none_spells(self) -> None:
        for cb in self._spell_checkboxes.values():
            cb.setChecked(False)

    def _rebuild_table(self) -> None:
        if not self._result or self._active_enc_index < 0:
            return
        enc = self._result.encounters[self._active_enc_index]
        selected_ids = {nid for nid, cb in self._npc_checkboxes.items() if cb.isChecked()}
        selected_types = {et for et, cb in self._evt_checkboxes.items() if cb.isChecked()}
        selected_spells = {s for s, cb in self._spell_checkboxes.items() if cb.isChecked()}
        events = [ev for ev in enc.events
                  if ev.src_npc_id in selected_ids
                  and ev.event_type in selected_types
                  and (ev.spell_name or ev.event_type) in selected_spells]
        events.sort(key=lambda e: e.rel_time)

        self._table.setRowCount(len(events))
        for row, ev in enumerate(events):
            # time
            t = self._table_item(self._fmt_time(ev.rel_time))
            t.setData(Qt.ItemDataRole.UserRole, ev)
            self._table.setItem(row, 0, t)
            # event type
            et = self._table_item(ev.event_type)
            self._table.setItem(row, 1, et)
            # NPC name + role
            npc = enc.npcs.get(ev.src_npc_id)
            npc_name = npc.name if npc else ev.src_name
            npc_role = npc.role if npc else "?"
            n = self._table_item(npc_name)
            self._table.setItem(row, 2, n)
            # spell
            spell_text = ev.spell_name or ev.event_type
            if ev.spell_id:
                spell_text += f" ({ev.spell_id})"
            s = self._table_item(spell_text)
            self._table.setItem(row, 3, s)
            # target
            d = self._table_item(ev.dst_name or "—")
            self._table.setItem(row, 4, d)

    def _on_table_clicked(self, item: QTableWidgetItem) -> None:
        # find the time column item for this row
        row = item.row()
        time_item = self._table.item(row, 0)
        if time_item is None:
            return
        ev = time_item.data(Qt.ItemDataRole.UserRole)
        if ev is None:
            return
        enc = self._result.encounters[self._active_enc_index]
        npc = enc.npcs.get(ev.src_npc_id)
        self._show_event_detail(npc, ev)

    def _on_table_context_menu(self, pos) -> None:
        item = self._table.itemAt(pos)
        if item is None:
            return
        row = item.row()
        col = item.column()
        menu = QMenu(self)
        action = None

        if col == 1:
            evt_item = self._table.item(row, 1)
            if evt_item:
                et = evt_item.text()
                act_only = menu.addAction(f"只看「{et}」")
                act_hide = menu.addAction(f"不看「{et}」")
                action = menu.exec(self._table.viewport().mapToGlobal(pos))
                if action == act_only:
                    for cb in self._evt_checkboxes.values():
                        cb.setChecked(False)
                    if et in self._evt_checkboxes:
                        self._evt_checkboxes[et].setChecked(True)
                elif action == act_hide:
                    if et in self._evt_checkboxes:
                        self._evt_checkboxes[et].setChecked(False)
            return

        elif col == 3:
            spell_item = self._table.item(row, 3)
            if spell_item:
                text = spell_item.text()
                # strip "(ID)" suffix for matching
                spell_name = text.rsplit(" (", 1)[0] if " (" in text else text
                act_only = menu.addAction(f"只看「{spell_name}」")
                act_hide = menu.addAction(f"不看「{spell_name}」")
                action = menu.exec(self._table.viewport().mapToGlobal(pos))
                if action == act_only:
                    for cb in self._spell_checkboxes.values():
                        cb.setChecked(False)
                    if spell_name in self._spell_checkboxes:
                        self._spell_checkboxes[spell_name].setChecked(True)
                elif action == act_hide:
                    if spell_name in self._spell_checkboxes:
                        self._spell_checkboxes[spell_name].setChecked(False)
            return

    def _show_event_detail(self, npc: NPCUnit | None, ev: SpellEvent) -> None:
        lines = []
        t = ev.rel_time
        lines.append(f"时间: {self._fmt_time(t)} ({t:.1f}s)")
        lines.append(f"施法者: {npc.name if npc else ev.src_name}")
        lines.append(f"事件: {ev.event_type}")
        lines.append(f"法术: {ev.spell_name or '—'} (ID: {ev.spell_id})")
        lines.append(f"法术系: {ev.spell_school}")
        lines.append(f"目标: {ev.dst_name or '—'}")
        if ev.amount:
            lines.append(f"数值: {ev.amount}")

        # nearby events from same NPC
        if self._result and self._active_enc_index >= 0:
            enc = self._result.encounters[self._active_enc_index]
            nearby = [
                e for e in enc.events
                if e is not ev
                and e.src_npc_id == ev.src_npc_id
                and abs(e.rel_time - t) < 5
            ]
            if nearby:
                lines.append("")
                lines.append(f"±5s 关联事件 ({len(nearby)}):")
                for ne in sorted(nearby, key=lambda e: e.rel_time):
                    lines.append(
                        f"  {self._fmt_time(ne.rel_time)}  "
                        f"{ne.event_type:22s}  {ne.spell_name or '—'}"
                    )
        self._detail.setPlainText("\n".join(lines))

    def _on_show_timeline(self) -> None:
        if not self._result or self._active_enc_index < 0:
            return
        enc = self._result.encounters[self._active_enc_index]

        if self._timeline_window is None:
            self._timeline_window = QMainWindow(self)
            self._timeline_window.setWindowTitle("时间轴")
            self._timeline_window.resize(900, 600)
            self._timeline_view = TimelineView()
            self._timeline_view.event_clicked.connect(self._on_event_clicked_timeline)
            self._timeline_view.npc_reclassify.connect(self._on_npc_reclassify)
            self._timeline_window.setCentralWidget(self._timeline_view)

        self._timeline_view.set_encounter(enc)
        roles = {"boss", "add", "unknown", "trash"}
        self._timeline_view.set_visible_roles(roles)
        self._timeline_window.show()
        self._timeline_window.raise_()

    def _on_event_clicked_timeline(self, npc, ev) -> None:
        self._show_event_detail(npc, ev)

    def _on_npc_reclassify(self, npc_id: int, role: str) -> None:
        self._user_npc[str(npc_id)] = {"r": role}
        self._save_user_npc()
        self._apply_npc_classification()
        if self._active_enc_index >= 0 and self._result:
            enc = self._result.encounters[self._active_enc_index]
            self._rebuild_npc_checkboxes()
            self._rebuild_table()
        self._status.showMessage(f"NPC #{npc_id} → {role}", 3000)

    def _on_export_lua(self) -> None:
        if not self._result or self._active_enc_index < 0:
            return
        enc = self._result.encounters[self._active_enc_index]
        content = export_lua(enc)
        path, _ = QFileDialog.getSaveFileName(
            self, "导出 Lua 时间轴",
            f"{enc.name}_timeline.lua",
            "Lua Files (*.lua)"
        )
        if path:
            with open(path, "w", encoding="utf-8") as f:
                f.write(content)
            self._status.showMessage(f"已导出: {path}")

    def _on_export_json(self) -> None:
        if not self._result or self._active_enc_index < 0:
            return
        enc = self._result.encounters[self._active_enc_index]
        content = export_json(enc)
        path, _ = QFileDialog.getSaveFileName(
            self, "导出 JSON 数据",
            f"{enc.name}.json",
            "JSON Files (*.json)"
        )
        if path:
            with open(path, "w", encoding="utf-8") as f:
                f.write(content)
            self._status.showMessage(f"已导出: {path}")

    def _load_file(self, filepath: str) -> None:
        log.info("Loading: %s", filepath)
        self._status.showMessage(f"解析中: {os.path.basename(filepath)} ...")
        QApplication.processEvents()
        text = None
        for enc_name in ("utf-8", "gbk", "gb2312", "gb18030"):
            try:
                with open(filepath, "r", encoding=enc_name, errors="replace") as f:
                    text = f.read()
                    break
            except Exception:
                continue
        if text is None:
            QMessageBox.warning(self, "错误", "无法读取文件（编码不支持）")
            self._status.showMessage("读取失败")
            return
        if text.startswith("\ufeff"):
            text = text[1:]
        self._worker = ParseWorker(text, self._npc_db)
        self._worker.finished.connect(self._on_parse_done)
        self._worker.error.connect(self._on_parse_error)
        self._worker.start()

    # ---- Drag & Drop ----

    def dragEnterEvent(self, event) -> None:
        if event.mimeData().hasUrls():
            urls = event.mimeData().urls()
            if any(url.toLocalFile().lower().endswith((".txt", ".log")) for url in urls):
                event.acceptProposedAction()
                self._central.setStyleSheet("border: 2px dashed #89b4fa;")
                return
        event.ignore()

    def dragLeaveEvent(self, event) -> None:
        self._central.setStyleSheet("")
        event.ignore()

    def dropEvent(self, event) -> None:
        self._central.setStyleSheet("")
        for url in event.mimeData().urls():
            path = url.toLocalFile()
            if path.lower().endswith((".txt", ".log")):
                self._load_file(path)
                return

    # ---- helpers ----

    @staticmethod
    def _fmt_time(t: float) -> str:
        m = int(t // 60)
        s = t % 60
        return f"{m}:{s:04.1f}"

    @staticmethod
    def _table_item(text: str) -> QTableWidgetItem:
        item = QTableWidgetItem(text)
        item.setFont(QFont("Consolas", 10))
        return item
