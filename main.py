#!/usr/bin/env python3
"""
Backend FastAPI para luisenriquemata.com
Servidor con auto-recuperación y monitoreo
"""

import os
import sys
import time
import logging
import asyncio
import threading
from datetime import datetime
from pathlib import Path
from typing import Optional

import uvicorn
import requests
import psutil
from fastapi import FastAPI, Request, HTTPException
from fastapi.staticfiles import StaticFiles
from fastapi.responses import HTMLResponse, JSONResponse
from fastapi.middleware.cors import CORSMiddleware

# Configuración de logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('server.log'),
        logging.StreamHandler(sys.stdout)
    ]
)
logger = logging.getLogger(__name__)

class ServerMonitor:
    """Monitor del servidor para auto-recuperación"""
    
    def __init__(self, port: int = 8000):
        self.port = port
        self.url = f"http://localhost:{port}"
        self.is_running = True
        self.last_check = datetime.now()
        
    def health_check(self) -> bool:
        """Verifica si el servidor está respondiendo"""
        try:
            response = requests.get(f"{self.url}/health", timeout=5)
            return response.status_code == 200
        except Exception as e:
            logger.warning(f"Health check failed: {e}")
            return False
    
    def get_system_stats(self) -> dict:
        """Obtiene estadísticas del sistema"""
        try:
            cpu_percent = psutil.cpu_percent(interval=1)
            memory = psutil.virtual_memory()
            disk = psutil.disk_usage('/')
            
            return {
                "cpu_percent": cpu_percent,
                "memory_percent": memory.percent,
                "memory_available": memory.available // (1024**3),  # GB
                "disk_percent": disk.percent,
                "disk_free": disk.free // (1024**3),  # GB
                "uptime": datetime.now().isoformat(),
                "last_check": self.last_check.isoformat()
            }
        except Exception as e:
            logger.error(f"Error getting system stats: {e}")
            return {"error": str(e)}
    
    def monitor_loop(self):
        """Loop de monitoreo en background"""
        while self.is_running:
            try:
                self.last_check = datetime.now()
                if not self.health_check():
                    logger.error("Server health check failed!")
                    # Aquí podrías agregar lógica de reinicio automático
                    
                time.sleep(30)  # Check cada 30 segundos
            except Exception as e:
                logger.error(f"Monitor error: {e}")
                time.sleep(60)

# Inicializar FastAPI
app = FastAPI(
    title="Luis Enrique Mata - Landing Page API",
    description="Backend para luisenriquemata.com con monitoreo y auto-recuperación",
    version="1.0.0"
)

# Configurar CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Inicializar monitor
monitor = ServerMonitor()

@app.on_event("startup")
async def startup_event():
    """Eventos de inicio del servidor"""
    logger.info("🚀 Iniciando servidor Luis Enrique Mata Landing...")
    
    # Iniciar monitor en background
    monitor_thread = threading.Thread(target=monitor.monitor_loop, daemon=True)
    monitor_thread.start()
    
    logger.info("✅ Servidor iniciado exitosamente")

@app.on_event("shutdown")
async def shutdown_event():
    """Eventos de cierre del servidor"""
    monitor.is_running = False
    logger.info("🛑 Servidor detenido")

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "timestamp": datetime.now().isoformat(),
        "service": "luisenriquemata.com"
    }

@app.get("/api/status")
async def get_status():
    """Estado completo del servidor y sistema"""
    return {
        "server": {
            "status": "running",
            "port": monitor.port,
            "uptime": datetime.now().isoformat()
        },
        "system": monitor.get_system_stats()
    }

@app.get("/api/ping")
async def ping():
    """Endpoint simple de ping"""
    return {"message": "pong", "timestamp": datetime.now().isoformat()}

# Servir archivos estáticos (HTML, CSS, JS)
app.mount("/static", StaticFiles(directory="."), name="static")

@app.get("/", response_class=HTMLResponse)
async def serve_index():
    """Servir página principal"""
    try:
        index_path = Path("index.html")
        if index_path.exists():
            return HTMLResponse(content=index_path.read_text(encoding='utf-8'))
        else:
            raise HTTPException(status_code=404, detail="index.html not found")
    except Exception as e:
        logger.error(f"Error serving index: {e}")
        raise HTTPException(status_code=500, detail="Internal server error")

@app.get("/about", response_class=HTMLResponse)
async def serve_about():
    """Servir página about"""
    try:
        about_path = Path("about.html")
        if about_path.exists():
            return HTMLResponse(content=about_path.read_text(encoding='utf-8'))
        else:
            raise HTTPException(status_code=404, detail="about.html not found")
    except Exception as e:
        logger.error(f"Error serving about: {e}")
        raise HTTPException(status_code=500, detail="Internal server error")

@app.exception_handler(404)
async def not_found_handler(request: Request, exc: HTTPException):
    """Manejador de errores 404"""
    return JSONResponse(
        status_code=404,
        content={
            "error": "Page not found",
            "path": str(request.url),
            "message": "La página solicitada no existe"
        }
    )

@app.exception_handler(500)
async def internal_error_handler(request: Request, exc: HTTPException):
    """Manejador de errores 500"""
    return JSONResponse(
        status_code=500,
        content={
            "error": "Internal server error",
            "message": "Error interno del servidor"
        }
    )

def run_server(port: int = 8000, host: str = "0.0.0.0"):
    """Ejecutar servidor con configuración optimizada"""
    try:
        logger.info(f"🌐 Iniciando servidor en http://{host}:{port}")
        
        uvicorn.run(
            "main:app",
            host=host,
            port=port,
            reload=False,  # Desactivar reload en producción
            workers=1,
            log_level="info",
            access_log=True,
            server_header=False,
            date_header=False
        )
    except Exception as e:
        logger.error(f"Error starting server: {e}")
        sys.exit(1)

if __name__ == "__main__":
    import argparse
    
    parser = argparse.ArgumentParser(description='Luis Enrique Mata Landing Server')
    parser.add_argument('--port', type=int, default=8000, help='Puerto del servidor')
    parser.add_argument('--host', type=str, default="0.0.0.0", help='Host del servidor')
    
    args = parser.parse_args()
    
    run_server(port=args.port, host=args.host)
