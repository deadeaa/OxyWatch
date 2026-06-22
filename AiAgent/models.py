from pydantic import BaseModel
from typing import Optional

class SpO2Data(BaseModel):
    patient_name: str
    spo2_value: float
    heart_rate: int
    timestamp: str
    patient_age: Optional[int] = None

class AgentResponse(BaseModel):
    patient_name: str
    spo2_value: float
    heart_rate: int
    condition: str  # Normal, Sedang, Bahaya
    explanation: str
    tips: str
    timestamp: str