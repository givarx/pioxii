"""Converte in batch JPG/JPEG in PNG senza modificare gli originali.

Dipendenza: python -m pip install Pillow
Uso: python jpg_to_png.py "C:\\Foto"
     python jpg_to_png.py "C:\\Foto" -o "C:\\PNG" --recursive
"""

import argparse
from pathlib import Path

from PIL import Image, ImageOps


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("cartella", type=Path, help="Cartella con i JPG")
    parser.add_argument("-o", "--output", type=Path, help="Destinazione (default: cartella/png)")
    parser.add_argument("-r", "--recursive", action="store_true", help="Includi le sottocartelle")
    args = parser.parse_args()
    source = args.cartella.expanduser().resolve()
    if not source.is_dir():
        parser.error(f"Cartella inesistente: {source}")
    output = (args.output.expanduser() if args.output else source / "png").resolve()
    candidates = source.rglob("*") if args.recursive else source.iterdir()
    files = sorted(p for p in candidates if p.is_file() and p.suffix.lower() in {".jpg", ".jpeg"})
    if not files:
        print("Nessun file JPG/JPEG trovato.")
        return 0

    converted = errors = 0
    for path in files:
        destination = output / path.relative_to(source).with_suffix(".png")
        created = False
        try:
            destination.parent.mkdir(parents=True, exist_ok=True)
            with Image.open(path) as original:
                # Applica la rotazione EXIF, comune nelle foto da smartphone.
                image = ImageOps.exif_transpose(original)
                if image.mode not in {"RGB", "RGBA", "L", "LA", "P", "1", "I", "I;16"}:
                    image = image.convert("RGB")
                    image.info.pop("icc_profile", None)
                # Non sovrascrive file esistenti, anche in caso di nomi uguali.
                base = destination
                index = 1
                while True:
                    try:
                        handle = destination.open("xb")
                        created = True
                        break
                    except FileExistsError:
                        destination = base.with_name(f"{base.stem}_{index}.png")
                        index += 1
                with handle:
                    image.save(handle, format="PNG")
            converted += 1
            print(f"OK: {path.name} -> {destination}")
        except (OSError, ValueError, Image.DecompressionBombError) as exc:
            if created:
                destination.unlink(missing_ok=True)
            errors += 1
            print(f"ERRORE: {path}: {exc}")

    print(f"Completato: {converted} convertite, {errors} errori.")
    return 1 if errors else 0


if __name__ == "__main__":
    raise SystemExit(main())
