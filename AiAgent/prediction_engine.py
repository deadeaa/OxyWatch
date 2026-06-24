"""
prediction_engine.py
Rule-based engine untuk klasifikasi risiko hipoksemia anak usia 2-5 tahun.
"""

from typing import TypedDict, Literal, List
from explanation_generator import generate_explanation

Level = Literal["normal", "waspada", "bahaya"]


class PredictionResult(TypedDict):
    level: str
    score: int
    color: str
    spo2_status: str
    hr_status: str
    recommendation: str
    explanation: str
    tips: List[str]


# PLACEHOLDER — ganti dengan tabel resmi dari Medical Student
HR_REFERENCE = {
    2: (80, 130),
    3: (80, 125),
    4: (80, 120),
    5: (75, 115),
}
HR_DEFAULT_RANGE = (80, 120)

SPO2_NORMAL_MIN = 95
SPO2_WASPADA_MIN = 91


def _classify_spo2(spo2: float) -> str:
    if spo2 >= SPO2_NORMAL_MIN:
        return "normal"
    elif spo2 >= SPO2_WASPADA_MIN:
        return "waspada"
    else:
        return "bahaya"


def _classify_hr(age: int, hr: float) -> str:
    hr_min, hr_max = HR_REFERENCE.get(age, HR_DEFAULT_RANGE)
    if hr_min <= hr <= hr_max:
        return "normal"
    elif hr < hr_min - 10 or hr > hr_max + 20:
        return "bahaya"
    else:
        return "waspada"


def _recommendation(level: str) -> str:
    if level == "bahaya":
        return (
            "Segera periksa anak secara langsung. Jika SpO2 tetap rendah atau "
            "anak terlihat sesak/lemas, hubungi dokter atau fasilitas kesehatan "
            "terdekat sekarang."
        )
    elif level == "waspada":
        return (
            "Pantau anak lebih sering dalam 15-30 menit ke depan. Pastikan anak "
            "dalam posisi nyaman dan cukup istirahat. Jika kondisi tidak membaik, "
            "hubungi dokter."
        )
    else:
        return "Kondisi anak normal. Lanjutkan pemantauan rutin seperti biasa."


def predict(age: int, weight: float, height: float, spo2: float, hr: float) -> PredictionResult:
    spo2_status = _classify_spo2(spo2)
    hr_status = _classify_hr(age, hr)

    if "bahaya" in (spo2_status, hr_status):
        level, score, color = "bahaya", 90, "red"
    elif "waspada" in (spo2_status, hr_status):
        level, score, color = "waspada", 55, "amber"
    else:
        level, score, color = "normal", 15, "green"

    extra = generate_explanation(spo2, hr, level.upper(), spo2_status, hr_status)

    return {
        "level": level.upper(),
        "score": score,
        "color": color,
        "spo2_status": spo2_status,
        "hr_status": hr_status,
        "recommendation": _recommendation(level),
        "explanation": extra["explanation"],
        "tips": extra["tips"],
    }


if __name__ == "__main__":
    samples = [
        (3, 14, 95, 97, 110),
        (4, 16, 100, 93, 122),
        (5, 17, 105, 88, 100),
    ]
    for age, weight, height, spo2, hr in samples:
        print((age, weight, height, spo2, hr), "->", predict(age, weight, height, spo2, hr))