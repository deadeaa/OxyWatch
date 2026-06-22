import requests
from typing import List, Dict, Optional

OLLAMA_URL = "http://localhost:11434/api/generate"
MODEL_NAME = "llama3.1"

def classify_condition(spo2_value: float, heart_rate: int) -> str:
    """
    Klasifikasi kondisi pasien: Normal, Sedang, Bahaya
    """
    # Bahaya: SpO2 < 85 atau HR > 120 atau HR < 55
    if spo2_value < 85 or heart_rate > 120 or heart_rate < 55:
        return "Bahaya"
    # Sedang: SpO2 85-90 atau HR 100-120 atau HR 55-60
    elif spo2_value < 90 or (heart_rate > 100) or (heart_rate < 60):
        return "Sedang"
    # Normal: SpO2 >= 90 dan HR 60-100
    else:
        return "Normal"

def get_explanation_and_tips(spo2_value: float, heart_rate: int, 
                             condition: str, patient_age: int = None) -> Dict[str, str]:
    """
    Generate penjelasan dan saran berdasarkan kondisi dengan tone casual & friendly
    """
    
    if condition == "Normal":
        tone = "Kondisi kamu BAGUS! Santai aja, semuanya normal."
    elif condition == "Sedang":
        tone = "Ada yang perlu diperhatiin nih, tapi belum gawat. Cukup istirahat dan monitor ya."
    else:  # Bahaya
        tone = "Ini DARURAT! Perlu tindakan cepat dan pergi ke dokter/rumah sakit SEKARANG."
    
    prompt = f"""
Kamu adalah dokter yang super ramah dan kasih penjelasan santai (bukan formal kaku).

DATA PASIEN:
- SpO2: {spo2_value}%
- Detak Jantung: {heart_rate} bpm
- Usia: {patient_age if patient_age else 'Tidak diketahui'}
- Kondisi: {condition}

TONE: {tone}

TUGAS: Kasih 2 hal dalam bahasa Indonesia casual & friendly (kayak ngobrol sama teman):

1. PENJELASAN (2-3 kalimat): Jelaskan KENAPA kondisi pasien masuk kategori {condition}. Jelaskan dari sisi SpO2 dan detak jantung. Gunakan bahasa santai, bukan medis yang kaku.

2. SARAN (3-4 poin): Kasih saran praktis apa yang harus dilakukan pasien SEKARANG. Pake bullet points, santai dan mudah dipahami. Jangan pakai istilah medis yang rumit.

Contoh tone santai:
- Bukan: "Pasien mengalami penurunan saturasi oksigen" 
- Tapi: "Kadar oksigen darah kamu turun nih"

- Bukan: "Rekomendasi adalah melakukan istirahat horizontal"
- Tapi: "Tiduran atau duduk yang nyaman biar napas lebih enak"

FORMAT OUTPUT:
PENJELASAN:
[isi casual]

SARAN:
- [poin 1]
- [poin 2]
- [poin 3]
"""

    payload = {
        "model": MODEL_NAME,
        "prompt": prompt,
        "stream": False,
        "temperature": 0.8  # Higher temperature = lebih creative & casual
    }

    try:
        response = requests.post(OLLAMA_URL, json=payload, timeout=90)
        result = response.json()
        text = result.get("response", "")
        
        # Parse response
        explanation = ""
        tips = ""
        
        if "PENJELASAN:" in text:
            parts = text.split("PENJELASAN:")
            if len(parts) > 1:
                explanation = parts[1].split("SARAN:")[0].strip()
        
        if "SARAN:" in text:
            parts = text.split("SARAN:")
            if len(parts) > 1:
                tips = parts[1].strip()
        
        return {
            "explanation": explanation if explanation else "Kondisi kamu perlu diperhatiin.",
            "tips": tips if tips else "Segera ke dokter atau rumah sakit."
        }
        
    except Exception as e:
        return {
            "explanation": f"Kondisi kamu: {condition}",
            "tips": "Cek ke dokter atau ke rumah sakit terdekat."
        }

def analyze_spo2(patient_name: str, spo2_value: float, heart_rate: int, 
                  timestamp: str, patient_age: int = None):
    
    condition = classify_condition(spo2_value, heart_rate)
    explanation_and_tips = get_explanation_and_tips(spo2_value, heart_rate, condition, patient_age)
    
    return {
        "patient_name": patient_name,
        "spo2_value": spo2_value,
        "heart_rate": heart_rate,
        "condition": condition,
        "explanation": explanation_and_tips["explanation"],
        "tips": explanation_and_tips["tips"],
        "timestamp": timestamp
    }