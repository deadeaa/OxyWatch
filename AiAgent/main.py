from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from models import SpO2Data, AgentResponse
from agent import analyze_spo2

app = FastAPI(
    title="Hipoxia Detection AI Agent",
    description="AI Agent untuk deteksi SpO2 dan heart rate - Normal, Sedang, Bahaya",
    version="3.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
def root():
    return {
        "message": "Hipoxia Detection AI Agent v3.0 aktif!",
        "status": "ready",
        "features": [
            "Deteksi SpO2 dan Heart Rate",
            "Klasifikasi: Normal, Sedang, Bahaya",
            "Penjelasan kondisi",
            "Saran/tips praktis"
        ]
    }

@app.post("/analyze", response_model=AgentResponse)
def analyze(data: SpO2Data):
    """
    Analisis SpO2 dan Heart Rate
    
    Klasifikasi:
    - Normal: SpO2 >= 90 dan HR 60-100 bpm
    - Sedang: SpO2 85-90 atau HR 100-120 atau HR 55-60
    - Bahaya: SpO2 < 85 atau HR > 120 atau HR < 55
    """
    try:
        result = analyze_spo2(
            patient_name=data.patient_name,
            spo2_value=data.spo2_value,
            heart_rate=data.heart_rate,
            timestamp=data.timestamp,
            patient_age=data.patient_age
        )
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/health")
def health_check():
    return {
        "status": "healthy",
        "service": "Hipoxia AI Agent v3.0"
    }