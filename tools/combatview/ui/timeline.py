"""Timeline widget using QGraphicsView."""

from __future__ import annotations
from PySide6.QtWidgets import (
    QGraphicsView, QGraphicsScene, QGraphicsRectItem, QGraphicsTextItem,
    QGraphicsLineItem, QMenu,
)
from PySide6.QtCore import Qt, QRectF, Signal
from PySide6.QtGui import (
    QColor, QPen, QBrush, QFont, QAction, QPainter, QMouseEvent, QWheelEvent,
)

from models import Encounter, NPCUnit, SpellEvent

SCHOOL_COLORS = {
    1: QColor("#a6adc8"), 2: QColor("#f9e2af"), 4: QColor("#f38ba8"),
    8: QColor("#a6e3a1"), 16: QColor("#89b4fa"), 32: QColor("#cba6f7"),
    64: QColor("#f5c2e7"), 0: QColor("#cdd6f4"),
}
ROLE_COLORS = {
    "boss": QColor("#f38ba8"), "add": QColor("#f9e2af"),
    "unknown": QColor("#a6adc8"), "trash": QColor("#585b70"),
}

ROW_H = 24
MARGIN_LEFT = 180
MARGIN_RIGHT = 30
MARGIN_TOP = 40
MARGIN_BOTTOM = 20


class TimelineView(QGraphicsView):
    event_clicked = Signal(object, object)  # (NPCUnit, SpellEvent)
    npc_reclassify = Signal(int, str)       # (npc_id, new_role)

    def __init__(self, parent=None):
        super().__init__(parent)
        self._scene = QGraphicsScene(self)
        self.setScene(self._scene)
        self.setRenderHint(QPainter.RenderHint.Antialiasing)
        self.setHorizontalScrollBarPolicy(Qt.ScrollBarPolicy.ScrollBarAlwaysOff)
        self.setVerticalScrollBarPolicy(Qt.ScrollBarPolicy.ScrollBarAsNeeded)
        self.setDragMode(QGraphicsView.DragMode.NoDrag)
        self.setTransformationAnchor(QGraphicsView.ViewportAnchor.AnchorUnderMouse)
        self._encounter: Encounter | None = None
        self._scale = 1.0
        self._visible_roles: set[str] = {"boss", "add", "unknown"}
        self._npc_items: dict[int, list] = {}

    def set_encounter(self, enc: Encounter | None) -> None:
        self._encounter = enc
        self._npc_items.clear()
        self.rebuild()

    def set_visible_roles(self, roles: set[str]) -> None:
        self._visible_roles = roles
        self.rebuild()

    def rebuild(self) -> None:
        self._scene.clear()
        self._npc_items.clear()
        if not self._encounter or self._encounter.duration <= 0:
            return

        enc = self._encounter
        duration = enc.duration
        visible = [
            n for n in enc.npcs.values()
            if n.role in self._visible_roles and n.events
        ]
        visible.sort(key=lambda n: {"boss": 0, "add": 1, "unknown": 2, "trash": 3}.get(n.role, 2))

        if not visible:
            return

        scene_w = 800 * self._scale
        scene_h = MARGIN_TOP + len(visible) * ROW_H + MARGIN_BOTTOM
        plot_w = scene_w - MARGIN_LEFT - MARGIN_RIGHT

        # background
        self._scene.setSceneRect(QRectF(0, 0, scene_w, scene_h))
        bg = QGraphicsRectItem(0, 0, scene_w, scene_h)
        bg.setBrush(QColor("#1a1a2e"))
        bg.setPen(Qt.PenStyle.NoPen)
        self._scene.addItem(bg)

        # grid
        tick_interval = self._calc_tick(duration)
        grid_pen = QPen(QColor("#313244"), 0.5)
        font = QFont("Consolas", 9)
        for t in range(0, int(duration) + 1, tick_interval):
            x = MARGIN_LEFT + (t / duration) * plot_w
            line = QGraphicsLineItem(x, MARGIN_TOP, x, MARGIN_TOP + len(visible) * ROW_H)
            line.setPen(grid_pen)
            self._scene.addItem(line)
            txt = self._scene.addText(f"{t}s", font)
            txt.setDefaultTextColor(QColor("#585b70"))
            txt.setPos(x - 10, MARGIN_TOP - 20)

        # row background + NPC name
        for i, npc in enumerate(visible):
            y = MARGIN_TOP + i * ROW_H
            if i % 2 == 0:
                row_bg = QGraphicsRectItem(MARGIN_LEFT, y, plot_w, ROW_H)
                row_bg.setBrush(QColor(49, 50, 68, 80))
                row_bg.setPen(Qt.PenStyle.NoPen)
                self._scene.addItem(row_bg)
            label = npc.name[:20] + "…" if len(npc.name) > 20 else npc.name
            txt = self._scene.addText(label, QFont("Consolas", 11))
            txt.setDefaultTextColor(ROLE_COLORS.get(npc.role, QColor("#cdd6f4")))
            txt.setPos(4, y + 2)
            # separator
            sep = QGraphicsLineItem(MARGIN_LEFT, y + ROW_H, MARGIN_LEFT + plot_w, y + ROW_H)
            sep.setPen(grid_pen)
            self._scene.addItem(sep)

            # events as rectangles
            by_spell: dict[str, list[SpellEvent]] = {}
            for ev in npc.events:
                key = ev.spell_name or ev.event_type
                by_spell.setdefault(key, []).append(ev)

            sub_h = max(3, (ROW_H - 6) / max(len(by_spell), 1))
            for j, (spell_name, evts) in enumerate(by_spell.items()):
                for ev in evts:
                    x = MARGIN_LEFT + (ev.rel_time / duration) * plot_w
                    w = 4
                    if ev.event_type == "SPELL_CAST_START":
                        w = 8
                    elif ev.event_type == "SPELL_AURA_APPLIED":
                        w = 14
                    rect = QGraphicsRectItem(x, y + 4 + j * sub_h, max(w, 2), sub_h - 1)
                    color = SCHOOL_COLORS.get(ev.spell_school, QColor("#cdd6f4"))
                    rect.setBrush(QBrush(color))
                    rect.setPen(Qt.PenStyle.NoPen)
                    rect.setOpacity(0.85)
                    rect.setData(0, npc)
                    rect.setData(1, ev)
                    rect.setData(2, spell_name)
                    rect.setAcceptHoverEvents(True)
                    rect.setToolTip(
                        f"{npc.name}\n{ev.spell_name or ev.event_type}\n"
                        f"{self._fmt_time(ev.rel_time)}"
                    )
                    self._scene.addItem(rect)
                    self._npc_items.setdefault(npc.npc_id, []).append(rect)

        self.fitInView(self._scene.sceneRect().adjusted(0, 0, 0, 10),
                       Qt.AspectRatioMode.KeepAspectRatio)

    def mousePressEvent(self, event: QMouseEvent) -> None:
        if event.button() == Qt.MouseButton.LeftButton:
            item = self.itemAt(event.pos())
            if item and item.data(1):
                npc = item.data(0)
                ev = item.data(1)
                self.event_clicked.emit(npc, ev)
                return
        elif event.button() == Qt.MouseButton.RightButton:
            item = self.itemAt(event.pos())
            if item and item.data(1):
                npc = item.data(0)
                self._show_context_menu(npc, event.globalPos())
                return
        super().mousePressEvent(event)

    def wheelEvent(self, event: QWheelEvent) -> None:
        factor = 1.15 if event.angleDelta().y() > 0 else 1 / 1.15
        self._scale *= factor
        self._scale = max(0.5, min(self._scale, 5.0))
        self.rebuild()

    def _show_context_menu(self, npc: NPCUnit, pos) -> None:
        menu = QMenu(self)
        for role, label in [("boss", "Boss"), ("add", "Encounter 小怪"),
                             ("trash", "普通小怪 (Trash)"), ("unknown", "未分类")]:
            action = QAction(label, self)
            action.setCheckable(True)
            action.setChecked(npc.role == role)
            action.triggered.connect(lambda checked, r=role, nid=npc.npc_id: self.npc_reclassify.emit(nid, r))
            menu.addAction(action)
        menu.exec(pos)

    @staticmethod
    def _calc_tick(duration: float) -> int:
        for iv in (1, 2, 5, 10, 15, 30, 60, 120, 300, 600):
            if duration / iv <= 20:
                return iv
        return 600

    @staticmethod
    def _fmt_time(t: float) -> str:
        m = int(t // 60)
        s = t % 60
        return f"{m}:{s:04.1f}"
