import joblib
import uvicorn
from fastapi import FastAPI
from pydantic import BaseModel
import numpy as np

app = FastAPI()

model = joblib.load('best_dt_model.pkl')

class BehaviorFeatures(BaseModel):
    mean_inter_arrival_time: float
    std_inter_arrival_time: float
    entropy: float

@app.post("/predict")
async def predict(features: BehaviorFeatures):
    try:
        input_data = np.array([[
            features.mean_inter_arrival_time, 
            features.std_inter_arrival_time, 
            features.entropy
        ]])

        prediction = model.predict(input_data)[0]
        probabilities = model.predict_proba(input_data)[0]
        risk_score = float(probabilities[1])

        return {
            "riskScore": risk_score,
            "decision": "THROTTLE" if risk_score > 0.7 else "ALLOW",
            "source": "decision_tree_v1"
        }
    except Exception as e:
        return {"error": str(e)}

if __name__ == "__main__":
    uvicorn.run(app, host="127.0.0.1", port=8000)