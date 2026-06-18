from fastapi import FastAPI

app = FastAPI(
    title="mod_w3c",
    version="1.0.0"
)

@app.get("/health")
def health():
    return {
        "status": "UP"
    }

@app.get("/version")
def version():
    return {
        "service": "mod_w3c",
        "version": "1.0.0"
    }
