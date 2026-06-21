"""CombatView — WOW Combat Log Analyzer

Usage:
    python combatview.py
    py -3 combatview.py

Drag a WoWCombatLog.txt to parse BOSS encounter spell timelines.
"""

import sys
import traceback
import logging
from datetime import datetime
from pathlib import Path

ROOT = Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT))

LOG_FILE = ROOT / "combatview.log"

logging.basicConfig(
    level=logging.DEBUG,
    format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
    handlers=[
        logging.FileHandler(LOG_FILE, encoding="utf-8"),
        logging.StreamHandler(sys.stderr),
    ],
)
log = logging.getLogger("combatview")


def _setup_excepthook() -> None:
    _original_hook = sys.excepthook

    def _hook(exc_type, exc_value, exc_tb):
        if exc_type is KeyboardInterrupt:
            _original_hook(exc_type, exc_value, exc_tb)
            return
        tb_text = "".join(traceback.format_exception(exc_type, exc_value, exc_tb))
        log.critical("Unhandled exception:\n%s", tb_text)
        # write crash summary
        crash_file = ROOT / f"crash_{datetime.now().strftime('%Y%m%d_%H%M%S')}.txt"
        crash_file.write_text(tb_text, encoding="utf-8")
        # show GUI dialog if QApplication exists
        try:
            from PySide6.QtWidgets import QApplication, QMessageBox
            app = QApplication.instance()
            if app:
                QMessageBox.critical(
                    None, "CombatView 崩溃",
                    f"未捕获的异常:\n\n{exc_value}\n\n"
                    f"详细日志已写入:\n{crash_file}\n{LOG_FILE}"
                )
        except Exception:
            pass
        _original_hook(exc_type, exc_value, exc_tb)

    sys.excepthook = _hook


_setup_excepthook()

from PySide6.QtWidgets import QApplication, QMessageBox
from PySide6.QtGui import QFont

from ui.mainwindow import MainWindow


def main() -> None:
    log.info("CombatView starting")
    app = QApplication(sys.argv)
    app.setApplicationName("CombatView")
    app.setStyle("Fusion")

    # dark palette
    from PySide6.QtGui import QPalette, QColor
    palette = QPalette()
    palette.setColor(QPalette.ColorRole.Window, QColor(26, 26, 46))
    palette.setColor(QPalette.ColorRole.WindowText, QColor(205, 214, 244))
    palette.setColor(QPalette.ColorRole.Base, QColor(30, 30, 46))
    palette.setColor(QPalette.ColorRole.AlternateBase, QColor(24, 24, 37))
    palette.setColor(QPalette.ColorRole.Text, QColor(205, 214, 244))
    palette.setColor(QPalette.ColorRole.Button, QColor(49, 50, 68))
    palette.setColor(QPalette.ColorRole.ButtonText, QColor(205, 214, 244))
    palette.setColor(QPalette.ColorRole.Highlight, QColor(137, 180, 250))
    palette.setColor(QPalette.ColorRole.HighlightedText, QColor(26, 26, 46))
    app.setPalette(palette)

    app.setFont(QFont("Microsoft YaHei", 10))

    try:
        window = MainWindow()
        window.show()
        log.info("MainWindow shown")
    except Exception:
        log.critical("Failed to create MainWindow", exc_info=True)
        QMessageBox.critical(
            None, "启动失败",
            f"创建主窗口时出错:\n\n{traceback.format_exc()}\n\n日志: {LOG_FILE}"
        )
        sys.exit(1)

    sys.exit(app.exec())


if __name__ == "__main__":
    main()
