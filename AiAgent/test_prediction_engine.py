# test_prediction_engine.py
# Jalankan dengan: python -m pytest test_prediction_engine.py -v

from prediction_engine import predict


def test_normal():
    r = predict(age=3, weight=14, height=95, spo2=97, hr=110)
    assert r["level"] == "NORMAL"
    assert r["score"] == 15
    assert r["color"] == "green"


def test_waspada_spo2():
    r = predict(age=4, weight=16, height=100, spo2=93, hr=120)
    assert r["level"] == "WASPADA"
    assert r["score"] == 55
    assert r["color"] == "amber"


def test_bahaya_spo2():
    r = predict(age=5, weight=17, height=105, spo2=88, hr=100)
    assert r["level"] == "BAHAYA"
    assert r["score"] == 90
    assert r["color"] == "red"


def test_bahaya_hr_extreme():
    r = predict(age=4, weight=16, height=100, spo2=98, hr=160)
    assert r["level"] == "BAHAYA"


def test_waspada_hr():
    # HR sedikit di luar batas tapi SpO2 normal
    r = predict(age=3, weight=14, height=95, spo2=97, hr=128)
    assert r["level"] == "WASPADA"


def test_usia_di_luar_rentang():
    # Usia 6 tahun (di luar 2-5), pakai HR_DEFAULT_RANGE (80-120)
    r = predict(age=6, weight=20, height=115, spo2=96, hr=100)
    assert r["level"] == "NORMAL"


def test_output_punya_explanation_dan_tips():
    r = predict(age=3, weight=14, height=95, spo2=97, hr=110)
    assert "explanation" in r
    assert "tips" in r
    assert len(r["tips"]) > 0