#!/usr/bin/env python3
"""Construit la présentation synthétique JWAIO v0.2.1 au format PDF."""

from __future__ import annotations

from io import BytesIO
from pathlib import Path

from PIL import Image
from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER, TA_LEFT
from reportlab.lib.pagesizes import A4, landscape
from reportlab.lib.styles import ParagraphStyle
from reportlab.lib.utils import ImageReader
from reportlab.lib.units import mm
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.pdfgen.canvas import Canvas
from reportlab.platypus import Paragraph


ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "output" / "pdf" / "JWAIO-Presentation-v0.2.1.pdf"
LOGO = ROOT / "docs" / "assets" / "jeckyll-hyde-logo.png"
SCREEN = ROOT / "docs" / "assets" / "jwaio-tx15-interface-final.jpg"

PAGE_W, PAGE_H = landscape(A4)
MARGIN = 18 * mm

BG = colors.HexColor("#090D14")
PANEL = colors.HexColor("#121A26")
PANEL_2 = colors.HexColor("#192536")
CYAN = colors.HexColor("#55C9FF")
GREEN = colors.HexColor("#46F26C")
ORANGE = colors.HexColor("#FFB02E")
WHITE = colors.HexColor("#F6F8FB")
MUTED = colors.HexColor("#A9B6C7")
LINE = colors.HexColor("#2F4965")


def register_fonts() -> None:
    regular = Path(r"C:\Windows\Fonts\arial.ttf")
    bold = Path(r"C:\Windows\Fonts\arialbd.ttf")
    if regular.exists() and bold.exists():
        pdfmetrics.registerFont(TTFont("JWAIO", str(regular)))
        pdfmetrics.registerFont(TTFont("JWAIO-Bold", str(bold)))
    else:
        # Fallback utile lors d'une reconstruction hors Windows.
        pdfmetrics.registerFont(TTFont("JWAIO", str(regular)))
        pdfmetrics.registerFont(TTFont("JWAIO-Bold", str(bold)))


def paragraph(canvas: Canvas, text: str, x: float, y_top: float, width: float,
              size: float = 10, color=WHITE, leading: float | None = None,
              align: int = TA_LEFT, bold: bool = False) -> float:
    style = ParagraphStyle(
        "body",
        fontName="JWAIO-Bold" if bold else "JWAIO",
        fontSize=size,
        leading=leading or size * 1.28,
        textColor=color,
        alignment=align,
        spaceAfter=0,
    )
    item = Paragraph(text, style)
    _, height = item.wrap(width, PAGE_H)
    item.drawOn(canvas, x, y_top - height)
    return height


def page_base(canvas: Canvas, section: str, page: int) -> None:
    canvas.setFillColor(BG)
    canvas.rect(0, 0, PAGE_W, PAGE_H, fill=1, stroke=0)
    canvas.setFillColor(CYAN)
    canvas.rect(0, PAGE_H - 8 * mm, PAGE_W, 8 * mm, fill=1, stroke=0)
    canvas.setFillColor(BG)
    canvas.setFont("JWAIO-Bold", 8)
    canvas.drawString(MARGIN, PAGE_H - 5.4 * mm, section.upper())
    canvas.drawRightString(PAGE_W - MARGIN, PAGE_H - 5.4 * mm, "JWAIO 0.2.1")
    canvas.setStrokeColor(LINE)
    canvas.line(MARGIN, 12 * mm, PAGE_W - MARGIN, 12 * mm)
    canvas.setFillColor(MUTED)
    canvas.setFont("JWAIO", 7.5)
    canvas.drawString(MARGIN, 7.5 * mm, "RadioMaster TX15 Max - EdgeTX 2.12.x")
    canvas.drawRightString(PAGE_W - MARGIN, 7.5 * mm, f"{page:02d}")


def title(canvas: Canvas, heading: str, subtitle: str) -> None:
    canvas.setFillColor(WHITE)
    canvas.setFont("JWAIO-Bold", 23)
    canvas.drawString(MARGIN, PAGE_H - 24 * mm, heading)
    paragraph(canvas, subtitle, MARGIN, PAGE_H - 29 * mm, PAGE_W - 2 * MARGIN,
              size=9.5, color=MUTED)


def panel(canvas: Canvas, x: float, y: float, width: float, height: float,
          heading: str, accent=CYAN) -> None:
    canvas.setFillColor(PANEL)
    canvas.roundRect(x, y, width, height, 4 * mm, fill=1, stroke=0)
    canvas.setFillColor(accent)
    canvas.roundRect(x, y + height - 6 * mm, width, 6 * mm, 4 * mm, fill=1, stroke=0)
    canvas.rect(x, y + height - 6 * mm, width, 3 * mm, fill=1, stroke=0)
    canvas.setFillColor(BG)
    canvas.setFont("JWAIO-Bold", 8.5)
    canvas.drawString(x + 5 * mm, y + height - 4.1 * mm, heading.upper())


def image_contain(canvas: Canvas, path: Path, x: float, y: float,
                  width: float, height: float) -> None:
    # Les visuels fournis sont plus grands que leur taille d'impression. Une
    # copie en mémoire à environ 160 dpi garde un rendu net sans alourdir le PDF.
    source = Image.open(path)
    source_w, source_h = source.size
    target_w = max(1, int(width / 72 * 160))
    target_h = max(1, int(height / 72 * 160))
    reduction = min(1.0, target_w / source_w, target_h / source_h)
    if reduction < 1.0:
        source = source.resize(
            (max(1, int(source_w * reduction)), max(1, int(source_h * reduction))),
            Image.Resampling.LANCZOS,
        )
    buffer = BytesIO()
    if path.suffix.lower() in {".jpg", ".jpeg"}:
        source.convert("RGB").save(buffer, format="JPEG", quality=84, optimize=True)
    else:
        source.save(buffer, format="PNG", optimize=True)
    buffer.seek(0)
    image = ImageReader(buffer)
    source_w, source_h = image.getSize()
    ratio = min(width / source_w, height / source_h)
    draw_w, draw_h = source_w * ratio, source_h * ratio
    canvas.drawImage(
        image,
        x + (width - draw_w) / 2,
        y + (height - draw_h) / 2,
        width=draw_w,
        height=draw_h,
        preserveAspectRatio=True,
        mask="auto",
    )


def draw_cover(canvas: Canvas) -> None:
    canvas.setFillColor(BG)
    canvas.rect(0, 0, PAGE_W, PAGE_H, fill=1, stroke=0)
    canvas.setFillColor(CYAN)
    canvas.rect(0, 0, 10 * mm, PAGE_H, fill=1, stroke=0)

    image_contain(canvas, LOGO, 28 * mm, 56 * mm, 84 * mm, 84 * mm)
    canvas.setFillColor(WHITE)
    canvas.setFont("JWAIO-Bold", 40)
    canvas.drawString(124 * mm, 137 * mm, "JWAIO")
    canvas.setFillColor(GREEN)
    canvas.setFont("JWAIO-Bold", 15)
    canvas.drawString(125 * mm, 124 * mm, "Jeckyll Widget All in One")
    paragraph(
        canvas,
        "Widget FPV plein écran réunissant télémétrie, alertes, suivi GPS et recherche du quad.",
        125 * mm,
        114 * mm,
        132 * mm,
        size=12,
        color=WHITE,
        leading=16,
    )

    canvas.setFillColor(PANEL_2)
    canvas.roundRect(124 * mm, 59 * mm, 132 * mm, 34 * mm, 4 * mm, fill=1, stroke=0)
    paragraph(canvas, "RadioMaster TX15 Max", 131 * mm, 86 * mm, 118 * mm,
              size=12, bold=True)
    paragraph(canvas, "EdgeTX 2.12.x - interface 480 x 320", 131 * mm, 75 * mm,
              118 * mm, size=10, color=MUTED)
    paragraph(canvas, "Version d'essai 0.2.1", 131 * mm, 66 * mm,
              118 * mm, size=10, color=ORANGE, bold=True)

    canvas.setFillColor(MUTED)
    canvas.setFont("JWAIO", 8.5)
    canvas.drawString(28 * mm, 20 * mm, "Conception et essais : DrJeckyllMrHyde - 3 septembre 2026")
    canvas.showPage()


def draw_interface(canvas: Canvas) -> None:
    page_base(canvas, "Interface", 2)
    title(canvas, "Une lecture immédiate", "La disposition reste stable pour retrouver chaque information sans chercher.")
    x, y, w, h = MARGIN, 31 * mm, 183 * mm, 116 * mm
    canvas.setFillColor(colors.black)
    canvas.roundRect(x, y, w, h, 4 * mm, fill=1, stroke=0)
    image_contain(canvas, SCREEN, x + 3 * mm, y + 3 * mm, w - 6 * mm, h - 6 * mm)

    right_x = 210 * mm
    panel(canvas, right_x, 101 * mm, 68 * mm, 46 * mm, "À gauche", ORANGE)
    paragraph(canvas, "Mode de vol<br/>Fly Time et Fly Total<br/>GPS et dernière position",
              right_x + 5 * mm, 136 * mm, 58 * mm, size=9.5, leading=14)
    panel(canvas, right_x, 57 * mm, 68 * mm, 38 * mm, "Au centre", GREEN)
    paragraph(canvas, "Ready / Pre-Arm / Arm<br/>Speed, Alt, Dist et Total<br/>Throttle",
              right_x + 5 * mm, 84 * mm, 58 * mm, size=9.5, leading=13)
    panel(canvas, right_x, 20 * mm, 68 * mm, 31 * mm, "À droite", CYAN)
    paragraph(canvas, "Batterie, liaison<br/>Beeper / Flip et Qwad Finder",
              right_x + 5 * mm, 41 * mm, 58 * mm, size=9.3, leading=13)
    canvas.showPage()


def draw_features(canvas: Canvas) -> None:
    page_base(canvas, "Fonctions", 3)
    title(canvas, "Les fonctions essentielles", "Des informations visuelles avant le vol et des annonces prioritaires pendant le vol.")
    cards = [
        ("VOL", "ANGLE, ACRO et RTH<br/>Ready, Pre-Arm et Arm<br/>TIMER 1 et TIMER 2", ORANGE),
        ("BATTERIE", "LiPo, LiIon ou LiHv<br/>Tension par cellule<br/>NO_DATA distinct d'une alerte", GREEN),
        ("LIAISON", "ELRS ou TBS Crossfire<br/>LQ, RSSI et jauge<br/>Alerte si LQ devient faible", CYAN),
        ("GPS", "Satellites, position, vitesse et altitude<br/>Distance au Home et trajet total<br/>Mise à jour chaque seconde", CYAN),
        ("AUDIO", "17 annonces WAV<br/>Batterie, GPS, altitude et commandes<br/>Priorités sans chevauchement", ORANGE),
        ("QWAD FINDER", "Actif avec Beeper, Flip ou RTH<br/>Bips plus rapides à l'approche<br/>Module libéré lorsqu'il est inutile", GREEN),
    ]
    card_w, card_h = 82 * mm, 49 * mm
    xs = [MARGIN, MARGIN + 89 * mm, MARGIN + 178 * mm]
    ys = [88 * mm, 32 * mm]
    for index, (heading, body, accent) in enumerate(cards):
        x = xs[index % 3]
        y = ys[index // 3]
        panel(canvas, x, y, card_w, card_h, heading, accent)
        paragraph(canvas, body, x + 6 * mm, y + card_h - 12 * mm,
                  card_w - 12 * mm, size=9.5, leading=14)
    canvas.showPage()


def draw_install(canvas: Canvas) -> None:
    page_base(canvas, "Installation", 4)
    title(canvas, "Installation et réglages", "Le ZIP est conçu pour être extrait directement à la racine de la carte SD.")

    panel(canvas, MARGIN, 30 * mm, 112 * mm, 112 * mm, "Installation en 5 étapes", GREEN)
    steps = [
        "1. Sauvegarder la carte SD et retirer les hélices.",
        "2. Extraire JWAIO-v0.2.1.zip à la racine.",
        "3. Découvrir les capteurs avec le drone alimenté.",
        "4. Redémarrer EdgeTX et créer une page plein écran.",
        "5. Ajouter JWAIO puis régler le menu du widget.",
    ]
    y = 128 * mm
    for step in steps:
        paragraph(canvas, step, MARGIN + 7 * mm, y, 98 * mm, size=10.5, leading=15)
        y -= 18 * mm

    panel(canvas, 138 * mm, 76 * mm, 140 * mm, 66 * mm, "Les 10 réglages", ORANGE)
    paragraph(
        canvas,
        "<b>BatType</b> LiPo / LiIon / LiHv &nbsp;&nbsp; <b>Cells</b> 1S à 8S<br/>"
        "<b>LinkType</b> ELRS / TBS_CF &nbsp;&nbsp; <b>LQ</b> RQly ou autre source<br/>"
        "<b>ARM</b> - <b>PreArm</b> - <b>Beeper</b> - <b>Flip</b> - <b>RTH</b><br/>"
        "<b>Thr</b> CH3 par défaut ou autre voie",
        145 * mm,
        129 * mm,
        126 * mm,
        size=9.8,
        leading=15,
    )

    panel(canvas, 138 * mm, 30 * mm, 140 * mm, 39 * mm, "Capteurs attendus", CYAN)
    paragraph(canvas, "RxBt - GPS - Alt - GSpd - Sats - 1RSS",
              145 * mm, 57 * mm, 126 * mm, size=11, bold=True, color=WHITE)
    paragraph(canvas, "Effectuer la découverte avant d'installer le widget.",
              145 * mm, 45 * mm, 126 * mm, size=9, color=MUTED)
    canvas.showPage()


def draw_data_logo(canvas: Canvas) -> None:
    page_base(canvas, "Données et personnalisation", 5)
    title(canvas, "Après le vol et à votre image", "Les journaux restent simples à exploiter et le logo central appartient à chaque utilisateur.")

    panel(canvas, MARGIN, 76 * mm, 82 * mm, 66 * mm, "Journal CSV", CYAN)
    paragraph(canvas, "Un fichier par armement, une ligne par seconde : position, altitude, vitesse, tension, distances, LQ et satellites.",
              MARGIN + 6 * mm, 128 * mm, 70 * mm, size=9.5, leading=14)
    paragraph(canvas, "Lisible directement dans Excel ou LibreOffice Calc.",
              MARGIN + 6 * mm, 94 * mm, 70 * mm, size=9.5, color=GREEN, bold=True)

    panel(canvas, MARGIN + 89 * mm, 76 * mm, 82 * mm, 66 * mm, "Open Drone Log", GREEN)
    paragraph(canvas, "Le convertisseur fourni crée une copie compatible sans modifier le journal original.",
              MARGIN + 95 * mm, 128 * mm, 70 * mm, size=9.5, leading=14)
    paragraph(canvas, "opendronelog.com<br/>Gratuit et open source",
              MARGIN + 95 * mm, 99 * mm, 70 * mm, size=10, color=GREEN, bold=True)

    panel(canvas, MARGIN + 178 * mm, 76 * mm, 82 * mm, 66 * mm, "Logo du widget", ORANGE)
    paragraph(canvas, "Remplacer :<br/><b>/WIDGETS/JWAIO/img/logo.png</b>",
              MARGIN + 184 * mm, 128 * mm, 70 * mm, size=9.3, leading=14)
    paragraph(canvas, "216 x 132 pixels<br/>PNG RGBA transparent<br/>Remplacement radio éteinte",
              MARGIN + 184 * mm, 100 * mm, 70 * mm, size=9.5, color=ORANGE, bold=True, leading=14)

    panel(canvas, MARGIN, 29 * mm, 260 * mm, 38 * mm, "Fichiers conservés sur la radio", CYAN)
    paragraph(canvas, "Fichier de vol CSV - dernière position lastpos.txt - distance maximale et totale lastdistance.txt",
              MARGIN + 7 * mm, 54 * mm, 246 * mm, size=10.5, align=TA_CENTER)
    canvas.showPage()


def draw_final(canvas: Canvas) -> None:
    page_base(canvas, "Projet", 6)
    title(canvas, "Un projet libre, documenté et attribué", "JWAIO reste gratuit tout en conservant clairement ses auteurs, ses licences et ses sources.")

    panel(canvas, MARGIN, 74 * mm, 80 * mm, 66 * mm, "Code source", CYAN)
    paragraph(canvas, "Apache License 2.0<br/><br/>Utilisation, modification et redistribution autorisées avec conservation de la licence et du fichier NOTICE.",
              MARGIN + 6 * mm, 126 * mm, 68 * mm, size=9.2, leading=13)
    panel(canvas, MARGIN + 90 * mm, 74 * mm, 80 * mm, 66 * mm, "Docs et médias", GREEN)
    paragraph(canvas, "Creative Commons BY 4.0<br/><br/>Documentation, logo de présentation et sons originaux réutilisables avec attribution.",
              MARGIN + 96 * mm, 126 * mm, 68 * mm, size=9.2, leading=13)
    panel(canvas, MARGIN + 180 * mm, 74 * mm, 80 * mm, 66 * mm, "Composants tiers", ORANGE)
    paragraph(canvas, "Attributions conservées<br/><br/>L'idée Qwad Finder issue du projet ELRS Finder reste créditée dans les avis tiers.",
              MARGIN + 186 * mm, 126 * mm, 68 * mm, size=9.2, leading=13)

    canvas.setFillColor(PANEL_2)
    canvas.roundRect(MARGIN, 29 * mm, 260 * mm, 34 * mm, 4 * mm, fill=1, stroke=0)
    paragraph(canvas, "JWAIO 0.2.1 - version d'essai pour RadioMaster TX15 Max<br/>"
              "Conception et essais : <b>DrJeckyllMrHyde</b>",
              MARGIN + 7 * mm, 54 * mm, 246 * mm, size=11, align=TA_CENTER, leading=16)
    canvas.showPage()


def main() -> None:
    register_fonts()
    for required in (LOGO, SCREEN):
        if not required.exists():
            raise FileNotFoundError(required)
    OUT.parent.mkdir(parents=True, exist_ok=True)
    canvas = Canvas(str(OUT), pagesize=landscape(A4), pageCompression=1)
    canvas.setTitle("JWAIO 0.2.1 - Présentation")
    canvas.setAuthor("DrJeckyllMrHyde")
    canvas.setSubject("Widget Lua FPV pour RadioMaster TX15 Max et EdgeTX 2.12.x")
    draw_cover(canvas)
    draw_interface(canvas)
    draw_features(canvas)
    draw_install(canvas)
    draw_data_logo(canvas)
    draw_final(canvas)
    canvas.save()
    print(OUT)


if __name__ == "__main__":
    main()
