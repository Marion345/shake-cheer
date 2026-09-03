"""Small, dependency-free checks for the two static ShakeCheer pages."""
from html.parser import HTMLParser
from pathlib import Path
from urllib.parse import unquote, urlsplit

ROOT = Path(__file__).resolve().parent / "dist"
EMAIL = "yanick.marion@hotmail.com"


class Page(HTMLParser):
    def __init__(self, text):
        super().__init__(convert_charrefs=True)
        self.ids = set()
        self.refs = []
        self.lang = None
        self.headings = 0
        self.titles = 0
        self.description = False
        self.viewport = False
        self.main = False
        self.current = 0
        self.feed(text)

    def handle_starttag(self, tag, attributes):
        attrs = dict(attributes)
        assert tag not in {"script", "iframe", "form"}, f"Unexpected active element: {tag}"
        assert not any(key.lower().startswith("on") for key in attrs), "Inline event handler"
        if tag == "html":
            self.lang = attrs.get("lang")
        if "id" in attrs:
            assert attrs["id"] not in self.ids, "Duplicate ID"
            self.ids.add(attrs["id"])
        self.headings += tag == "h1"
        self.titles += tag == "title"
        self.current += attrs.get("aria-current") == "page"
        self.main |= tag == "main"
        if tag == "meta":
            self.description |= attrs.get("name") == "description" and bool(attrs.get("content"))
            self.viewport |= attrs.get("name") == "viewport"
        for name in ("href", "src"):
            if name in attrs:
                self.refs.append((tag, attrs[name]))
        if tag == "link":
            assert attrs.get("rel") == "stylesheet", "Unexpected linked dependency"


def luminance(hex_color):
    values = [int(hex_color[i:i + 2], 16) / 255 for i in (1, 3, 5)]
    linear = [v / 12.92 if v <= 0.04045 else ((v + 0.055) / 1.055) ** 2.4 for v in values]
    return sum(c * w for c, w in zip(linear, (0.2126, 0.7152, 0.0722)))


def contrast(a, b):
    x, y = sorted((luminance(a), luminance(b)))
    return (y + 0.05) / (x + 0.05)


pages = {p: Page(p.read_text(encoding="utf-8")) for p in ROOT.glob("*.html")}
assert {p.name for p in pages} == {"index.html", "confidentialite.html"}
for path, page in pages.items():
    assert page.lang == "fr-CA"
    assert page.headings == page.titles == page.current == 1
    assert page.main and page.description and page.viewport
    assert EMAIL in path.read_text(encoding="utf-8")
    for tag, ref in page.refs:
        url = urlsplit(ref)
        if url.scheme == "mailto":
            assert url.path == EMAIL
        elif url.scheme or url.netloc:
            assert url.scheme == "https" and tag == "a", "Remote embedded resource or unsafe URL"
        else:
            target = (path.parent / unquote(url.path)).resolve() if url.path else path
            assert target.is_relative_to(ROOT), "Reference outside public directory"
            assert target.is_file(), f"Missing link target: {ref}"
            if url.fragment:
                assert target in pages and unquote(url.fragment) in pages[target].ids, f"Missing anchor: {ref}"
    print(f"PASS {path.name}: metadata, navigation, links, anchors, email and no active tracking code")

css = (ROOT / "styles.css").read_text(encoding="utf-8")
assert "@import" not in css and "url(" not in css
assert "@media" in css and ":focus-visible" in css and "prefers-reduced-motion" in css
assert css.count("{") == css.count("}")
for fg, bg in (("#f6f3ed", "#0b0b0c"), ("#b6b4b0", "#151517"), ("#ffae43", "#0b0b0c"), ("#1d1200", "#ffae43"), ("#d0cec9", "#0b0b0c")):
    ratio = contrast(fg, bg)
    assert ratio >= 4.5, f"Insufficient contrast: {fg}/{bg}"
    print(f"PASS contrast {fg}/{bg}: {ratio:.2f}:1")
assert "Des publicités sont prévues" in (ROOT / "confidentialite.html").read_text(encoding="utf-8")
print("PASS static site checks")
