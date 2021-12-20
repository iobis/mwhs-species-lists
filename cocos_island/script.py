import pdf2image
import pytesseract
from PIL import Image
import os
from taxonerd import TaxoNERD


def process_images(page=None):
    if page is None:
        files = [file for file in os.listdir("images") if file.endswith(".png")]
        for file in files:
            print(file)
            text = pytesseract.image_to_string(f"images/{file}")
            with open(f"text/{file}.txt", "w") as text_file:
                text_file.write(text)


def save_images(pdf_file):
    images = pdf2image.convert_from_path(pdf_file)
    for page, img in enumerate(images):
        path = f"images/{page + 1}.png"
        print(path)
        img.save(path, "PNG")


def process_text():
    ner = TaxoNERD(model="en_ner_eco_biobert", with_abbrev=True)
    files = [file for file in os.listdir("text") if file.endswith(".txt")]
    ids = [int(file.split(".")[0]) for file in files if file.endswith(".txt")]
    ids.sort()
    with open("taxa.txt", "w") as output_file:
        for i in ids:
            file = f"text/{i}.png.txt"
            print(file)
            with open(file, "r") as text_file:
                result = ner.find_in_text(text_file.read())
                if len(result) > 0:
                    print(result)
                    output_file.write(f"page {i}\n")
                    output_file.write("-----" + "-" * len(str(i)))
                    output_file.write("\n\n")
                    taxa = result["text"].tolist()
                    output_file.write("\n".join(taxa) + "\n\n")


save_images("820bis.pdf")
process_images()
process_text()

