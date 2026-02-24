import os
import uuid
import magic
import re
from pdfminer.high_level import extract_text as extract_pdf_text
from docx import Document
from fastapi import UploadFile, HTTPException

ALLOWED_EXTENSIONS = {".pdf", ".docx"}
MAX_FILE_SIZE = 5 * 1024 * 1024  # 5MB
UPLOAD_DIR = "uploads"

os.makedirs(UPLOAD_DIR, exist_ok=True)


def validate_file(file_bytes: bytes, filename: str):
    # taille du fichier
    if len(file_bytes) > MAX_FILE_SIZE:
        raise HTTPException(status_code=400, detail="Fichier trop volumineux")

    # extension pdf ou docx
    ext = os.path.splitext(filename)[1].lower()
    if ext not in ALLOWED_EXTENSIONS:
        raise HTTPException(status_code=400, detail="Format non autorisé")

    # MIME réel
    mime = magic.from_buffer(file_bytes, mime=True)

    allowed_mimes = [
        "application/pdf",
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
    ]

    if mime not in allowed_mimes:
        raise HTTPException(status_code=400, detail="Type MIME invalide")


def save_file(file_bytes: bytes, extension: str):
    filename = f"{uuid.uuid4()}{extension}"
    file_path = os.path.join(UPLOAD_DIR, filename)

    with open(file_path, "wb") as f:
        f.write(file_bytes)

    return file_path


def extract_text_from_pdf(file_path: str):
    return extract_pdf_text(file_path)


def extract_text_from_docx(file_path: str):
    doc = Document(file_path)
    return "\n".join([p.text for p in doc.paragraphs])


def clean_text(text: str):
    if not text:
        return ""

    text = re.sub(r"[\u2018\u2019\u201b\u2032\u2035]", "'", text)

    text = re.sub(r"[\u2022\u2023\u25cf\u2043\u25b6]", " - ", text)

    text = re.sub(r"[\x00-\x08\x0b\x0c\x0e-\x1f\x7f-\x9f]", "", text)

    text = re.sub(r"(\w+)-\s+(\w+)", r"\1-\2", text)
    
    text = re.sub(r"[^\w\s@.:/+\-,\(\)'€$|?!&éèàùâêîôûëïüçÉÈÀÙÂÊÎÔÛËÏÜÇ]", " ", text)

    text = re.sub(r"\s+", " ", text)

    return text.strip()


async def process_cv(file: UploadFile):
    file_bytes = await file.read()
    extension = os.path.splitext(file.filename)[1].lower()

    validate_file(file_bytes, file.filename)

    file_path = save_file(file_bytes, extension)

    if extension == ".pdf":
        text = extract_text_from_pdf(file_path)
    else:
        text = extract_text_from_docx(file_path)

    cleaned_text = clean_text(text)

    return cleaned_text , file_path