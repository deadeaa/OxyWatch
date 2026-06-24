"""
main.py
FastAPI backend untuk OxyWatch.
"""

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from typing import Optional

from prediction_engine import predict
import firebase_service as fb

app = FastAPI(title="OxyWatch API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)


class PredictRequest(BaseModel):
    child_id: str = Field(..., description="ID anak di Firestore")
    age: int
    weight: float
    height: float
    spo2: float
    hr: float
    device_token: Optional[str] = None
    child_name: Optional[str] = "Anak"


class RecommendationRequest(BaseModel):
    child_id: str
    doctor_id: str
    note: str


@app.get("/health")
def health():
    return {"status": "ok"}


@app.post("/predict")
def predict_risk(payload: PredictRequest):
    result = predict(
        age=payload.age,
        weight=payload.weight,
        height=payload.height,
        spo2=payload.spo2,
        hr=payload.hr,
    )

    try:
        fb.save_sensor_reading(
            child_id=payload.child_id,
            reading={
                "age": payload.age,
                "weight": payload.weight,
                "height": payload.height,
                "spo2": payload.spo2,
                "hr": payload.hr,
            },
            prediction=result,
        )
    except Exception as e:
        result["save_error"] = str(e)

    if result["level"] == "BAHAYA" and payload.device_token:
        try:
            fb.send_fcm_alert(
                device_token=payload.device_token,
                child_name=payload.child_name,
                level=result["level"],
                score=result["score"],
            )
        except Exception as e:
            result["fcm_error"] = str(e)

    return result


@app.get("/children/{child_id}/history")
def get_history(child_id: str, limit: int = 50):
    try:
        history = fb.get_history(child_id, limit=limit)
        return {"child_id": child_id, "history": history}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/recommendation")
def post_recommendation(payload: RecommendationRequest):
    try:
        doc_id = fb.save_recommendation(
            child_id=payload.child_id,
            doctor_id=payload.doctor_id,
            note=payload.note,
        )
        return {"status": "saved", "id": doc_id}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))