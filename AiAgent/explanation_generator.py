"""
explanation_generator.py
Generator penjelasan & tips casual berbasis template (tanpa Ollama/LLM).
Dipanggil dari prediction_engine.py setelah level/score didapat.
"""

from typing import Dict


def generate_explanation(spo2: float, hr: float, level: str, spo2_status: str, hr_status: str) -> Dict[str, str]:
    parts = []

    if spo2_status == "bahaya":
        parts.append(f"Kadar oksigen darahnya turun cukup rendah ({spo2}%)")
    elif spo2_status == "waspada":
        parts.append(f"Kadar oksigen darahnya agak turun ({spo2}%), belum normal tapi belum gawat")
    else:
        parts.append(f"Kadar oksigen darahnya bagus ({spo2}%)")

    if hr_status == "bahaya":
        parts.append(f"detak jantungnya juga di luar batas wajar ({hr} bpm)")
    elif hr_status == "waspada":
        parts.append(f"detak jantungnya sedikit di luar rentang normal ({hr} bpm)")
    else:
        parts.append(f"detak jantungnya normal ({hr} bpm)")

    explanation = " dan ".join(parts) + "."

    if level == "BAHAYA":
        tips = [
            "Segera periksa kondisi anak secara langsung, lihat apakah ada tanda sesak atau lemas.",
            "Tetap tenang, dudukkan atau bawa anak ke posisi yang nyaman.",
            "Hubungi dokter atau langsung ke fasilitas kesehatan terdekat sekarang.",
            "Jangan tunggu kondisi memburuk sebelum bertindak.",
        ]
    elif level == "WASPADA":
        tips = [
            "Pantau anak lebih sering dalam 15-30 menit ke depan.",
            "Pastikan anak istirahat cukup dan tidak banyak aktivitas berat.",
            "Cek ulang SpO2 dan detak jantung beberapa saat lagi.",
            "Kalau belum membaik atau malah memburuk, hubungi dokter.",
        ]
    else:
        tips = [
            "Kondisinya bagus, lanjutkan aktivitas seperti biasa.",
            "Tetap pantau secara rutin sesuai jadwal monitoring.",
        ]

    return {"explanation": explanation, "tips": tips}